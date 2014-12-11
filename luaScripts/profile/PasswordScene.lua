
local PasswordScene = class('PasswordScene')
local AccountInfo = require('AccountInfo')
local Resources = require('Resources')
local showMessageBox = require('UICommon.MessageBox').showMessageBox;

function PasswordScene.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, PasswordScene)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function PasswordScene:ctor(...)
  local this = self
  self:registerScriptHandler(function(event)
    print('[PasswordScene] event => ', event)
    local on_event = 'on_' .. event
    if type(this[on_event]) == 'function' then
      this[on_event](this)
    end
    -- if event == "enterTransitionFinish" then
    --   self:initKeypadHandler()
    --   self:onEnter()
    -- elseif event == 'exit' then
    --   -- umeng:stopSession()
    -- end
  end)

  self:init()
end

function PasswordScene:init()
  local rootLayer = cc.Layer:create()
  self:addChild(rootLayer)
  self.rootLayer = rootLayer

  local guiReader = ccs.GUIReader:getInstance()
  -- local uiRoot = guiReader:widgetFromBinaryFile('gameUI/UP_Pasword.csb')
  local uiRoot = cc.CSLoader:createNode('UP_PasswordScene.csb')
  rootLayer:addChild(uiRoot)
  self.uiRoot = uiRoot

  self:initKeypadHandler()

  require('utils.UIVariableBinding').bind(uiRoot, self, self)
end

function PasswordScene:on_enter()
  local user = AccountInfo.getCurrentUser()
  dump(user, '[PasswordScene:on_enter] user')
end

function PasswordScene:PanelPassword_onClicked()
  self.InputPassword:attachWithIME()
end

function PasswordScene:PanelPassword2_onClicked()
  self.InputPassword2:attachWithIME()
end

function PasswordScene:ButtonChangePassword_onClicked()
  local this = self
  local password = string.trim(self.InputPassword:getString())
  local password2 = string.trim(self.InputPassword2:getString())

  if #password < 6 then
    local msgParam = {
      msg = '请输入6到8位长度的密码。'
    }
    showMessageBox(self, msgParam)
    return
  end

  if password ~= password2 then
    local msgParam = {
      msg = '输入的两个密码不一致。'
    }
    showMessageBox(self, msgParam)
    return
  end

  local reqParams = {}
  reqParams.password = password
  ddz.pomeloClient:request('auth.userHandler.updatePassword', reqParams, function(data) 
      if data.retCode == 0 then
        showMessageBox(this, {msg = '密码修改成功!', onOk = function() this:close() end})
      else
        showMessageBox(this, {msg = '密码修改失败!'})
      end
    end);
end

function PasswordScene:ButtonCancelPassword_onClicked()
  self:close()
end

function PasswordScene:initKeypadHandler()
  local this = self
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      event:stopPropagation()
      this:close()
    elseif keyCode == cc.KeyCode.KEY_MENU  then
      --label:setString("MENU clicked!")
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function PasswordScene:close()
  cc.Director:getInstance():popScene()
end

function PasswordScene:ButtonTopBack_onClicked()
  self:close()
end


local function createScene()
  local scene = cc.Scene:create()

  return PasswordScene.extend(scene)
end

return createScene
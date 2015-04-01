
local PasswordLayer = class('PasswordLayer', function() 
  return cc.Layer:create()
end)

local AccountInfo = require('AccountInfo')
local Resources = require('Resources')
local showMessageBox = require('UICommon.MsgBox').showMessageBox;



function PasswordLayer:ctor(...)
  local this = self
  self:registerScriptHandler(function(event)
    print('[PasswordLayer] event => ', event)
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

function PasswordLayer:init()
  local rootLayer = self

  self:setVisible(false)

  local uiRoot = cc.CSLoader:createNode('UP_PasswordLayer.csb')
  rootLayer:addChild(uiRoot)
  self.uiRoot = uiRoot

  self:initKeypadHandler()

  require('utils.UIVariableBinding').bind(uiRoot, self, self)
end

function PasswordLayer:on_enter()
  local user = AccountInfo.getCurrentUser()
  dump(user, '[PasswordLayer:on_enter] user')
end


function PasswordLayer:ButtonChangePassword_onClicked()
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

function PasswordLayer:show()
  local this = self

  this.closing = false

  self.InputPassword:setString('')
  self.InputPassword2:setString('')

  self:setVisible(true)
  self.PanelPassword:setScale(0.001)
  self.PanelPassword:runAction(cc.EaseElasticInOut:create(cc.ScaleTo:create(0.5, 1.0), 0.5))

end

function PasswordLayer:ButtonCancelPassword_onClicked()
  self:close()
end

function PasswordLayer:initKeypadHandler()
  local this = self
  local function onKeyReleased(keyCode, event)
    if not this:isVisible() then
      return
    end

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

function PasswordLayer:close()
  local this = self

  if this.closing then
    return
  end

  this.closing = true

  self.PanelPassword:runAction(cc.Sequence:create(
    cc.EaseElasticInOut:create(cc.ScaleTo:create(0.5, 0.01), 0.5),
    cc.TargetedAction:create(this, cc.Hide:create())
  ))

end

function PasswordLayer:ButtonTopBack_onClicked()
  self:close()
end

return PasswordLayer
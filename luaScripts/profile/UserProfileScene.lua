
local UserProfileScene = class('UserProfileScene')
local AccountInfo = require('AccountInfo')
local Resources = require('Resources')
local showMessageBox = require('UICommon.MessageBox').showMessageBox;

function UserProfileScene.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, UserProfileScene)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function UserProfileScene:ctor(...)
  local this = self
  self:registerScriptHandler(function(event)
    print('[UserProfileScene] event => ', event)
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

function UserProfileScene:init()
  local rootLayer = cc.Layer:create()
  self:addChild(rootLayer)
  self.rootLayer = rootLayer

  local guiReader = ccs.GUIReader:getInstance()
  local uiRoot = guiReader:widgetFromBinaryFile('UI/UserProfile.csb')
  rootLayer:addChild(uiRoot)
  self.uiRoot = uiRoot

  self:initKeypadHandler()

  require('utils.UIVariableBinding').bind(uiRoot, self, self)

  local userInfo = AccountInfo.getCurrentUser()

  self.UserId:setString(userInfo.userId)
  self.UserNickname:setText(userInfo.nickName)
  if userInfo.gender == '男' then
    self.CheckboxMale:setSelectedState(true)
    self.CheckboxFemale:setSelectedState(false)
  else
    self.CheckboxMale:setSelectedState(false)
    self.CheckboxFemale:setSelectedState(true)
  end

end

function UserProfileScene:on_enter()
  local user = AccountInfo.getCurrentUser()
  if user.headIcon then
    self.ButtonChangeHead:loadTextureNormal(Resources.getHeadIconPath(user.headIcon), ccui.TextureResType.localType)
  end
end

function UserProfileScene:PanelNickname_onClicked()
  self.UserNickname:attachWithIME()
end

function UserProfileScene:ButtonPassword_onClicked()
  cc.Director:getInstance():pushScene(require('profile.PasswordScene')())
end

function UserProfileScene:ButtonBindMobile_onClicked()
  print('[UserProfileScene:ButtonBindMobile_onClicked]')
  local reqParams = {}
  reqParams.nickName = self.UserNickname:getStringValue()
  if self.CheckboxMale:getSelectedState() then
    reqParams.gender = '男'
  else
    reqParams.gender = '女'
  end

  ddz.pomeloClient:request('ddz.entryHandler.updateUserInfo', reqParams, function(data) 
      dump(data, 'ddz.entryHandler.updateUserInfo -> resp')
      local userInfo = AccountInfo.getCurrentUser()
      userInfo.gender = reqParams.gender;
      userInfo.nickName = reqParams.nickName
      AccountInfo.save()
    end)
end


function UserProfileScene:CheckboxMale_onEvent(sender, eventType)
  if self.CheckboxFemale:getSelectedState() then
    self.CheckboxFemale:setSelectedState(false)    
  else
    self.CheckboxMale:setSelectedState(true)
  end
end

function UserProfileScene:CheckboxFemale_onEvent(sender, eventType)
  print('[UserProfileScene:CheckboxFemale_onEvent] eventType => ', eventType)
  if self.CheckboxMale:getSelectedState() then
    self.CheckboxMale:setSelectedState(false)    
  else
    self.CheckboxFemale:setSelectedState(true)
  end
end

function UserProfileScene:initKeypadHandler()
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

function UserProfileScene:close()
  cc.Director:getInstance():popScene()
end

function UserProfileScene:ButtonTest_onClicked()
  local this = self
  local img = self.ImageTips
  local panelSize = self.PanelHolder:getContentSize()

  img:setScale(0.3)
  img:setPosition(cc.p(panelSize.width / 2.0, -40))
  --img:runAction(cc.ScaleTo:create(0.8, 1.0))
  img:runAction( cc.Sequence:create(
      cc.Spawn:create(
          cc.MoveTo:create(0.4, cc.p(panelSize.width / 2.0, panelSize.height / 2.0)),
          cc.ScaleTo:create(0.4, 1.0)
        ),
      cc.DelayTime:create(2),
      cc.Spawn:create(
          cc.MoveBy:create(0.3, cc.p(0, panelSize.height + 20)),
          cc.ScaleTo:create(0.4, 0.3)
        )
    ))
end


function UserProfileScene:ButtonChangeHead_onClicked(sender, eventType)
  cc.Director:getInstance():pushScene(require('profile.HeadIconScene')())
end

function UserProfileScene:ButtonBack_onClicked()
  self:close()
end

function UserProfileScene:ButtonTopBack_onClicked()
  self:close()
end


local function createScene()
  local scene = cc.Scene:create()

  return UserProfileScene.extend(scene)
end

return createScene
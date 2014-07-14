
local UserProfileScene = class('UserProfileScene')

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
  self:init()
end

function UserProfileScene:init()
  local rootLayer = cc.Layer:create()
  self:addChild(rootLayer)
  self.rootLayer = rootLayer

  local guiReader = ccs.GUIReader:getInstance()
  local uiRoot = guiReader:widgetFromJsonFile('UI/UserProfile.json')
  rootLayer:addChild(uiRoot)
  self.uiRoot = uiRoot

  self:initKeypadHandler()

  require('utils.UIVariableBinding').bind(uiRoot, self, self)

  local userInfo = ddz.GlobalSettings.userInfo

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

function UserProfileScene:PanelNickname_onClicked()
  self.UserNickname:attachWithIME()
end

function UserProfileScene:PanelPassword_onClicked()
  self.InputPassword:attachWithIME()
end

function UserProfileScene:PanelPassword2_onClicked()
  self.InputPassword2:attachWithIME()
end

function UserProfileScene:ButtonBindMobile_onClicked()
  print('[UserProfileScene:ButtonBindMobile_onClicked]')
  local data = {}
  data.nickName = self.UserNickname:getStringValue()
  if self.CheckboxMale:getSelectedState() then
    data.gender = '男'
  else
    data.gender = '女'
  end

  ddz.pomeloClient:request('ddz.entryHandler.updateUserInfo', data, function(data) 
      dump(data, 'ddz.entryHandler.updateUserInfo -> resp')
    end)
end

function UserProfileScene:ButtonChangePassword_onClicked()

end

function UserProfileScene:ButtonCancelPassword_onClicked()
  self.InputPassword:setText('')
  self.InputPassword2:setText('')
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
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
--      if type(self.onMainMenu) == 'function' then
--        self.onMainMenu()
--      end
      cc.Director:getInstance():popScene() 
    elseif keyCode == cc.KeyCode.KEY_MENU  then
      --label:setString("MENU clicked!")
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end




local function createScene()
  local scene = cc.Scene:create()

  return UserProfileScene.extend(scene)
end

return createScene
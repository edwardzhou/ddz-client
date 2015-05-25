
local UserProfileLayer = class('UserProfileLayer', function() 
  return cc.Layer:create()
end)

local utils = require('utils.utils')
local AccountInfo = require('AccountInfo')
local Resources = require('Resources')
local showMessageBox = require('UICommon.MessageBox').showMessageBox;

function UserProfileLayer:ctor(...)
  local this = self
  self:registerScriptHandler(function(event)
    print('[UserProfileLayer] event => ', event)
    local on_event = 'on_' .. event
    if type(this[on_event]) == 'function' then
      this[on_event](this)
    end
  end)

  self:init()
end

function UserProfileLayer:init()
  local rootLayer = self

  self:setVisible(false)

  local uiRoot = cc.CSLoader:createNode('UserProfileLayer.csb')
  rootLayer:addChild(uiRoot)
  self.uiRoot = uiRoot

  self:initKeypadHandler()

  require('utils.UIVariableBinding').bind(uiRoot, self, self)

  ddz.clearPressedDisabledTexture(self.ButtonHeadIcon)

end

function UserProfileLayer:on_enter()

end


function UserProfileLayer:show()
  self.closing = false
  local user = AccountInfo.getCurrentUser()
  local iconIndex = tonumber(user.headIcon) or 1

  self.UserHeadIcon:loadTexture(
      string.format('NewRes/idImg/idImg_head_%02d.jpg', iconIndex),
      ccui.TextureResType.localType
    )

  if user.ddzProfile then
    self.LabelCoins:setString(user.ddzProfile.coins)
    local rate = '-'
    local won = user.ddzProfile.gameStat.won
    local lose = user.ddzProfile.gameStat.lose
    local totalGames = won + lose
    if totalGames > 0 then
      rate = math.floor(won * 1000.0 / totalGames) / 100 .. '%'
    end

    local winRate = string.format('%d胜%d负, 胜率%s', won, lose, rate)
    self.LabelWinRate:setString(winRate)
  end

  if user.gender == ddz.Gender.Male then
    self.CheckboxMale:setSelected(true)
    self.CheckboxFemale:setSelected(false)
  else
    self.CheckboxMale:setSelected(true)
    self.CheckboxFemale:setSelected(false)
  end

  self.LabelUserId:setString('(' .. user.userId .. ')')
  self.UserNickname:setString(user.nickName)
  self.UserNickname:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)

  self:setVisible(true)
  self.PanelProfile:setScale(0.001)
  self.PanelProfile:runAction(cc.EaseElasticInOut:create(cc.ScaleTo:create(0.5, 1.0), 0.5))
end

function UserProfileLayer:ButtonChangeNickname_onClicked()
  self.UserNickname:attachWithIME()
end

function UserProfileLayer:ButtonChangePassword_onClicked()
  local this = self
  local pwdLayer = self.pwdLayer
  if pwdLayer == nil then
    pwdLayer = require('profile.PasswordLayer').new()
    self:addChild(pwdLayer)
    self.pwdLayer = pwdLayer
  end
  pwdLayer:show()
end

function UserProfileLayer:ButtonBindMobile_onClicked()
  print('[UserProfileLayer:ButtonBindMobile_onClicked]')
  local reqParams = {}
  reqParams.nickName = self.UserNickname:getString()
  if self.CheckboxMale:isSelected() then
    reqParams.gender = ddz.Gender.Male
  else
    reqParams.gender = ddz.Gender.Female
  end

  ddz.pomeloClient:request('ddz.entryHandler.updateUserInfo', reqParams, function(data) 
      dump(data, 'ddz.entryHandler.updateUserInfo -> resp')
      local userInfo = AccountInfo.getCurrentUser()
      userInfo.gender = reqParams.gender;
      userInfo.nickName = reqParams.nickName
      AccountInfo.save()
      local scene = cc.Director:getInstance():getRunningScene()
      utils.invokeCallback(scene.updateUserInfo, scene)
    end)
end


function UserProfileLayer:CheckboxMale_onEvent(sender, eventType)
  if self.CheckboxFemale:isSelected() then
    self.CheckboxFemale:setSelected(false)    
  else
    self.CheckboxMale:setSelected(true)
  end
end

function UserProfileLayer:CheckboxFemale_onEvent(sender, eventType)
  print('[UserProfileLayer:CheckboxFemale_onEvent] eventType => ', eventType)
  if self.CheckboxMale:isSelected() then
    self.CheckboxMale:setSelected(false)
  else
    self.CheckboxFemale:setSelected(true)
  end
end

function UserProfileLayer:initKeypadHandler()
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

function UserProfileLayer:close()
  local this = self
  if this.closing then
    return
  end

  this.closing = true

  self.PanelProfile:runAction(cc.Sequence:create(
    cc.EaseElasticInOut:create(cc.ScaleTo:create(0.5, 0.01), 0.5),
    cc.TargetedAction:create(this, cc.RemoveSelf:create())
  ))
end



function UserProfileLayer:ButtonHeadIcon_onClicked(sender, eventType)
  local this = self
  --cc.Director:getInstance():pushScene(require('profile.HeadIconScene')())
  local iconsLayer = self.iconsLayer 
  if iconsLayer == nil then
    iconsLayer = require('profile.HeadIconsLayer').new()
    iconsLayer.onHeadChanged = function()
      local user = AccountInfo.getCurrentUser()
      local iconIndex = tonumber(user.headIcon) or 1

      this.UserHeadIcon:loadTexture(
          string.format('NewRes/idImg/idImg_head_%02d.jpg', iconIndex),
          ccui.TextureResType.localType
        )
    end

    self:addChild(iconsLayer)
    self.iconsLayer = iconsLayer
  end
  iconsLayer:show()
end

function UserProfileLayer:ButtonChangeHead_onClicked( ... )
  self:ButtonHeadIcon_onClicked()
end

function UserProfileLayer:ButtonClose_onClicked()
  self:close()
end

function UserProfileLayer:ButtonSwitchAccount_onClicked()
  cc.Director:getInstance():replaceScene(require('login.LoginScene')())
end


return UserProfileLayer
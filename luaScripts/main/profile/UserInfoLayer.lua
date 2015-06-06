--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

local UserInfoLayer = class('UserInfoLayer')
local utils = require('utils.utils')
local AccountInfo = require('AccountInfo')


function UserInfoLayer.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, UserInfoLayer)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function UserInfoLayer:ctor(userInfo)

  self.showCloseButton = true
  self.autoClose = false
  self.grayBackground = true
  self.closeOnClickOutside = true
  self.closeAsCancel = true
  self.userInfo = userInfo

  self:init()
end

function UserInfoLayer:init()
  local this = self
  local rootLayer = self
  local currentUser = AccountInfo.getCurrentUser()
  local selfUserId = currentUser.userId

  local uiRoot = cc.CSLoader:createNode('UserInfoLayer.csb')
  self.uiRoot = uiRoot
  rootLayer:addChild(uiRoot)
--  self.uiRoot:setOpacity(0)

  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initKeypadHandler()

  self.PanelGray:setVisible(self.grayBackground)

  this.PanelMain:setVisible(true)
  this.PanelMain:setScale(0.001)

  self:registerScriptHandler(function(event)
    --print('event => ', event)
    utils.invokeCallback(this["on_" .. event], this)
  end)

  self.LabelNickName:setString(self.userInfo.nickName)
  if self.userInfo.gender == '男' then
    self.ImageGender:loadTexture('icon/icon_info_male.png', ccui.TextureResType.localType)
  else
    self.ImageGender:loadTexture('icon/icon_info_female.png', ccui.TextureResType.localType)
  end
  local boxRect = self.LabelNickName:getBoundingBox()
  local headIconPos = cc.p(self.ImageGender:getPosition())
  self.ImageGender:setPosition(cc.p(boxRect.x + boxRect.width + 5, headIconPos.y))
  self.LabelUserId:setString(string.format('(%d)', self.userInfo.userId))
  self.ImageHeadIcon:loadTexture(
      string.format('NewRes/idImg/idImg_head_%02d.jpg', self.userInfo.headIcon),
      ccui.TextureResType.localType
    )

end

function UserInfoLayer:on_enter()
  local this = self

  this.PanelMain:runAction(
    cc.Sequence:create(
        cc.EaseElasticInOut:create(cc.ScaleTo:create(0.5, 1.0), 0.5),
        cc.CallFunc:create(function() 
              -- if this.autoClose then
              --   this:runAction(cc.Sequence:create(
              --       cc.DelayTime:create(this.autoClose),
              --       cc.CallFunc:create(__bind(this.close, this))
              --     ))
              -- end
          end)
      )
  )
end

function UserInfoLayer:on_cleanup()
  local this = self

end

function UserInfoLayer:close()
  local this = self
  --self.uiRoot:setOpacity(0)
  if this.closing then
    return
  end

  this.closing = true

  this.PanelGray:setVisible(false)
  this.PanelMain:runAction(
    cc.Sequence:create(
        cc.EaseElasticInOut:create(cc.ScaleTo:create(0.5, 0.001), 0.5),
        cc.TargetedAction:create(this, cc.RemoveSelf:create())
      )
    )
  -- self.MsgPanel:setVisible(false)
  -- self.ImageBox:setVisible(true)
  -- self.ImageBox:runAction( 
  --   cc.Sequence:create(
  --     cc.ScaleTo:create(0.15, 1),
  --     cc.TargetedAction:create(this, cc.RemoveSelf:create())
  --   )
  -- )
end

function UserInfoLayer:initKeypadHandler()
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      event:stopPropagation()
      self:ButtonClose_onClicked(self.ButtonClose_onClicked)
    elseif keyCode == cc.KeyCode.KEY_MENU  then
      --label:setString("MENU clicked!")
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function UserInfoLayer:ButtonCancel_onClicked(sender, eventType)
  if utils.invokeCallback(self.onCancelCallback) == false then
    return
  else
    self:close()
  end
end

function UserInfoLayer:ButtonOk_onClicked(sender, eventType)
  local this = self
  if this.closing then
    return
  end
  if utils.invokeCallback(self.onOkCallback) == false then
    return
  else
    self:close()
  end
end

function UserInfoLayer:ButtonClose_onClicked(sender, eventType)
  local this = self
  if this.closing then
    return
  end

  self:close()
end

function UserInfoLayer:RootBox_onClicked(sender, eventType)
  if self.closeOnClickOutside then
    if self.ButtonClose:isVisible() then
      self:ButtonClose_onClicked(self.ButtonClose)
    elseif self.ButtonOk:isVisible() then
      self:ButtonOk_onClicked(self.ButtonOk)
    end
  end
end

local function showUserInfo(container, userInfo)
  local layer = cc.Layer:create()
  local newLayer = UserInfoLayer.extend(layer, userInfo)

  newLayer:setLocalZOrder(1000)
  container:addChild(newLayer)
end

return {
  showUserInfo = showUserInfo
}
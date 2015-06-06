--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

local AppointPlayInformLayer = class('AppointPlayInformLayer')
local utils = require('utils.utils')

function AppointPlayInformLayer.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, AppointPlayInformLayer)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function AppointPlayInformLayer:ctor(requester, appointPlay, onOkCallback)

  self.requester = requester
  self.appointPlay = appointPlay

  self.msg = string.format('%s (%d) 邀您与TA对战, 是否开始对战?', requester.nickName, requester.userId)

  self.showCloseButton = true
  self.autoClose = false
  self.onOkCallback = onOkCallback
  self.grayBackground = true
  self.closeOnClickOutside = false

  self:init()
end

function AppointPlayInformLayer:init()
  local this = self
  local rootLayer = self

  local uiRoot = cc.CSLoader:createNode('AppointPlayInformLayer.csb')
  self.uiRoot = uiRoot
  rootLayer:addChild(uiRoot)
--  self.uiRoot:setOpacity(0)

  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initKeypadHandler()

  self.PanelGray:setVisible(self.grayBackground)
  local boxSize = self.MsgPanel:getContentSize()

  this.MsgPanel:setVisible(true)
  this.MsgPanel:setScale(0.001)

  self:registerScriptHandler(function(event)
    --print('event => ', event)
    utils.invokeCallback(this["on_" .. event], this)
  end)

  -- self.LabelMessage:ignoreContentAdaptWithSize(false)
  -- self.LabelMessage:setAnchorPoint(cc.p(0.5, 1.0))
  -- self.LabelMessage:setTextAreaSize(cc.size(360, 125))
  -- self.LabelMessage:setPosition(cc.p(200, 182))

  self.LabelMessage:setString(self.msg)

  -- local size = this.LabelMessage:getContentSize()
  -- size.width = boxSize.width - 60
  -- size.height = boxSize.height - 60 - 95
  -- this.LabelMessage:setContentSize(size)
  -- this.LabelMessage:setPosition(cc.p(boxSize.width/2, boxSize.height - 60))

  -- this.LabelTitle:setPosition(cc.p(boxSize.width/2, boxSize.height - 30))

  -- local showOk = string.find(self.buttonType, 'ok') ~= nil
  -- local showCancel = string.find(self.buttonType, 'cancel') ~= nil
  -- local showCloseButton = string.find(self.buttonType, 'close') ~= nil

  -- self.ButtonOk:setVisible(showOk)
  -- self.ButtonCancel:setVisible(showCancel)
  -- self.ButtonClose:setVisible(showCloseButton)

  -- if showOk and showCancel then
  --   --
  -- elseif showOk then
  --   local pos = self.ButtonOk:getPositionPercent()
  --   pos.x = 0.5
  --   self.ButtonOk:setPositionPercent(pos)
  -- elseif showCancel then
  --   local pos = self.ButtonCancel:getPositionPercent()
  --   pos.x = 0.5
  --   self.ButtonCancel:setPositionPercent(pos)
  -- end

end

function AppointPlayInformLayer:on_enter()
  local this = self

  this.MsgPanel:runAction(
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

function AppointPlayInformLayer:on_cleanup()
  local this = self

end

function AppointPlayInformLayer:close()
  local this = self
  --self.uiRoot:setOpacity(0)
  if this.closing then
    return
  end

  this.closing = true

  this.PanelGray:setVisible(false)
  this.MsgPanel:runAction(
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

function AppointPlayInformLayer:initKeypadHandler()
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      event:stopPropagation()
      if self.ButtonCancel:isVisible() then
        self:ButtonCancel_onClicked(self.ButtonCancel)
      elseif self.ButtonOk:isVisible() then
        self:ButtonOk_onClicked(self.ButtonOk)
      end
    elseif keyCode == cc.KeyCode.KEY_MENU  then
      --label:setString("MENU clicked!")
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function AppointPlayInformLayer:ButtonCancel_onClicked(sender, eventType)
  if utils.invokeCallback(self.onCancelCallback) == false then
    return
  else
    self:close()
  end
end

function AppointPlayInformLayer:ButtonOk_onClicked(sender, eventType)
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

function AppointPlayInformLayer:ButtonClose_onClicked(sender, eventType)
  local this = self
  if this.closing then
    return
  end
  if self.ButtonCancel:isVisible() or self.closeAsCancel then
    self:ButtonCancel_onClicked(sender, eventType)
  else
    self:ButtonOk_onClicked(sender, eventType)
  end
end

function AppointPlayInformLayer:RootBox_onClicked(sender, eventType)
  if self.closeOnClickOutside then
    if self.ButtonCancel:isVisible() then
      self:ButtonCancel_onClicked(self.ButtonCancel)
    elseif self.ButtonOk:isVisible() then
      self:ButtonOk_onClicked(self.ButtonOk)
    end
  end
end

local function showAppointPlayInform(container, appointPlay, requester, onOkCallback)
  local layer = cc.Layer:create()
  local AppointPlayInformLayer = AppointPlayInformLayer.extend(layer, appointPlay, requester, onOkCallback)

  AppointPlayInformLayer:setLocalZOrder(1000)
  container:addChild(AppointPlayInformLayer)
end

return {
  showAppointPlayInform = showAppointPlayInform
}
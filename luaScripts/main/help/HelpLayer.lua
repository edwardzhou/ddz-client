--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

local HelpLayer = class('HelpLayer')
local utils = require('utils.utils')
local AccountInfo = require('AccountInfo')
local showMessageBox = require('UICommon.MsgBox').showMessageBox
local showToastBox = require('UICommon.ToastBox2').showToastBox
local hideToastBox = require('UICommon.ToastBox2').hideToastBox


function HelpLayer.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, HelpLayer)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function HelpLayer:ctor()

  self.showCloseButton = true
  self.autoClose = false
  self.grayBackground = true
  self.closeOnClickOutside = true
  self.closeAsCancel = true

  self:init()
end

function HelpLayer:init()
  local this = self
  local rootLayer = self
  local currentUser = AccountInfo.getCurrentUser()
  local selfUserId = currentUser.userId

  local uiRoot = cc.CSLoader:createNode('HelpLayer.csb')
  self.uiRoot = uiRoot
  rootLayer:addChild(uiRoot)
--  self.uiRoot:setOpacity(0)

  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initKeypadHandler()

  self.PanelGray:setVisible(self.grayBackground)

  this.MsgPanel:setVisible(true)
  this.MsgPanel:setScale(0.001)

  this.PanelRule:setVisible(false)
  this.PanelFeedback:setVisible(true)

  this:ButtonAbout_onClicked(this.ButtonAbout)

  self:registerScriptHandler(function(event)
    --print('event => ', event)
    utils.invokeCallback(this["on_" .. event], this)
  end)

  self.LabelVersion:setString('v'  .. require('version'))

end

function HelpLayer:on_enter()
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

function HelpLayer:on_cleanup()
  local this = self

end

function HelpLayer:close()
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

function HelpLayer:initKeypadHandler()
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

function HelpLayer:ButtonCancel_onClicked(sender, eventType)
  if utils.invokeCallback(self.onCancelCallback) == false then
    return
  else
    self:close()
  end
end

function HelpLayer:ButtonOk_onClicked(sender, eventType)
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

function HelpLayer:ButtonClose_onClicked(sender, eventType)
  local this = self
  if this.closing then
    return
  end

  self:close()
end

function HelpLayer:RootBox_onClicked(sender, eventType)
  if self.closeOnClickOutside then
    if self.ButtonCancel:isVisible() then
      self:ButtonCancel_onClicked(self.ButtonCancel)
    elseif self.ButtonOk:isVisible() then
      self:ButtonOk_onClicked(self.ButtonOk)
    end
  end
end

function HelpLayer:ButtonAbout_onClicked(sender)
  if not self.PanelRule:isVisible() then
    self.TabFeedback:setClippingEnabled(true)
    self.TabAbout:setClippingEnabled(false)
    self.PanelRule:setVisible(true)
    self.PanelFeedback:setVisible(false)
  end
  -- if self.PageView:getCurPageIndex() ~= 0 then
  --   self.TabFeedback:setClippingEnabled(true)
  --   self.TabAbout:setClippingEnabled(false)
  --   self.PageView:scrollToPage(0)
  -- end
end

function HelpLayer:ButtonFeedback_onClicked(sender)
  if not self.PanelFeedback:isVisible() then
    self.TabAbout:setClippingEnabled(true)
    self.TabFeedback:setClippingEnabled(false)
    self.PanelFeedback:setVisible(true)
    self.PanelRule:setVisible(false)
  end
end

function HelpLayer:ButtonSubmitFeedback_onClicked(sender)
  local this = self
  local feedback = self.Feedback:getString()
  feedback = string.trim(feedback)
  if #feedback < 10 then
    local msgParam = {
      msg = '请输入至少10文字的反馈意见'
      , grayBackground = true
      , closeOnClickOutside = true
      , buttonType = 'ok|close'
      , closeAsCancel = true
    }
    showMessageBox(this, msgParam)
    return
  end

  self.Feedback:setString('')

  local toastParams = {
    zorder = 1099,
    showLoading = false, 
    grayBackground = false,
    closeOnTouch = true,
    closeOnBack = true,
    showingTime = 2,
    msg = '您的反馈已提交，非常感谢您宝贵的意见。'
  }

  showToastBox(this, toastParams)

end

local function showHelp(container)
  local layer = cc.Layer:create()
  local newLayer = HelpLayer.extend(layer)

  newLayer:setLocalZOrder(1000)
  container:addChild(newLayer)
end

return {
  showHelp = showHelp
}
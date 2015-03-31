local MsgBox = class('MsgBox')
local utils = require('utils.utils')

function MsgBox.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, MsgBox)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function MsgBox:ctor(params)

  self.title = params.title
  self.msg = params.msg
  self.boxWidth = params.width
  self.boxHeight = params.height

  self.buttonType = params.buttonType or 'ok'
  self.showCloseButton = true
  self.autoClose = params.autoClose
  self.onCancelCallback = params.onCancel
  self.onOkCallback = params.onOk
  self.grayBackground = true
  self.closeOnClickOutside = true
  if params.closeOnClickOutside ~= nil then
    self.closeOnClickOutside = params.closeOnClickOutside
  end
  if params.grayBackground ~= nil then
    self.grayBackground = params.grayBackground
  end

  if params.showCloseButton then
    self.showCloseButton = params.showCloseButton
  end

  self.closeAsCancel = params.closeAsCancel

  self:init()
end

function MsgBox:init()
  -- local rootLayer = cc.Layer:create()
  -- self.rootLayer = rootLayer
  -- self:addChild(rootLayer)
  local this = self
  local rootLayer = self

  -- this:setAnchorPoint(0.5, 0.5)
  -- this:setPosition(400, 240)

  local guiReader = ccs.GUIReader:getInstance()
  -- local uiRoot = guiReader:widgetFromBinaryFile('gameUI/MsgBox.csb')
  local uiRoot = cc.CSLoader:createNode('MsgBoxLayer.csb')
  self.uiRoot = uiRoot
  rootLayer:addChild(uiRoot)
--  self.uiRoot:setOpacity(0)

  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initKeypadHandler()

  self.PanelGray:setVisible(self.grayBackground)
  local boxSize = self.MsgPanel:getContentSize()

  if this.boxHeight ~= nil or this.boxWidth ~= nil then
    boxSize.width = this.boxWidth or boxSize.width
    boxSize.height = this.boxHeight or boxSize.height
    this.MsgPanel:setContentSize(boxSize)
    this.ButtonClose:setPosition(boxSize.width - 5, boxSize.height - 5)
    local pos = cc.p( this.PanelButtons:getPosition() )
    pos.x = boxSize.width / 2
    this.PanelButtons:setPosition(cc.p(boxSize.width / 2, 40))
  end

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

  self.LabelTitle:setString(self.title)
  self.LabelMessage:setString(self.msg)

  local size = this.LabelMessage:getContentSize()
  size.width = boxSize.width - 60
  size.height = boxSize.height - 60 - 95
  this.LabelMessage:setContentSize(size)
  this.LabelMessage:setPosition(cc.p(boxSize.width/2, boxSize.height - 60))

  this.LabelTitle:setPosition(cc.p(boxSize.width/2, boxSize.height - 30))

  local showOk = string.find(self.buttonType, 'ok') ~= nil
  local showCancel = string.find(self.buttonType, 'cancel') ~= nil
  local showCloseButton = string.find(self.buttonType, 'close') ~= nil

  self.ButtonOk:setVisible(showOk)
  self.ButtonCancel:setVisible(showCancel)
  self.ButtonClose:setVisible(showCloseButton)

  if showOk and showCancel then
    --
  elseif showOk then
    local pos = self.ButtonOk:getPositionPercent()
    pos.x = 0.5
    self.ButtonOk:setPositionPercent(pos)
  elseif showCancel then
    local pos = self.ButtonCancel:getPositionPercent()
    pos.x = 0.5
    self.ButtonCancel:setPositionPercent(pos)
  end

end

function MsgBox:on_enter()
  local this = self

  this.MsgPanel:runAction(
    cc.Sequence:create(
        cc.EaseElasticInOut:create(cc.ScaleTo:create(0.5, 1.0), 0.5),
        cc.CallFunc:create(function() 
              if this.autoClose then
                this:runAction(cc.Sequence:create(
                    cc.DelayTime:create(this.autoClose),
                    cc.CallFunc:create(__bind(this.close, this))
                  ))
              end
          end)
      )
  )
end

function MsgBox:on_cleanup()
  local this = self

end

function MsgBox:close()
  local this = self
  --self.uiRoot:setOpacity(0)
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

function MsgBox:initKeypadHandler()
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

function MsgBox:ButtonCancel_onClicked(sender, eventType)
  if utils.invokeCallback(self.onCancelCallback) == false then
    return
  else
    self:close()
  end
end

function MsgBox:ButtonOk_onClicked(sender, eventType)
  if utils.invokeCallback(self.onOkCallback) == false then
    return
  else
    self:close()
  end
end

function MsgBox:ButtonClose_onClicked(sender, eventType)
  if self.ButtonCancel:isVisible() or self.closeAsCancel then
    self:ButtonCancel_onClicked(sender, eventType)
  else
    self:ButtonOk_onClicked(sender, eventType)
  end
end

function MsgBox:RootBox_onClicked(sender, eventType)
  if self.closeOnClickOutside then
    if self.ButtonCancel:isVisible() then
      self:ButtonCancel_onClicked(self.ButtonCancel)
    elseif self.ButtonOk:isVisible() then
      self:ButtonOk_onClicked(self.ButtonOk)
    end
  end
end

local function showMsgBox(container, params)
  local layer = cc.Layer:create()
  local msgBox = MsgBox.extend(layer, params)

  msgBox:setLocalZOrder(1000)
  container:addChild(msgBox)
end

return {
  showMsgBox = showMsgBox,
  showMessageBox = showMsgBox
}
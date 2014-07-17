local MessageBox = class('MessageBox')
local utils = require('utils.utils')

function MessageBox.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, MessageBox)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function MessageBox:ctor(params)

  self.title = params.title
  self.msg = params.msg

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

  self:init()
end

function MessageBox:init()
  -- local rootLayer = cc.Layer:create()
  -- self.rootLayer = rootLayer
  -- self:addChild(rootLayer)
  local this = self
  local rootLayer = self

  -- this:setAnchorPoint(0.5, 0.5)
  -- this:setPosition(400, 240)

  local guiReader = ccs.GUIReader:getInstance()
  local uiRoot = guiReader:widgetFromBinaryFile('UI/MessageBox.csb')
  self.uiRoot = uiRoot
  rootLayer:addChild(uiRoot)
--  self.uiRoot:setOpacity(0)

  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initKeypadHandler()

  self.PanelGray:setVisible(self.grayBackground)

  this.MsgPanel:setVisible(false)

  self:registerScriptHandler(function(event)
    --print('event => ', event)

    if event == "enter" then
      this.ImageBox:runAction(
          cc.Sequence:create(
              cc.ScaleTo:create(0.15, 5),
              cc.CallFunc:create(function() 
                  this.ImageBox:setVisible(false)
                  this.MsgPanel:setVisible(true)
                end)
            )
        )
    elseif event == 'exit' then
    end
  end)

  self.LabelTitle:setString(self.title)
  self.LabelMessage:setString(self.msg)

end

function MessageBox:close()
  local this = self
  --self.uiRoot:setOpacity(0)
  self.MsgPanel:setVisible(false)
  self.ImageBox:setVisible(true)
  self.ImageBox:runAction( 
    cc.Sequence:create(
      cc.ScaleTo:create(0.15, 1),
      cc.TargetedAction:create(this, cc.RemoveSelf:create())
    )
  )
end

function MessageBox:initKeypadHandler()
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
--      if type(self.onMainMenu) == 'function' then
--        self.onMainMenu()
--      end
      event:stopPropagation()
      self:close()
    elseif keyCode == cc.KeyCode.KEY_MENU  then
      --label:setString("MENU clicked!")
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function MessageBox:ButtonCancel_onClicked(sender, eventType)
  if utils.invokeCallback(self.onCancelCallback) == false then
    return
  else
    self:close()
  end
end

function MessageBox:ButtonOk_onClicked(sender, eventType)
  if utils.invokeCallback(self.onOkCallback) == false then
    return
  else
    self:close()
  end
end

function MessageBox:RootBox_onClicked(sender, eventType)
  if self.closeOnClickOutside then
    self:ButtonCancel_onClicked(sender, eventType)
  end
end

local function showMessageBox(container, params)
  local layer = cc.Layer:create()
  local msgBox = MessageBox.extend(layer, params)

  msgBox:setLocalZOrder(1000)
  container:addChild(msgBox)
end

return {
  showMessageBox = showMessageBox
}
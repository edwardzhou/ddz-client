

local ToastBox = class('ToastBox')
local utils = require('utils.utils')

function ToastBox.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, ToastBox)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function ToastBox:ctor(params)

  self.msg = params.msg

  self.grayBackground = true
  self.closeOnTouch = true

  self.showingTime = params.showingTime or 2
  self.showLoading = false
  
  if params.closeOnTouch ~= nil then
    self.closeOnTouch = params.closeOnTouch
  end

  if params.showLoading ~= nil then
    self.showLoading = params.showLoading
  end

  if params.grayBackground ~= nil then
    self.grayBackground = params.grayBackground
  end

  self:init()
end

function ToastBox:init()
  local this = self
  local rootLayer = self

  local guiReader = ccs.GUIReader:getInstance()
  local uiRoot = guiReader:widgetFromBinaryFile('UI/Toast.csb')
  self.uiRoot = uiRoot
  rootLayer:addChild(uiRoot)

  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initKeypadHandler()

  self.PanelBg:setVisible(self.grayBackground)

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

  self.LabelMsg:setString(self.msg)
  local rect = self.LabelMsg:getBoundingBox()

  local pos = cc.p(self.Loading:getPosition())
  pos.x = rect.x - 20
  self.Loading:setPosition(pos)

end

function ToastBox:close()
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

function ToastBox:initKeypadHandler()
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

function ToastBox:ButtonCancel_onClicked(sender, eventType)
  if utils.invokeCallback(self.onCancelCallback) == false then
    return
  else
    self:close()
  end
end

function ToastBox:ButtonOk_onClicked(sender, eventType)
  if utils.invokeCallback(self.onOkCallback) == false then
    return
  else
    self:close()
  end
end

function ToastBox:RootBox_onClicked(sender, eventType)
  if self.closeOnClickOutside then
    self:ButtonCancel_onClicked(sender, eventType)
  end
end

local function showToastBox(container, params)
  local layer = cc.Layer:create()
  local msgBox = ToastBox.extend(layer, params)

  msgBox:setLocalZOrder(1000)
  container:addChild(msgBox)
end

return {
  showToastBox = showToastBox
}


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

  local animCache = cc.AnimationCache:getInstance()
  local animation = animCache:getAnimation('loading')
  if animation == nil then
    local frameCache = cc.SpriteFrameCache:getInstance()
    local frames = {}
    for i=1, 10 do
      local frameName = string.format('load%02d.png', i)
      local frame = frameCache:getSpriteFrame(frameName)
      table.insert(frames, frame)
    end
    animation = cc.Animation:createWithSpriteFrames(frames, 0.05)
    animCache:addAnimation(animation, 'loading')
  end

  local sprite = cc.Sprite:createWithSpriteFrameName('load01.png')
  sprite:setAnchorPoint(1.0, 0.5)
  self.PanelBox:addChild(sprite)
  self.sprite = sprite

  self:registerScriptHandler(function(event)
    --print('event => ', event)

    if event == "enter" then
      local rect = self.LabelMsg:getBoundingBox()
      local size = self.PanelBox:getContentSize()      
      local pos = cc.p(rect.x - 20, size.height / 2)
      this.sprite:setPosition(pos)      

      local animation = animCache:getAnimation('loading')
      this.sprite:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))
      this.PanelBox:setOpacity(0)
      this.PanelBox:runAction(cc.FadeIn:create(0.4))

      this:runAction(cc.Sequence:create(
          cc.DelayTime:create(this.showingTime),
          cc.TargetedAction:create(this.PanelBox, cc.FadeOut:create(0.3)),
          cc.CallFunc:create(function() this:close() end)
        ))

    elseif event == 'exit' then
    end
  end)

  self.LabelMsg:setString(self.msg)
end

function ToastBox:close()
  local this = self
  self:removeFromParent()
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

function ToastBox:PanelRoot_onClicked(sender, eventType)
  self:close()
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
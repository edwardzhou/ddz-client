

local ToastBox = class('ToastBox')
local utils = require('utils.utils')

local TOAST_BOX_ACTION_TAG = 0x10001
local LOADING_ACTION_TAG = 0x10002

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
  self.showing = false
  self.closeOnTouch = true
  self:init()
end

function ToastBox:init()
  local this = self
  local rootLayer = self

  local guiReader = ccs.GUIReader:getInstance()
  local uiRoot = guiReader:widgetFromBinaryFile('gameUI/Toast.csb')
  self.uiRoot = uiRoot
  rootLayer:addChild(uiRoot)

  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initKeypadHandler()

  self:registerScriptHandler(function(event)
    --print('event => ', event)

    if event == "enter" then      
    elseif event == 'exit' then
    end
  end)

end

function ToastBox:doShow(params)
  local this = self

  self.LabelMsg:setString(params.msg)
  local showingLoading = false
  local grayBackground = false
  local closeOnTouch = true
  local showingTime = params.showingTime or 3
  local fadeInTime = params.fadeInTime or 0.4
  this.closeOnBack = true

  if params.closeOnBack ~= nil then
    this.closeOnBack = params.closeOnBack
  end

  if params.showLoading ~= nil then
    showLoading = params.showLoading
  end

  if params.grayBackground ~= nil then
    grayBackground = params.grayBackground
  end

  if params.closeOnTouch ~= nil then
    closeOnTouch = params.closeOnTouch
  end

  self.closeOnTouch = closeOnTouch

  self.PanelBg:setVisible(grayBackground)

  if showLoading then
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

    if this.loadingSprite == nil then
      local sprite = cc.Sprite:createWithSpriteFrameName('load01.png')
      sprite:setAnchorPoint(1.0, 0.5)
      self.PanelBox:addChild(sprite)
      this.loadingSprite = sprite
      sprite:setVisible(false)
    end

    local rect = self.LabelMsg:getBoundingBox()
    local size = self.PanelBox:getContentSize()      
    local pos = cc.p(rect.x - 20, size.height / 2)
    this.loadingSprite:setPosition(pos)
    this.loadingSprite:setVisible(true)

    this.loadingSprite:stopActionByTag(LOADING_ACTION_TAG)
    local action = this.loadingSprite:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))
    action:setTag(LOADING_ACTION_TAG)
  else
    if this.loadingSprite ~= nil then
      this.loadingSprite:stopActionByTag(LOADING_ACTION_TAG)
      this.loadingSprite:setVisible(false)
    end
  end

  this:stopActionByTag(TOAST_BOX_ACTION_TAG)

  this:setVisible(true)
  this.PanelBox:setOpacity(0)
  this.PanelBox:runAction(cc.FadeIn:create(fadeInTime))
  this.showing = true

  if showingTime > 0 then
    local action = this:runAction(cc.Sequence:create(
        cc.DelayTime:create(showingTime),
        cc.CallFunc:create(function() this:close() end)
      ))
    action:setTag(TOAST_BOX_ACTION_TAG)
  end
end

function ToastBox:close(fadeOut)
  local this = self
  this.showing = false

  if fadeOut == nil then
    fadeOut = true
  end

  if this.loadingSprite ~= nil then
    this.loadingSprite:stopActionByTag(LOADING_ACTION_TAG)
  end
  this:stopActionByTag(TOAST_BOX_ACTION_TAG)

  if fadeOut then
    local action = this:runAction(cc.Sequence:create(
        cc.TargetedAction:create(this.PanelBox, cc.FadeOut:create(0.3)),
        cc.Hide:create()
      ))
    action:setTag(TOAST_BOX_ACTION_TAG)
  else
    this:setVisible(false)
  end

end

function ToastBox:initKeypadHandler()
  local this = self
  local function onKeyReleased(keyCode, event)
    if this.showing then
      print('[ToastBox - onKeyReleased]')
      if keyCode == cc.KeyCode.KEY_BACKSPACE then
        event:stopPropagation()
        if this.closeOnBack then
          self:close()
        end
      elseif keyCode == cc.KeyCode.KEY_MENU then
        --label:setString("MENU clicked!")
      end
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function ToastBox:PanelRoot_onClicked(sender, eventType)
  if self.closeOnTouch then
    self:close()
  end
end

local function showToastBox(container, params)
  if container.toastBox == nil then
    local layer = cc.Layer:create()
    local msgBox = ToastBox.extend(layer)

    msgBox:setLocalZOrder(1100)
    container:addChild(msgBox)
    container.toastBox = msgBox
  end

  container.toastBox:doShow(params)
  return container.toastBox
end

local function hideToastBox(container, fadeOut)
  if container.toastBox then
    container.toastBox:close(fadeOut)
  end
end

return {
  showToastBox = showToastBox,
  hideToastBox = hideToastBox
}
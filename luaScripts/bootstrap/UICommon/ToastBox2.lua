

local ToastBox2 = class('ToastBox2')
local utils = require('utils.utils')
local display = require('cocos.framework.display')

local TOAST_BOX_ACTION_TAG = 0x10001
local LOADING_ACTION_TAG = 0x10002

function ToastBox2.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, ToastBox2)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function ToastBox2:ctor(params)
  self.showing = false
  self.closeOnTouch = true
  self:init()
end

function ToastBox2:init()
  local this = self
  local rootLayer = self

  local guiReader = ccs.GUIReader:getInstance()
  -- local uiRoot = guiReader:widgetFromBinaryFile('gameUI/Toast.csb')
  local uiRoot = cc.CSLoader:createNode('ToastLayer.csb')
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

function ToastBox2:doShow(params)
  local this = self

  self.LabelMsg:setString(params.msg)
  local showLoading = true
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
    local rect = self.LabelMsg:getBoundingBox()
    local size = self.PanelBox:getContentSize()      
    local pos = cc.p(size.width / 2, size.height * 0.7)
    this.LoadingSprite:setPosition(pos)
    this.LoadingSprite:setVisible(true)
    self.LabelMsg:setPositionPercent(cc.p(0.5, 0.3))

    this.LoadingSprite:stopActionByTag(LOADING_ACTION_TAG)

    local action = this.LoadingSprite:runAction(
      cc.RepeatForever:create(
        cc.Animate:create(
          display.getAnimationCache('loadingAnimation')
        )
      )
    )

    action:setTag(LOADING_ACTION_TAG)
  else
    if this.LoadingSprite ~= nil then
      this.LoadingSprite:stopActionByTag(LOADING_ACTION_TAG)
      this.LoadingSprite:setVisible(false)
    end
    self.LabelMsg:setPositionPercent(cc.p(0.5, 0.5))
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

function ToastBox2:close(fadeOut)
  local this = self
  this.showing = false

  if fadeOut == nil then
    fadeOut = true
  end

  if this.LoadingSprite ~= nil then
    this.LoadingSprite:stopActionByTag(LOADING_ACTION_TAG)
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

function ToastBox2:initKeypadHandler()
  local this = self
  local function onKeyReleased(keyCode, event)
    if this.showing then
      print('[ToastBox2 - onKeyReleased]')
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

function ToastBox2:PanelRoot_onClicked(sender, eventType)
  if self.closeOnTouch then
    self:close()
  end
end

local function showToastBox2(container, params)
  local toastId = 'ToastBox2'
  local toastZOrder = 1100
  if params.id ~= nil then
    toastId = params.id
  end
  if params.zorder ~= nil then
    toastZOrder = params.zorder
  end

  if container[toastId] == nil then
    local layer = cc.Layer:create()
    local msgBox = ToastBox2.extend(layer)

    msgBox:setLocalZOrder(toastZOrder)
    container:addChild(msgBox)
    container[toastId] = msgBox
  end

  container[toastId]:doShow(params)
  return container[toastId]
end

local function hideToastBox2(container, fadeOut, toastId)
  if toastId == nil then
    toastId = 'ToastBox2'
  end

  if container[toastId] then
    container[toastId]:close(fadeOut)
  end
end

return {
  showToastBox = showToastBox2,
  hideToastBox = hideToastBox2
}
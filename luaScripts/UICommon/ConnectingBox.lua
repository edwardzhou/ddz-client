

local ConnectingBox = class('ConnectingBox')
local utils = require('utils.utils')

local TOAST_BOX_ACTION_TAG = 0x20001
local LOADING_ACTION_TAG = 0x20002
local CONNECTING_DOT_TAG = 0x20003

function ConnectingBox.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, ConnectingBox)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function ConnectingBox:ctor(params)
  self.showing = false
  self.closeOnTouch = true
  self:init()
end

function ConnectingBox:init()
  local this = self
  local rootLayer = self

  this.showing = false
  local guiReader = ccs.GUIReader:getInstance()
  local uiRoot = guiReader:widgetFromBinaryFile('UI/NetworkConnecting.csb')
  self.uiRoot = uiRoot
  rootLayer:addChild(uiRoot)

  require('utils.UIVariableBinding').bind(uiRoot, self, self)

  self.LabelMsg:setFontName('')

  self:initKeypadHandler()

  self:registerScriptHandler(function(event)
    --print('event => ', event)

    if event == "enter" then      
    elseif event == 'exit' then
    end
  end)

  self.ButtonNetworkSetup:setVisible(false)
  -- self.ButtonTryAgain:setVisible(false)
  -- self.ButtonQuit:setVisible(false)
  self.PanelOption:setVisible(false)

  self.LabelMsg:setPosition(260, 0)
end

function ConnectingBox:doShow(params)
  local this = self
  this.retries = 1

  this.onRetry = params.onRetry

  self.LabelMsg:setString(params.msg)
  local showingLoading = false
  local grayBackground = false
  local closeOnTouch = true
  local showingTime = params.showingTime or 3
  local fadeInTime = params.fadeInTime or 0.4
  this.closeOnBack = true

  if params.closeOnBack ~= nil then
    --this.closeOnBack = params.closeOnBack
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

  this:setCurrentRetries(1)
  this.PanelOption:setVisible(false)

  local n = 1
  local progressAction = this:runAction(
    cc.RepeatForever:create(
      cc.Sequence:create(
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(function() 
            local msg = this.textMsg .. string.rep('.' , n)
            this.LabelMsg:setString(msg)
            n = n + 1
            if n > 6 then
              n = 1
            end
        end)
       )
    )
  )

  progressAction:setTag(CONNECTING_DOT_TAG)

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

function ConnectingBox:close(fadeOut)
  local this = self
  this.showing = false

  if fadeOut == nil then
    fadeOut = true
  end

  if this.loadingSprite ~= nil then
    this.loadingSprite:stopActionByTag(LOADING_ACTION_TAG)
  end
  this:stopActionByTag(TOAST_BOX_ACTION_TAG)
  this:stopActionByTag(CONNECTING_DOT_TAG)

  if fadeOut then
    local action = this:runAction(cc.Sequence:create(
        cc.TargetedAction:create(this.PanelBox, cc.FadeOut:create(0.3)),
        cc.Hide:create()
        --,cc.RemoveSelf:create()
      ))
    action:setTag(TOAST_BOX_ACTION_TAG)
  else
    this:setVisible(false)
    --this:runAction(cc.RemoveSelf:create())
  end

end

function ConnectingBox:initKeypadHandler()
  local this = self
  local function onKeyReleased(keyCode, event)
    if this.showing then
      print('[ConnectingBox - onKeyReleased]')
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

function ConnectingBox:PanelRoot_onClicked(sender, eventType)
  if self.closeOnTouch then
    self:close()
  end
end

function ConnectingBox:setCurrentRetries(retries)
  local this = self
  local rect, size, pos
  pos = cc.p(260, 40)
  this.retries = retries

  print('[ConnectingBox:setCurrentRetries] --------------', retries)
  cclog(debug.traceback())
  print('[ConnectingBox:setCurrentRetries] --------------', retries)

  if retries <= 2 then
    this.PanelOption:setVisible(false)
    this.ButtonNetworkSetup:setVisible(false)
    -- this.ButtonTryAgain:setVisible(false)
    -- this.ButtonQuit:setVisible(false)
    this.LabelMsg:setPosition(pos)
  elseif retries > 3 then    
    this.ButtonNetworkSetup:setVisible(true)
    --this.ButtonNetworkSetup:setPosition(590, 40)
    pos = cc.p(200, 40)
    this.LabelMsg:setPosition(pos)
  end

  this.loadingSprite:setPosition(pos.x - 20, pos.y)

  if this.retries < 4 then
    this.textMsg = string.format('正在努力链接中 #%d ', this.retries)
  else
    this.textMsg = string.format( '网络不给力，加倍努力链接中 #%d ' , this.retries)
  end

end

function ConnectingBox:setFailure()
  local this = self
  local rect, size, pos

  this.ButtonNetworkSetup:setVisible(true)
  this.textMsg = '网络无法连上，臣妾做不到啊~ \n请设置网络再试一次'
  this.LabelMsg:setString(this.textMsg)
  this:stopActionByTag(CONNECTING_DOT_TAG)
  -- this.ButtonNetworkSetup:setPosition(470, 40)
  -- this.ButtonTryAgain:setVisible(true)
  -- this.ButtonTryAgain:setPosition(590, 40)
  -- this.ButtonQuit:setVisible(true)
  -- this.ButtonQuit:setPosition(710, 40)
  -- this.LabelMsg:setPosition(160, 40)

  this.loadingSprite:setPosition(140, 40)

  this.PanelOption:setVisible(true)
end

function ConnectingBox:ButtonNetworkSetup_onClicked(sender, event)
  local luaj = require('luaj')
  local ok = luaj.callStaticMethod("com/fungame/DDZ/Utils", "wifiSetting", {}, "()V")
end

function ConnectingBox:ButtonQuit_onClicked(sender, event)
  cc.Director:getInstance():endToLua()
end

function ConnectingBox:ButtonTryAgain_onClicked(sender, event)
  local this = self
  if this.onRetry then
    this.onRetry()
  end
end

local function showConnectingBox(container, params)

  if container.connectingBox == nil then
    local layer = cc.Layer:create()
    local msgBox = ConnectingBox.extend(layer)

    msgBox:setLocalZOrder(900)
    container:addChild(msgBox)
    container.connectingBox = msgBox
  end

  if not container.connectingBox.showing then
    container.connectingBox:doShow(params)
  end

  return container.connectingBox
end

local function hideConnectingBox(container, fadeOut)
  if container.connectingBox and container.connectingBox.showing then
    container.connectingBox.showing = false
    container.connectingBox:close(fadeOut)
    --container.connectingBox = nil
  end
end

return {
  showConnectingBox = showConnectingBox,
  hideConnectingBox = hideConnectingBox
}
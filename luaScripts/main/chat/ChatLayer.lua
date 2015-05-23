local UIVarBinding = require('utils.UIVariableBinding')

local ChatLayer = class('ChatLayer', function() 
  return cc.Layer:create()
end)

function ChatLayer:ctor()
  self:init()
end

function ChatLayer:init()
	for index = 1, 8 do
  	self[string.format("ButtonMsg_%d_onClicked",index)] = self.onDefaultMsgClicked
  end
  for index = 1, 12 do
  	self[string.format("Emoji_%d_onClicked",index)] = self.onEmojiClicked
  end

  local uiRoot = cc.CSLoader:createNode('ChatLayer.csb')
  self:addChild(uiRoot)
  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initTouch()
  self:initKeypadHandler()
  
  for index = 1, 12 do
  	local button = self['Emoji_' .. tostring(index)]
  	button.index = index
  end
end

function ChatLayer:getAnimate(name, count, interval, plist, nameFunc)
	local animCache = cc.AnimationCache:getInstance()
  local animation = animCache:getAnimation(name)
  if animation == nil then
    local frameCache = cc.SpriteFrameCache:getInstance()
    frameCache:addSpriteFrames(plist)
    local frames = {}
    for i=1, count do
      local frame = frameCache:getSpriteFrame(nameFunc(i))
      table.insert(frames, frame)
    end
    animation = cc.Animation:createWithSpriteFrames(frames, interval)
    animCache:addAnimation(animation, name)
  end
  return cc.Animate:create(animation)
end

function ChatLayer:onEmojiClicked(sender, eventType)
	local counts = {2,4,3,8,12,11,11,4,2,6,7,11}
	local count = counts[sender.index]
	local repeatTime = 1
	if count < 4 then
		repeatTime = 3
	elseif count < 8 then
		repeatTime = 2
	end
	local nameFunc = function(index)
		return string.format("%02d/emo%02d_%02d.png",sender.index,sender.index,index)
	end
	local animate = self:getAnimate("emoji_"..tostring(sender.index), count, 0.2, "emo.plist", nameFunc)
	local scene = cc.Director:getInstance():getRunningScene()
	local sprite = cc.Sprite:createWithSpriteFrameName(nameFunc(1))
	scene:addChild(sprite)
	local winSize = cc.Director:getInstance():getWinSize()
	sprite:setPosition(winSize.width/2, winSize.height/2)
	local seq = cc.Sequence:create(cc.Repeat:create(animate, repeatTime), cc.RemoveSelf:create())
	sprite:runAction(seq)
	sprite:setAnchorPoint(0,0)
	self:close()
end

function ChatLayer:onDefaultMsgClicked(sender, eventType)
	local text = sender:getTitleText()
	self:sendTextMessage(text)
  self:close()
end

function ChatLayer:sendTextMessage(msg)
	local showToastBox = require('UICommon.ToastBox').showToastBox
	local params = {
    msg = msg,
    grayBackground = false,
    showLoading = false,
    showingTime = 3
  }

  showToastBox(cc.Director:getInstance():getRunningScene(), params)
end

function ChatLayer:initTouch()
	local onTouchBegan = function() return true end
	local touchListener = cc.EventListenerTouchOneByOne:create()
	touchListener:setSwallowTouches(true)
	touchListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, self) 
end

function ChatLayer:initKeypadHandler()
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      event:stopPropagation()
      self:close()
    end
  end
  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function ChatLayer:BgPanel_onClicked()
  self:close()
end

function ChatLayer:ButtonSend_onClicked()
	if self.Text:getString() ~= "" then
		self:sendTextMessage(self.Text:getString())
	end
  self:close()
end

function ChatLayer:close()
  self:runAction(cc.RemoveSelf:create())
end

return ChatLayer
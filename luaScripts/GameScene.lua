require 'GuiConstants'
require 'PokeCard'

local GameScene = class('GameScene', function()
  return cc.Scene:create() 
end)

function GameScene.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, GameScene)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end

  return target
end

function GameScene:ctor(...)
  cc.SpriteFrameCache:getInstance():addSpriteFramesWithFile('poke_cards.plist')

  self:registerScriptHandler(function(event)
    print('event => ', event)
    if event == "enterTransitionFinish" then
      self:init()
    elseif event == 'exit' then
    end
  end)

end

function GameScene:init()
  self:initKeypadHandler()

  local rootLayer = cc.Layer:create()
  self:addChild(rootLayer)

  local ui = ccs.GUIReader:getInstance():widgetFromJsonFile('UI/Gaming/Gaming.json')
  rootLayer:addChild(ui)

  local pokeCardsPanel = ccui.Helper:seekWidgetByName(ui, 'SelfPokeCards_Panel')
  local pokeCardsLayer = cc.Layer:create()
  pokeCardsPanel:addNode(pokeCardsLayer)

--  local poke = cc.Sprite:createWithSpriteFrameName('a03.png')
--  poke:setPosition(400, 130)
--  pokeCardsLayer:addChild(poke)
--
  PokeCard.sharedPokeCard(pokeCardsLayer)
  PokeCard.reloadAllCardSprites(pokeCardsLayer)

  local pokeCards = PokeCard.getByPokeChars('AcjmDrEekRTWCVNXp')

  for i=1, 17 do
    local c = pokeCards[i]
    c.card_sprite:setPosition(i * 40, 0)
    c.card_sprite:setVisible(true)
    c.card_sprite:setLocalZOrder(i)
    if i % 4 == 0 then
      --c.card_sprite:setOpacity(255 * 0.9)
      --c.card_sprite:setColor(cc.c3b(187, 187, 187))
    end
  end
  self.pokeCards = pokeCards

  self.pokeCardsLayer = pokeCardsLayer

  self:initPokeCardsLayerTouchHandler()

end

function GameScene:initKeypadHandler()
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      --      if type(self.onMainMenu) == 'function' then
      --        self.onMainMenu()
      --      end
      cc.Director:getInstance():popScene()
    elseif keyCode == cc.KeyCode.KEY_MENU  then
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function GameScene:initPokeCardsLayerTouchHandler()

  local function getCardIndex(loc)
    local result = -1
    for index = #self.pokeCards, 1, -1 do
      local poke_card = self.pokeCards[index]
      local cardBoundingBox = poke_card.card_sprite:getBoundingBox()
      if cc.rectContainsPoint(cardBoundingBox, loc) then
        --cclog("in rect")
        result = index
        break
      else
        --cclog("not in rect")
      end
    end
    return result
  end
  
  local function move_check(start, end_p) 
    if start == end_p then
      -- return
    end
    
    local s = end_p
    if start < end_p then s = start end
    local e = start
    if start < end_p then e = end_p end
    local white = cc.c3b(255,255,255)
    local red = cc.c3b(187,187,187)
    for index = #self.pokeCards, 1, -1 do
      local poke_card = self.pokeCards[index]
      if index > e or index < s then
        if poke_card.card_sprite:getTag() ~= 1000 then
          poke_card.card_sprite:setColor(white)
          poke_card.card_sprite:setTag(1000)
        end
      else 
        if poke_card.card_sprite:getTag() ~= 1003 then
          poke_card.card_sprite:setColor(red)
          poke_card.card_sprite:setTag(1003)
        end
      end
    end
  end
  

  local function onTouchBegan(touch, event)
    local locationInNode = self:convertToNodeSpace(touch:getLocation())
    self.cardIndexBegin = getCardIndex(locationInNode)
    if self.cardIndexBegin > 0 then
      move_check(self.cardIndexBegin, self.cardIndexBegin)
    end
    
    return self.cardIndexBegin > 0
  end

  local function onTouchMoved(touch, event)
    local locationInNode = self:convertToNodeSpace(touch:getLocation())
    local cur_index = getCardIndex(locationInNode)
    if cur_index < 0 or cur_index == self.lastIndex then
      return
    end
    
    if self.cardIndexBegin < 0 then
      self.cardIndexBegin = cur_index
    end
    
    move_check(self.cardIndexBegin , cur_index)
    
  end

  local  function onTouchEnded(touch, event)
    --self:setColor(cc.c3b(255, 255, 255))
    local locationInNode = self:convertToNodeSpace(touch:getLocation())
    self.cardIndex = getCardIndex(locationInNode)
    local poke = nil
    if self.cardIndex > 0 then
      poke = self.pokeCards[self.cardIndex]
      poke.card_sprite:runAction(cc.MoveBy:create(0.08, cc.p(0, 30)))
    end
  end

  local listener = cc.EventListenerTouchOneByOne:create()
  self._listener = listener
  listener:setSwallowTouches(true)

  listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
  listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
  listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )

  local eventDispatcher = self:getEventDispatcher()
  eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.pokeCardsLayer)
end


local function createScene()
  --local scene = cc.Scene:create()
  return GameScene.new()
end

return createScene
require 'GuiConstants'
require 'PokeCard'

local GameScene = class('GameScene')

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
  --  ui:setAnchorPoint(0, 0)
  --  ui:setPosition(0, 0)
  rootLayer:addChild(ui)

  local pokeCardsPanel = ccui.Helper:seekWidgetByName(ui, 'SelfPokeCards_Panel')
  local pokeCardsLayer = cc.Layer:create()
  pokeCardsPanel:addNode(pokeCardsLayer)

  local poke = cc.Sprite:createWithSpriteFrameName('a03.png')
  poke:setPosition(400, 130)
  pokeCardsLayer:addChild(poke)

  PokeCard.resetAll(pokeCardsLayer)

  local pokeCards = PokeCard.getByPokeChars('AcjmDrEekRTWCVNXp')

  for i=1, 17 do
    local c = pokeCards[i]
    c.card_sprite:setPosition(i * 40, 0)
    c.card_sprite:setVisible(true)
    c.card_sprite:setLocalZOrder(i)
    if i % 4 == 0 then
      --c.card_sprite:setOpacity(255 * 0.9)
      c.card_sprite:setColor(cc.c3b(187, 187, 187))
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
    --label:setString("MENU clicked!")
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
        cclog("in rect")
        result = index
        break
      else
        cclog("not in rect")
      end
    end
    return result
  end

  local function onTouchBegan(touch, event)
    --local locationInNode = self:convertToNodeSpace(touch:getLocation())
    --self.cardIndex = getCardIndex(locationInNode)
    return true
  end

  local function onTouchMoved(touch, event)

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
  local scene = cc.Scene:createWithPhysics()
  return GameScene.extend(scene)
end

return createScene
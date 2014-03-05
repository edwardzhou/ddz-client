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
  
  self.visibleSize = cc.Director:getInstance():getVisibleSize()
  self.origin = cc.Director:getInstance():getVisibleOrigin()

  self:registerScriptHandler(function(event)
    print('event => ', event)
    if event == "enterTransitionFinish" then
      self:init()
    elseif event == 'exit' then
      self:cleanup()
    end
  end)
end

function GameScene:cleanup()
end

function GameScene:init()
  local this = self
  self:initKeypadHandler()

  local rootLayer = cc.Layer:create()
  self:addChild(rootLayer)

  local ui = ccs.GUIReader:getInstance():widgetFromJsonFile('UI/Gaming/Gaming.json')
  rootLayer:addChild(ui)
  self.uiWidget = ui

  local pokeCardsPanel = ccui.Helper:seekWidgetByName(ui, 'SelfPokeCards_Panel')
  local pokeCardsLayer = cc.Layer:create()
  pokeCardsPanel:addNode(pokeCardsLayer)
  self.pokeCardsLayer = pokeCardsLayer
  
  self:assignControlsVariables()
  

--  local readyButton = ccui.Helper:seekWidgetByName(ui, 'Ready_Button')
--  readyButton:addTouchEventListener(function(sender, eventType)
--    local buttonName = sender:getName()
--    print('button clicked: ', buttonName, eventType)
--    if eventType == ccui.TouchEventType.ended then
--    end
--  end)

  PokeCard.sharedPokeCard(pokeCardsLayer)
  PokeCard.reloadAllCardSprites(pokeCardsLayer)
  
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

    local s = math.min(start, end_p)
    local e = math.max(start, end_p)

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
    if cur_index < 0 or cur_index == self.cardIndexEnd then
      return
    end

    self.cardIndexEnd = cur_index

    if self.cardIndexBegin < 0 then
      self.cardIndexBegin = cur_index
    end

    move_check(self.cardIndexBegin , self.cardIndexEnd)
  end

  local  function onTouchEnded(touch, event)
    --self:setColor(cc.c3b(255, 255, 255))
    --    local locationInNode = self:convertToNodeSpace(touch:getLocation())
    --    self.cardIndex = getCardIndex(locationInNode)
    --    local poke = nil
    --    if self.cardIndex > 0 then
    --      poke = self.pokeCards[self.cardIndex]
    --      poke.card_sprite:runAction(cc.MoveBy:create(0.08, cc.p(0, 30)))
    --    end

    local indexBegin, indexEnd = self.cardIndexBegin, self.cardIndexEnd
    self.cardIndexBegin, self.cardIndexEnd = nil, nil

    if (indexBegin == nil or indexBegin < 0) then
      return
    end
    if indexEnd == nil or indexEnd < 0 then
      indexEnd = indexBegin
    end

    for _, pokeCard in pairs(self.pokeCards) do
      if pokeCard.picked then
        pokeCard.picked = false
        pokeCard.card_sprite:setPositionY(0)
      end
    end

    if indexBegin > indexEnd then
      indexBegin, indexEnd = indexEnd, indexBegin
    end

    if indexBegin == indexEnd then
      local pokeCard = self.pokeCards[indexBegin]
      if pokeCard.picked then
        pokeCard.picked = false
        pokeCard.card_sprite:setTag(1000)
        pokeCard.card_sprite:setColor(cc.c3b(225,255,225))
        pokeCard.card_sprite:runAction(cc.MoveBy:create(0.07, cc.p(0, -30)))
        return
      end
    end

    for i = indexBegin, indexEnd do
      local pokeCard = self.pokeCards[i]
      pokeCard.picked = true
      pokeCard.card_sprite:setTag(1000)
      pokeCard.card_sprite:setColor(cc.c3b(255,255,255))
      pokeCard.card_sprite:runAction(cc.MoveBy:create(0.07, cc.p(0, 30)))
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

function GameScene:assignControlsVariables()
  local uiRoot = self.uiWidget
  
  local function widgetByName(root, name, typeName)
    local widget = ccui.Helper:seekWidgetByName(root, name)
    if widget == nil then
      return nil
    end
    return tolua.cast(widget, typeName) 
  end
  
  local function assignUserPanel(userTag)
    local ctrlPrefix = userPrefix
    local userPanel = ccui.Helper:seekWidgetByName(uiRoot, userTag .. '_Panel')
    local userAttr = {}
    userAttr.Name = widgetByName(userPanel, userTag .. 'Name_Label', 'ccui.Text')
    userAttr.Role = widgetByName(userPanel, userTag .. 'Role_Image', 'ccui.ImageView')
    userAttr.Head = widgetByName(userPanel, userTag .. 'Head_Image', 'ccui.ImageView')
    userAttr.Status = widgetByName(userPanel, userTag .. 'Status_Image', 'ccui.ImageView')
    self[userTag] = userAttr
  end
  
  -- 上家
  assignUserPanel('PrevUser')
  -- 下家
  assignUserPanel('NextUser')
  -- 自己
  assignUserPanel('SelfUser')
  
end

local function createScene()
  --local scene = cc.Scene:create()
  return GameScene.new()
end

return createScene
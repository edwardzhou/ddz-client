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
  
  for i=1, 17 do
    local c = PokeCard.getCard(i*3)
    c.card_sprite:setPosition(i * 40, 0)
    c.card_sprite:setVisible(true)
    if i % 4 == 0 then
      --c.card_sprite:setOpacity(255 * 0.9)
      c.card_sprite:setColor(cc.c3b(187, 187, 187))
    end
  end
  
  
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



local function createScene()
  local scene = cc.Scene:createWithPhysics()
  return GameScene.extend(scene)
end

return createScene
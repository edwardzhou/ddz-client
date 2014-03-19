require 'GuiConstants'
require 'PokeCard'
local GamePlayer = require('GamePlayer')
local GameService = require('LocalGameService')

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

  self.gameService = GameService.new()

  cc.SpriteFrameCache:getInstance():addSpriteFrames('poke_cards.plist')
  
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
  self:bindControlsVariables()

  local pokeCardsLayer = cc.Layer:create()
  self.SelfPokeCards:addNode(pokeCardsLayer)
  self.pokeCardsLayer = pokeCardsLayer
  
  self.selfUserId = 1

  PokeCard.sharedPokeCard(pokeCardsLayer)
  self:initPokeCardsLayerTouchHandler()
  self:showSysTime()
  self:initPlayers()
  self.SysTime:setFontName("fonts/Marker Felt.ttf")
  self:showButtonsPanel(false)

end

function GameScene:Ready_onClicked(sender, event)
  local this = self
  --if event == ccui.TouchEventType.ended then
    PokeCard.releaseAllCards()
    PokeCard.reloadAllCardSprites(self.pokeCardsLayer)
    this.cardContentSize = PokeCard.getByPokeChars('A')[1].card_sprite:getContentSize()

    -- local p1, p2, p3, lordPokeCards = PokeCard.slicePokeCards()
    -- self.pokeCards = p1
    -- self.selfPlayerInfo.pokeCards = p1
    -- self.nextPlayerInfo.pokeCards = p2
    -- self.prevPlayerInfo.pokeCards = p3
    -- self.lordPokeCards = lordPokeCards
    self.gameService:readyGame(__bind(self.onServerGameStart, self))
  --end
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

function GameScene:bindControlsVariables()
  local VarBinding = require('utils.UIVariableBinding')
  VarBinding.bind(self.uiWidget, self, self)
end

function GameScene:showSysTime()
  self:runAction(cc.RepeatForever:create(cc.Sequence:create(
    cc.CallFunc:create(function()
      local tm = os.date("*t")
      self.SysTime:setText( string.format("%02d:%02d:%02d", tm.hour, tm.min, tm.sec) )
    end),
    cc.DelayTime:create(1.0)
  )))  
end

function GameScene:initPlayers()
  self.selfUserId = 1
  local this = self

  this.gameService:enterRoom(1, __bind(self.onServerPlayerJoin, self))
end

function GameScene:onServerGameStart(pokeGame)
  self.pokeGame = pokeGame
  self.pokeCards = self.selfPlayerInfo.pokeCards
  self:doUpdatePlayersUI()
  self.Ready:setVisible(false)
  self:showButtonsPanel(true)
  self:showCards()
  self.LordCard1:loadTexture(pokeGame.lordPokeCards[1].image_filename, ccui.TextureResType.plistType)
  self.LordCard2:loadTexture(pokeGame.lordPokeCards[2].image_filename, ccui.TextureResType.plistType)
  self.LordCard3:loadTexture(pokeGame.lordPokeCards[3].image_filename, ccui.TextureResType.plistType)
end

function GameScene:ButtonPass_onClicked(sender, event)
  self:enableButtonTip(false)
end

function GameScene:ButtonReset_onClicked(sender, event)
  self:enableButtonTip(true)
end

function GameScene:ButtonTip_onClicked(sender, event)
  self:enableButtonPlay( not self.ButtonPlay:isEnabled() )
end

local function createScene()
  --local scene = cc.Scene:create()
  return GameScene.new()
end

require('gaming.UIPlayerUpdatePlugin').bind(GameScene)
require('gaming.SPlayerJoinPlugin').bind(GameScene)
require('gaming.UIPokecardPickPlugin').bind(GameScene)
require('gaming.UIButtonsPlugin').bind(GameScene)

return createScene
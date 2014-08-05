require 'GuiConstants'
require 'PokeCard'
local mobdebug = require('src.mobdebug')
local GamePlayer = require('GamePlayer')
--local GameService = require('LocalGameService')
local GameService = require('RemoteGameService')

local gameConnection = require('network.GameConnection')

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
  local this = self

  self.gameService = GameService.new(self, ddz.GlobalSettings.userInfo.userId)

  self.visibleSize = cc.Director:getInstance():getVisibleSize()
  self.origin = cc.Director:getInstance():getVisibleOrigin()

  self:registerScriptHandler(function(event)
    print('[GameScene] event => ', event)
    local on_event = 'on_' .. event
    if type(this[on_event]) == 'function' then
      this[on_event](this)
    end
   -- if event == "enterTransitionFinish" then
    --   self:init()
    -- elseif event == 'exit' then
    --   self:cleanup()
    -- end
  end)

  self._onReconnected = __bind(self.onReconnected, self)
end

function GameScene:on_enterTransitionFinish()
  self:init()
end

function GameScene:on_cleanup()
  umeng.MobClickCpp:finishLevel('base_200')
  umeng.MobClickCpp:endLogPageView('page_gaming')
  umeng.MobClickCpp:endScene('gaming')
  self:stopAllActions()
  --PokeCard.releaseAllCards()
  self.gameService:leaveGame()
  self.gameService:cleanup()
  gameConnection:off('connectionReady', self._onReconnected)
end

function GameScene:init()
  umeng.MobClickCpp:beginScene('gaming')
  umeng.MobClickCpp:beginLogPageView('page_gaming')
  umeng.MobClickCpp:startLevel('base_200')

  umeng.MobClickCpp:pay(10, 2, 1000)
  umeng.MobClickCpp:pay(20, 1, "count_card", 1, 20)

  local this = self
  self:initKeypadHandler()

  local rootLayer = cc.Layer:create()
  self:addChild(rootLayer)

  local ui = ccs.GUIReader:getInstance():widgetFromBinaryFile('UI/Gaming.csb')
  rootLayer:addChild(ui)
  self.uiWidget = ui
  self:bindControlsVariables()

  local pokeCardsLayer = cc.Layer:create()
  -- local pokeCardsBatchNode = cc.SpriteBatchNode:createWithTexture(
  --   cc.Director:getInstance():getTextureCache():getTextureForKey('pokecards.png'))
  
  self.SelfPokeCards:addChild(pokeCardsLayer)
  PokeCard.resetAll()
  pokeCardsLayer:addChild(g_pokecards_node)
  self.pokeCardsLayer = pokeCardsLayer
  self.cardContentSize = g_shared_cards[1].card_sprite:getContentSize()
  -- self.pokeCardsBatchNode = pokeCardsBatchNode
  
  self.selfUserId = 1

  self:initPokeCardsLayerTouchHandler()
  self:showSysTime()
  self:initPlayers()

  self:resetScene()

  self.LabelBetBase:setString(ddz.selectedRoom.ante)



  gameConnection:on('connectionReady', self._onReconnected)
end

function GameScene:resetScene()
  self:showButtonsPanel(false)
  self:showGrabLordButtonsPanel(false)
  self.ButtonReady:setVisible(false)
  local emptyUserInfo = {
    nickName = '',
    state = ddz.PlayerStatus.None,    
  }
  self:updateNextPlayerUI(emptyUserInfo)
  self:updatePrevPlayerUI(emptyUserInfo)
  self:stopCountdown()
  self.LabelLordValue:setString(0)
end

function GameScene:onReconnected()
  self.gameService:restoreGame()
end

function GameScene:initKeypadHandler()
  local this = self
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      --      if type(self.onMainMenu) == 'function' then
      --        self.onMainMenu()
      --      end
      --this.gameService:leaveGame()
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
  self.timerAction = self:runAction(cc.RepeatForever:create(cc.Sequence:create(
    cc.CallFunc:create(function()
      local tm = os.date("*t")
      self.SysTime:setString( string.format("%02d:%02d:%02d", tm.hour, tm.min, tm.sec) )
    end),
    cc.DelayTime:create(1.0)
  )))  
end

function GameScene:initPlayers()
  self.selfUserId = ddz.GlobalSettings.userInfo.userId
  local this = self

  this.gameService:enterRoom(ddz.selectedRoom.roomId, function(data) 
      if data.timing then
        this:startSelfPlayerCountdown(function()
            this:ButtonReady_onClicked(this.ButtonReady, 0)
          end, data.timing)
      end
    end)
end

function GameScene:doServerGameStart(pokeGame, pokeIdChars, nextUserId)
  self:hideSelfPokecards()
  self.selfPlayerInfo = pokeGame:getPlayerInfo(self.selfUserId)
  self.prevPlayerInfo = self.selfPlayerInfo.prevPlayer
  self.nextPlayerInfo = self.selfPlayerInfo.nextPlayer

  self.selfPlayerInfo.lastCard = nil
  self.prevPlayerInfo.lastCard = nil
  self.nextPlayerInfo.lastCard = nil
  self.pokeGame = pokeGame
  self.selfPlayerInfo:setPokeIdChars(pokeIdChars)
  self.pokeCards = self.selfPlayerInfo.pokeCards
  table.sort(self.pokeCards, sortDescBy('index'))
  self.selfPlayerInfo:analyzePokecards()
  self:doUpdatePlayersUI()
  self.ButtonReady:setVisible(false)
  self:showGrabLordButtonsPanel(nextUserId == self.selfUserId, self.pokeGame.grabbingLord.lordValue)
  -- self.LabelBetBase:setStringValue(pokeGame.betBase)
  -- self:showButtonsPanel(nextUserId == self.selfUserId)
  self:showCards()
  self.LordCard1:loadTexture('images/game6.png', ccui.TextureResType.localType)
  self.LordCard2:loadTexture('images/game6.png', ccui.TextureResType.localType)
  self.LordCard3:loadTexture('images/game6.png', ccui.TextureResType.localType)
  self.LabelLordValue:setString('0')
  self:showPlaycardClock()
end

local function createScene()
  --local scene = cc.Scene:create()b
  return GameScene.new()
end

require('gaming.UIPlayerUpdatePlugin').bind(GameScene)
require('gaming.SPlayerJoinPlugin').bind(GameScene)
require('gaming.UIPokecardsPlugin').bind(GameScene)
require('gaming.UIButtonsPlugin').bind(GameScene)
require('gaming.SGamingActionsPlugin').bind(GameScene)
require('gaming.UIClockCountDownPlugin').bind(GameScene)

return createScene
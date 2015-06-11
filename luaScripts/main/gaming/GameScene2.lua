--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

require 'PokeCard'
local AccountInfo = require('AccountInfo')
--local mobdebug = require('src.mobdebug')
local GamePlayer = require('GamePlayer')
--local GameService = require('LocalGameService')
local GameService = require('RemoteGameService')
local showMessageBox = require('UICommon.MsgBox').showMessageBox
local gameConnection = require('network.GameConnection')
local bit = require('bit');

local GameScene2 = class('GameScene2', function()
  return cc.Scene:create()
end)

function GameScene2.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, GameScene2)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end

  return target
end

function GameScene2:ctor(...)
  local this = self

  this.hidenRetries = 1
  this.needReconnect = true

  self.gameConnection = require('network.GameConnection')
  self.gameService = GameService.new(self, ddz.GlobalSettings.userInfo.userId)

  self.visibleSize = cc.Director:getInstance():getVisibleSize()
  self.origin = cc.Director:getInstance():getVisibleOrigin()

  -- hard code bytes state
  self.gameConnection:resetBytesStat()

  self:registerScriptHandler(function(event)
    print('[GameScene2] event => ', event)
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

  self:runAction(
    cc.RepeatForever:create(
      cc.Sequence:create(
        cc.DelayTime:create(10),
        cc.CallFunc:create(function() this.gameConnection:doHeartbeat() end)
      )
    )
  )

  self:init()
 
end

function GameScene2:on_enterTransitionFinish()
  self.gameConnection.needReconnect = true
  gameConnection:on('connectionReady', self._onReconnected)
end

function GameScene2:on_exit()
  gameConnection:off('connectionReady', self._onReconnected)
end

function GameScene2:on_cleanup()
  print('[GameScene2:on_cleanup]')
  --g_pokecards_node:removeFromParent()
  --g_pokecards_node:setParent(nil)
  -- umeng.MobClickCpp:finishLevel('base_200')
  -- umeng.MobClickCpp:endLogPageView('page_gaming')
  -- umeng.MobClickCpp:endScene('gaming')
  self:stopAllActions()
  --PokeCard.releaseAllCards()
  self.gameService:leaveGame()
  self.gameService:cleanup()
end

function GameScene2:init()
  -- umeng.MobClickCpp:beginScene('gaming')
  -- umeng.MobClickCpp:beginLogPageView('page_gaming')
  -- umeng.MobClickCpp:startLevel('base_200')

  -- umeng.MobClickCpp:pay(10, 2, 1000)
  -- umeng.MobClickCpp:pay(20, 1, "count_card", 1, 20)
  print('[GameScene2:init]')

  _analytics:logEvent('entetGaming')

  local this = self
  self:initKeypadHandler()

  local rootLayer = cc.Layer:create()
  self:addChild(rootLayer)

  -- local ui = ccs.GUIReader:getInstance():widgetFromBinaryFile('gameUI/Gaming.csb')
  local ui = cc.CSLoader:createNode('GamingScene2.csb')
  rootLayer:addChild(ui)
  self.uiWidget = ui
  self:bindControlsVariables()

  local jipaiqi = require('gaming.JipaiqiPlugin')()
  -- jipaiqi:setAnchorPoint(cc.p(0.5, 0))
  -- jipaiqi:setPosition(cc.p(400, 0))
  self.JipaiqiPanel:addChild(jipaiqi)
  self.jipaiqi = jipaiqi
  self.JipaiqiPanel:setVisible(false)

  self.WaitingLabel:ignoreContentAdaptWithSize(true)
  self.PrevPlayTipsLabel:ignoreContentAdaptWithSize(true)
  self.PlayTipsLabel:ignoreContentAdaptWithSize(true)
  self.NextPlayTipsLabel:ignoreContentAdaptWithSize(true)

  self:updateUserInfo()

  local pokeCardsLayer = self.SelfPokeCards
  -- local pokeCardsLayer = cc.Layer:create()
  -- local pokeCardsBatchNode = cc.SpriteBatchNode:createWithTexture(
  --   cc.Director:getInstance():getTextureCache():getTextureForKey('pokecards.png'))
  
  -- self.SelfPokeCards:addChild(pokeCardsLayer)
  PokeCard.resetAll()
  g_pokecards_node:removeFromParent()
  pokeCardsLayer:addChild(g_pokecards_node)
  self.pokeCardsLayer = pokeCardsLayer
  self.cardContentSize = g_shared_cards[1].card_sprite:getContentSize()
  -- self.pokeCardsBatchNode = pokeCardsBatchNode
  
  self.selfUserId = 1

  self:initPokeCardsLayerTouchHandler()
  self:showSysTime()
  self:initPlayers()

  self:resetScene()

  self:startWaitingEffect()

  self.LabelBetBase:setString(ddz.selectedRoom.ante)
  self:updateTask()

  self.ButtonRoomList:setTitleText(ddz.selectedRoom.roomName)

end

function GameScene2:resetScene()
  self.jipaiqi:reset()
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

  local thisUser = AccountInfo.getCurrentUser()
  local selfUserInfo = {
    userId = thisUser.userId,
    nickName = thisUser.nickName,
    headIcon = thisUser.headIcon,
    state = ddz.PlayerStatus.None
  }
  self:updateSelfPlayerUI(selfUserInfo)

  self.SelfUserStatus:setVisible(false)
  self.PrevUserStatus:setVisible(false)
  self.NextUserStatus:setVisible(false)


  self.LordCard1:loadTexture('lord_back.png', ccui.TextureResType.plistType)
  self.LordCard2:loadTexture('lord_back.png', ccui.TextureResType.plistType)
  self.LordCard3:loadTexture('lord_back.png', ccui.TextureResType.plistType)

  self.LabelLordValue:setString('X 0')

  self.PlayTipsLabel:setVisible(false)
  self.PrevPlayTipsLabel:setVisible(false)
  self.NextPlayTipsLabel:setVisible(false)
  self.ButtonDelegate:setVisible(false)

  self.SelfUserRole:setVisible(false)
  self.PrevUserRole:setVisible(false)
  self.NextUserRole:setVisible(false)

  self.PanelPrevHead:setVisible(false)
  self.PanelNextHead:setVisible(false)
  self.SelfUserHead:setVisible(true)

  self.SelfChatPanel:setVisible(false)
  self.PrevChatPanel:setVisible(false)
  self.NextChatPanel:setVisible(false)
  self.nextPlayerInfo = nil
  self.prevPlayerInfo = nil

  self.ButtonChat:setEnabled(false)
  self.ButtonRobot:setEnabled(false)
  self.ButtonChat:setBright(false)
  self.ButtonRobot:setBright(false)

  self:stopCountdown(true)
end

function GameScene2:onReconnected()
  self.gameService:restoreGame()
end

function GameScene2:SelfPokeCards_onTouchEvent(sender, event)
  if self.pokeCardsTouchEvents and self.pokeCardsTouchEvents[event] then
    local location
    if event == ccui.TouchEventType.began then
      location = sender:getTouchBeganPosition()
    elseif event == ccui.TouchEventType.moved then
      location = sender:getTouchMovePosition()
    elseif event == ccui.TouchEventType.ended then
      location = sender:getTouchEndPosition()
    end
    self.pokeCardsTouchEvents[event](location, event)
  end
end

function GameScene2:onBackClicked()
  local this = self
  if not self.pokeGame or self.pokeGame.gameOver then
    cc.Director:getInstance():popScene()
    return
  end

  local function doQuitGame()
    --self.gameService:leaveGame(function()
        cc.Director:getInstance():popScene()
      --end)
  end

  local msgParams = {
    msg = '牌局未结束, 现在退出系统将作判负处理, 扣减相应的金币。是否真的要退出牌局?',
    title = '重要提示',
    buttonType = 'ok|cancel',
    width = 430,
    height = 250,
    onOk = doQuitGame
  }

  showMessageBox(self, msgParams)
end

function GameScene2:initKeypadHandler()
  local this = self
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      --      if type(self.onMainMenu) == 'function' then
      --        self.onMainMenu()
      --      end
      --this.gameService:leaveGame()
      --cc.Director:getInstance():popScene()
      this:onBackClicked()
    elseif keyCode == cc.KeyCode.KEY_MENU  then
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function GameScene2:bindControlsVariables()
  local VarBinding = require('utils.UIVariableBinding')
  VarBinding.bind(self.uiWidget, self, self, true)

  ddz.clearPressedDisabledTexture({
    self.SelfUserHead,
    self.PrevUserHead,
    self.NextUserHead,
    self.ButtonChat, 
    self.ButtonEmoj, 
    self.ButtonRobot, 
    self.ButtonConfig, 
    self.ButtonRoomList,
    self.ButtonBack})

end

function GameScene2:showSysTime()
  self.timerAction = self:runAction(cc.RepeatForever:create(cc.Sequence:create(
    cc.CallFunc:create(function()
      local tm = os.date("*t")
      self.SysTime:setString( string.format("%02d:%02d:%02d", tm.hour, tm.min, tm.sec) )
    end),
    cc.DelayTime:create(1.0)
  )))  
end

function GameScene2:initPlayers()
  self.selfUserId = ddz.GlobalSettings.userInfo.userId
  local this = self

  this.gameService:enterRoom(ddz.selectedRoom.roomId, ddz.selectedRoom.tableId, function(data) 
      if data.timing then
        this:startSelfPlayerCountdown(function()
            this:ButtonReady_onClicked(this.ButtonReady, 0)
          end, data.timing)
      end
      ddz.selectedRoom = data.room
    end)
end

function GameScene2:doServerGameStart(pokeGame, pokeIdChars, nextUserId, timing, data)
  _analytics:logEvent('开始新牌局', pokeGame)

  local this = self
  self:hideSelfPokecards()
  self:stopWaitingEffect()
  self.selfPlayerInfo = pokeGame:getPlayerInfo(self.selfUserId)
  self.prevPlayerInfo = self.selfPlayerInfo.prevPlayer
  self.nextPlayerInfo = self.selfPlayerInfo.nextPlayer

  self.selfPlayerInfo.lastCard = nil
  self.prevPlayerInfo.lastCard = nil
  self.nextPlayerInfo.lastCard = nil
  self.pokeGame = pokeGame
  self.selfPlayerInfo:setPokeIdChars(pokeIdChars)
  -- self.pokeCards = self.selfPlayerInfo.pokeCards
  -- table.sort(self.pokeCards, sortDescBy('index'))
  -- self.selfPlayerInfo:analyzePokecards()
  self:doUpdatePlayersUI()
  self.ButtonReady:setVisible(false)
  -- self:showGrabLordButtonsPanel(nextUserId == self.selfUserId, self.pokeGame.grabbingLord.lordValue)
  -- self.LabelBetBase:setStringValue(pokeGame.betBase)
  -- self:showButtonsPanel(nextUserId == self.selfUserId)
  PokeCard.resetAll()
  --self:showCards()
  self.LordCard1:loadTexture('lord_back.png', ccui.TextureResType.plistType)
  self.LordCard2:loadTexture('lord_back.png', ccui.TextureResType.plistType)
  self.LordCard3:loadTexture('lord_back.png', ccui.TextureResType.plistType)
  self.LabelLordValue:setString('X 0')
  --self:showPlaycardClock()

  self.PanelPrevHead:setVisible(true)
  self.PanelNextHead:setVisible(true)
  self.SelfUserHead:setVisible(true)  

  self.PrevUserRole:setVisible(false)
  self.NextUserRole:setVisible(false)
  self.SelfUserRole:setVisible(false)

  self.SelfUserStatus:setVisible(false)
  self.PrevUserStatus:setVisible(false)
  self.NextUserStatus:setVisible(false)
  print('[GameScene2:doServerGameStart] timing: ', timing)
  self:showDrawingCardsAnimation(nextUserId, timing)

  self.ButtonChat:setEnabled(true)
  self.ButtonRobot:setEnabled(true)
  self.ButtonChat:setBright(true)
  self.ButtonRobot:setBright(true)
  --self.pokeGame.assetBits = data.
  --self.JipaiqiPanel:setVisible( bit.band(data.assetBits, 0x01) > 0 )

  -- local pokeCards = table.copy(self.selfPlayerInfo.pokeCards)
  -- local pokeLen = #pokeCards
  -- local index = 1
  -- shuffleArray(pokeCards)

  -- self.pokeCards = {}
  -- if not self.selfDrawingCard then
  --   self.selfDrawingCard = cc.Sprite:create('images/game168.png')
  --   self.selfDrawingCard:setVisible(false)
  --   self.pokeCardsLayer:addChild(self.selfDrawingCard, -100)    
  -- end

  -- self:runAction(
  --   cc.Sequence:create(
  --     cc.Repeat:create( 
  --       cc.Sequence:create(
  --         cc.CallFunc:create(function() 
  --           this.selfDrawingCard:setPosition(400, 300)
  --           this.selfDrawingCard:setVisible(true)
  --         end),
  --         cc.TargetedAction:create(
  --           this.selfDrawingCard,
  --           cc.MoveTo:create(2/17, cc.p(400, 60))
  --         ),
  --         cc.CallFunc:create(function() 
  --           this.selfDrawingCard:setVisible(false)
  --           table.insert(this.pokeCards, pokeCards[index])
  --           table.sort(this.pokeCards, sortDescBy('index'))
  --           this:showCards(this.pokeCards, true)
  --           index = index + 1
  --         end)
  --         --,cc.DelayTime:create(2 / 17)
  --       ), 
  --       pokeLen
  --     ),
  --     cc.CallFunc:create(function()
  --       this.pokeCards = this.selfPlayerInfo.pokeCards
  --       table.sort(this.pokeCards, sortDescBy('index'))
  --       this:showGrabLordButtonsPanel(nextUserId == this.selfUserId, this.pokeGame.grabbingLord.lordValue)
  --       this:showPlaycardClock()
  --     end)
  --   )
  -- )

end

local function createScene()
  --local scene = cc.Scene:create()b
  return GameScene2.new()
end

require('gaming.UIPlayerUpdatePlugin').bind(GameScene2)
require('gaming.SPlayerJoinPlugin').bind(GameScene2)
require('gaming.UIPokecardsPlugin').bind(GameScene2)
require('gaming.UIButtonsPlugin').bind(GameScene2)
require('gaming.SGamingActionsPlugin').bind(GameScene2)
require('gaming.UIClockCountDownPlugin').bind(GameScene2)
require('gaming.SoundEffectPlugin').bind(GameScene2)
require('gaming.PlayingTipsPlugin').bind(GameScene2)
require('gaming.TaskUpdatePlugin').bind(GameScene2)
require('gaming.UIChatMsgPlugin').bind(GameScene2)
require('gaming.GameRoomUpgradePlugin').bind(GameScene2)
require('network.ConnectionStatusPlugin').bind(GameScene2)

return createScene
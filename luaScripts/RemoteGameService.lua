local GamePlayer = require('GamePlayer')
local PokeGame = require('PokeGame')
local scheduler = require('framework.scheduler')
local AI = require('PokecardAI')
local utils = require('utils.utils')

RemoteGameService = class('GameService')

function RemoteGameService:ctor(msgReceiver, selfUserId)
  self.selfUserId = selfUserId
  self.msgReceiver = msgReceiver or {}
  self._onServerPlayerJoinMsg = __bind(self.onServerPlayerJoinMsg, self)
  self._onServerPlayerReadyMsg = __bind(self.onServerPlayerReadyMsg, self)
  self._onServerGameStartMsg = __bind(self.onServerGameStartMsg, self)
  self._onServerGrabLordMsg = __bind(self.onServerGrabbingLordMsg, self)
  self._onServerPlayCardMsg = __bind(self.onServerPlayCardMsg, self)
  self._onServerLordValueUpgradeMsg = __bind(self.onServerLordValueUpgradeMsg, self)
  self._onServerGameOverMsg= __bind(self.onServerGameOverMsg, self)
  self:setupPomeloEvents()
end

function RemoteGameService:cleanup()
  self:removePomeloEvents()
end

function RemoteGameService:setupPomeloEvents()
  ddz.pomeloClient:on('onPlayerJoin', self._onServerPlayerJoinMsg)
  ddz.pomeloClient:on('onPlayerReady', self._onServerPlayerReadyMsg)
  ddz.pomeloClient:on('onGameStart', self._onServerGameStartMsg)
  ddz.pomeloClient:on('onGrabLord', self._onServerGrabLordMsg)
  ddz.pomeloClient:on('onPlayCard', self._onServerPlayCardMsg)
  ddz.pomeloClient:on('onLordValueUpgrade', self._onServerLordValueUpgradeMsg)
  ddz.pomeloClient:on('onGameOver', self._onServerGameOverMsg)
end

function RemoteGameService:removePomeloEvents()
  ddz.pomeloClient:off('onPlayerJoin', self._onServerPlayerJoinMsg)
  ddz.pomeloClient:off('onPlayerReady', self._onServerPlayerReadyMsg)
  ddz.pomeloClient:off('onGameStart', self._onServerGameStartMsg)
  ddz.pomeloClient:off('onGrabLord', self._onServerGrabLordMsg)
  ddz.pomeloClient:off('onPlayCard', self._onServerPlayCardMsg)
  ddz.pomeloClient:off('onLordValueUpgrade', self._onServerLordValueUpgradeMsg)
  ddz.pomeloClient:off('onGameOver', self._onServerGameOverMsg)
end


function RemoteGameService:onServerPlayerJoinMsg(data)

  dump(data, '[RemoteGameService:onServerPlayerJoinMsg] data => ')
  local players = {}
  for i = 1, #data.players do
    table.insert(players, GamePlayer.new(data.players[i]))
  end
  
  self.playersInfo = players

  utils.invokeCallback(self.msgReceiver.onServerPlayerJoin, self.msgReceiver, players)
  -- if self.msgReceiver.onServerPlayerJoin then
  --   self.msgReceiver:onServerPlayerJoin(players)
  -- end
end

function RemoteGameService:onServerPlayerReadyMsg(data)
  dump(data, '[RemoteGameService:onServerPlayerReadyMsg] data => ')
  local players = {}
  for i = 1, #data.players do
    --self.playersInfo
    table.insert(players, GamePlayer.new(data.players[i]))
  end
  utils.invokeCallback(self.msgReceiver.onServerPlayerJoin, self.msgReceiver, players)
  -- if self.msgReceiver.onServerPlayerJoin then
  --   self.msgReceiver:onServerPlayerJoin(players)
  -- end
end

function RemoteGameService:onServerLordValueUpgradeMsg(data)
  dump(data, '[RemoteGameService:onServerLordValueUpgradeMsg] data => ')
  self.pokeGame.lordValue = data.lordValue;
  self.pokeGame.currentMsgNo = data.msgNo
  utils.invokeCallback(self.msgReceiver.onLordValueUpgrade, self.msgReceiver, data.lordValue)
  -- if self.msgReceiver.onServerPlayerJoin then
  --   self.msgReceiver:onServerPlayerJoin(players)
  -- end
end

function RemoteGameService:enterRoom(roomId, callback)
  local this = self

  ddz.pomeloClient:request('ddz.entryHandler.enterRoom', {room_id = roomId}, function(data)
      dump(data, '[RemoteGameService:enterRoom] ddz.entryHandler.enterRoom =>')
      utils.invokeCallback(callback, data)
    end)
end

function RemoteGameService:restoreGame(callback)
  local this = self
  local params = {
    gameId = self.pokeGame.gameId,
    msgNo = self.pokeGame.currentMsgNo
  }

  dump(params, "[RemoteGameService:restoreGame] params")
  ddz.pomeloClient:request('ddz.gameHandler.restoreGame', params, function(data)
      dump(data, '[RemoteGameService:restoreGame] data' )
    end)

end

function RemoteGameService:readyGame(callback)
  ddz.pomeloClient:request('ddz.gameHandler.ready', {}, function(data) 
      dump(data, '[RemoteGameService:readyGame] ddz.gameHandler.ready')
      utils.invokeCallback(callback, data)
    end)
end

function RemoteGameService:leaveGame(callback)
  ddz.pomeloClient:request('ddz.entryHandler.leave', {}, function(data) 
      dump(data, '[RemoteGameService:leaveGame] ddz.entryHandler.leave')
    end)
end

function RemoteGameService:startNewGame()
  self.playersInfo[1].role = ddz.PlayerRoles.None
  self.playersInfo[2].role = ddz.PlayerRoles.None
  self.playersInfo[3].role = ddz.PlayerRoles.None
  
  local pokeGame = PokeGame.new(self.playersInfo)
  self.playersInfo[1]:analyzePokecards()
  self.playersInfo[2]:analyzePokecards()
  self.playersInfo[3]:analyzePokecards()
  pokeGame.betBase = 600
  self:onServerStartNewGameMsg({pokeGame = pokeGame})
end

function RemoteGameService:grabLord(userId, lordActionValue)
  --self:onServerGrabbingLordMsg({userId = userId, lordActionValue = lordActionValue})
  local params = {
    lordAction = lordActionValue,
    seqNo = self.pokeGame.currentSeqNo
  }

  ddz.pomeloClient:request('ddz.gameHandler.grabLord', params, function(data)
      dump(data, '[RemoteGameService:grabLord] ddz.gameHandler.grabLord => ')
    end)
end

function RemoteGameService:playCard(userId, pokeIdChars, callback)
  --self:onServerPlayCardMsg({userId = userId, pokeIdChars = pokeIdChars})
  local params = {
    card = pokeIdChars,
    seqNo = self.pokeGame.currentSeqNo
  }
  ddz.pomeloClient:request('ddz.gameHandler.playCard', params, function(data)
      dump(data, '[RemoteGameService:playCard] ddz.gameHandler.playCard response')
      utils.invokeCallback(callback, data)
    end)
end

function RemoteGameService:onServerGrabbingLordMsg(data)
  local this = self
  local userId = data.userId
  -- local player = self.playersMap[userId]
  local pokeGame = self.pokeGame
  pokeGame.currentSeqNo = data.seqNo
  pokeGame.currentMsgNo = data.msgNo

  dump(data, '[RemoteGameService:onServerGrabbingLordMsg] data')

  for i=1, #data.players do 
    pokeGame:updatePlayerInfo(data.players[i])
  end

  --dump(pokeGame, '[RemoteGameService:onServerGrabbingLordMsg] pokeGame')

  -- if data.lordValue > pokeGame.lordValue then
  --   pokeGame.lordValue = data.lordValue
  --   utils.invokeCallback(self.msgReceiver.onLordValueUpgrade, 
  --     self.msgReceiver,
  --     pokeGame.lordValue)
  -- end

  if data.lordUserId > 0 then
    pokeGame.lordUserId = data.lordUserId
    pokeGame.lordPokeCards = PokeCard.pokeCardsFromChars(data.lordPokeCards)
    pokeGame.lordPlayer = pokeGame:getPlayerInfo(pokeGame.lordUserId)
    self.msgReceiver:onGrabbingLordMsg(userId, data.nextUserId, pokeGame, false, true)
  else
    -- 未产生地主
    self.msgReceiver:onGrabbingLordMsg(userId, data.nextUserId, pokeGame, false, false)
  end
end

function RemoteGameService:onServerGameStartMsg(data)
  dump(data, "[RemoteGameService:onServerGameStartMsg] data => ")
  local this = self
  self.pokeGame = PokeGame.createWithGameData(data.pokeGame)
  local nextPlayerId = data.nextUserId
  local seqNo = data.seqNo
  self.pokeGame.currentSeqNo = seqNo
  self.pokeGame.currentMsgNo = data.msgNo
  self.pokeGame.nextPlayerId = nextPlayerId

  if self.msgReceiver.onStartNewGameMsg then
    self.msgReceiver:onStartNewGameMsg(self.pokeGame, data.pokeCards, nextPlayerId)
  end
end

function RemoteGameService:onServerPlayCardMsg(data)
  dump(data, "[RemoteGameService:onServerPlayCardMsg] data => ")
  local this = self
  local MR = self.msgReceiver
  local pokeGame = self.pokeGame
  local player = pokeGame:getPlayerInfo(data.player.userId)
  local nextPlayer = pokeGame:getPlayerInfo(data.nextUserId)
  local pokeChars = data.pokeChars
  pokeGame.currentMsgNo = data.msgNo
  player:init(data.player)
  if (data.nextUserId == self.selfUserId) then
    pokeGame.currentSeqNo = data.seqNo
  end

  local pokeCards = PokeCard.getByPokeChars(pokeChars)
  local card = Card.create(pokeCards)

  if self.selfUserId == player.userId then
    table.removeItems(player.pokeCards, pokeCards)
    player:analyzePokecards()
  end

  --local nextPlayer = self.pokeGame:setToNextPlayer()

  -- if card:isBomb() or card:isRocket() then
  --   self.pokeGame.bombs = self.pokeGame.bombs + 1
  --   self.pokeGame.lordValue = self.pokeGame.lordValue * 2
  --   self.msgReceiver:onLordValueUpgrade(self.pokeGame.lordValue)
  -- end

  pokeGame.prevPlay = {player = player, card = card}
  if card:isValid() then
    pokeGame.lastPlay = {player = player, card = card}
  end

  utils.invokeCallback(MR.onPlayCardMsg, MR, player.userId, card, nextPlayer)

  -- local this = self
  -- local userId = data.userId
  -- local pokeIdChars = data.pokeIdChars
  -- local player = self.playersMap[userId]
  -- local pokeCards = PokeCard.getByPokeChars(pokeIdChars)
  -- table.removeItems(player.pokeCards, pokeCards)
  -- player:analyzePokecards()
  -- local nextPlayer = self.pokeGame:setToNextPlayer()

  -- local card = Card.create(pokeCards)
  -- if card:isBomb() or card:isRocket() then
  --   self.pokeGame.bombs = self.pokeGame.bombs + 1
  --   self.pokeGame.lordValue = self.pokeGame.lordValue * 2
  --   self.msgReceiver:onLordValueUpgrade(self.pokeGame.lordValue)
  -- end

  -- self.pokeGame.prevPlay = {player = player, card = card}
  -- if card:isValid() then
  --   self.pokeGame.lastPlay = {player = player, card = card}
  -- end

  -- if self.msgReceiver.onPlayCardMsg then
  --   self.msgReceiver:onPlayCardMsg(userId, pokeIdChars)
  -- end

  -- if #player.pokeCards == 0 then
  --   local balance = self:getGameBalance(self.pokeGame, player)
  --   scheduler.performWithDelayGlobal(function ()
  --       this:onServerGameOverMsg({balance = balance})
  --     end, 0.3)

  --   return
  -- end

  -- if nextPlayer.robot then
  --   scheduler.performWithDelayGlobal(
  --     AI.playCard, 
  --     {this, this.pokeGame, nextPlayer},
  --     math.random()*10 % 2)
  --   -- scheduler.performWithDelayGlobal(function() 
  --   --   local pokeCards = table.copy(nextPlayer.pokeCards, 1, 1)
  --   --   this:playCard(nextPlayer.userId, PokeCard.getIdChars(pokeCards))
  --   -- end, math.random(2) - 0.5)
  -- end
end

function RemoteGameService:onServerGameOverMsg(data)
  local balance = data
  dump(data, '[RemoteGameService:onServerGameOverMsg] data')
  local players = {}
  players[data.players[1].userId] = data.players[1]
  players[data.players[2].userId] = data.players[2]
  players[data.players[3].userId] = data.players[3]
  data.playersMap = players
  utils.invokeCallback(self.msgReceiver.onGameOverMsg, self.msgReceiver, balance)
  -- if self.msgReceiver.onGameOverMsg then
  --   self.msgReceiver:onGameOverMsg(balance)
  -- end
end

function RemoteGameService:getGameBalance(pokeGame, winner)
  local balance = {}
  balance.winner = winner
  balance.betBase = pokeGame.betBase
  balance.lordValue = pokeGame.lordValue -- * math.pow(2, pokeGame.bombs)
  local totalPrize = balance.lordValue * pokeGame.betBase

  balance.totalPrize = totalPrize
  local prevPlayer = pokeGame:getPrevPlayer(winner)
  local nextPlayer = pokeGame:getNextPlayer(winner)
  if winner.role == ddz.PlayerRoles.Lord then
    balance.playerResults = {}
    balance.playerResults[winner.userId] = {balance = totalPrize}
    balance.playerResults[prevPlayer.userId] = {balance = -totalPrize / 2}
    balance.playerResults[nextPlayer.userId] = {balance = -totalPrize / 2}
  else
    balance.playerResults = {}
    balance.playerResults[winner.userId] = {balance = totalPrize / 2 }
    if prevPlayer.role == ddz.PlayerRoles.Lord then
      balance.playerResults[prevPlayer.userId] = {balance = -totalPrize}
      balance.playerResults[nextPlayer.userId] = {balance = totalPrize / 2}
    else
      balance.playerResults[prevPlayer.userId] = {balance = totalPrize / 2}
      balance.playerResults[nextPlayer.userId] = {balance = -totalPrize}
    end
  end

  return balance
end

return RemoteGameService
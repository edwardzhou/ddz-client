local GamePlayer = require('GamePlayer')
local PokeGame = require('PokeGame')
local scheduler = require('framework.scheduler')
local AI = require('PokecardAI')
local utils = require('utils.utils')

RemoteGameService = class('GameService')

function RemoteGameService:ctor(msgReceiver, selfUserId)
  self.gameConnection = require('network.GameConnection')
  self.selfUserId = selfUserId
  self.msgReceiver = msgReceiver or {}
  self._onServerPlayerJoinMsg = __bind(self.onServerPlayerJoinMsg, self)
  self._onServerPlayerReadyMsg = __bind(self.onServerPlayerReadyMsg, self)
  self._onServerGameStartMsg = __bind(self.onServerGameStartMsg, self)
  self._onServerGrabLordMsg = __bind(self.onServerGrabbingLordMsg, self)
  self._onServerPlayCardMsg = __bind(self.onServerPlayCardMsg, self)
  self._onServerLordValueUpgradeMsg = __bind(self.onServerLordValueUpgradeMsg, self)
  self._onServerGameOverMsg= __bind(self.onServerGameOverMsg, self)
  self._onServerPreStartGameMsg = __bind(self.onServerPreStartGameMsg, self)
  self._onServerRoomUpgrade = __bind(self.onServerRoomUpgrade, self)
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
  ddz.pomeloClient:on('onPreStartGame', self._onServerPreStartGameMsg)
  ddz.pomeloClient:on('onRoomUpgrade', self._onServerRoomUpgrade)
end

function RemoteGameService:removePomeloEvents()
  ddz.pomeloClient:off('onPlayerJoin')
  ddz.pomeloClient:off('onPlayerReady')
  ddz.pomeloClient:off('onGameStart')
  ddz.pomeloClient:off('onGrabLord')
  ddz.pomeloClient:off('onPlayCard')
  ddz.pomeloClient:off('onLordValueUpgrade')
  ddz.pomeloClient:off('onGameOver')
  ddz.pomeloClient:off('onPreStartGame')
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

function RemoteGameService:queryRooms(callback)
  self.gameConnection:request('ddz.entryHandler.queryRooms', {}, function(data) 
    dump(data, 'queryRooms => ')
    if data.err == nil then
      ddz.GlobalSettings.rooms = data.rooms
      utils.invokeCallback(callback, data.rooms)
    end
  end)
end


function RemoteGameService:enterRoom(roomId, callback)
  local this = self

  self.gameConnection:request('ddz.entryHandler.enterRoom', {room_id = roomId}, function(data)
      dump(data, '[RemoteGameService:enterRoom] ddz.entryHandler.enterRoom =>')
      utils.invokeCallback(callback, data)
    end)
end

function RemoteGameService:restoreGame(callback)
  local this = self

  if this.pokeGame and this.pokeGame.gameOver then
    return
  end


  local params = {
  }

  if this.pokeGame then
    params.gameId = self.pokeGame.gameId
    params.msgNo = self.pokeGame.currentMsgNo
  end

  dump(params, "[RemoteGameService:restoreGame] params")
  self.gameConnection:request('ddz.gameHandler.restoreGame', params, function(data)
      dump(data, '[RemoteGameService:restoreGame] data' )
    end)

end

function RemoteGameService:readyGame(callback)
  self.pokeGame = nil
  self.gameConnection:request('ddz.gameHandler.ready', {}, function(data) 
      dump(data, '[RemoteGameService:readyGame] ddz.gameHandler.ready')
      utils.invokeCallback(callback, data)
    end)
end

function RemoteGameService:leaveGame(callback)
  --if self.pokeGame and not self.pokeGame.gameOver then
    self.gameConnection:request('ddz.entryHandler.leave', {}, function(data) 
        dump(data, '[RemoteGameService:leaveGame] ddz.entryHandler.leave')
        utils.invokeCallback(callback)
      end)
    --self.pokeGame.gameOver = true
  --end
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

  self.gameConnection:request('ddz.gameHandler.grabLord', params, function(data)
      dump(data, '[RemoteGameService:grabLord] ddz.gameHandler.grabLord => ')
    end)
end

function RemoteGameService:playCard(userId, pokeIdChars, callback)
  --self:onServerPlayCardMsg({userId = userId, pokeIdChars = pokeIdChars})
  local params = {
    card = pokeIdChars,
    seqNo = self.pokeGame.currentSeqNo
  }
  self.gameConnection:request('ddz.gameHandler.playCard', params, function(data)
      dump(data, '[RemoteGameService:playCard] ddz.gameHandler.playCard response')
      utils.invokeCallback(callback, data)
    end)
end

function RemoteGameService:cancelDelegate(callback)
  self.gameConnection:request('ddz.gameHandler.cancelDelegate', {}, function(data) 
      dump(data, '[RemoteGameService:cancelDelegate] ddz.gameHandler.cancelDelegate response')
      utils.invokeCallback(callback, data)
    end)
end

function RemoteGameService:setDelegate(callback)
  self.gameConnection:request('ddz.gameHandler.setDelegate', {}, function(data) 
      dump(data, '[RemoteGameService:cancelDelegate] ddz.gameHandler.setDelegate response')
      utils.invokeCallback(callback, data)
    end)
end

function RemoteGameService:onServerGrabbingLordMsg(data)
  local this = self
  local userId = data.userId
  local grabState = data.grabState
  -- local player = self.playersMap[userId]
  local pokeGame = self.pokeGame
  pokeGame.currentSeqNo = data.seqNo
  pokeGame.currentMsgNo = data.msgNo
  pokeGame.grabbingLord.lordValue = data.lordValue

  dump(data, '[RemoteGameService:onServerGrabbingLordMsg] data')

  for i=1, #data.players do 
    pokeGame:updatePlayerInfo(data.players[i])
  end

  --pokeGame:setNextPlayerById(data.nextUserId)
  pokeGame.nextPlayerId = data.nextUserId

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
    self.msgReceiver:onGrabbingLordMsg(userId, grabState, data.nextUserId, data.timing, pokeGame, false, true, data)
  else
    -- 未产生地主
    self.msgReceiver:onGrabbingLordMsg(userId, grabState, data.nextUserId, data.timing, pokeGame, false, false, data)
  end
end

function RemoteGameService:onServerPreStartGameMsg(data)
  dump(data, "[RemoteGameService:onServerPreStartGameMsg] data => ")
  local this = self
  local roomId = data.roomId
  local tableId = data.tableId

  local params = {
    roomId = roomId,
    tableId = tableId
  }

  self.gameConnection:request('ddz.entryHandler.ackPreStartGame', params, function(resp) 
    end)

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
  self.pokeGame.assetBits = data.assetBits or 0

  self:onServerPlayerJoinMsg(data.pokeGame)

  if self.msgReceiver.onStartNewGameMsg then
    self.msgReceiver:onStartNewGameMsg(self.pokeGame, data.pokeCards, nextPlayerId, data.timing or 20, data)
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
  pokeGame.nextPlayerId = data.nextUserId

  pokeGame.prevPlay = {player = player, card = card}
  if card:isValid() then
    pokeGame.lastPlay = {player = player, card = card}
  end

  utils.invokeCallback(MR.onPlayCardMsg, MR, player.userId, card, nextPlayer, data.timing, data.delegating > 0, data)

end

function RemoteGameService:onServerRoomUpgrade(data)
  dump(data, '[RemoteGameService:onServerRoomUpgrade] data', 5)

  utils.invokeCallback(self.msgReceiver.onRoomUpgrade, self.msgReceiver, data)
end

function RemoteGameService:onServerGameOverMsg(data)
  local balance = data
  dump(data, '[RemoteGameService:onServerGameOverMsg] data', 5)
  self.pokeGame.gameOver = true
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
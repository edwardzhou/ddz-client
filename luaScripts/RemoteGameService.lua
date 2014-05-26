local GamePlayer = require('GamePlayer')
local PokeGame = require('PokeGame')
local scheduler = require('framework.scheduler')
local AI = require('PokecardAI')
local utils = require('utils.utils')

RemoteGameService = class('GameService')

function RemoteGameService:ctor(msgReceiver)
  self.msgReceiver = msgReceiver or {}
  self._onServerPlayerJoinMsg = __bind(self.onServerPlayerJoinMsg, self)
  self._onServerPlayerReadyMsg = __bind(self.onServerPlayerReadyMsg, self)
  self:setupPomeloEvents()
end

function RemoteGameService:setupPomeloEvents()
  ddz.pomeloClient:on('onPlayerJoin', self._onServerPlayerJoinMsg)
  ddz.pomeloClient:on('onPlayerReady', self._onServerPlayerReadyMsg)
end

function RemoteGameService:removePomeloEvents()
  ddz.pomeloClient:off('onPlayerJoin', self._onServerPlayerJoinMsg)
  ddz.pomeloClient:off('onPlayerReady', self._onServerPlayerReadyMsg)
end

function RemoteGameService:onServerPlayerJoinMsg(data)
  dump(data, '[RemoteGameService:onServerPlayerJoinMsg] data => ')
  local players = {}
  for i = 1, #data.players do
    table.insert(players, GamePlayer.new(data.players[i]))
  end
  utils.invokeCallback(self.msgReceiver.onServerPlayerJoin, self.msgReceiver, players)
  -- if self.msgReceiver.onServerPlayerJoin then
  --   self.msgReceiver:onServerPlayerJoin(players)
  -- end
end

function RemoteGameService:onServerPlayerReadyMsg(data)
  dump(data, '[RemoteGameService:onServerPlayerReadyMsg] data => ')
  local players = {}
  for i = 1, #data.players do
    table.insert(players, GamePlayer.new(data.players[i]))
  end
  utils.invokeCallback(self.msgReceiver.onServerPlayerJoin, self.msgReceiver, players)
  -- if self.msgReceiver.onServerPlayerJoin then
  --   self.msgReceiver:onServerPlayerJoin(players)
  -- end
end



function RemoteGameService:enterRoom(roomId, callback)
  local this = self

  ddz.pomeloClient:request('ddz.entryHandler.enterRoom', {room_id = roomId}, function(data)
      dump(data, '[RemoteGameService:enterRoom] ddz.entryHandler.enterRoom =>')
    end)
end

function RemoteGameService:readyGame(callback)
  ddz.pomeloClient:request('ddz.gameHandler.ready', {}, function(data) 
      dump(data, '[RemoteGameService:readyGame] ddz.gameHandler.ready')
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
  self:onServerGrabbingLordMsg({userId = userId, lordActionValue = lordActionValue})
end

function RemoteGameService:playCard(userId, pokeIdChars, callback)
  self:onServerPlayCardMsg({userId = userId, pokeIdChars = pokeIdChars})
end

function RemoteGameService:onServerGrabbingLordMsg(data)
  local this = self
  local userId = data.userId
  local player = self.playersMap[userId]
  local pokeGame = self.pokeGame
  --player.lordValue = data.lordValue
  if pokeGame.grabbingLord.lordValue == 0 then
    if data.lordActionValue == ddz.Actions.GrabbingLord.None then
      player.status = ddz.PlayerStatus.NoGrabLord
    else
      player.status = ddz.PlayerStatus.GrabLord
      pokeGame.grabbingLord.lordValue = 3
      pokeGame.grabbingLord.firstLordPlayer = player
      pokeGame.grabbingLord.lordPlayer = player
      self.msgReceiver:onLordValueUpgrade(pokeGame.grabbingLord.lordValue)
    end
  else
    if data.lordActionValue == ddz.Actions.GrabbingLord.None then
      player.status = ddz.PlayerStatus.PassGrabLord
    else
      player.status = ddz.PlayerStatus.ReGrabLord
      pokeGame.grabbingLord.lordValue = pokeGame.grabbingLord.lordValue * 2
      pokeGame.grabbingLord.lordPlayer = player
      self.msgReceiver:onLordValueUpgrade(pokeGame.grabbingLord.lordValue)
    end
  end

  local nextPlayer = self.pokeGame:setToNextPlayer()
  if nextPlayer.status == ddz.PlayerStatus.NoGrabLord then
    nextPlayer = self.pokeGame:setToNextPlayer()
  end

  local isGiveup = (self.pokeGame.grabbingLord.firstPlayer == nextPlayer) and 
                    (self.pokeGame.grabbingLord.lordValue == 0)
  local isGrabLordFinish = false
  if self.pokeGame.grabbingLord.lordValue == 3 then
    isGrabLordFinish = self.pokeGame.grabbingLord.firstPlayer == nextPlayer
  elseif self.pokeGame.grabbingLord.lordValue > 3 then
    isGrabLordFinish = self.pokeGame.grabbingLord.firstLordPlayer == player
  end

  if isGrabLordFinish then
    self.pokeGame.lordValue = self.pokeGame.grabbingLord.lordValue
    local lordPlayer = self.pokeGame.grabbingLord.lordPlayer
    self.pokeGame:setNextPlayer(lordPlayer)
    dump(self.pokeGame.lordPokeCards, 'lordPokeCards')
    --dump(lordPlayer, 'lordPlayer')
    table.append(lordPlayer.pokeCards, self.pokeGame.lordPokeCards)
    table.sort(lordPlayer.pokeCards, sortDescBy('index'))
    --dump(lordPlayer.pokeCards, 'lordPlayer.pokeCards')
    lordPlayer.role = ddz.PlayerRoles.Lord 
    lordPlayer.nextPlayer.role = ddz.PlayerRoles.Farmer
    lordPlayer.prevPlayer.role = ddz.PlayerRoles.Farmer
    self.pokeGame.lordPlayer = lordPlayer
    lordPlayer:analyzePokecards()
    self.playersInfo[1].status = ddz.PlayerStatus.None
    self.playersInfo[2].status = ddz.PlayerStatus.None
    self.playersInfo[3].status = ddz.PlayerStatus.None
  end

  if self.msgReceiver.onGrabbingLordMsg then
    self.msgReceiver:onGrabbingLordMsg(userId, nextPlayer.userId, isGiveup, isGrabLordFinish)
  end

  if isGiveup then
    -- 流局
    scheduler.performWithDelayGlobal(function() 
        this.pokeGame:restart()
        this:onServerStartNewGameMsg({pokeGame = self.pokeGame})
      end, 0.7)

    return
  end

  if isGrabLordFinish then
    if self.pokeGame.lordPlayer.robot then
      local this = self
      scheduler.performWithDelayGlobal( 
        AI.playCard, 
        {this, this, this.pokeGame.lordPlayer},
        math.random() * 10 % 2)
      -- AI.playCard(self, self.pokeGame, self.pokeGame.lordPlayer)
    end

    return
  end

  if nextPlayer.robot then
    AI.grabLord(self, self.pokeGame, nextPlayer)
      -- scheduler.performWithDelayGlobal( 
      --   AI.playCard, 
      --   {self, self.pokeGame, nextPlayer},
      --   math.random() * 10 % 2)
  end  

end

function RemoteGameService:onServerStartNewGameMsg(data)
  local this = self
  self.pokeGame = data.pokeGame
  local nextPlayer = self.pokeGame.currentPlayer
  self.playersInfo[1].status = ddz.PlayerStatus.None
  self.playersInfo[2].status = ddz.PlayerStatus.None
  self.playersInfo[3].status = ddz.PlayerStatus.None
  if self.msgReceiver.onStartNewGameMsg then
    self.msgReceiver:onStartNewGameMsg(self.pokeGame, nextPlayer.userId)
  end

  if nextPlayer.robot then
    AI.grabLord(self, self.pokeGame, nextPlayer)
  end

  -- if nextPlayer.robot then
  --   scheduler.performWithDelayGlobal(function() 
  --     local pokeCards = table.copy(nextPlayer.pokeCards, 1, 1)
  --     this:playCard(nextPlayer.userId, PokeCard.getIdChars(pokeCards))
  --   end, math.random(5) - 0.5)
  -- end
end

function RemoteGameService:onServerPlayCardMsg(data)
  local this = self
  local userId = data.userId
  local pokeIdChars = data.pokeIdChars
  local player = self.playersMap[userId]
  local pokeCards = PokeCard.getByPokeChars(pokeIdChars)
  table.removeItems(player.pokeCards, pokeCards)
  player:analyzePokecards()
  local nextPlayer = self.pokeGame:setToNextPlayer()

  local card = Card.create(pokeCards)
  if card:isBomb() or card:isRocket() then
    self.pokeGame.bombs = self.pokeGame.bombs + 1
    self.pokeGame.lordValue = self.pokeGame.lordValue * 2
    self.msgReceiver:onLordValueUpgrade(self.pokeGame.lordValue)
  end

  self.pokeGame.prevPlay = {player = player, card = card}
  if card:isValid() then
    self.pokeGame.lastPlay = {player = player, card = card}
  end

  if self.msgReceiver.onPlayCardMsg then
    self.msgReceiver:onPlayCardMsg(userId, pokeIdChars)
  end

  if #player.pokeCards == 0 then
    local balance = self:getGameBalance(self.pokeGame, player)
    scheduler.performWithDelayGlobal(function ()
        this:onServerGameOverMsg({balance = balance})
      end, 0.3)

    return
  end

  if nextPlayer.robot then
    scheduler.performWithDelayGlobal(
      AI.playCard, 
      {this, this.pokeGame, nextPlayer},
      math.random()*10 % 2)
    -- scheduler.performWithDelayGlobal(function() 
    --   local pokeCards = table.copy(nextPlayer.pokeCards, 1, 1)
    --   this:playCard(nextPlayer.userId, PokeCard.getIdChars(pokeCards))
    -- end, math.random(2) - 0.5)
  end
end

function RemoteGameService:onServerGameOverMsg(data)
  local balance = data.balance
  dump(balance, '[RemoteGameService:onServerGameOverMsg] balance', false, 3)
  if self.msgReceiver.onGameOverMsg then
    self.msgReceiver:onGameOverMsg(balance)
  end
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
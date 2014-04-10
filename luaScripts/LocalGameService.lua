local GamePlayer = require('GamePlayer')
local PokeGame = require('PokeGame')
local scheduler = require('framework.scheduler')
local AI = require('PokecardAI')

LocalGameService = class('GameService')

function LocalGameService:ctor(msgReceiver)
  self.msgReceiver = msgReceiver or {}
end

function LocalGameService:enterRoom(roomId, callback)
  local this = self
  local Heads = {'head1', 'head2', 'head3', 'head4', 'head5', 'head6', 'head7', 'head8'}
  local Status = {ddz.PlayerStatus.None, ddz.PlayerStatus.Ready}
  local Roles = {ddz.PlayerRoles.Farmer, ddz.PlayerRoles.Lord, ddz.PlayerRoles.Farmer}
  table.shuffle(Roles)
  local playersInfo = {
    GamePlayer.new({userId=1, name='我自己', role=ddz.PlayerRoles.None, status=ddz.PlayerStatus.None}),
    GamePlayer.new({userId=2, name='张无忌', robot=true, role=ddz.PlayerRoles.None, status=ddz.PlayerStatus.Ready}),
    GamePlayer.new({userId=3, name='东方不败', robot=true, role=ddz.PlayerRoles.None, status=ddz.PlayerStatus.Ready})
  }
  for _, playerInfo in pairs(playersInfo) do
    playerInfo.headIcon = Heads[ math.random(#Heads) ]
  end
  table.shuffle(playersInfo)

  self.playersInfo = playersInfo

  self.playersMap = {
    [playersInfo[1].userId] = playersInfo[1],
    [playersInfo[2].userId] = playersInfo[2],
    [playersInfo[3].userId] = playersInfo[3]
  }

  callback(playersInfo)
end

function LocalGameService:readyGame(callback)
  local Roles = {ddz.PlayerRoles.Farmer, ddz.PlayerRoles.Lord, ddz.PlayerRoles.Farmer}
  table.shuffle(Roles)
  self.playersInfo[1].role = ddz.PlayerRoles.None
  self.playersInfo[2].role = ddz.PlayerRoles.None
  self.playersInfo[3].role = ddz.PlayerRoles.None
  
  local pokeGame = PokeGame.new(self.playersInfo)
  self.playersInfo[1]:analyzePokecards()
  self.playersInfo[2]:analyzePokecards()
  self.playersInfo[3]:analyzePokecards()
  pokeGame.betBase = 600
  self:onServerStartNewGameMsg({pokeGame = pokeGame})
  -- if type(callback) == 'function' then
  --   callback(self.pokeGame)
  -- end
end

function LocalGameService:startNewGame()
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

function LocalGameService:grabLord(userId, lordActionValue)
  self:onServerGrabbingLordMsg({userId = userId, lordActionValue = lordActionValue})
end

function LocalGameService:playCard(userId, pokeIdChars, callback)
  self:onServerPlayCardMsg({userId = userId, pokeIdChars = pokeIdChars})
end

function LocalGameService:onServerGrabbingLordMsg(data)
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
      AI.playCard(self, self.pokeGame, self.pokeGame.lordPlayer)
    end

    return
  end

  if nextPlayer.robot then
    AI.grabLord(self, self.pokeGame, nextPlayer)
  end  

end

function LocalGameService:onServerStartNewGameMsg(data)
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

function LocalGameService:onServerPlayCardMsg(data)
  local this = self
  local userId = data.userId
  local pokeIdChars = data.pokeIdChars
  local player = self.playersMap[userId]
  local pokeCards = PokeCard.getByPokeChars(pokeIdChars)
  table.removeItems(player.pokeCards, pokeCards)
  local nextPlayer = self.pokeGame:setToNextPlayer()

  local card = Card.create(pokeCards)
  if card:isBomb() or card:isRocket() then
    self.pokeGame.bombs = self.pokeGame.bombs + 1
    self.pokeGame.lordValue = self.pokeGame.lordValue * 2
    self.msgReceiver:onLordValueUpgrade(self.pokeGame.lordValue)
  end

  if self.msgReceiver.onPlayCardMsg then
    self.msgReceiver:onPlayCardMsg(userId, pokeIdChars)
  end

  if #player.pokeCards == 0 then
    local balance = self:getGameBalance(self.pokeGame, player)
    scheduler.performWithDelayGlobal(function ()
        this:onServerGameOverMsg({balance = balance})
      end, 0.5)

    return
  end

  if nextPlayer.robot then
    scheduler.performWithDelayGlobal(function() 
      local pokeCards = table.copy(nextPlayer.pokeCards, 1, 1)
      this:playCard(nextPlayer.userId, PokeCard.getIdChars(pokeCards))
    end, math.random(2) - 0.5)
  end
end

function LocalGameService:onServerGameOverMsg(data)
  local balance = data.balance
  dump(balance, '[LocalGameService:onServerGameOverMsg] balance', false, 3)
  if self.msgReceiver.onGameOverMsg then
    self.msgReceiver:onGameOverMsg(balance)
  end
end

function LocalGameService:getGameBalance(pokeGame, winner)
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

return LocalGameService
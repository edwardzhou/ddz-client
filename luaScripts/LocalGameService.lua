local GamePlayer = require('GamePlayer')
local PokeGame = require('PokeGame')
local scheduler = require('framework.scheduler')

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
  self.playersInfo[1].role = Roles[1]
  self.playersInfo[2].role = Roles[2]
  self.playersInfo[3].role = Roles[3]
  
  local pokeGame = PokeGame.new(self.playersInfo)
  self.playersInfo[1]:analyzePokecards()
  self.playersInfo[2]:analyzePokecards()
  self.playersInfo[3]:analyzePokecards()
  self:onServerStartNewGameMsg({pokeGame = pokeGame})
  -- if type(callback) == 'function' then
  --   callback(self.pokeGame)
  -- end
end

function LocalGameService:playCard(userId, pokeIdChars, callback)
  self:onServerPlayCardMsg({userId = userId, pokeIdChars = pokeIdChars})
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
    scheduler.performWithDelayGlobal(function() 
      local pokeCards = table.copy(nextPlayer.pokeCards, 1, 1)
      this:playCard(nextPlayer.userId, PokeCard.getIdChars(pokeCards))
    end, math.random(2) - 0.5)
  end

end


function LocalGameService:onServerPlayCardMsg(data)
  local this = self
  local userId = data.userId
  local pokeIdChars = data.pokeIdChars
  local player = self.playersMap[userId]
  table.removeItems(player.pokeCards, PokeCard.getByPokeChars(pokeIdChars))
  local nextPlayer = self.pokeGame:setToNextPlayer()

  if self.msgReceiver.onPlayCardMsg then
    self.msgReceiver:onPlayCardMsg(userId, pokeIdChars)
  end

  if nextPlayer.robot then
    scheduler.performWithDelayGlobal(function() 
      local pokeCards = table.copy(nextPlayer.pokeCards, 1, 1)
      this:playCard(nextPlayer.userId, PokeCard.getIdChars(pokeCards))
    end, math.random(2) - 0.5)
  end

end

return LocalGameService
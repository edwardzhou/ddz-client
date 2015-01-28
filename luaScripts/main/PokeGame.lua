--local PokeCard = require('PokeCard')
local GamePlayer = require('GamePlayer')
local PokeGame = class('PokeGame')

function PokeGame.createWithGameData(gameData)
  local newPokeGame = PokeGame.new()

  newPokeGame:initWithGameData(gameData)
  return newPokeGame
end

function PokeGame.createWithPlayers(playersInfo)
  local newPokeGame = PokeGame.new()
  newPokeGame:initWithPlayers(playersInfo)
  return newPokeGame
end

function PokeGame:ctor()
  self.grabbingLord = {}
  self.grabbingLord.lordValue = 0
  self.lordValue = 0
  self.lordUserId = 0
  self.gameOver = false
end

function PokeGame:initWithGameData(gameData)
  self.gameAnte = gameData.gameAnte or self.gameAnte
  self.gameId = gameData.gameId or self.gameId
  self.gameLordValue = gameData.gameLordValue or self.gameLordValue
  self.gameRake = gameData.gameRake or self.gameRake
  self.roomId = gameData.roomId or self.roomId
  self.state = gameData.state or self.state
  self.tableId = gameData.tableId or self.tableId
  self.currentSeqNo = gameData.currentSeqNo or self.currentSeqNo
  if gameData.players then
    if self.playersInfo == nil then
      self.playersInfo = {
          GamePlayer.new(),
          GamePlayer.new(),
          GamePlayer.new()
        }
    end
    for i=1, #gameData.players do
      self.playersInfo[i]:init( gameData.players[i] )
    end
    self.playersInfo[1].nextPlayer = self.playersInfo[2]
    self.playersInfo[1].prevPlayer = self.playersInfo[3]
    self.playersInfo[2].nextPlayer = self.playersInfo[3]
    self.playersInfo[2].prevPlayer = self.playersInfo[1]
    self.playersInfo[3].nextPlayer = self.playersInfo[1]
    self.playersInfo[3].prevPlayer = self.playersInfo[2]

    self.playersMap = {}
    self.playersMap[self.playersInfo[1].userId] = self.playersInfo[1]
    self.playersMap[self.playersInfo[2].userId] = self.playersInfo[2]
    self.playersMap[self.playersInfo[3].userId] = self.playersInfo[3]
  end
end

function PokeGame:initWithPlayers(playersInfo)
  self.playersInfo = playersInfo
  self.playersInfo[1].nextPlayer = self.playersInfo[2]
  self.playersInfo[1].prevPlayer = self.playersInfo[3]
  self.playersInfo[2].nextPlayer = self.playersInfo[3]
  self.playersInfo[2].prevPlayer = self.playersInfo[1]
  self.playersInfo[3].nextPlayer = self.playersInfo[1]
  self.playersInfo[3].prevPlayer = self.playersInfo[2]
  self.playersMap = {}
  self.playersMap[self.playerInfo[1].userId] = self.playersInfo[1]
  self.playersMap[self.playerInfo[2].userId] = self.playersInfo[2]
  self.playersMap[self.playerInfo[3].userId] = self.playersInfo[3]
  self.currentPlayer = self.playersInfo[math.random(3)]
  self.bombs = 0
  self.spring = 0
  self.antiSpring = 0
  self.grabbingLord = {}
  self.grabbingLord.lordValue = 0
  self.grabbingLord.firstPlayer = self.currentPlayer
  self:arrangePokeCards()
end

function PokeGame:arrangePokeCards()
  local p1, p2, p3, lordPokeCards = PokeCard.slicePokeCards()
  self.playersInfo[1].pokeCards = p1
  self.playersInfo[2].pokeCards = p2
  self.playersInfo[3].pokeCards = p3
  self.lordPokeCards = lordPokeCards

  -- if self.playersInfo[1].role == ddz.PlayerRoles.Lord then
  --   table.append(self.playersInfo[1].pokeCards, self.lordPokeCards)
  --   table.sort(self.playersInfo[1].pokeCards, sortDescBy('index'))
  --   self.currentPlayer = self.playersInfo[1]
  -- elseif self.playersInfo[2].role == ddz.PlayerRoles.Lord then
  --   table.append(self.playersInfo[2].pokeCards, self.lordPokeCards)
  --   table.sort(self.playersInfo[2].pokeCards, sortDescBy('index'))
  --   self.currentPlayer = self.playersInfo[2]
  -- else
  --   table.append(self.playersInfo[3].pokeCards, self.lordPokeCards)
  --   table.sort(self.playersInfo[3].pokeCards, sortDescBy('index'))
  --   self.currentPlayer = self.playersInfo[3]
  -- end
end

function PokeGame:restart()
  self.currentPlayer = self.playersInfo[math.random(3)]
  self.grabbingLord = {}
  self.grabbingLord.lordValue = 0
  self.grabbingLord.firstPlayer = self.currentPlayer
  self:arrangePokeCards()
end

function PokeGame:updatePlayerInfo(player)
  print('[PokeGame:updatePlayerInfo] player.userId => ', player.userId)
  dump(self.playersMap, '[PokeGame:updatePlayerInfo] self.playersMap', 2)
  local p = self.playersMap[player.userId]
  p:init(player)
end

function PokeGame:getPlayerInfo(playerId)
  return self.playersMap[playerId]
end

function PokeGame:setNextPlayerById(nextPlayerId)
  return self:setNextPlayer(self:getPlayerInfo(nextPlayerId))
end

function PokeGame:setNextPlayer(nextPlayer)
  self.currentPlayer = nextPlayer
  return self.currentPlayer
end

function PokeGame:getNextPlayer(curPlayer)
  curPlayer = curPlayer or self.currentPlayer
  local index = table.indexOf(self.playersInfo, curPlayer)
  index = (index + 1) % 3
  if index == 0 then
    index = 3
  end
  return self.playersInfo[index]
end

function PokeGame:getPrevPlayer(curPlayer)
  curPlayer = curPlayer or self.currentPlayer
  local index = table.indexOf(self.playersInfo, curPlayer)
  index = (index - 1)
  if index == 0 then
    index = 3
  end
  return self.playersInfo[index]
end

function PokeGame:setToNextPlayer()
  self.currentPlayer = self:getNextPlayer()
  return self.currentPlayer
end

return PokeGame
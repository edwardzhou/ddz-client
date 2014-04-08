--local PokeCard = require('PokeCard')
local PokeGame = class('PokeGame')

function PokeGame:ctor(playersInfo)
  self.playersInfo = playersInfo
  self.playersInfo[1].nextPlayer = self.playersInfo[2]
  self.playersInfo[1].prevPlayer = self.playersInfo[3]
  self.playersInfo[2].nextPlayer = self.playersInfo[3]
  self.playersInfo[2].prevPlayer = self.playersInfo[1]
  self.playersInfo[3].nextPlayer = self.playersInfo[1]
  self.playersInfo[3].prevPlayer = self.playersInfo[2]
  self.currentPlayer = self.playersInfo[math.random(3)]
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
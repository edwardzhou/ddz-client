--local PokeCard = require('PokeCard')
local PokeGame = class('PokeGame')

function PokeGame:ctor(playersInfo)
  self.playersInfo = playersInfo
  self:arrangePokeCards()
end

function PokeGame:arrangePokeCards()
    local p1, p2, p3, lordPokeCards = PokeCard.slicePokeCards()
    self.playersInfo[1].pokeCards = p1
    self.playersInfo[2].pokeCards = p2
    self.playersInfo[3].pokeCards = p3
    self.lordPokeCards = lordPokeCards

    if self.playersInfo[1].role == ddz.PlayerRoles.Lord then
      table.append(self.playersInfo[1].pokeCards, self.lordPokeCards)
      table.sort(self.playersInfo[1].pokeCards, sortDescBy('index'))
    elseif self.playersInfo[2].role == ddz.PlayerRoles.Lord then
      table.append(self.playersInfo[2].pokeCards, self.lordPokeCards)
      table.sort(self.playersInfo[2].pokeCards, sortDescBy('index'))
    else
      table.append(self.playersInfo[3].pokeCards, self.lordPokeCards)
      table.sort(self.playersInfo[3].pokeCards, sortDescBy('index'))
    end
end

return PokeGame
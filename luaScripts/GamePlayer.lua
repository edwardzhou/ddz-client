local GamePlayer = class('GamePlayer')

function GamePlayer:ctor(playerInfo)
  playerInfo = playerInfo or {}
  self.name = playerInfo.name
  self.userId = playerInfo.userId
  if playerInfo.pokeCards then
    self.pokeCards = playerInfo.pokeCards
  elseif playerInfo.pokeIdChars then
    self.pokeCards = PokeCard.getByPokeChars(playerInfo.pokeIdChars)
  else
    self.pokeCards = {}
  end
  self.headIcon = playerInfo.headIcon
  self.role = playerInfo.role
  self.status = playerInfo.status
end

return GamePlayer
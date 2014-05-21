local CardAnalyzer = require('CardAnalyzer')

local GamePlayer = class('GamePlayer')

function GamePlayer:ctor(playerInfo)
  playerInfo = playerInfo or {}
  self.nickName = playerInfo.nickName
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
  self.state = playerInfo.state
  self.robot = playerInfo.robot or false
end

function GamePlayer:isFarmer()
  return self.role == ddz.PlayerRoles.Farmer
end

function GamePlayer:isLord()
  return self.role == ddz.PlayerRoles.Lord
end

function GamePlayer:analyzePokecards()
  self.analyzedCards = CardAnalyzer.analyze(self.pokeCards)
  -- if self.cardAnalyzer == nil then
  --   self.cardAnalyzer = CardAnalyzer.new(self.pokeCards)
  -- else
  --   self.cardAnalyzer:setPokecards(self.pokeCards)
  -- end

  -- self.cardAnalyzer:analyze()

end


return GamePlayer
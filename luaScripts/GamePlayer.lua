local CardAnalyzer = require('CardAnalyzer')

local GamePlayer = class('GamePlayer')

function GamePlayer:ctor(playerInfo)
  self.pokeCards = {}
  self.headIcon = nil
  self:init(playerInfo)
end

function GamePlayer:init(playerInfo)
  playerInfo = playerInfo or {}
  self.nickName = playerInfo.nickName or self.nickName
  self.userId = playerInfo.userId or self.userId
  if playerInfo.pokeCards then
    self.pokeCards = playerInfo.pokeCards
  elseif playerInfo.pokeIdChars then
    self.pokeCards = PokeCard.getByPokeChars(playerInfo.pokeIdChars)
    table.sort(self.pokeCards, sortDescBy('index'))
  end
  self.pokeCount = playerInfo.pokeCount or self.pokeCount
  self.headIcon = playerInfo.headIcon or self.headIcon
  self.role = playerInfo.role or self.role
  self.state = playerInfo.state or self.state
  self.robot = playerInfo.robot or self.robot
end

function GamePlayer:isFarmer()
  return self.role == ddz.PlayerRoles.Farmer
end

function GamePlayer:isLord()
  return self.role == ddz.PlayerRoles.Lord
end

function GamePlayer:setPokeIdChars(chars)
  self.pokeCards = PokeCard.getByPokeChars(chars)
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
--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

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
  self.gender = playerInfo.gender or self.gender
  self.role = playerInfo.role or self.role
  self.state = playerInfo.state or self.state
  self.robot = playerInfo.robot or self.robot
end

function GamePlayer:isFarmer()
  -- print('[GamePlayer:isFarmer] self.role:' , self.role, ', ddz.PlayerRoles.Lord:' , ddz.PlayerRoles.Farmer)
  return self.role == ddz.PlayerRoles.Farmer
end

function GamePlayer:isLord()
  -- print('[GamePlayer:isLord] self.role:' , self.role, ', ddz.PlayerRoles.Lord:' , ddz.PlayerRoles.Lord)
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
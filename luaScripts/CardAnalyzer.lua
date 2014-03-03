require 'CardUtility'

CardAnalyzer = class('CardAnalyzer')

function CardAnalyzer:ctor(pokeCards)
  self.pokeCards = table.dup(pokeCards)
  self.orgPokeCards = table.dup(pokeCards)
--  self.bombsInfos = CardUtility.getBombsInfos(self.pokeInfos)
--  self.pairsInfos = CardUtility.getPairsInfos(self.pokeInfos)
--  self.threesInfos = CardUtility.getThreesInfos(self.pokeInfos)
--  self.singlesInfos = CardUtility.getSinglesInfos(self.pokeInfos)
--  self.rocketInfos = CardUtility.getRocketInfos(self.pokeInfos)
end

function CardAnalyzer:analyze()
  self.availCards = {}
  self.cardInfos = CardUtility.getPokeCardsInfo(self.pokeCards)
  
  self:extractRocket()
  self:extractBombs()
  self:extractThreesStraights()
  self:extractThrees()
  self:extractStraights()
end

function CardAnalyzer:extractRocket()
  local found = false
  if #(self.cardInfos.rocketInfos) > 0 then
    table.insert(self.availCards, Card.create(self.cardInfos.rocketInfos[1].pokeCards))
    found = true
  end
  
  if found then
    table.removeItems(self.pokeCards, self.cardInfos.rocketInfos[1].pokeCards)
    self.cardInfos = CardUtility.getPokeCardsInfo(self.pokeCards)
  end  
end

function CardAnalyzer:extractBombs()
  local bombsInfos = self.cardInfos.BombsInfos
  local found = false
  for _, pokeInfo in pairs(bombsInfos) do
    table.insert(self.availCards, Card.create(pokeInfo.pokeCards))
    table.removeItems(self.pokeCards, pokeInfo.pokeCards)
    found = true
  end
  
  if found then
    self.cardInfos = CardUtility.getPokeCardsInfo(self.pokeCards)
  end
end

function CardAnalyzer:extractThreesStraights()
  local threesInfos = self.cardInfos.threesInfos
  local threesCount = #threesInfos
  if threesCount < 2 then
    return
  end
  
  local startIndex = 1
  local endIndex
  local found = false
  while startIndex <= threesCount do
    for endIndex = startIndex+1, threesCount do
    end
  end
  
end

function CardAnalyzer:extractThrees()
end

function CardAnalyzer:extractStraights()
end

function CardAnalyzer:dump(level)
  level = level or 3
--  dump(self.cardInfos.indexedPokeCards, 'pokeInfos', false, level)
--  dump(self.cardInfos.rocketInfos, 'rocketInfos', false, level)
--  dump(self.cardInfos.bombsInfos, 'bombsInfos', false, level)
--  dump(self.cardInfos.threesInfos, 'threesInfos', false, level)
--  dump(self.cardInfos.pairsInfos, 'pairsInfos', false, level)
--  dump(self.cardInfos.singlesInfos, 'singlesInfos', false, level)

  for _, card in pairs(self.availCards) do
    print(card:toString())
  end

end
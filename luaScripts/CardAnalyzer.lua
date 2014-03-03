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
  --dump(self.cardInfos.rocketInfos, 'self.cardInfos.rocketInfos')
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
  local bombsInfos = self.cardInfos.bombsInfos
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
    endIndex = startIndex + 1
    local lastIndex = 0
    while endIndex <= threesCount do
      local valueChars = ''
      local card
      for i = startIndex, endIndex do
        valueChars = valueChars .. PokeCard.getPokeValuesChars(threesInfos[i].pokeCards)
      end
      card = allCardTypes[valueChars]
      if card == nil or card.cardType ~= CardType.THREE_STRAIGHT then
        break
      end
      
      lastIndex = endIndex
      endIndex = endIndex + 1
    end
    
    if lastIndex > 0 then
      local tmpPokeCards = {}
      for i = startIndex, lastIndex do
        table.append(tmpPokeCards, threesInfos[i].pokeCards)
      end
      table.insert(self.availCards, Card.create(tmpPokeCards))
      table.removeItems(self.pokeCards, tmpPokeCards)
      startIndex = lastIndex + 1
      found = true
    else
      startIndex = startIndex + 1      
    end    
  end
  
  if found then
    self.cardInfos = CardUtility.getPokeCardsInfo(self.pokeCards)
  end  
end

function CardAnalyzer:extractThrees()
  local threesInfos = self.cardInfos.threesInfos
  local threesCount = #threesInfos
  if threesCount < 1 then
    return
  end
  
  local found = false
  
  for _, pokeInfo in pairs(threesInfos) do
    table.insert(self.availCards, Card.create(pokeInfo.pokeCards))
    table.removeItems(self.pokeCards, pokeInfo.pokeCards)
    found = true
  end
  
  if found then
    self.cardInfos = CardUtility.getPokeCardsInfo(self.pokeCards)
  end
end

function CardAnalyzer:extractStraights()
  local pokeCards = self.pokeCards

  local straights = {}
  local indexedPokeCards = self.cardInfos.indexedPokeCards  
  local count = #indexedPokeCards
  
  print('count = ', count)
  dump(indexedPokeCards)
  
  while count >= 5 do
    local found = false
    for i=1, count-5 do
      local valuesChars = table.tableFromField(indexedPokeCards, 'pokeValueChar', i, i + 4)
      valuesChars = table.concat(valuesChars)
      print('CardAnalyzer:extractStraights: valuesChars = ', valuesChars)
      local card = allCardTypes[valuesChars]
      if card and card.cardType == CardType.STRAIGHT then
        local tmpPokeCards = {}
        for x=i, i+4 do
          table.insert(tmpPokeCards, indexedPokeCards[x].pokeCards[1])
        end
        table.insert(straights, Card.create(tmpPokeCards))
        table.removeItems(self.pokeCards, tmpPokeCards)
        self.cardInfos = CardUtility.getPokeCardsInfo(self.pokeCards)
        indexedPokeCards = self.cardInfos.indexedPokeCards
        count = #indexedPokeCards
        found = true        
      end
    end
    if not found then
      break
    end 
  end

  local i = #straights
  while i >=2 do 
    local card1 = straights[i]
    local card2 = straights[i-1]
    if card1:equals(card2) then
      local tmpPokeCards = {}
      table.append(tmpPokeCards, card1.pokeCards)
      table.append(tmpPokeCards, card2.pokeCards)
      table.sort(tmpPokeCards, sortAscBy('index'))
      straights[i-1] = Card.create(tmpPokeCards)
      table.remove(straights, i)
      i = i - 1
    end
    i = i - 1
  end
  
  if #straights > 0 then
    table.append(self.availCards, straights)
  end
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
  
  --dump(self.pokeCards)
  local remaining = table.tableFromField(self.pokeCards, 'valueChar')
  print('remaining: ' , table.concat(remaining, ', ')) 
  
end
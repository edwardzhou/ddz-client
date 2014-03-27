require 'CardUtility'

local CardAnalyzer = class('CardAnalyzer')

function CardAnalyzer:ctor(pokeCards)
  self:setPokecards(pokeCards)
end

function CardAnalyzer:setPokecards(pokeCards)
  self.pokeCards = table.dup(pokeCards)
  self.orgPokeCards = table.dup(pokeCards)
end

local function sumWegiht(cards)
  local weight = 0
  --dump(cards)
  for _, card in pairs(cards) do
    weight = weight + card.weight
  end
  return weight
end

function CardAnalyzer.analyze(pokeCards)
  print('[CardAnalyzer.analyze] start ---------------------')
  print('[CardAnalyzer.analyze] pokeCards: ' , PokeCard.getPokeValuesChars(pokeCards))

  local results = {}

  -- print('[CardAnalyzer.analyze] CardUtility.getPokeCardsInfo start')
  local cardInfos = CardUtility.getPokeCardsInfo(pokeCards)
  -- print('[CardAnalyzer.analyze] CardUtility.getPokeCardsInfo end')
  -- print('[CardAnalyzer.analyze] cardInfos:clone start')
  results.cardInfos = cardInfos:clone()
  -- print('[CardAnalyzer.analyze] cardInfos:clone end')

  local params = {
    cardInfos = cardInfos, 
    pokeCards = table.dup(pokeCards)
  }

  results.rocketCards = CardAnalyzer.extractRocket(params)
  results.bombsCards = CardAnalyzer.extractBombs(params)
  results.threesStraightsCards = CardAnalyzer.extractThreesStraights(params)
  results.threesCards = CardAnalyzer.extractThrees(params)
  results.straightsCards = CardAnalyzer.extractStraights(params)
  results.pairsStraightsCards = CardAnalyzer.extractPairsStraights(params)
  results.pairsCards = CardAnalyzer.extractPairs(params)
  results.singlesCards = CardAnalyzer.extractSingles(params)

  results.totalWeight = 0
  results.totalWeight = results.totalWeight + sumWegiht(results.rocketCards)
  results.totalWeight = results.totalWeight + sumWegiht(results.bombsCards)
  results.totalWeight = results.totalWeight + sumWegiht(results.threesStraightsCards)
  results.totalWeight = results.totalWeight + sumWegiht(results.threesCards)
  results.totalWeight = results.totalWeight + sumWegiht(results.straightsCards)
  results.totalWeight = results.totalWeight + sumWegiht(results.pairsStraightsCards)
  results.totalWeight = results.totalWeight + sumWegiht(results.pairsCards)
  results.totalWeight = results.totalWeight + sumWegiht(results.singlesCards)

  results.totalHands = 0
  results.totalHands = results.totalHands + #results.rocketCards
  results.totalHands = results.totalHands + #results.bombsCards
  results.totalHands = results.totalHands + #results.threesStraightsCards
  results.totalHands = results.totalHands + #results.threesCards
  results.totalHands = results.totalHands + #results.straightsCards
  results.totalHands = results.totalHands + #results.pairsStraightsCards
  results.totalHands = results.totalHands + #results.pairsCards
  results.totalHands = results.totalHands + #results.singlesCards

  local threesCardsCount = #results.threesCards
  local singlesCardsCount = #results.singlesCards
  local pairsCardsCount = #results.pairsCards

  if threesCardsCount > 0 then
    if singlesCardsCount >= threesCardsCount then
      results.totalHands = results.totalHands - threesCardsCount
    else
      local leftHands = threesCardsCount - singlesCardsCount
      if pairsCardsCount >= leftHands then
        results.totalHands = results.totalHands - threesCardsCount
      else
        results.totalHands = results.totalHands - (singlesCardsCount + pairsCardsCount)
      end
    end
  end

  print('[CardAnalyzer.analyze] end ************')
  return results
end

function CardAnalyzer.extractRocket(params)
  local found = false
  local result = {}
  --dump(self.cardInfos.rocketInfos, 'self.cardInfos.rocketInfos')
  if #(params.cardInfos.rocketInfos) > 0 then
    local rocketCard = Card.create(params.cardInfos.rocketInfos[1].pokeCards)
    table.insert(result, rocketCard)
    found = true
  end
  
  if found then
    table.removeItems(params.pokeCards, params.cardInfos.rocketInfos[1].pokeCards)
    params.cardInfos = CardUtility.getPokeCardsInfo(params.pokeCards)
  end
  return result
end

function CardAnalyzer.extractBombs(params)
  local bombsInfos = params.cardInfos.bombsInfos
  local found = false
  local result = {}
  for _, pokeInfo in pairs(bombsInfos) do
    local bombCard = Card.create(pokeInfo.pokeCards)
    table.insert(result, bombCard)
    table.removeItems(params.pokeCards, pokeInfo.pokeCards)
    found = true
  end
  
  if found then
    params.cardInfos = CardUtility.getPokeCardsInfo(params.pokeCards)
  end
  return result
end

function CardAnalyzer.extractThreesStraights(params)
  local result = {}
  local threesInfos = params.cardInfos.threesInfos
  local threesCount = #threesInfos
  if threesCount < 2 then
    return result
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
      table.insert(result, Card.create(tmpPokeCards))
      table.removeItems(params.pokeCards, tmpPokeCards)
      startIndex = lastIndex + 1
      found = true
    else
      startIndex = startIndex + 1      
    end    
  end
  
  if found then
    params.cardInfos = CardUtility.getPokeCardsInfo(params.pokeCards)
  end
  return result
end

function CardAnalyzer.extractThrees(params)
  local result = {}
  local threesInfos = params.cardInfos.threesInfos
  local threesCount = #threesInfos
  if threesCount < 1 then
    return result
  end
  
  local found = false
  
  for _, pokeInfo in pairs(threesInfos) do
    table.insert(result, Card.create(pokeInfo.pokeCards))
    table.removeItems(params.pokeCards, pokeInfo.pokeCards)
    found = true
  end
  
  if found then
    params.cardInfos = CardUtility.getPokeCardsInfo(params.pokeCards)
  end
  return result
end

function CardAnalyzer.extractStraights(params)
  local pokeCards = params.pokeCards

  local result = {}
  local straights = {}
  local indexedPokeCards = params.cardInfos.indexedPokeCards  
  local count = #indexedPokeCards
  
  --print('count = ', count)
  --dump(indexedPokeCards)
  
  while count >= 5 do
    local found = false
    for i=1, count-5 do
      local valuesChars = table.tableFromField(indexedPokeCards, 'pokeValueChar', i, i + 4)
      valuesChars = table.concat(valuesChars)
      -- print('CardAnalyzer:extractStraights: valuesChars = ', valuesChars)
      local card = allCardTypes[valuesChars]
      if card and card.cardType == CardType.STRAIGHT then
        local tmpPokeCards = {}
        for x=i, i+4 do
          table.insert(tmpPokeCards, indexedPokeCards[x].pokeCards[1])
        end
        table.insert(straights, Card.create(tmpPokeCards))
        table.removeItems(params.pokeCards, tmpPokeCards)
        params.cardInfos = CardUtility.getPokeCardsInfo(params.pokeCards)
        indexedPokeCards = params.cardInfos.indexedPokeCards
        count = #indexedPokeCards
        found = true
        break        
      end
    end
    if not found then
      break
    end 
  end
  
  -- 扩展顺子
  for i=1, #straights do
    local card = straights[i]
    local tmpPokeCards = table.dup(card.pokeCards)
    local found = false
    for j=1, #params.cardInfos.indexedPokeCards do
      local pokeInfo = params.cardInfos.indexedPokeCards[j]
      local tmpPokeCardsBak = table.dup(tmpPokeCards)
      if pokeInfo.pokeValue < card.minPokeValue then
        table.insert(tmpPokeCards, 1, pokeInfo.pokeCards[1])
      else
        table.insert(tmpPokeCards, pokeInfo.pokeCards[1])
      end
      local valuesChars = PokeCard.getPokeValuesChars(tmpPokeCards)
      local tmpCardType = allCardTypes[valuesChars]
      if tmpCardType and tmpCardType.cardType == CardType.STRAIGHT then
        straights[i] = Card.create(tmpPokeCards)
        table.removeItem(params.pokeCards, pokeInfo.pokeCards[1])
        found = true
      else
        tmpPokeCards = tmpPokeCardsBak
      end
    end
    if found then
      params.cardInfos = CardUtility.getPokeCardsInfo(params.pokeCards)
    end
  end
  
  -- 合并单顺
  for i=#straights, 2, -1 do
    local card1 = straights[i]
    local card2 = straights[i-1]
    if card1.minPokeValue - 1 == card2.maxPokeValue then
      local tmpPokeCards = table.dup(card2.pokeCards)
      table.append(tmpPokeCards, card1.pokeCards)
      straights[i-1] = Card.create(tmpPokeCards)
      table.remove(straights, i)
    end
  end
  
  -- 合并双顺
  local i = #straights
  while i >=2 do 
    local card1 = straights[i]
    local card2 = straights[i-1]
    if card1:equals(card2) then
      local tmpPokeCards = {}
      table.append(tmpPokeCards, card1.pokeCards)
      table.append(tmpPokeCards, card2.pokeCards)
      table.sort(tmpPokeCards, sortAscBy('index'))
      table.insert(result, Card.create(tmpPokeCards))
      table.remove(straights, i)
      table.remove(straights, i-1)
      i = i - 1
    end
    i = i - 1
  end
  
  if #straights > 0 then
    table.append(result, straights)
  end
  return result
end

function CardAnalyzer.extractPairsStraights(params)
  local result = {}
  local pairsInfos = params.cardInfos.pairsInfos
  local pairsCount = #pairsInfos
  if pairsCount < 2 then
    return result
  end
  
  local startIndex = 1
  local endIndex
  local found = false
  while startIndex <= pairsCount - 2 do
    endIndex = startIndex + 2
    local lastIndex = 0
    while endIndex <= pairsCount do
      local valueChars = ''
      local card
      for i = startIndex, endIndex do
        valueChars = valueChars .. PokeCard.getPokeValuesChars(pairsInfos[i].pokeCards)
      end
      card = allCardTypes[valueChars]
      if card == nil or card.cardType ~= CardType.PAIRS_STRAIGHT then
        break
      end
      
      lastIndex = endIndex
      endIndex = endIndex + 1
    end
    
    if lastIndex > 0 then
      local tmpPokeCards = {}
      for i = startIndex, lastIndex do
        table.append(tmpPokeCards, pairsInfos[i].pokeCards)
      end
      table.insert(result, Card.create(tmpPokeCards))
      table.removeItems(params.pokeCards, tmpPokeCards)
      startIndex = lastIndex + 1
      found = true
    else
      startIndex = startIndex + 1      
    end    
  end
  
  if found then
    params.cardInfos = CardUtility.getPokeCardsInfo(params.pokeCards)
  end
  return result
end

function CardAnalyzer.extractPairs(params)
  local found = false
  local result = {}
  
  for _, pokeInfo in pairs(params.cardInfos.pairsInfos) do
    table.insert(result, Card.create(pokeInfo.pokeCards))
    table.removeItems(params.pokeCards, pokeInfo.pokeCards)
    found = true
  end
  
  if found then
    params.cardInfos = CardUtility.getPokeCardsInfo(params.pokeCards)
  end
  return result
end

function CardAnalyzer.extractSingles(params)
  local tmpPokeCards = {}
  local result = {}
  
  for _, pokeInfo in pairs(params.cardInfos.singlesInfos) do
    table.insert(result, Card.create(pokeInfo.pokeCards))
    table.append(tmpPokeCards, pokeInfo.pokeCards)
  end
  
  table.removeItems(params.pokeCards, tmpPokeCards)  
  return result
end

function CardAnalyzer.getMaxAvailStraights(params)
  local straights = {}
  local index = 1
  local indexedPokeCards = params.indexedPokeCards 
  while index < #indexedPokeCards - 5 do
    local indexEnd = index
    local tempStraight = {}
    while indexEnd < #indexedPokeCards do
      if indexedPokeCards[indexEnd].pokeValue == indexedPokeCards[indexEnd+1].pokeValue - 1 then
        table.insert(tempStraight, indexedPokeCards[indexEnd])
      else
        if indexedPokeCards[indexEnd].pokeValue == indexedPokeCards[indexEnd-1].pokeValue + 1 then
          table.insert(tempStraight, indexedPokeCards[indexEnd])
        end
        break
      end
      indexEnd = indexEnd + 1
    end
    if #tempStraight >= 5 then
      index = indexEnd + 1
      table.insert(straights, tempStraight)
    else
      index = index + 1
    end
  end

  return straights
end

function CardAnalyzer.filterCards(cards, cardType)
  local tmpCards = {}
  for _, card in pairs(cards) do
    if card.cardType == cardType then
      table.insert(tmpCards, card)
    end
  end

  table.sort(tmpCards, sortAscBy('maxPokeValue'))
  return tmpCards  
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

function CardAnalyzer.dumpResults(results, level)
  level = level or 3
  for cardsName, cards in pairs(results) do
    if type(cards) == 'table' then
      print('------------------ ' .. cardsName .. ' ------------------' )
      for _, card in pairs(cards) do
        print(card:toString())
      end
    end
  end
  print('totalWeight: ', results.totalWeight, ',   totalHands: ', results.totalHands)
end

return CardAnalyzer
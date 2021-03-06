--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

CardUtility = class('CardUtility')

PokeCardInfo = class('PokeCardInfo')
-- PokeCardInfo = {}
-- PokeCardInfo.__index = PokeCardInfo
-- function PokeCardInfo.new(pokes)
--   local newObj = {}
--   setmetatable(newObj, PokeCardInfo)
--   --newObj.__index = PokeCardInfo
--   if newObj.ctor then
--     newObj:ctor(pokes)
--   end
--   return newObj
-- end

function PokeCardInfo:ctor(pokes)
  local pokeCards = table.copy(pokes)
  self.pokeCards = pokeCards
  self.pokeValue = pokeCards[1].value
  self.pokeValueChar = pokeCards[1].valueChar
  self.pokeCount = #pokeCards
  
  return self
end

function PokeCardInfo:push(pokeCard)
  table.insert(self.pokeCards, pokeCard)
  self.pokeCount = #(self.pokeCards)
  return self
end

function PokeCardInfo:clone()
  local newObj = PokeCardInfo.new(self.pokeCards)
  return newObj
end

CardInfo = class('CardInfo')
-- CardInfo = {}
-- CardInfo.__index = CardInfo
-- function CardInfo.new(opts)
--   local newObj = {}
--   setmetatable(newObj, CardInfo)
--   --newObj.__index = PokeCardInfo
--   if newObj.ctor then
--     newObj:ctor(opts)
--   end
--   return newObj  
-- end

function CardInfo:ctor(opts)
  local pokeCards = {}
  table.merge(pokeCards, opts.pokeCards)
  --table.sort(pokeCards, sortAscBy('index'))
  self.pokeCards = pokeCards
  self.valuedPokeCards = nil
  self.indexedPokeCards = nil
end

function CardInfo:clone()
  local newCardInfo = CardInfo.new({pokeCards = self.pokeCards})
  newCardInfo.valuedPokeCards = {}
  newCardInfo.indexedPokeCards = {}
  for k, v in pairs(self.valuedPokeCards) do
    newCardInfo.valuedPokeCards[k] = v:clone()
  end
  for _, v in pairs(newCardInfo.valuedPokeCards) do
    table.insert(newCardInfo.indexedPokeCards, v)
  end
  return newCardInfo
end

function CardUtility.getPokeCardsInfo(pokeCards)
  -- print('[CardUtility.getPokeCardsInfo] clone and sort pokeCards')
  local tmpPokeCards = {}
  table.merge(tmpPokeCards, pokeCards)
  table.sort(tmpPokeCards, sortAscBy('index'))
  
  -- print('[CardUtility.getPokeCardsInfo] build valuedPokeCards')
  local infos = {}
  local pokeInfo
  for _, pokeCard in pairs(tmpPokeCards) do
    pokeInfo = infos[pokeCard.value]
    if pokeInfo == nil then
      infos[pokeCard.value] = PokeCardInfo.new({pokeCard})
    else
      pokeInfo:push(pokeCard)
    end
  end
  
  -- print('[CardUtility.getPokeCardsInfo] build indexedPokeCards')
  local tmp = {}
  for _, pokeInfo in pairs(infos) do
    table.insert(tmp, pokeInfo)
  end
  table.sort(tmp, sortAscBy('pokeValue'))
  
  -- print('[CardUtility.getPokeCardsInfo] build card info')
  local cardInfo = CardInfo.new({pokeCards = tmpPokeCards})
  cardInfo.valuedPokeCards = infos
  cardInfo.indexedPokeCards = tmp
  
  cardInfo.bombsInfos = CardUtility.getBombsInfos(tmp)
  cardInfo.threesInfos = CardUtility.getThreesInfos(tmp)
  cardInfo.pairsInfos = CardUtility.getPairsInfos(tmp)
  cardInfo.singlesInfos = CardUtility.getSinglesInfos(tmp)
  cardInfo.rocketInfos = CardUtility.getRocketInfos(tmp)
  
  -- print('[CardUtility.getPokeCardsInfo] end')
  return cardInfo
end

function CardUtility.extractSinglePokecards(pokeInfos, startIndex, length)
  local pokecards = {}
  if startIndex + length > #pokeInfos + 1 then
    return pokecards
  end

  for index = startIndex, startIndex + length - 1 do
    table.insert(pokecards, pokeInfos[index].pokeCards[1])
  end

  return pokecards
end

function CardUtility.isPokeInfoStraight(pokeInfos, startIndex, length)
  if not startIndex then
    startIndex = 1
  end
  
  if not length then
    length = #pokeInfos
  end

  local pokecards = CardUtility.extractSinglePokecards(pokeInfos, startIndex, startIndex + length - 1)
  if #pokecards == 0 then
    return false
  end

  local card = Card.create(pokecards)
  return card.cardType == CardType.STRAIGHT
end

function CardUtility.isStraight(pokecards)
  local card = Card.create(pokecards)
  return card.cardType == CardType.STRAIGHT
end

function CardUtility.isPairsStraight(pokecards)
  local card = Card.create(pokecards)
  return card.cardType == CardType.PAIRS_STRAIGHT
end

function CardUtility.isThreesStraight(pokecards)
  local card = Card.create(pokecards)
  return card.cardType == CardType.THREE_STRAIGHT
end

function CardUtility.getBombsInfos(pokeInfos)
  local infos = {}
  for _, pokeInfo in pairs(pokeInfos) do
    if pokeInfo.pokeCount == 4 then
      table.insert(infos, pokeInfo)
    end
  end
  
  return infos
end

function CardUtility.getThreesInfos(pokeInfos, exclude4)
  local infos = {}
  for _, pokeInfo in pairs(pokeInfos) do
    if not exclude4 and pokeInfo.pokeCount >= 3 then
      table.insert(infos, pokeInfo)
    elseif pokeInfo.pokeCount == 3 then
      table.insert(infos, pokeInfo)
    end
  end
  
  return infos
end

function CardUtility.getPairsInfos(pokeInfos, exclude3_4)
  local infos = {}
  for _, pokeInfo in pairs(pokeInfos) do
    if not exclude3_4 and pokeInfo.pokeCount >= 2 then
      table.insert(infos, pokeInfo)
    elseif pokeInfo.pokeCount == 2 then
      table.insert(infos, pokeInfo)
    end
  end
  
  return infos  
end

function CardUtility.getSinglesInfos(pokeInfos, excludeWw)
  local infos = {}
  for _, pokeInfo in pairs(pokeInfos) do
    if pokeInfo.pokeCount == 1 then
      table.insert(infos, pokeInfo)
    end
  end
  
  return infos  
end

function CardUtility.getRocketInfos(pokeInfos)
  local infos = {}
  local count = #pokeInfos
  if count >= 2 and pokeInfos[count].pokeValue == PokeCardValue.BIG_JOKER and
      pokeInfos[count-1].pokeValue == PokeCardValue.SMALL_JOKER then
    local newInfo = pokeInfos[count]:clone()
    newInfo:push(pokeInfos[count-1].pokeCards[1])
    table.insert(infos, newInfo)
  end
--  dump(pokeInfos, ' CardUtility.getRocketInfos')
--  dump(count, ' CardUtility.getRocketInfos')
--  dump(pokeInfos[count], ' CardUtility.getRocketInfos')
--  dump(pokeInfos[count-1], ' CardUtility.getRocketInfos')
  
  return infos
end
CardUtility = class('CardUtility')

PokeCardInfo = class('PokeCardInfo')
function PokeCardInfo:ctor(...)
  local pokeCards = {...}
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
  local newObj = PokeCardInfo.new(unpack(self.pokeCards))
  return newObj
end

CardInfo = class('CardInfo')

function CardInfo:ctor(opts)
  local pokeCards = {}
  table.merge(pokeCards, opts.pokeCards)
  --table.sort(pokeCards, sortAscBy('index'))
  self.pokeCards = pokeCards
  self.valuedPokeInfo = nil
  self.indexedPokeInfo = nil
end


function CardUtility.getPokeCardsInfo(pokeCards)
  local tmpPokeCards = {}
  table.merge(tmpPokeCards, pokeCards)
  table.sort(tmpPokeCards, sortAscBy('index'))
  
  local infos = {}
  for _, pokeCard in pairs(tmpPokeCards) do
    if infos[pokeCard.value] == nil then
      infos[pokeCard.value] = PokeCardInfo.new(pokeCard)
    else
      infos[pokeCard.value]:push(pokeCard) 
    end
  end
  
  local tmp = {}
  for _, pokeInfo in pairs(infos) do
    table.insert(tmp, pokeInfo)
  end
  
  local cardInfo = CardInfo.new({pokeCards = tmpPokeCards})
  cardInfo.valuedPokeCards = infos
  cardInfo.indexedPokeCards = tmp
  
  cardInfo.bombsInfos = CardUtility.getBombsInfos(infos)
  cardInfo.threesInfos = CardUtility.getThreesInfos(infos)
  cardInfo.pairsInfos = CardUtility.getPairsInfos(infos)
  cardInfo.singlesInfos = CardUtility.getSinglesInfos(infos)
  cardInfo.rocketInfos = CardUtility.getRocketInfos(infos)
  
  return cardInfo
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
    if not exclude4 and pokeInfo.pokeCount >= 2 then
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
  if count > 2 and pokeInfos[count].pokeValue == PokeCardValue.BIG_JOKER and
      pokeInfos[count-1].pokeValue == PokeCardValue.SMALL_JOKER then
    local newInfo = pokeInfos[count]:clone()
    newInfo:push(pokeInfos[count-1].pokeCards[1])
    table.insert(infos, newInfo)
  end
  
  return infos
end
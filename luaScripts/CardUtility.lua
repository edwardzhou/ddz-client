CardUtility = class('CardUtility')

PokeCardInfo = class('PokeCardInfo')
function PokeCardInfo:ctor(...)
  local pokeCards = {...}
  self.pokeCards = pokeCards
  self.pokeValue = pokeCards[1].value
  self.pokeCount = #pokeCards
  
  return self
end

function PokeCardInfo:push(pokeCard)
  table.insert(self.pokeCards, pokeCard)
  self.pokeCount = #(self.pokeCards)
  return self
end

local function sortIndexAsc(a, b)
  return a.index < b.index
end

function CardUtility.getPokeCardsInfo(pokeCards)
  local tmpPokeCards = {}
  table.merge(tmpPokeCards, pokeCards)
  table.sort(tmpPokeCards, sortIndexAsc)
  
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
  
  return tmp
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

function CardUtility.getThreeInfos(pokeInfos, exclude4)
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

function CardUtility.getPairInfos(pokeInfos, exclude3_4)
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
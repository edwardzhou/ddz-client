local PokecardPickAI = class('PokecardPickAI')

--[[
  在选取的牌中查找大于lastCard的对子。
  1. 先在现有对子里面找, 无则
  2. 再在现有三张里面找, 无则
  3. 找炸弹，火箭
--]]
function findPairs(pickedPokecards, cardInfos, lastCard, tipPokecards)
  for index = 1, #cardInfos.pairsInfos do
    if cardInfos.pairsInfos[index].pokeValue > lastCard.maxPokeValue and cardInfos.pairsInfos[index].pokeCount == 2 then
      return table.copy(cardInfos.pairsInfos[index].pokeCards, 1, 2)
    end
  end
  for index = 1, #cardInfos.threesInfos do
    if cardInfos.threesInfos[index].pokeValue > lastCard.maxPokeValue and cardInfos.threesInfos[index].pokeCount == 3 then
      return table.copy(cardInfos.threesInfos[index].pokeCards, 1, 2)
    end
  end
  if #cardInfos.bombsInfos > 0 then
    return table.copy(cardInfos.bombsInfos[1].pokeCards, 1, 4)
  end

  if #cardInfos.rocketInfos > 0 then
    return table.copy(cardInfos.rocketInfos[1], 1, 2)
  end

  return nil
end

--[[
  在选取的牌中查找大于lastCard的三张。
  1. 在现有三张里面找, 无则
  2. 找炸弹，火箭
--]]
function findThree(pickedPokecards, cardInfos, lastCard, tipPokecards)
  for index = 1, #cardInfos.threesInfos do
    if cardInfos.threesInfos[index].pokeValue > lastCard.maxPokeValue and cardInfos.threesInfos[index].pokeCount == 3 then
      return table.copy(cardInfos.threesInfos[index].pokeCards, 1, 3)
    end
  end

  if #cardInfos.bombsInfos > 0 then
    return table.copy(cardInfos.bombsInfos[1].pokeCards, 1, 4)
  end

  if #cardInfos.rocketInfos > 0 then
    return table.copy(cardInfos.rocketInfos[1].pokeCards, 1, 2)
  end

  return nil
end

--[[
  在选取的牌中查找大于lastCard的三张带一。
  1. 在现有三张里面找
    1.1 找单张凑
    1.2 拆对子凑
    1.3 拆其他三张凑
  2. 找炸弹，火箭
--]]
function findThreeWithOne(pickedPokecards, cardInfos, lastCard, tipPokecards)
  for index = 1, #cardInfos.threesInfos do
    if cardInfos.threesInfos[index].pokeValue > lastCard.maxPokeValue and cardInfos.threesInfos[index].pokeCount == 3 then
      local pokes = table.copy(cardInfos.threesInfos[index].pokeCards, 1, 3)
      if #cardInfos.singlesInfos > 0 then
        table.insert(pokes, cardInfos.singlesInfos[1].pokeCards[1])
        return pokes
      end

      for i = 1,  #cardInfos.pairsInfos do
        if cardInfos.pairsInfos[i].pokeCount == 2 then
          table.insert(pokes, cardInfos.pairsInfos[i].pokeCards[1])
          return pokes
        end
      end

      for i = 1, #cardInfos.threesInfos do
        if cardInfos.threesInfos[i].pokeCount == 3 and index ~= i then
          table.insert(pokes, cardInfos.threesInfos[i].pokeCards[1])
        end
      end
    end
  end

  if #cardInfos.bombsInfos > 0 then
    return table.copy(cardInfos.bombsInfos[1].pokeCards, 1, 4)
  end

  if #cardInfos.rocketInfos > 0 then
    return table.copy(cardInfos.rocketInfos[1].pokeCards, 1, 2)
  end

  return nil
end

--[[
  在选取的牌中查找大于lastCard的三张带一对。
  1. 在现有三张里面找
    1.1 找单张凑
    1.2 拆对子凑
    1.3 拆其他三张凑
  2. 找炸弹，火箭
--]]
function findThreeWithPairs(pickedPokecards, cardInfos, lastCard, tipPokecards)
  for index = 1, #cardInfos.threesInfos do
    if cardInfos.threesInfos[index].pokeValue > lastCard.maxPokeValue and cardInfos.threesInfos[index].pokeCount == 3 then
      local pokes = table.copy(cardInfos.threesInfos[index].pokeCards, 1, 3)
      for i = 1,  #cardInfos.pairsInfos do
        if cardInfos.pairsInfos[i].pokeCount == 2 then
          table.insert(pokes, cardInfos.pairsInfos[i].pokeCards[1])
          table.insert(pokes, cardInfos.pairsInfos[i].pokeCards[2])
          return pokes
        end
      end

      for i = 1, #cardInfos.threesInfos do
        if cardInfos.threesInfos[i].pokeCount == 3 and index ~= i then
          table.insert(pokes, cardInfos.threesInfos[i].pokeCards[1])
          table.insert(pokes, cardInfos.threesInfos[i].pokeCards[2])
        end
      end
    end
  end

  if #cardInfos.bombsInfos > 0 then
    return table.copy(cardInfos.bombsInfos[1].pokeCards, 1, 4)
  end

  if #cardInfos.rocketInfos > 0 then
    return table.copy(cardInfos.rocketInfos[1].pokeCards, 1, 2)
  end

  return nil
end

--[[
  在选取的牌中查找大于lastCard的单顺。
  1. 找顺子
  2. 找炸弹，火箭
--]]
function findStraights(pickedPokecards, cardInfos, lastCard, tipPokecards)
  local lastCardLen = lastCard.cardLength 
  local endIndex =  #cardInfos.indexedPokeCards - lastCardLen + 1
  for index = 1, endIndex do
    if cardInfos.indexedPokeCards[index].pokeValue > lastCard.minPokeValue then
      local pokecards = CardUtility.extractSinglePokecards(cardInfos.indexedPokeCards, index, lastCardLen)
      if CardUtility.isStraight(pokecards) then
        return pokecards
      end
    end
  end
  
  if #cardInfos.bombsInfos > 0 then
    return table.copy(cardInfos.bombsInfos[1].pokeCards, 1, 4)
  end

  if #cardInfos.rocketInfos > 0 then
    return table.copy(cardInfos.rocketInfos[1].pokeCards, 1, 2)
  end

  return nil
end

--[[
  在选取的牌中查找大于lastCard的双顺。
  1. 找顺子
  2. 找炸弹，火箭
--]]
function findPairsStraights(pickedPokecards, cardInfos, lastCard, tipPokecards)
  local lastCardLen = lastCard.cardLength 
  local endIndex =  #cardInfos.pairsInfos - lastCardLen + 1
  for index = 1, endIndex do
    if cardInfos.pairsInfos[index].pokeValue > lastCard.minPokeValue then
      local pokecards = {}
      for i=index, index + lastCardLen - 1 do
        table.insert(pokecards, cardInfos.pairsInfos[i].pokeCards[1])
        table.insert(pokecards, cardInfos.pairsInfos[i].pokeCards[2])
      end
      if CardUtility.isPairsStraight(pokecards) then
        return pokecards
      end
    end
  end

  if #cardInfos.bombsInfos > 0 then
    return table.copy(cardInfos.bombsInfos[1].pokeCards, 1, 4)
  end

  if #cardInfos.rocketInfos > 0 then
    return table.copy(cardInfos.rocketInfos[1].pokeCards, 1, 2)
  end

  return nil
end

--[[
  在选取的牌中查找大于lastCard的三顺。
  1. 找顺子
  2. 找炸弹，火箭
--]]
function findThreesStraights(pickedPokecards, cardInfos, lastCard, tipPokecards)
  local lastCardLen = lastCard.cardLength 
  local endIndex =  #cardInfos.threesInfos - lastCardLen + 1
  for index = 1, endIndex do
    if cardInfos.threesInfos[index].pokeValue > lastCard.minPokeValue then
      local pokecards = {}
      for i=index, index + lastCardLen - 1 do
        table.insert(pokecards, cardInfos.threesInfos[i].pokeCards[1])
        table.insert(pokecards, cardInfos.threesInfos[i].pokeCards[2])
        table.insert(pokecards, cardInfos.threesInfos[i].pokeCards[3])
      end
      if CardUtility.isThreesStraight(pokecards) then
        return pokecards
      end
    end
  end

  if #cardInfos.bombsInfos > 0 then
    return table.copy(cardInfos.bombsInfos[1].pokeCards, 1, 4)
  end

  if #cardInfos.rocketInfos > 0 then
    return table.copy(cardInfos.rocketInfos[1].pokeCards, 1, 2)
  end

  return nil
end

--[[
  在选取的牌中查找大于lastCard的四带二。
  1. 找顺子
  2. 找炸弹，火箭
--]]
function findFourWithTwo(pickedPokecards, cardInfos, lastCard, tipPokecards)
  local lastCardLen = lastCard.cardLength 
  local endIndex =  #cardInfos.bombsInfos - lastCardLen + 1
  for index = 1, endIndex do
    if cardInfos.bombsInfos[index].pokeValue > lastCard.minPokeValue then
      local pokecards = {}
      local remainingPokecards = table.copy(pickedPokecards)
      table.append(pokecards, cardInfos.bombsInfos[index].pokeCards)
      table.removeItems(remainingPokecards, pokecards)
      if #remainingPokecards > 2 then
        local remainingCardInfos = CardUtility.getPokeCardsInfo(remainingPokecards)
        if #remainingCardInfos.singlesInfos > 1 then
          table.insert(pokecards, remainingCardInfos.singlesInfos[1].pokeCards[1])
          table.insert(pokecards, remainingCardInfos.singlesInfos[2].pokeCards[1])
          return pokecards
        elseif #remainingCardInfos.pairsInfos > 0 then
          if #remainingCardInfos.singlesInfos > 0 
            and remainingCardInfos.singlesInfos[1].pokeValue < remainingCardInfos.pairsInfos[1].pokeValue then
            table.insert(pokecards, remainingCardInfos.singlesInfos[1].pokeCards[1])
            table.insert(pokecards, remainingCardInfos.pairsInfos[1].pokeCards[1])
          else
            table.append(pokecards, remainingCardInfos.pairsInfos[1].pokeCards)
          end
          return pokecards
        elseif #remainingCardInfos.threesInfos > 0 then
          if #remainingCardInfos.singlesInfos > 0 then
            table.insert(pokecards, remainingCardInfos.singlesInfos[1].pokeCards[1])
            table.insert(pokecards, remainingCardInfos.threesInfos[1].pokeCards[1])
          else
            table.insert(pokecards, remainingCardInfos.threesInfos[1].pokeCards[1])
            table.insert(pokecards, remainingCardInfos.threesInfos[1].pokeCards[2])
          end
          return pokecards
        end
      end
    end
  end

  if #cardInfos.bombsInfos > 0 then
    return table.copy(cardInfos.bombsInfos[1].pokeCards, 1, 4)
  end

  if #cardInfos.rocketInfos > 0 then
    return table.copy(cardInfos.rocketInfos[1].pokeCards, 1, 2)
  end

  return nil
end


--[[
  在选取的牌中查找大于lastCard的四带二对。
  1. 找顺子
  2. 找炸弹，火箭
--]]
function findFourWithTwoPairs(pickedPokecards, cardInfos, lastCard, tipPokecards)
  local lastCardLen = lastCard.cardLength 
  local endIndex =  #cardInfos.bombsInfos - lastCardLen + 1
  for index = 1, endIndex do
    if cardInfos.bombsInfos[index].pokeValue > lastCard.minPokeValue then
      local pokecards = {}
      local remainingPokecards = table.copy(pickedPokecards)
      table.append(pokecards, cardInfos.bombsInfos[index].pokeCards)
      table.removeItems(remainingPokecards, pokecards)
      if #remainingPokecards >= 4 then
        local remainingCardInfos = CardUtility.getPokeCardsInfo(remainingPokecards)
        if #remainingCardInfos.pairsInfos > 1 then
          table.append(pokecards, remainingCardInfos.pairsInfos[1].pokeCards)
          table.append(pokecards, remainingCardInfos.pairsInfos[2].pokeCards)
          return pokecards
        elseif #remainingCardInfos.threesInfos > 1 then
          table.insert(pokecards, remainingCardInfos.threesInfos[1].pokeCards[1])
          table.insert(pokecards, remainingCardInfos.threesInfos[1].pokeCards[2])
          table.insert(pokecards, remainingCardInfos.threesInfos[2].pokeCards[1])
          table.insert(pokecards, remainingCardInfos.threesInfos[2].pokeCards[2])
          return pokecards
        end
      end
    end
  end

  if #cardInfos.bombsInfos > 0 then
    return table.copy(cardInfos.bombsInfos[1].pokeCards, 1, 4)
  end

  if #cardInfos.rocketInfos > 0 then
    return table.copy(cardInfos.rocketInfos[1].pokeCards, 1, 2)
  end

  return nil
end


function PokecardPickAI:findValidCard(pickedPokecards, lastCard, tipPokecards)
  -- 两张以下的，直接返回
  local count = #pickedPokecards
  if count == 0 or lastCard == nil then
    return nil
  end

  local pickedCard = Card.create(pickedPokecards)

  local cardInfos = CardUtility.getPokeCardsInfo(pickedPokecards)

  if lastCard then
    -- 选中的牌刚好比上一手大, 直接返回
    if pickedCard:isGreaterThan(lastCard) then
      return pickedPokecards
    end

    -- -- 如果选中的牌，数量没有上手多，返回nil
    -- if count < #lastCard.pokeCards then
    --   return nil
    -- end

    if lastCard.cardType == CardType.SINGLE then
      for index = 1, count do
        if pickedPokecards[index].value > lastCard.maxPokeValue then
          return {pickedPokecards[index]}
        end
      end

      return nil
    end

    if lastCard.cardType == CardType.PAIRS then
      return findPairs(pickedPokecards, cardInfos, lastCard, tipPokecards)
    end
 
    if lastCard.cardType == CardType.THREE then
      return findThree(pickedPokecards, cardInfos, lastCard, tipPokecards)
    end

    if lastCard.cardType == CardType.THREE_WITH_ONE then
      return findThreeWithOne(pickedPokecards, cardInfos, lastCard, tipPokecards)
    end

    if lastCard.cardType == CardType.THREE_WITH_PAIRS then
      return findThreeWithPairs(pickedPokecards, cardInfos, lastCard, tipPokecards)
    end
    
    if lastCard.cardType == CardType.STRAIGHT then
      return findStraights(pickedPokecards, cardInfos, lastCard, tipPokecards)
    end

    if lastCard.cardType == CardType.PAIRS_STRAIGHT then
      return findPairsStraights(pickedPokecards, cardInfos, lastCard, tipPokecards)
    end
    
    if lastCard.cardType == CardType.THREE_STRAIGHT then
      return findThreesStraights(pickedPokecards, cardInfos, lastCard, tipPokecards)
    end

    if lastCard.cardType == CardType.FOUR_WITH_TWO then
      return findFourWithTwo(pickedPokecards, cardInfos, lastCard, tipPokecards)
    end

    if lastCard.cardType == CardType.FOUR_WITH_TWO_PAIRS then
      return findFourWithTwoPairs(pickedPokecards, cardInfos, lastCard, tipPokecards)
    end
  end


end

return PokecardPickAI
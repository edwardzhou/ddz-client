local PokecardPickAI = class('PokecardPickAI')

function PokecardPickAI:findValidCard(pickedPokecards, lastCard, tipPokecards)
  -- 两张以下的，直接返回
  local count = #pickedPokecards
  if count <= 2 then
    return pickedPokecards
  end

  local pickedCard = Card.create(pickedPokecards)

  local cardInfos = CardUtility.getPokeCardsInfo(pickedPokecards)

  if lastCard then
    -- 选中的牌刚好比上一手大, 直接返回
    if pickedCard:isGreaterThan(lastCard) then
      return pickedPokecards
    end

    -- 如果选中的牌，数量没有上手多，返回nil
    if count < #lastCard.pokecards then
      return nil
    end

    if lastCard.cardType == CardType.SINGLE then
      for index = 1, count do
        if pickedPokecards[index].value > lastCard.maxPokeValue then
          return {pickedPokecards[index]}
        end
      end

      return nil
    end

    if lastCard.cardType == CardType.PAIRS then
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

    if lastCard.cardType == CardType.THREE then
      for index = 1, #cardInfos.threesInfos do
        if cardInfos.threesInfos[index].pokeValue > lastCard.maxPokeValue and cardInfos.threesInfos[index].pokeCount == 3 then
          return table.copy(cardInfos.threesInfos[index].pokeCards, 1, 3)
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

    if lastCard.cardType == CardType.THREE then
      for index = 1, #cardInfos.threesInfos do
        if cardInfos.threesInfos[index].pokeValue > lastCard.maxPokeValue and cardInfos.threesInfos[index].pokeCount == 3 then
          local pokes = table.copy(cardInfos.threesInfos[index].pokeCards, 1, 3)
          if #cardInfos.singlesInfos > 0 then
            table.append(pokes, cardInfos.singlesInfos[1])
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
        return table.copy(cardInfos.rocketInfos[1], 1, 2)
      end

      return nil
    end

  end


end

return PokecardPickAI
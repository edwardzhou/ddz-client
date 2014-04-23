local PokecardAI = class('PokecardAI')
local scheduler = require('framework.scheduler')

function PokecardAI:ctor(...)
end

function PokecardAI.grabLord(gameService, pokeGame, currentPlayer)
  scheduler.performWithDelayGlobal(
    function()
      local grabs = {ddz.Actions.GrabbingLord.None, ddz.Actions.GrabbingLord.Grab}
      local action = grabs[math.random(1000)%2 + 1]
      action = ddz.Actions.GrabbingLord.Grab
      gameService:grabLord(currentPlayer.userId, action)
    end, 
    math.random(2) - 0.5)
end

function PokecardAI.playCard(gameService, pokeGame, currentPlayer)
  -- local pokeCards = table.copy(currentPlayer.pokeCards, 1, 1)
  -- gameService:playCard(currentPlayer.userId, PokeCard.getIdChars(pokeCards))

  if currentPlayer:isLord() then
    local card = PokecardAI.getAICard(pokeGame, currentPlayer)
    print('player[id: ' .. currentPlayer.userId .. ' ] plays ' .. card:toString())
    gameService:playCard(currentPlayer.userId, PokeCard.getIdChars(card.pokeCards))
  else
    gameService:playCard(currentPlayer.userId, '')
  end

  do return end

  local analyzedCards = currentPlayer.analyzedCards

  if currentPlayer:isLord() then
    -- 当前玩家是地主
    if pokeGame.lastPlay == nil or pokeGame.lastPlay.player.userId == currentPlayer.userId then
      -- 上轮是自己或自己是第一个出牌
      if #analyzedCards.singlesStraightsCards then
      end

    else
      -- 上手牌是其他玩家
    end
  else
    -- 当前玩家是农民
    if pokeGame.lordPlayer.robot then
    else
    end
  end


  -- local pokeCards = table.copy(currentPlayer.pokeCards, 1, 1)
  -- gameService:playCard(currentPlayer.userId, PokeCard.getIdChars(pokeCards))
end

function PokecardAI.getAICard(pokeGame, currentPlayer, prevPlayer, nextPlayer)
  local card = nil
  local analyzedCards = currentPlayer.analyzedCards
  local straightsCount = #analyzedCards.straightsCards
  if straightsCount > 0 then
    local prevStraightsCount = #prevPlayer.analyzedCards.straightsCards
    local nextStraightsCount = #nextPlayer.analyzedCards.straightsCards
    local card = analyzedCards.straightsCards[1]
    if prevStraightsCount == 0 and nextStraightsCount == 0 and card.maxPokeValue <= PokeCardValue.QUEEN then
      return card
    end

    if card.minPokeValue == 3 then
      return card
    end

    local prevLastStraight = #prevPlayer.analyzedCards.straightsCards[prevStraightsCount]
    local nextLastStraight = #nextPlayer.analyzedCards.straightsCards[nextStraightsCount]

    local biggestStraightCard = analyzedCards.straightsCards[straightsCount]

    if card.maxPokeValue > PokeCardValue.QUEEN then
      if analyzedCards.totalHands <= 3 then
        return card
      end
    end

  end

  if #analyzedCards.pairsStraightsCards > 0 then
    return analyzedCards.pairsStraightsCards[1]
  end

  if #analyzedCards.threesStraightsCards > 0 then
    local card = analyzedCards.threesStraightsCards[1]
    local pokeCards = table.dup(card.pokeCards)
    local cardLength = card.cardLength
    if cardLength <= #analyzedCards.singlesCards then
      for i = 1, cardLength do
        table.append(pokeCards, analyzedCards.singlesCards[i].pokeCards)
      end
    elseif cardLength <= #analyzedCards.pairsCards then
      for i = 1, cardLength do
        table.append(pokeCards, analyzedCards.pairsCards[i].pokeCards)
      end
    end

    return Card.create(pokeCards)
  end

  if #analyzedCards.threesCards > 0 then
    local card = analyzedCards.threesCards[1]
    if #analyzedCards.singlesCards > 0 then
      return Card.create( table.union(card.pokeCards, analyzedCards.singlesCards[1].pokeCards) )
    end
    if #analyzedCards.pairsCards > 0 then
      return Card.create( table.union(card.pokeCards, analyzedCards.pairsCards[1].pokeCards) )
    end

    return card
  end

  if #analyzedCards.pairsCards > 0 then
    return analyzedCards.pairsCards[1]
  end

  if #analyzedCards.singlesCards > 0 then
    return analyzedCards.singlesCards[1]
  end

  return Card.create({currentPlayer.pokeCards[1]})
end

function PokecardAI.findCardGreaterThan(player, testCard)
  local analyzedCards = player.analyzedCards
  local result = {}

  if #player.pokeCards < #testCard.pokeCards then
    -- 牌不足，直接返回
    return result
  elseif testCard.isRocket() then
    -- 对方火箭，直接返回
    return result
  elseif testCard.isBomb() then
    -- 炸弹
    for _, card in pairs(analyzedCards.bombsCards) do
      if card:isGreaterThan(testCard) then
        table.insert(result, {card, 0})
      end
    end
  elseif testCard.cardType == CardType.THREE or testCard.cardType == CardType.THREE_WITH_ONE then
    -- 三张, 或三带一
    for _, card in pairs(analyzedCards.threesCards) do
      if card.maxPokeValue > testCard.maxPokeValue then
        table.insert(result, {card, 0})
      end
    end
  elseif testCard.cardType == CardType.THREE_WITH_PAIRS then
    -- 三带二
    local hasPairs = false
    local cardBreak = 0
    hasPairs = #analyzedCards.pairsCards > 0
    if not hasPairs then
      hasPairs = #analyzedCards.threesCards > 2
    end
    if not hasPairs then
      hasPairs = #analyzedCards.pairsStraightsCards > 0
      cardBreak = 1
    end
    if not hasPairs then
      hasPairs = #analyzedCards.threesStraightsCards > 0
      cardBreak = 2
    end

    if not hasPairs then
      -- 没有可用的对子，直接返回
      return {}
    end

    for _, card in pairs(analyzedCards.threesCards) do
      if card.maxPokeValue > testCard.maxPokeValue then
        table.insert(result, {card, cardBreak})
      end
    end
  elseif testCard.cardType == CardType.THREE_STRAIGHT then
    -- 三顺
    for _, card in pairs(analyzedCards.threesStraightsCards) do
      if card.maxPokeValue > testCard.maxPokeValue and card.cardLength >= testCard.cardLength then
        if card.cardLength == testCard.cardLength then
          table.insert( result, {card, 0} )
        else
          table.insert( result, {card, 1} )
        end
      end
    end
  elseif testCard.cardType == CardType.PAIRS_STRAIGHT or testCard.cardType == CardType.STRAIGHT then
    -- 双顺 -- 单顺
    for _, card in pairs(analyzedCards.pairsStraightsCards) do
      if card.maxPokeValue > testCard.maxPokeValue and card.cardLength >= testCard.cardLength then
        if card.cardLength == testCard.cardLength then
          table.insert( result, {card, 0} )
        else
          table.insert( result, {card, 1} )
        end
      end
    end
  elseif testCard.cardType == CardType.PAIRS then
    for _, card in pairs(analyzedCards.pairsCards) do
      if card.maxPokeValue > testCard.maxPokeValue then
        table.insert( result, {card, 0})
      end
    end
  elseif testCard.cardType == CardType.SINGLE then
    for _, card in pairs(analyzedCards.singlesCards) do
      if card.maxPokeValue > testCard.maxPokeValue then
        table.insert( result, {card, 0} )
      end
    end
    if #result == 0 and #analyzedCards.straightsCards > 0 then
      for _, card in pairs(analyzedCards.straightsCards) do
        if card.cardLength > 5 then
          if card.minPokeValue > testCard.maxPokeValue then
            table.insert(result, {Card.create(card.pokeCards[1]), 1})
          elseif card.maxPokeValue > testCard.maxPokeValue then
            table.insert(result, {Card.create(card.pokeCards[#card.pokeCards]), 1})            
          end
          if #result > 0 then
            break
          end
        end
      end
    end
    --if #result == 0 and #analyzedCards.threesCards do
  end

  return result
end

return PokecardAI
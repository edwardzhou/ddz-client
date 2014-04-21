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
  if currentPlayer:isLord() then
    -- 当前玩家是地主
    if pokeGame.lastPlay == nil or pokeGame.lastPlay.player.userId == currentPlayer.userId then
      -- 上轮是自己或自己是第一个出牌
      
    else
      -- 上手牌是其他玩家
    end
  else
    -- 当前玩家是农民
    if pokeGame.lordPlayer.robot then
    else
    end
  end


  local pokeCards = table.copy(currentPlayer.pokeCards, 1, 1)
  gameService:playCard(currentPlayer.userId, PokeCard.getIdChars(pokeCards))
end


return PokecardAI
local PokecardAI = class('PokecardAI')
local scheduler = require('framework.scheduler')

function PokecardAI:ctor(...)
end

function PokecardAI.grabLord(gameService, pokeGame, currentPlayer)
  scheduler.performWithDelayGlobal(
    function()
      local grabs = {ddz.Actions.GrabbingLord.None, ddz.Actions.GrabbingLord.Grab}
      local action = grabs[math.random(1000)%2 + 1]
      gameService:grabLord(currentPlayer.userId, action)
    end, 
    math.random(5) - 0.5)
end

function PokecardAI.playCard(gameService, pokeGame, currentPlayer)
  scheduler.performWithDelayGlobal(function() 
    local pokeCards = table.copy(currentPlayer.pokeCards, 1, 1)
    gameService:playCard(currentPlayer.userId, PokeCard.getIdChars(pokeCards))
  end, math.random(5) - 0.5)
end


return PokecardAI
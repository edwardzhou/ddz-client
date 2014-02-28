require('framework.functions')
require('framework.debug')
require('GlobalFunctions')
require('extern')
require('PokeCard')
require('CardUtility')
require('CardAnalyzer')


-- cclog
cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
end

PokeCard.sharedPokeCard(pokeCardsLayer)

pokeCards = PokeCard.getByPokeChars('AcjmDrBekRuvCVNXp')
table.sort(pokeCards, function(a, b) return a.index > b.index end)

analyzer = CardAnalyzer.new(pokeCards)
analyzer:dump()

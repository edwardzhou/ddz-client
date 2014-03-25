require('framework.functions')
require('framework.debug')
require('GlobalFunctions')
require('extern')
require('PokeCard')
require('CardUtility')
local CardAnalyzer = require('CardAnalyzer')


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

pokeIds = {
    'c04',
    'b04',
    'd05',
    'a06',
    'd06',
    'd07',
    'c08',
    'c09',
    'd10',
    'd11',
    'd12',
    'b12',
    'a12',
    'c01',
    'a01',
    'd02',
    'c02',
    'b02',
    'w01'
}

--pokeCards = PokeCard.getByPokeChars('AcjmDrBekRuvCVNXp')
pokeCards = PokeCard.pokeCardsFromIds(pokeIds)
table.sort(pokeCards, sortAscBy('index'))

function testA(card)
    card = {x=5}
end

local x = {y=6}
dump(x, "org X")
testA(x)
dump(x, "new X")

--card = Card.create({pokeCards[1], pokeCards[2]})
--dump(card)

--analyzer = CardAnalyzer.new(pokeCards)
results = CardAnalyzer.analyze(pokeCards)
CardAnalyzer.dumpResults(results)

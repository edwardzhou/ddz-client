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

--card = Card.create({pokeCards[1], pokeCards[2]})
--dump(card)

analyzer = CardAnalyzer.new(pokeCards)
analyzer:analyze()
analyzer:dump()
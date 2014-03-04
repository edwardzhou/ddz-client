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
  'a05',
  'b06',
  'a06',
  'd08',
  'c09',
  'c10',
  'a11',
  'c12',
  'c13',
  'a01',
  'a03',
  'c02',
  'b02',
  'w01',
  'w02'
}

--pokeCards = PokeCard.getByPokeChars('AcjmDrBekRuvCVNXp')
pokeCards = PokeCard.pokeCardsFromIds(pokeIds)
table.sort(pokeCards, sortAscBy('index'))

--card = Card.create({pokeCards[1], pokeCards[2]})
--dump(card)

analyzer = CardAnalyzer.new(pokeCards)
analyzer:analyze()
analyzer:dump()

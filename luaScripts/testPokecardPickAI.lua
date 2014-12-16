require('framework.functions')
require('framework.debug')
require('GlobalSettings')
require('GlobalFunctions')require('extern')
require('PokeCard')
require('CardUtility')
cjson = require('cjson.safe')

PokecardPickAI = require('PokecardPickAI')
CardAnalyzer = require('CardAnalyzer')

file = io.open('../Resources/allCardTypes.json')
data = file:read('*a')
file:close()

allCardTypes = cjson.decode(data)

--dump(allCardTypes)


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

testCases = { 
  'GJMRUWXYZ[^`cejmprs', --// 4, 5, 6, 7, 888, 99, 00, J, Q, K, AA, 22
  'GJMRUXZ[^`cejmprs', --// 4, 5, 6, 7, 88, 99, 00, J, Q, K, AA, 
  'AEGJKUVWX_cdhijpqv'   -- // 3, 44, 5, 8888, 0, JJ, Q, KK, A, 2, W
}

testCase = testCases[1]
PokeCard.sharedPokeCard()
pokecards = PokeCard.pokeCardsFromChars( testCase )
dump(pokecards)

cclog('pokecards: %s', PokeCard.getPokeValuesChars(pokecards, true))

--[[
选取 678899 , 找比 55 大的对子, 应该获得 88
]]
pickedPokecards = table.copy(pokecards, 1, 10)
cclog('pickedPokecards: %s', PokeCard.getPokeValuesChars(pickedPokecards))
testPokecards = PokeCard.pokeCardsFromIds('a05, b05')
cclog('testPokecards: %s', PokeCard.getPokeValuesChars(testPokecards))
testCard = Card.create(testPokecards)
cclog('testCard: %s', testCard:toString())

resultPokes = PokecardPickAI:findValidCard(pickedPokecards, testCard, nil)
dump( Card.create(resultPokes):toString(), 'greater 55 =>' )

testCard = Card.create(PokeCard.pokeCardsFromIds('a05'))
resultPokes = PokecardPickAI:findValidCard(pickedPokecards, testCard, nil)
dump( Card.create(resultPokes):toString(), 'greater 5 =>' )

testCard = Card.create(PokeCard.pokeCardsFromIds('a08'))
resultPokes = PokecardPickAI:findValidCard(pickedPokecards, testCard, nil)
dump( Card.create(resultPokes):toString(), 'greater 8 =>' )

testCard = Card.create(PokeCard.pokeCardsFromIds('a03, b03, c03'))
resultPokes = PokecardPickAI:findValidCard(pickedPokecards, testCard, nil)
dump( Card.create(resultPokes):toString(), 'greater 333 =>' )

testCard = Card.create(PokeCard.pokeCardsFromIds('a03, b03, c03, a04'))
resultPokes = PokecardPickAI:findValidCard(pickedPokecards, testCard, nil)
dump( Card.create(resultPokes):toString(), 'greater 3334 =>' )

testCard = Card.create(PokeCard.pokeCardsFromIds('a03, b03, c03, a04, b04'))
resultPokes = PokecardPickAI:findValidCard(pickedPokecards, testCard, nil)
dump( Card.create(resultPokes):toString(), 'greater 33344 =>' )

testCard = Card.create(PokeCard.pokeCardsFromIds('a03, b04, c05, a06, b07'))
resultPokes = PokecardPickAI:findValidCard(pickedPokecards, testCard, nil)
dump( Card.create(resultPokes):toString(), 'greater 34567 =>' )

bombPokecards = table.copy(pickedPokecards)
table.append(bombPokecards, PokeCard.pokeCardsFromIds('a10, b10, w01, w02'))
cclog('bombPokecards: %s', PokeCard.getPokeValuesChars(bombPokecards))
testCard = Card.create(PokeCard.pokeCardsFromIds('a03, b04, c05, a06, b07, b08, c09'))
resultPokes = PokecardPickAI:findValidCard(bombPokecards, testCard, nil)
dump( Card.create(resultPokes):toString(), 'greater 3456789 =>' )

testCard = Card.create(PokeCard.pokeCardsFromIds('a11, b11, c11, a04, b04'))
cclog('testCard: %s', testCard:toString())
resultPokes = PokecardPickAI:findValidCard(bombPokecards, testCard, nil)
dump( Card.create(resultPokes):toString(), 'greater JJJ44 =>' )


testCard = Card.create(PokeCard.pokeCardsFromIds('a03, b03, a04, b04, c05, d05'))
cclog('testCard: %s', testCard:toString())
resultPokes = PokecardPickAI:findValidCard(bombPokecards, testCard, nil)
dump( Card.create(resultPokes):toString(), 'greater 334455 =>' )

testCard = Card.create(PokeCard.pokeCardsFromIds('a03, b03, c03, b04, c04, d04'))
cclog('testCard: %s', testCard:toString())
resultPokes = PokecardPickAI:findValidCard(bombPokecards, testCard, nil)
dump( Card.create(resultPokes):toString(), 'greater 333444 =>' )


testCase = testCases[3]
PokeCard.sharedPokeCard()
pokecards = PokeCard.pokeCardsFromChars( testCase )
cclog('pokecards: %s', PokeCard.getPokeValuesChars(pokecards, true))
pickedPokecards = table.copy(pokecards,2, 9)

testCard = Card.create(PokeCard.pokeCardsFromIds('a09, b09, c09, d09, c04, a04, a05, d05'))
cclog('testCard: %s', testCard:toString())
resultPokes = PokecardPickAI:findValidCard(pickedPokecards, testCard, nil)
dump( Card.create(resultPokes):toString(), 'greater 333345 =>' )

require('framework.functions')
require('framework.debug')
require('extern')
require('PokeCard')
require('CardUtility')


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

pokeCards = PokeCard.getByPokeChars('AcjmDrEekRTWCVNXp')
table.sort(pokeCards, function(a, b) return a.index > b.index end)

cardInfos = CardUtility.getPokeCardsInfo(pokeCards)

dump(cardInfos, 'cardInfo', false, 2)

dump(CardUtility.getBombsInfos(cardInfos), 'getBombsInfos', false, 2)
dump(CardUtility.getThreeInfos(cardInfos), 'getThreeInfos', false, 2)
dump(CardUtility.getPairInfos(cardInfos), 'getPairInfos', false, 2)
--dump(CardUtility.getBombsInfos(cardInfos), 'cardInfo', false, 2)
g_shared_cards = {}

g_pokecards_node = nil


PokeCardState = {
	["NONE"] = 0,
	["NORMAL"] = 1,
	["PICKED"] = 2,
	["PLAYED"] = 3
}

-- 扑克牌的取值对照
PokeCardValue = {
		["NONE"] = 0,			-- 无效
		["THREE"] = 3,			-- 3
		["FOUR"] =  4,			-- 4
		["FIVE"] =  5,			-- 5
		["SIX"] =  6,				-- 6
		["SEVEN"] =  7,			-- 7
		["EIGHT"] =  8,			-- 8
		["NINE"] =  9,			-- 9
		["TEN"] =  10,			-- 10
		["JACK"] =  11,			-- J
		["QUEEN"] =  12,			-- Q
		["KING"] =  13,			-- K
		["ACE"] =  14,			-- A
		["TWO"] =  15,			-- 2
		["SMALL_JOKER"] =  16,	-- 小王
		["BIG_JOKER"] =  17		-- 大王
}

local g_PokeCardMap = {}
local PokeCardString = {}
local g_PokeCharMap = {}

PokeCardString[PokeCardValue.NONE] = " "
PokeCardString[PokeCardValue.THREE] = "3"
PokeCardString[PokeCardValue.FOUR] = "4"
PokeCardString[PokeCardValue.FIVE] = "5"
PokeCardString[PokeCardValue.SIX] = "6"
PokeCardString[PokeCardValue.SEVEN] = "7"
PokeCardString[PokeCardValue.EIGHT] = "8"
PokeCardString[PokeCardValue.NINE] = "9"
PokeCardString[PokeCardValue.TEN] = "0"
PokeCardString[PokeCardValue.JACK] = "J"
PokeCardString[PokeCardValue.QUEEN] = "Q"
PokeCardString[PokeCardValue.KING] = "K"
PokeCardString[PokeCardValue.ACE] = "A"
PokeCardString[PokeCardValue.TWO] = "2"
PokeCardString[PokeCardValue.SMALL_JOKER] = "w"
PokeCardString[PokeCardValue.BIG_JOKER] = "W"

-- 扑克牌花色
PokeCardType = {
		["NONE"] =  0, 		-- 无效
		["DIAMOND"] =   1, 	-- 方块
		["HEART"] =   2, 		-- 红桃
		["CLUB"] =   3, 		-- 梅花
		["SPADE"] =   4,		-- 黑桃
		["SMALL_JOKER"] =   5,	-- 小王  
		["BIG_JOKER"] =   6	-- 大王  
}

local PokeCardTypeString = {}
PokeCardTypeString[PokeCardType.NONE] = "无效"
PokeCardTypeString[PokeCardType.DIAMOND] = "方块"
PokeCardTypeString[PokeCardType.HEART] = "红桃"
PokeCardTypeString[PokeCardType.CLUB] = "梅花"
PokeCardTypeString[PokeCardType.SPADE] = "黑桃"
PokeCardTypeString[PokeCardType.SMALL_JOKER] = "小王"
PokeCardTypeString[PokeCardType.BIG_JOKER] = "大王"


local PokeCardTypeId = {}
PokeCardTypeId[""] = PokeCardType.NONE
PokeCardTypeId["d"] = PokeCardType.DIAMOND
PokeCardTypeId["c"] = PokeCardType.HEART
PokeCardTypeId["b"] = PokeCardType.CLUB
PokeCardTypeId["a"] = PokeCardType.SPADE
PokeCardTypeId["w"] = PokeCardType.SMALL_JOKER
PokeCardTypeId["W"] = PokeCardType.BIG_JOKER


-- 出牌牌型
CardType = {
		["NONE"] = 0, 				-- 无效
		["SINGLE"] = 1,				-- 单张
		["PAIRS"] = 2,				-- 一对
		["PAIRS_STRAIGHT"] = 3,		-- 连对
		["THREE"] = 4,				-- 三张
		["THREE_WITH_ONE"] = 5,		-- 三带一
		["THREE_WITH_PAIRS"] = 6,	-- 三带一对
		["THREE_STRAIGHT"] = 7,		-- 三张的顺子
		["FOUR_WITH_TWO"] = 8,		-- 四带二
		["FOUR_WITH_TWO_PAIRS"] = 9, -- 四带二对
		["PLANE"] = 10,				-- 飞机
		["PLANE_WITH_WING"] = 11,		-- 飞机带翅膀(三张带一对的顺子)
		["STRAIGHT"] = 12,			-- 顺子
		["BOMB"] = 13,				-- 炸弹
		["ROCKET"] = 14				-- 火箭(王炸)
}

local CardTypeString = {}

CardTypeString[ CardType.NONE ]                  = "无效"
CardTypeString[ CardType.SINGLE ]                = "单张"
CardTypeString[ CardType.PAIRS ]                 = "一对"
CardTypeString[ CardType.PAIRS_STRAIGHT ]        = "连对"
CardTypeString[ CardType.THREE ]                 = "三张"
CardTypeString[ CardType.THREE_WITH_ONE ]        = "三带一"
CardTypeString[ CardType.THREE_WITH_PAIRS ]      = "三带一对"
CardTypeString[ CardType.THREE_STRAIGHT]         = "三张的顺子"
CardTypeString[ CardType.FOUR_WITH_TWO]          = "四带二"
CardTypeString[ CardType.FOUR_WITH_TWO_PAIRS ]   = "四带二对"
CardTypeString[ CardType.PLANE ]                 = "飞机"
CardTypeString[ CardType.PLANE_WITH_WING ]       = "飞机带翅膀"
CardTypeString[ CardType.STRAIGHT ]              = "顺子"
CardTypeString[ CardType.BOMB ]                  = "炸弹"
CardTypeString[ CardType.ROCKET ]                = "火箭"


PokeCard = class("PokeCard")

function PokeCard.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, PokeCard)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

-- 单张扑克牌定义
function PokeCard:ctor(container, filename, scaleFactor)
	
	self.image_filename = filename
	self.pokeType = PokeCardType.NONE
	self.value = 0
	self.pokeIndex = 0
	self.id = ""
	self.scaleFactor = 1.0
	self.state = PokeCardState.NORMAL
	self.picked = false
	
	if scaleFactor then
		self.scaleFactor = scaleFactor
	end
	
--	self.card_sprite = cc.Sprite:createWithSpriteFrameName(self.image_filename)
--	self.card_sprite:setAnchorPoint(cc.p(0,0))
--	self.card_sprite:setPosition(cc.p(-150, -150))
--	self.card_sprite:setVisible(false)
--	--self.card_sprite:retain()
--	container:addChild(self.card_sprite)
end

function createPokecardSprite(poke)
  local cardSprite = cc.Sprite:createWithSpriteFrameName('poke_bg_l.png')
  cardSprite:setAnchorPoint(cc.p(0, 0))
  cardSprite:setPosition(cc.p(-150, -150))
  dump(poke, '[createPokecardSprite] poke =>')

  if poke.value <= PokeCardValue.TEN or poke.value == PokeCardValue.TWO or poke.value == PokeCardValue.ACE then
    local pbfFrameName = 'pbf_l_' .. poke.pokeType .. '.png'
    local pbfSprite = cc.Sprite:createWithSpriteFrameName(pbfFrameName)
    pbfSprite:setAnchorPoint(cc.p(0.5, 0.5))
    pbfSprite:setPosition(50, 45)
    cardSprite:addChild(pbfSprite)

    local pvFrameName = 'pv_l_'
    local colorName = 'b_'
    if poke.pokeType == PokeCardType.DIAMOND or poke.pokeType == PokeCardType.HEART then
      colorName = 'r_'
    end
    pvFrameName = pvFrameName .. colorName .. poke.valueChar .. '.png'
    local numSprite = cc.Sprite:createWithSpriteFrameName(pvFrameName) 
    numSprite:setAnchorPoint(cc.p(0.5, 0.5))
    numSprite:setPosition(18, 140 - 23)
    cardSprite:addChild(numSprite)

    local psfFrameName = 'psf_l_' .. poke.pokeType .. '.png'
    local psfSprite = cc.Sprite:createWithSpriteFrameName(psfFrameName)
    psfSprite:setAnchorPoint(cc.p(0.5, 0.5))
    psfSprite:setPosition(18, 80)
    cardSprite:addChild(psfSprite)

  elseif poke.value >= PokeCardValue.JACK and poke.value <= PokeCardValue.KING then
    local pbfFrameName = 'pbf_l_' .. poke.valueChar .. '.png'
    local pbfSprite = cc.Sprite:createWithSpriteFrameName(pbfFrameName)
    pbfSprite:setAnchorPoint(cc.p(0.5, 0.5))
    pbfSprite:setPosition(50, 70)
    cardSprite:addChild(pbfSprite)

    local pvFrameName = 'pv_l_'
    local colorName = 'b_'
    if poke.pokeType == PokeCardType.DIAMOND or poke.pokeType == PokeCardType.HEART then
      colorName = 'r_'
    end
    pvFrameName = pvFrameName .. colorName .. poke.valueChar  .. '.png'
    local numSprite = cc.Sprite:createWithSpriteFrameName(pvFrameName) 
    numSprite:setAnchorPoint(cc.p(0.5, 0.5))
    numSprite:setPosition(18, 140 - 23)
    cardSprite:addChild(numSprite)

    local psfFrameName = 'psf_l_' .. poke.pokeType .. '.png'
    local psfSprite = cc.Sprite:createWithSpriteFrameName(psfFrameName)
    psfSprite:setAnchorPoint(cc.p(0.5, 0.5))
    psfSprite:setPosition(18, 80)
    cardSprite:addChild(psfSprite)
  else
    local pbfFrameName = 'pbf_l_'
    if poke.value == PokeCardValue.BIG_JOKER then
      pbfFrameName = pbfFrameName .. 'BIG_JOKER'
    else
      pbfFrameName = pbfFrameName .. 'SMALL_JOKER'
    end
    pbfFrameName = pbfFrameName .. '.png'

    local pbfSprite = cc.Sprite:createWithSpriteFrameName(pbfFrameName)
    pbfSprite:setAnchorPoint(cc.p(0.5, 0.5))
    pbfSprite:setPosition(50, 70)
    cardSprite:addChild(pbfSprite)

  end

  return cardSprite
 end

function PokeCard:loadCardSprite(container)
  -- self.card_sprite = cc.Sprite:createWithSpriteFrameName(self.image_filename)
  -- self.card_sprite:setAnchorPoint(cc.p(0,0))
  -- self.card_sprite:setPosition(cc.p(-150, -150))
  -- self.card_sprite:setVisible(false)
  --self.card_sprite:retain()

  self.card_sprite = createPokecardSprite(self)
  self.card_sprite:setAnchorPoint(cc.p(0,0))
  self.card_sprite:setPosition(cc.p(-150, -150))
  self.card_sprite:setVisible(false)
  self.card_sprite:setLocalZOrder(54-self.pokeIndex)

  container:addChild(self.card_sprite)
end

function PokeCard:reset()
    self.state = PokeCardState.NORMAL
    self.picked = false
    if self.card_sprite then
      self.card_sprite:setVisible(false)
      self.card_sprite:setPosition(cc.p(-150, -150))
      self.card_sprite:setScale(self.scaleFactor)
    end
end

function PokeCard:getPokeString()
    return PokeCardString[self.value]
end

function PokeCard:toString()
    return "PokeCard[" + PokeCardTypeString[self.pokeType] ..
    		PokeCardString[self.value] .. "]"
end

Card = class("Card")

-- 出牌
function Card:ctor(opts)
  opts = opts or {}
	self.cardType = opts.cardType or CardType.NONE
	local pokeCards = {}
	table.merge(pokeCards, opts.pokeCards or {})
	self.pokeCards = pokeCards
	self.maxPokeValue = opts.maxPokeValue or (pokeCards[#pokeCards] and pokeCards[#pokeCards].value) or 0  
  self.minPokeValue = opts.minPokeValue or (pokeCards[1] and pokeCards[1].value) or 0  
	self.cardLength = opts.cardLength or 0
	self.weight = opts.weight or self:calcWeight()
	self.owner = nil
end

function Card:equals(other)
  if other == nil 
    or self.cardType ~= other.cardType 
    or self.cardLength ~= other.cardLength 
    or self.maxPokeValue ~= other.maxPokeValue then
    return false
  end
  
  return true
end

function Card.create(pokeCards)
  local opts = {}
  if pokeCards and #pokeCards > 0 then
    opts.pokeCards = table.dup(pokeCards)
    table.sort(opts.pokeCards, sortAscBy('index'))
    local valueChars = PokeCard.getPokeValuesChars(opts.pokeCards, true)
    local cardDef = allCardTypes[valueChars]
    if cardDef ~= nil then
      opts.cardType = cardDef.cardType
      opts.cardLength = cardDef.cardLength
      opts.maxPokeValue = cardDef.maxPokeValue
    end
  end  
  return Card.new(opts)
end

function Card:calcWeight()
  if self.CardType == CardType.NONE then
    return 0
  end
  
  if self.cardType == CardType.SINGLE then
    return 1
  elseif self.cardType == CardType.PAIRS then
    return 2
  elseif self.cardType == CardType.THREE or
          self.cardType == CardType.THREE_WITH_ONE or
          self.cardType == CardType.THREE_WITH_PAIRS then
    return 3
  elseif self.cardType == CardType.STRAIGHT then
    return 4 + #self.pokeCards - 5
  elseif self.cardType == CardType.PAIRS_STRAIGHT then
    return 5 + #self.pokeCards - 6
  elseif self.cardType == CardType.THREE_STRAIGHT then
    return 6 + #self.pokeCards - 3
  elseif self.cardType == CardType.BOMB or self.cardType == CardType.ROCKET then
    return 7
  end

  print('[Card:calcWeight] WARNING: no weight for ' , self:toString())

  return 0
end

function Card:isValid()
  return self.cardType ~= CardType.NONE
end

function Card:isBomb()
  return self.cardType == CardType.BOMB
end

function Card:isRocket()
  return self.cardType == CardType.ROCKET
end

function Card:getPokeValues(wantsValue)
	local pokeValues = {}
	for  _, pokeCard in pairs(self.pokeCards) do
		local v
		if (wantsValue) then
			v = pokeCard.value
		else
			v = pokeCard:getPokeString()
		end
		table.insert(pokeValues, v)
	end
		
	return pokeValues
end

function Card:getPokeIds()
	local poke_ids = {}
	for  _, value in pairs(self.pokeCards) do
		table.insert(poke_ids, value.id)
	end
		
	return poke_ids
end

function Card:getPokeChars()
  local pokeChars = {}
  for _, pokeCard in pairs(self.pokeCards) do
    table.insert(pokeChars, pokeCard.idChar)
  end
  return table.concat(pokeChars)
end

function Card:isGreaterThan(otherCard)
  -- 火箭最大
  if self:isRocket() then
    return true
  end

  -- 自己是炸弹，对方不是炸弹
  if self:isBomb() and not otherCard:isBomb() then
    return true
  end

  if self.cardType ~= otherCard.cardType then
    return false
  elseif self.cardLength ~= otherCard.cardLength then
    return false
  elseif self.maxPokeValue <= otherCard.maxPokeValue then
    return false
  end

  return true
end

function Card:dumpPokeValues()
	cclog("[Card.dumpPokeValues] " .. table.toString(self.getPokeValues(true)))
end

function Card:dumpPokeStrings()
	cclog("[Card.dumpPokeStrings] " .. table.toString(self.getPokeValues(false)))
end

function Card:toString()

--	return "Card[ " .. table.concat(self:getPokeValues(true), ', ') .. 
  return "Card[ " .. PokeCard.getPokeValuesChars(self.pokeCards, true) .. 
				", cardType: " .. CardTypeString[self.cardType] ..
        ", cardLen: " .. self.cardLength ..
				", pokeLen: " .. #self.pokeCards ..
				", maxVal: " .. self.maxPokeValue ..
        ", minVal: " .. self.minPokeValue ..
				" ]"
end


PokeCard.releaseAllCards = function() 
-- 	for _, value in pairs(g_shared_cards) do
-- --	  dump(value, 'poke card')
-- --	  print(value.card_sprite.cname)
-- 		local pokeSprite = value.card_sprite
-- 		if pokeSprite and pokeSprite:getParent() then
-- 			pokeSprite:removeFromParent(true)
-- 		end
-- 		pokeSprite = nil
-- 		value.card_sprite = nil
-- 	end

	
--	g_shared_cards = {}
--	g_PokeCardMap = {}	
end

PokeCard.reloadAllCardSprites = function(container)
  for i=#g_shared_cards, 1, -1 do
    local pokeCard = g_shared_cards[i]
    pokeCard:loadCardSprite(container)
  end
  -- for _, pokeCard in pairs(g_shared_cards) do
  --   pokeCard:loadCardSprite(container)
  -- end  
end

PokeCard.resetAll = function(container)
  -- if g_shared_cards[1].card_sprite == nil then
  --   PokeCard.reloadAllCardSprites(container)
  -- end

  

  for _, pokeCard in pairs(g_shared_cards) do
    pokeCard.picked = false
    pokeCard.card_sprite:setVisible(false)
    pokeCard.card_sprite:setScale(1)
    pokeCard.card_sprite:setPosition(-150, -150)
  end
--	PokeCard.releaseAllCards()
--	PokeCard.sharedPokeCard(container)
end

PokeCard.sharedPokeCard = function(container) 
	
	if #g_shared_cards > 0 then
		return
		--g_shared_cards = {}
	end
	
	--CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(Res.s_cards_plist)
	local types = {"d", "c", "b", "a"}
	local card_indexes = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 1, 2}
	local ci = 1
	for card_index, index in pairs(card_indexes) do
		for _, t in pairs(types) do
			local card_type = t
			local pokeId = t
			pokeId = string.format('%s%02d', t, index)
			local card_image_file_name = pokeId .. ".png"
			
			local pokeCard = PokeCard.new(container, card_image_file_name)
			pokeCard.index = ci
			ci = ci + 1
			pokeCard.value = tonumber(card_index) + 2
			pokeCard.pokeType = PokeCardTypeId[ card_type ]
			pokeCard.id = pokeId
			pokeCard.idChar = string.char(pokeCard.index + 64)
			pokeCard.valueChar = PokeCardString[pokeCard.value]
			g_PokeCharMap[pokeCard.idChar] = pokeCard
			table.insert(g_shared_cards, pokeCard)
			g_PokeCardMap[pokeId] = pokeCard
		end
	end
	
	local pokeId = "w01"
	local card_image_file_name = pokeId .. ".png"
	local pokeCard =  PokeCard.new(container, card_image_file_name)
	pokeCard.image_filename = card_image_file_name
	pokeCard.pokeType = PokeCardType.SMALL_JOKER
	pokeCard.value = 16
	pokeCard.id = pokeId
	pokeCard.index = ci
	ci = ci + 1
  pokeCard.idChar = string.char(pokeCard.index + 64)
  pokeCard.valueChar = PokeCardString[pokeCard.value]
  g_PokeCharMap[pokeCard.idChar] = pokeCard
	table.insert(g_shared_cards, pokeCard)
	g_PokeCardMap[pokeId] = pokeCard
	
	pokeId = "w02"
	card_image_file_name = pokeId .. ".png"
	local pokeCard = PokeCard.new(container, card_image_file_name)
	pokeCard.pokeType = PokeCardType.BIG_JOKER
	pokeCard.value = 17
	pokeCard.id = pokeId
	pokeCard.index = ci
	ci = ci + 1	
  pokeCard.idChar = string.char(pokeCard.index + 64)
  g_PokeCharMap[pokeCard.idChar] = pokeCard
  pokeCard.valueChar = PokeCardString[pokeCard.value]
	table.insert(g_shared_cards, pokeCard)
	g_PokeCardMap[pokeId] = pokeCard
	cclog("g_shared_cards.length => %d" , #g_shared_cards)

  g_pokecards_node = cc.SpriteBatchNode:createWithTexture(
    cc.Director:getInstance():getTextureCache():getTextureForKey('pokecards.png'))
  g_pokecards_node:retain()

  PokeCard.reloadAllCardSprites(g_pokecards_node)

end

PokeCard.getCard = function(card_value)
	return g_shared_cards[card_value]
end

PokeCard.getCardById = function(card_id)
	return g_PokeCardMap[card_id]
end

PokeCard.getByChar = function(char)
  return g_PokeCharMap[char]
end

PokeCard.getIdChars = function(pokeCards)
  local pokeChars = {}
  for _, pokeCard in pairs(pokeCards) do
    table.insert(pokeChars, pokeCard.idChar)
  end
  return table.concat(pokeChars)
end

PokeCard.pokeCardsFromIds = function(pokeIds)
  if type(pokeIds) == 'string' then
    pokeIds = string.split(pokeIds, ',')
    for i=1, #pokeIds do
      pokeIds[i] = string.trim(pokeIds[i])
    end
  end
  
  local pokeCards = {}
  for i=1, #pokeIds do
    table.insert(pokeCards, g_PokeCardMap[pokeIds[i]])
  end

  return pokeCards  
end

PokeCard.pokeCardsFromChars = function(chars)
  local pokeCards = {}
  for i=1, #chars do
    local char = string.sub(chars, i, i)
    table.insert(pokeCards, g_PokeCharMap[char])
  end
  
  return pokeCards
end

PokeCard.getPokeValuesChars = function(pokeCards, sorted)
  local tmpPokeCards = pokeCards
  if not sorted then
    tmpPokeCards = table.dup(pokeCards)
    table.sort(tmpPokeCards, sortAscBy('index'))
  end
  
  local s = ''
  for _, poke in pairs(tmpPokeCards) do
    s = s .. poke.valueChar
  end
  
  return s
end

PokeCard.getShuffledPokeCards = function()
  local pokeCards = table.dup(g_shared_cards)
  shuffleArray(pokeCards)
  shuffleArray(pokeCards)
  shuffleArray(pokeCards)

  return pokeCards
end

PokeCard.slicePokeCards = function()
  local allPokeCards = PokeCard.getShuffledPokeCards()
  local p1, p2, p3, lordCards = {}, {}, {}, {}
  for i=1, 17 do
    table.insert(p1, table.remove(allPokeCards, math.random(#allPokeCards)))
    table.insert(p2, table.remove(allPokeCards, math.random(#allPokeCards)))
    table.insert(p3, table.remove(allPokeCards, math.random(#allPokeCards)))
  end

  table.sort(p1, sortDescBy('index'))
  table.sort(p2, sortDescBy('index'))
  table.sort(p3, sortDescBy('index'))
  table.sort(allPokeCards, sortDescBy('index'))

  return p1, p2, p3, allPokeCards
end

allCardTypes = require('cjson.safe').decode(getContent('allCardTypes.json'))

PokeCard.getByPokeChars = PokeCard.pokeCardsFromChars
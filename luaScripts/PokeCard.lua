g_shared_cards = {}

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
PokeCardString[PokeCardValue.TEN] = "10"
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
	self.poke_card_type = PokeCardType.NONE
	self.poke_value = 0
	self.poke_index = 0
	self.poke_id = ""
	self.scaleFactor = 1.0
	self.state = PokeCardState.NORMAL
	self.picked = false
	
	if scaleFactor then
		self.scaleFactor = scaleFactor
	end
	
	self.card_sprite = cc.Sprite:createWithSpriteFrameName(self.image_filename)
	self.card_sprite:setAnchorPoint(cc.p(0,0))
	self.card_sprite:setPosition(cc.p(-150, -150))
	self.card_sprite:setVisible(false)
	--self.card_sprite:retain()
	container:addChild(self.card_sprite)
	
end

function PokeCard:reset()
    self.state = PokeCardState.NORMAL
    self.picked = false
    self.card_sprite:setVisible(false)
    self.card_sprite:setPosition(cc.p(-150, -150))
    self.card_sprite:setScale(self.scaleFactor)
end

function PokeCard:getPokeString()
    return PokeCardString[self.poke_value]
end

function PokeCard:toString()
    return "PokeCard[" + PokeCardTypeString[self.poke_card_type] ..
    		PokeCardString[self.poke_value] .. "]"
end

Card = class("Card")

-- 出牌
function Card:ctor()
	self.card_type = CardType.NONE
	self.poke_cards = nil
	self.max_poke_value = 0
	self.card_length = 0
	self.owner = nil
end

function Card:getPokeValues(wantsValue)
	local poke_values = {}
	for  _, value in pairs(self.poke_cards) do
		local v
		if (wantsValue) then
			v = value.poke_value
		else
			v = value:getPokeString()
		end
		table.insert(poke_values, v)
	end
		
	return poke_values
end

function Card:getPokeIds()
	local poke_ids = {}
	for  _, value in pairs(self.poke_cards) do
		table.insert(poke_ids, value.poke_id)
	end
		
	return poke_ids
end

function Card:dumpPokeValues()
	cclog("[Card.dumpPokeValues] " .. table.toString(self.getPokeValues(true)))
end

function Card:dumpPokeStrings()
	cclog("[Card.dumpPokeStrings] " .. table.toString(self.getPokeValues(false)))
end

function Card:toString()
	return "Card[ " .. table.toString(self.getPokeValues(true)) .. 
				" , card_type: " .. CardTypeString[self.card_type] ..
				" , poke_length: " .. #self.poke_cards ..
				" , max_poke_value: " .. self.max_poke_value ..
				" ]"
end


PokeCard.releaseAllCards = function() 
	for _, value in pairs(g_shared_cards) do
		local poke_card = value.card_sprite
		if poke_card:getParent() then
			poke_card:removeFromParentAndCleanup(true)
		end
		poke_card = nil
	end
	
	g_shared_cards = {}
	g_PokeCardMap = {}	
end

PokeCard.resetAll = function(container)
	PokeCard.releaseAllCards()
	PokeCard.sharedPokeCard(container)
end

PokeCard.sharedPokeCard = function(container) 
	
	if #g_shared_cards > 0 then
		-- return
		g_shared_cards = {}
	end
	
	--CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(Res.s_cards_plist)
	local types = {"d", "c", "b", "a"}
	local card_indexes = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 1, 2}
	local ci = 1
	for card_index, index in pairs(card_indexes) do
		for _, t in pairs(types) do
			local card_type = t
			local card_name = t
			--card_name = string.format('%s%2d', card_name, index)
			if index < 10 then
				card_name = card_name .. "0" .. index
			else
				card_name = card_name .. index
			end
			local card_image_file_name = card_name .. ".png"
			
			local poke_card = PokeCard.new(container, card_image_file_name)
			poke_card.index = ci
			ci = ci + 1
			poke_card.poke_value = tonumber(card_index) + 2
			poke_card.poke_card_type = PokeCardTypeId[ card_type ]
			poke_card.poke_id = card_name
			poke_card.poke_char = string.char(poke_card.index + 64)
			g_PokeCharMap[poke_card.poke_char] = poke_card
			table.insert(g_shared_cards, poke_card)
			g_PokeCardMap[card_name] = poke_card
		end
	end
	
	local card_name = "w01"
	local card_image_file_name = card_name .. ".png"
	local poke_card =  PokeCard.new(container, card_image_file_name)
	poke_card.image_filename = card_image_file_name
	poke_card.poke_card_type = PokeCardType.SMALL_JOKER
	poke_card.poke_value = 16
	poke_card.poke_id = card_name
	poke_card.index = ci
	ci = ci + 1
  poke_card.poke_char = string.char(poke_card.index + 64)
  g_PokeCharMap[poke_card.poke_char] = poke_card
	table.insert(g_shared_cards, poke_card)
	g_PokeCardMap[card_name] = poke_card
	card_name = "w02"
	card_image_file_name = card_name .. ".png"
	local poke_card = PokeCard.new(container, card_image_file_name)
	poke_card.poke_card_type = PokeCardType.BIG_JOKER
	poke_card.poke_value = 17
	poke_card.poke_id = card_name
	poke_card.index = ci
	ci = ci + 1
		
  poke_card.poke_char = string.char(poke_card.index + 64)
  g_PokeCharMap[poke_card.poke_char] = poke_card
	table.insert(g_shared_cards, poke_card)
	g_PokeCardMap[card_name] = poke_card
	cclog("g_shared_cards.length => %d" , #g_shared_cards)
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

PokeCard.pokeCardsFromChars = function(chars)
  local pokeCards = {}
  for i=1, #chars do
    local char = string.sub(chars, i, i)
    table.insert(pokeCards, g_PokeCharMap[char])
  end
  
  return pokeCards
end

PokeCard.getByPokeChars = PokeCard.getByChars
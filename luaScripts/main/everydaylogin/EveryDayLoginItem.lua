local UIVarBinding = require('utils.UIVariableBinding')

local EveryDayLoginItem = class('EveryDayLoginItem', function() 
  return cc.Layer:create()
end)

function EveryDayLoginItem:ctor(day, status)
  self.day = day
  self.status = status
  self:init()
end

function EveryDayLoginItem:init()
	local path = "Res/everydaylogin/"
	local coins = {"coin_01","coin_02","coin_03","coin_03","coin_03","coin_03","coin_07"}
	local coinNums = {"three_hundred","six_hundred","one_thousand","one_thousand","one_thousand","one_thousand","ten_thousand"}
  local uiRoot = cc.CSLoader:createNode('EveryDayLoginItemLayer.csb')
  self:addChild(uiRoot)
  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self.LabelDay:setString(tostring(self.day))
  local coinImg = path .. coins[self.day] .. ".png"
  local coinNumImg = path .. coinNums[self.day] .. ".png"
  self.ImageCoin:loadTexture(coinImg)
  self.ImageNum:loadTexture(coinNumImg)
  if self.status == "get" then
  	self.ImageGet:removeFromParent(true)
  	self.ImageCover:removeFromParent(true)
  elseif self.status == "getted" then
  	self.ImageStar:removeFromParent(true)
  elseif self.status == "disable" then
  	self.ImageStar:removeFromParent(true)
  	self.ImageGet:removeFromParent(true)
  end
end

return EveryDayLoginItem
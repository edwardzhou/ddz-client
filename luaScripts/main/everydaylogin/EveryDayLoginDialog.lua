--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

local UIVarBinding = require('utils.UIVariableBinding')
local AccountInfo = require('AccountInfo')

local EveryDayLoginDialog = class('EveryDayLoginDialog', function() 
  return cc.Layer:create()
end)

function EveryDayLoginDialog:ctor(status, total)
	self.status = status
	self.total = total
  self:init()
end

function EveryDayLoginDialog:init()
  local uiRoot = cc.CSLoader:createNode('EveryDayLoginLayer.csb')
  self:addChild(uiRoot)
  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:addItems(uiRoot)
  self:initTouch()
  self:initKeypadHandler()
end

function EveryDayLoginDialog:addItems(uiRoot)
	--local status = {"getted","getted","get","get","disable","disable","disable"}
  local startx = -214
  local starty = 87.5
  for i=1,7 do 
  	local item1 = require("everydaylogin.EveryDayLoginItem").new(i, self.status[i])
  	if i <= 4 then
  		item1:setPosition(startx + 160 * (i - 1), starty)
  	else
  		item1:setPosition(startx + 160 * (i - 5), starty - 150)
  	end
  	uiRoot:addChild(item1)
  end
end

function EveryDayLoginDialog:initTouch()
	local onTouchBegan = function() return true end
	local touchListener = cc.EventListenerTouchOneByOne:create()
	touchListener:setSwallowTouches(true)
	touchListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, self) 
end

function EveryDayLoginDialog:initKeypadHandler()
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      event:stopPropagation()
    end
  end
  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function EveryDayLoginDialog:ButtonGet_onClicked(sender, eventType)
  local drop_coins = cc.ParticleSystemQuad:create('drop_coins.plist')
  drop_coins:setPosition(400, 480)
  self:getParent():addChild(drop_coins)
  self:removeFromParent(true)

  local reqParams = {}
  local user = AccountInfo.getCurrentUser()
  reqParams.userId = user.userId

  ddz.pomeloClient:request('ddz.loginRewardsHandler.takeLoginRewards', reqParams, function(data) 
      dump(data, 'deliverLoginReward result')
      if data.result then
        local currentUser = AccountInfo.getCurrentUser()
        local coins = currentUser.ddzProfile.coins or 0
      	currentUser.ddzProfile.coins = coins + data.coins
        local scene = cc.Director:getInstance():getRunningScene()
        if scene.updateUserInfo then
          scene:updateUserInfo()
        end
        TDGAVirtualCurrency:onReward(data.coins, "每日登录奖励")
    	end
    end)
end

return EveryDayLoginDialog
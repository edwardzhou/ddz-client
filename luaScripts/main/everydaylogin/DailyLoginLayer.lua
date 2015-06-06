--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

local UIVarBinding = require('utils.UIVariableBinding')
local AccountInfo = require('AccountInfo')


DailyLoginLayer = class('DailyLoginLayer', function() 
  return cc.Layer:create()
end)

function DailyLoginLayer:ctor(data, total)
  --self.status = status
  self.loginRewardsData = data
  self.total = total
  self:init()
end

function DailyLoginLayer:init()
  local uiRoot = cc.CSLoader:createNode('LoginRewardsLayer.csb')
  self:addChild(uiRoot)
  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initItems()
  self:initTouch()
  self:initKeypadHandler()
end

function DailyLoginLayer:initItems()
  --local status = {"getted","getted","get","get","disable","disable","disable"}
  for index=1, 7 do 
    local dayData = self.loginRewardsData[index]
    dump(dayData, '[DailyLoginLayer:initItems] dayData =>')
    self['LabelDay_' .. index]:setString(tostring(dayData.bonus) .. '金币')
    if dayData.statusText == 'getted' then
      self['ReadyDay_' .. index]:setVisible(false)
      self['CheckedDay_' .. index]:setVisible(true)
      self['ImageMaskDay_' .. index]:setVisible(false)
    elseif dayData.statusText == 'get' then
      self['ReadyDay_' .. index]:setVisible(true)
      self['CheckedDay_' .. index]:setVisible(false)
      self['ImageMaskDay_' .. index]:setVisible(false)
    else
      self['ReadyDay_' .. index]:setVisible(false)
      self['CheckedDay_' .. index]:setVisible(false)
    end
  end
end

function DailyLoginLayer:initTouch()
  local onTouchBegan = function() return true end
  local touchListener = cc.EventListenerTouchOneByOne:create()
  touchListener:setSwallowTouches(true)
  touchListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, self) 
end

function DailyLoginLayer:initKeypadHandler()
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      event:stopPropagation()
    end
  end
  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function DailyLoginLayer:ButtonTakeRewards_onClicked(sender, eventType)
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

return DailyLoginLayer
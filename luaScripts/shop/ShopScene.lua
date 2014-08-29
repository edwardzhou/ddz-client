
local ShopScene = class('ShopScene')
local gameConnection = require('network.GameConnection')
local AccountInfo = require('AccountInfo')

local showToastBox = require('UICommon.ToastBox').showToastBox;

function ShopScene.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, ShopScene)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function ShopScene:ctor(...)
  local this = self
  self:registerScriptHandler(function(event)
    print('[ShopScene] event => ', event)
    local on_event = 'on_' .. event
    if type(this[on_event]) == 'function' then
      this[on_event](this)
    end
  end)

  self:init()

end

function ShopScene:init()
  local rootLayer = cc.Layer:create()
  self.rootLayer = rootLayer
  self:addChild(rootLayer)

  local guiReader = ccs.GUIReader:getInstance()
  local uiRoot = guiReader:widgetFromBinaryFile('UI/Shop.csb')
  self.uiRoot = guiReader
  rootLayer:addChild(uiRoot)

  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initKeypadHandler()

  local item_model = self.ShopItemModel:clone()
  self.ShopItemList:setItemModel(item_model)
  self.ShopItemModel:setVisible(false)

  self.ShopItemList:pushBackDefaultItem()
  self.ShopItemList:pushBackDefaultItem()
  self.ShopItemList:pushBackDefaultItem()
  self.ShopItemList:pushBackDefaultItem()
  self.ShopItemList:pushBackDefaultItem()

end

function ShopScene:on_enterTransitionFinish()
  local this = self
end

function ShopScene:on_exit()
end


function ShopScene:initKeypadHandler()
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
--      if type(self.onMainMenu) == 'function' then
--        self.onMainMenu()
--      end
      event:stopPropagation()
      cc.Director:getInstance():popScene() 
    elseif keyCode == cc.KeyCode.KEY_MENU  then
      --label:setString("MENU clicked!")
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end


local function createScene()
  local scene = cc.Scene:create()
  return ShopScene.extend(scene)
end



return createScene
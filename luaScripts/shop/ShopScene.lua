
local ShopScene = class('ShopScene')
local gameConnection = require('network.GameConnection')
local AccountInfo = require('AccountInfo')

local showToastBox = require('UICommon.ToastBox').showToastBox
local showMessageBox = require('UICommon.MessageBox').showMessageBox

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

  this._onButtonBuyClicked = __bind(this.ButtonBuy_onClicked, this)

  self:init()

end

function ShopScene:init()
  local this = self
  local rootLayer = cc.Layer:create()

  this.gameConnection = require('network.GameConnection')

  self.rootLayer = rootLayer
  self:addChild(rootLayer)

  local guiReader = ccs.GUIReader:getInstance()
  -- local uiRoot = guiReader:widgetFromBinaryFile('gameUI/Shop.csb')
  local uiRoot = cc.CSLoader:createNode('ShopScene.csb')
  self.uiRoot = guiReader
  rootLayer:addChild(uiRoot)

  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initKeypadHandler()
  self.ShopItemModel:setVisible(false)


end


function ShopScene:on_enterTransitionFinish()
  local this = self

  self:loadShopItems()
end

function ShopScene:on_exit()
end

function ShopScene:loadShopItems()
  local this = self
  local listView

  if not self.ShopItemList then
    listView = ccui.ListView:create()
    listView:setAnchorPoint(cc.p(0,0))
    listView:setPosition(cc.p(0,0))
    listView:setContentSize(cc.size(800, 412))
    listView:setGravity(ccui.ListViewGravity.left)
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setColor(cc.c3b(0x96, 0x96, 0xFF))
    listView:setOpacity(100)
    listView:addEventListener(__bind(self.ShopItemList_onEvent, self))
    self.ShopItemList = listView
    self.PanelRoot:addChild(listView)
    local item_model = self.ShopItemModel:clone()
    item_model:setVisible(true)
    self.ShopItemList:setItemModel(item_model)
  else
    self.ShopItemList:removeAllItems()
  end
  
  local textureCache = cc.Director:getInstance():getTextureCache()
  textureCache:addImage('images/bag1.png')
  textureCache:addImage('images/bag2.png')
  textureCache:addImage('images/bag3.png')
  textureCache:addImage('images/bag4.png')


  this.gameConnection:request('ddz.hallHandler.getShopItems', {}, function(data) 
    dump(data, '[ddz.hallHandler.getShopItems] data =>')
    for i=1, #data do
      local pkg = data[i]
      this.ShopItemList:pushBackDefaultItem()
      local item = this.ShopItemList:getItem(i-1)
      local label, imgIcon, price, button
      price = pkg.price or 0.0
      label = tolua.cast(ccui.Helper:seekWidgetByName(item, 'LabelPkgName'), 'ccui.Text')
      label:setString(pkg.packageName)
      label = tolua.cast(ccui.Helper:seekWidgetByName(item, 'LabelPkgDesc'), 'ccui.Text')
      label:setString(pkg.packageDesc)
      label = tolua.cast(ccui.Helper:seekWidgetByName(item, 'LabelPrice'), 'ccui.Text')
      label:setString(string.format('价格 %d 元', price/100))

      imgIcon = tolua.cast(ccui.Helper:seekWidgetByName(item, 'ImagePkgIcon'), 'ccui.ImageView')
      if pkg.packageIcon then
        local imgFilename = 'images/' .. pkg.packageIcon
        print('packageIcon => ', imgFilename)
        imgIcon:loadTexture(imgFilename, ccui.TextureResType.localType)
      end

      button = tolua.cast(ccui.Helper:seekWidgetByName(item, 'ButtonBuy'), 'ccui.Button')
      button.package = pkg

      button:addTouchEventListener(this._onButtonBuyClicked)      
    end
  end)
end

function ShopScene:initKeypadHandler()
  local this = self
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
--      if type(self.onMainMenu) == 'function' then
--        self.onMainMenu()
--      end
      event:stopPropagation()
      this:close()
    elseif keyCode == cc.KeyCode.KEY_MENU  then
      --label:setString("MENU clicked!")
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function ShopScene:ButtonBuy_onClicked(sender, eventType)
  local this = self
  local pkg = sender.package
  --print('[ShopScene:ButtonBuy_onClicked] eventType => ', eventType)
  if eventType == ccui.TouchEventType.ended then
    print('[ShopScene:ButtonBuy_onClicked] you want to buy : ' , pkg.packageName)
    local msgParams = {
      title = '购买道具',
      msg = string.format('购买 %s\n%s\n价格 %d 元', pkg.packageName, pkg.packageDesc, pkg.price / 100),
      closeOnClickOutside = false,
      buttonType = 'ok|cancel',
      onOk = function() return this:buyPackage(pkg) end
    }
    showMessageBox(this, msgParams)
  end
end

function ShopScene:ButtonBack_onClicked(sender, eventType)
  cc.Director:getInstance():popScene()
end

function ShopScene:close()
  cc.Director:getInstance():popScene(cc.Tr)
end

function ShopScene:buyPackage(pkg)
  local this = self
  local params = {
    pkgId = pkg.packageId
  }
  this.gameConnection:request('ddz.hallHandler.buyItem', params, function(data)
      dump(data, '[ShopScene:buyPackage] ddz.hallHandler.buyItem =>')
      return true
    end)
end

local function createScene()
  local scene = cc.Scene:create()
  return ShopScene.extend(scene)
end

require('network.ConnectionStatusPlugin').bind(ShopScene)

return createScene
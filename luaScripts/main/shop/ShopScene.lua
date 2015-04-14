
local ShopScene = class('ShopScene')
local gameConnection = require('network.GameConnection')
local AccountInfo = require('AccountInfo')

local showToastBox = require('UICommon.ToastBox').showToastBox
local showMessageBox = require('UICommon.MsgBox').showMessageBox

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
  local uiRoot = cc.CSLoader:createNode('ShopScene2.csb')
  self.uiRoot = guiReader
  rootLayer:addChild(uiRoot)

  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initKeypadHandler()
  self.ShopItemModel:setVisible(false)

  self.ShopItemList:addScrollViewEventListener(__bind(self.ListView_onScrollViewEvent, self))

  self:updateUserInfo()
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

  if not self.listHasItemModel then
    -- listView = ccui.ListView:create()
    -- listView:setAnchorPoint(cc.p(0,0))
    -- listView:setPosition(cc.p(0,0))
    -- listView:setContentSize(cc.size(800, 412))
    -- listView:setGravity(ccui.ListViewGravity.left)
    -- listView:setDirection(ccui.ScrollViewDir.vertical)
    -- listView:setBounceEnabled(true)
    -- listView:setColor(cc.c3b(0x96, 0x96, 0xFF))
    -- listView:setOpacity(100)
    -- listView:addEventListener(__bind(self.ShopItemList_onEvent, self))
    -- self.ShopItemList = listView
    -- self.PanelRoot:addChild(listView)
    local item_model = self.ShopItemModel:clone()
    item_model:setVisible(true)
    self.ShopItemList:setItemModel(item_model)
    self.listHasItemModel = true
  else
    --self.ShopItemList:removeAllItems()
  end
  
  -- local textureCache = cc.Director:getInstance():getTextureCache()
  -- textureCache:addImage('images/bag1.png')
  -- textureCache:addImage('images/bag2.png')
  -- textureCache:addImage('images/bag3.png')
  -- textureCache:addImage('images/bag4.png')

  local function addListItem(pkg, index)
    this.ShopItemList:pushBackDefaultItem()
    local item = this.ShopItemList:getItem(index-1)
    local label, imgIcon, price, button
    price = pkg.price or 0.0
    label = tolua.cast(ccui.Helper:seekWidgetByName(item, 'LabelPkgName'), 'ccui.Text')
    label:setString(pkg.packageName)
    label = tolua.cast(ccui.Helper:seekWidgetByName(item, 'LabelPkgDesc'), 'ccui.Text')
    --label:ignoreContentAdaptWithSize(true)
    label:setContentSize(cc.size(370, 60))
    label:setPosition(96, 10)
    label:setString(pkg.packageDesc)
    -- label = tolua.cast(ccui.Helper:seekWidgetByName(item, 'LabelPrice'), 'ccui.Text')
    -- label:setString(string.format('￥%0.2f 元', price/100))

    imgIcon = tolua.cast(ccui.Helper:seekWidgetByName(item, 'ImagePkgIcon'), 'ccui.ImageView')
    if pkg.packageIcon then
      local imgFilename = 'images/' .. pkg.packageIcon
      print('packageIcon => ', imgFilename)
      --imgIcon:loadTexture(imgFilename, ccui.TextureResType.localType)
    end

    button = tolua.cast(ccui.Helper:seekWidgetByName(item, 'ButtonBuy'), 'ccui.Button')
    button.package = pkg
    button:setTitleText(string.format('￥%0.2f', price/100))
    button:addTouchEventListener(this._onButtonBuyClicked)
    -- item:setOpacity(0)
    -- item:runAction(cc.FadeIn:create(0.8))
  end

  local function addItems(items)
    local actions = {}
    for i=1, #items do
      local pkg = items[i]
      table.insert(actions, cc.DelayTime:create(0.05))
      table.insert(actions, cc.CallFunc:create(__bind(__bind(addListItem, pkg), i)))
    end
    table.insert(actions, cc.DelayTime:create(0.01))
    table.insert(actions, cc.CallFunc:create(function() 
        this.ShopItemList:jumpToTop()
        this.ImageThumb:setPosition(3, 300)
      end))
    this:runAction(cc.Sequence:create(unpack(actions)))
  end
  
  self.ShopItemList:removeAllItems()

  if _globalShopItems == nil then
    this.gameConnection:request('ddz.hallHandler.getShopItems', {}, function(data) 
      dump(data, '[ddz.hallHandler.getShopItems] data =>')
      _globalShopItems = data
      addItems(_globalShopItems)
    end)
  else
    addItems(_globalShopItems)
  end
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
      msg = string.format('购买 %s\n%s\n价格 %.1f 元', pkg.packageName, pkg.packageDesc, pkg.price / 100),
      closeOnClickOutside = false,
      closeAsCancel = true,
      buttonType = 'ok|close',
      --width = 450,
      onOk = function() return this:buyPackage(pkg) end
    }
    showMessageBox(this, msgParams)
  end
end

function ShopScene:ButtonBack_onClicked(sender, eventType)
  self:close()
end

function ShopScene:close()
  cc.Director:getInstance():popScene()
end

function ShopScene:buyPackage(pkg)
  local this = self
  local params = {
    pkgId = pkg.packageId
  }
  this.gameConnection:request('ddz.hallHandler.buyItem', params, function(data)
      dump(data, '[ShopScene:buyPackage] ddz.hallHandler.buyItem =>', 20)
      dump(data.pkg.packageData.items, '[ShopScene:buyPackage] packageData.items =>')
      local purchaseOrder = data.pkg
      local pkgData = purchaseOrder.packageData
      local tdOrderId = purchaseOrder.userId .. '-' .. purchaseOrder.orderId
      local pkgId = pkgData.packageId .. '-' .. pkgData.packageName
      local pkgCoins = pkgData.packageCoins
      local paidPrice = purchaseOrder.paidPrice
      local paymentMethodId = 'unknown'
      if purchaseOrder.payment then 
        paymentMethodId = purchaseOrder.payment.paymentMethod.methodId
      end

      print('[ShopScene:buyPackage] tdOrderId: ', tdOrderId, ', pkgId: ', pkgId)
      TDGAVirtualCurrency:onChargeRequest(tdOrderId, pkgId, paidPrice, 'CNY', pkgCoins, paymentMethodId)
      return true
    end)
end

function ShopScene:updateUserInfo()
  local user = AccountInfo.getCurrentUser();
  
  -- local idNickName = string.format("%s (%s)", user.nickName, user.userId)
  -- self.LabelNickName:setString(idNickName)
  local coins = user.ddzProfile.coins or 0
  self.LabelCoins:setString(coins)

  -- local iconIndex = tonumber(user.headIcon) or 1
  -- if iconIndex < 1 then
  --   iconIndex = 1
  -- end

  -- self.ImageHeadIcon:loadTexture(
  --     string.format('NewRes/idImg/idImg_head_%02d.jpg', iconIndex),
  --     ccui.TextureResType.localType
  --   )

  -- if user.headIcon then
  --   self.ButtonHead:loadTextureNormal(Resources.getHeadIconPath(user.headIcon), ccui.TextureResType.localType)
  -- end
end


function ShopScene:ListView_onScrollViewEvent(sender, evenType)
  local this = self
  if evenType == ccui.ScrollviewEventType.scrollToBottom then
      print("SCROLL_TO_BOTTOM")
  elseif evenType ==  ccui.ScrollviewEventType.scrollToTop then
      print("SCROLL_TO_TOP")
  end

    -- float minY = _contentSize.height - _innerContainer->getContentSize().height;
    -- float h = - minY;
    -- jumpToDestination(Vec2(_innerContainer->getPosition().x, minY + percent * h / 100.0f));

  local innerContainer = sender:getInnerContainer()
  local contentSize = sender:getContentSize()
  local innerContainerSize = sender:getInnerContainerSize()
  local minY = contentSize.height - innerContainerSize.height
  local h = - minY
  local percent = cc.p(innerContainer:getPosition()).y / h

  local thumbMinY = 10
  local thumbMaxY = 300
  local thumbHeight = thumbMaxY - thumbMinY
  local y = thumbHeight * (-percent) + thumbMinY

  if y > thumbMaxY then
    y = thumbMaxY
  elseif y < thumbMinY then
    y = thumbMinY
  end

  -- cclog('[ShopScene:ListView_onScrollViewEvent] h: %0.2f, minY: %0.2f, percent: %0.2f, y: %0.2f',
  --   h, minY, percent, y)

  if this.ImageThumb then
    this.ImageThumb:setPosition(3, y)
  end
  -- this.ImageThumb:setPosition(3, y)

end


local function createScene()
  local scene = cc.Scene:create()
  return ShopScene.extend(scene)
end

require('network.ConnectionStatusPlugin').bind(ShopScene)

return createScene
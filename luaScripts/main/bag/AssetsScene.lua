--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

local AssetsScene = class('AssetsScene')
local gameConnection = require('network.GameConnection')
local AccountInfo = require('AccountInfo')

local showToastBox = require('UICommon.ToastBox').showToastBox
local showMessageBox = require('UICommon.MessageBox').showMessageBox

function AssetsScene.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, AssetsScene)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function AssetsScene:ctor(...)
  local this = self
  self:registerScriptHandler(function(event)
    print('[AssetsScene] event => ', event)
    local on_event = 'on_' .. event
    if type(this[on_event]) == 'function' then
      this[on_event](this)
    end
  end)

  this._onButtonUseClicked = __bind(this.ButtonUse_onClicked, this)

  self:init()

end

function AssetsScene:init()
  local this = self
  local rootLayer = cc.Layer:create()

  this.gameConnection = require('network.GameConnection')

  self.rootLayer = rootLayer
  self:addChild(rootLayer)

  local guiReader = ccs.GUIReader:getInstance()
  -- local uiRoot = guiReader:widgetFromBinaryFile('gameUI/Shop.csb')
  local uiRoot = cc.CSLoader:createNode('AssetsScene.csb')
  self.uiRoot = guiReader
  rootLayer:addChild(uiRoot)

  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initKeypadHandler()
  self.AssetItemModel:setVisible(false)


end


function AssetsScene:on_enterTransitionFinish()
  local this = self

  self:loadAssetItems()
end

function AssetsScene:on_exit()
end

function AssetsScene:loadAssetItems()
  local this = self
  local listView

  if not self.listHasItemModel then
    local item_model = self.AssetItemModel:clone()
    item_model:setVisible(true)
    self.AssetItemList:setItemModel(item_model)
    self.listHasItemModel = true
  else
    --self.ShopItemList:removeAllItems()
  end
  
  local textureCache = cc.Director:getInstance():getTextureCache()
  textureCache:addImage('images/bag1.png')
  textureCache:addImage('images/bag2.png')
  textureCache:addImage('images/bag3.png')
  textureCache:addImage('images/bag4.png')
  textureCache:addImage('images/bag5.png')


  this.gameConnection:request('ddz.hallHandler.getAssetItems', {}, function(data) 
    dump(data, '[ddz.hallHandler.getAssetItems] data =>')
    self.AssetItemList:removeAllItems()
    for i=1, #data.assets do
      local goods = data.assets[i]
      this.AssetItemList:pushBackDefaultItem()
      local item = this.AssetItemList:getItem(i-1)
      local label, imgIcon, price, button, inUsePanel
      price = goods.price or 0.0
      label = tolua.cast(ccui.Helper:seekWidgetByName(item, 'LabelGoodsName'), 'ccui.Text')
      label:setString(goods.goodsName)
      label = tolua.cast(ccui.Helper:seekWidgetByName(item, 'LabelGoodsDesc'), 'ccui.Text')
      label:setString(goods.goodsDesc)
      label = tolua.cast(ccui.Helper:seekWidgetByName(item, 'LabelRemainingCount'), 'ccui.Text')
      label:setString(string.format('剩余数量: %d', goods.count))

      imgIcon = tolua.cast(ccui.Helper:seekWidgetByName(item, 'ImageGoodsIcon'), 'ccui.ImageView')
      if goods.goodsIcon then
        local imgFilename = 'images/' .. goods.goodsIcon
        print('goodsIcon => ', imgFilename)
        imgIcon:loadTexture(imgFilename, ccui.TextureResType.localType)
      end

      button = tolua.cast(ccui.Helper:seekWidgetByName(item, 'ButtonUse'), 'ccui.Button')
      button.goods = goods
      button:addTouchEventListener(this._onButtonUseClicked)
      inUsePanel = tolua.cast(ccui.Helper:seekWidgetByName(item, 'InUsePanel'), 'ccui.Layout')
      button:setVisible(goods.using == 0)
      inUsePanel:setVisible(goods.using == 1)
      if goods.using == 1 then
        local timeRemainingLabel = tolua.cast(ccui.Helper:seekWidgetByName(item, 'TimeRemaining'), 'ccui.Text')
        local tm = os.time() + goods.remainingSeconds
        local daySeconds = 24 * 3600
        local hourSeconds = 3600
        local tick = function()
          local elipsed = tm - os.time()
          local str = ''

          if elipsed <= 0 then
            elipsed = 0
            this:loadAssetItems()
          end

          if elipsed > daySeconds then
            str = str + math.floor(elipsed / daySeconds) + '天'
            elipsed = elipsed % daySeconds
          end
          if elipsed > hourSeconds then
            str = str .. string.format('%02d:', math.floor(elipsed / hourSeconds)) 
            elipsed = elipsed % hourSeconds
          else
            str = str .. '00:'
          end
          if elipsed > 60 then
            str = str .. string.format('%02d:', math.floor(elipsed/60)) 
            elipsed = elipsed % 60
          else
            str = str .. '00:'
          end
          str = str .. string.format('%02d', elipsed)
          timeRemainingLabel:setString(str)
        end

        timeRemainingLabel:runAction(
          cc.Repeat:create(
            cc.Sequence:create(cc.CallFunc:create(tick), cc.DelayTime:create(1)), 
            goods.remainingSeconds
          ))
      end
    end
  end)
end

function AssetsScene:initKeypadHandler()
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

function AssetsScene:ButtonUse_onClicked(sender, eventType)
  local this = self
  local goods = sender.goods
  sender:setBright(false)
  --print('[AssetsScene:ButtonBuy_onClicked] eventType => ', eventType)
  if eventType == ccui.TouchEventType.ended then
    print('[AssetsScene:ButtonBuy_onClicked] you want to buy : ' , goods.packageName)
    local msgParams = {
      title = '使用道具',
      msg = string.format('使用道具 %s\n%s', goods.goodsName, goods.goodsDesc),
      closeOnClickOutside = false,
      buttonType = 'ok|cancel',
      onOk = function() return this:useGoods(goods) end,
      onCancelCallback = function() sender:setBright(true) end
    }
    showMessageBox(this, msgParams)
  end
end

function AssetsScene:ButtonBack_onClicked(sender, eventType)
  self:close()
end

function AssetsScene:close()
  cc.Director:getInstance():popScene()
end

function AssetsScene:useGoods(goods)
  local this = self
  local params = {
    assetId = goods._id;
  }
  this.gameConnection:request('ddz.hallHandler.useAssetItem', params, function(data)
      dump(data, '[ddz.hallHandler.useAssetItem] ddz.hallHandler.buyItem =>')
      if data.retCode ~= 0 then
        local msgParams = {
          title = '使用道具出错',
          msg = string.format('错误: %d, %s', data.retCode, data.message),
          closeOnClickOutside = false,
          buttonType = 'ok|cancel'
        }
        showMessageBox(this, msgParams)
      end
      this:loadAssetItems()
      return true
    end)
end

local function createScene()
  local scene = cc.Scene:create()
  return AssetsScene.extend(scene)
end

require('network.ConnectionStatusPlugin').bind(AssetsScene)

return createScene
local AccountInfo = require('AccountInfo')
local Resources = require('Resources')
local showMessageBox = require('UICommon.MsgBox').showMessageBox
local showToastBox = require('UICommon.ToastBox2').showToastBox
local hideToastBox = require('UICommon.ToastBox2').hideToastBox
local utils = require('utils.utils')
local HallScene2 = class('HallScene2')

function HallScene2.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, HallScene2)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function HallScene2:ctor(...)
  local this = self
  this.hidenRetries = 4
  self:registerScriptHandler(function(event)
    print('[HallScene2] event => ', event)
    local on_event = 'on_' .. event
    if type(this[on_event]) == 'function' then
      this[on_event](this)
    end
  end)

  self:init()

end

function HallScene2:on_enter()
  print('[HallScene2:on_enter] ...')
  self:updateUserInfo()
  self.gameConnection.needReconnect = false
  self.gameConnection:checkLoginRewardEvent()
end

function HallScene2:on_enterTransitionFinish()
end

function HallScene2:on_cleanup()
end

function HallScene2:init()
  self:initKeypadHandler()
  local rootLayer = cc.Layer:create()
  self:addChild(rootLayer)

  self.gameConnection = require('network.GameConnection')
  self.gameConnection:scheduleUpdateSession()
  local guiReader = ccs.GUIReader:getInstance()
  
  -- local ui = guiReader:widgetFromBinaryFile('gameUI/Hall.csb')
  local ui = cc.CSLoader:createNode('HallScene2.csb')
--  ui:setAnchorPoint(0, 0)
--  ui:setPosition(0, 0)
  rootLayer:addChild(ui)
  require('utils.UIVariableBinding').bind(ui, self, self)

  -- ddz.clearPressedDisabledTexture({
  --   self.ButtonStore,
  --   self.ButtonTask,
  --   self.ButtonAssets,
  --   self.ButtonHead,
  --   self.ButtonHelp,
  --   self.ButtonMsg,
  --   self.ButtonSetting,
  --   self.ButtonVip,
  --   self.ButtonPrize,
  --   self.ButtonNormalRoom,
  --   self.ButtonYueZhan
  -- })

  TalkingDataGA:onEvent(ddz.TDEventType.VIEW_EVENT, {
      action = ddz.ViewAction.ACTION_ENTER_VIEW,
      view = ddz.ViewName.HALL
    })

  local user = AccountInfo.getCurrentUser();
  local idNickName = string.format("%s (%d)", user.nickName, user.userId)

  self.gameConnection:request('ddz.loginRewardsHandler.queryLoginRewards', {}, function(data)
      self.gameConnection.pomeloClient:emit('onLoginReward', data)
    end)

  
  local textureCache = cc.Director:getInstance():getTextureCache()
  
  
  --local modelPanel = ccui.Helper:seekWidgetByName(ui, 'model_Panel')
  ddz.clearPressedDisabledTexture(self.PanelFriendsItemModel:getChildByName('ButtonUserHead'))
  ddz.clearPressedDisabledTexture(self.PanelFriendsItemModel:getChildByName('ButtonChat'))
  ddz.clearPressedDisabledTexture(self.PanelFriendsItemModel:getChildByName('ButtonYZ'))

  local model = self.PanelFriendsItemModel:clone()
  self.PanelFriendsItemModel:setVisible(false)
  local listview = self.ListViewFriends
  listview:setItemModel(model)
  listview:setVisible(false)

  model = self.PanelPlayedItemModel:clone()
  self.PanelPlayedItemModel:setVisible(false)
  listview = self.ListViewPlayed
  listview:setItemModel(model)
  listview:setVisible(true)



  local gameRooms = ddz.GlobalSettings.rooms

  self.CheckBoxFriends:setSelected(false)
  self.CheckBoxPlayed:setSelected(true)
  self:loadPlayedList()

  -- for i=1, 5 do
  --   listview:pushBackDefaultItem()
  --   local item = listview:getItem(i-1)
  --   ddz.clearPressedDisabledTexture(item:getChildByName('ButtonUserHead'))
  --   ddz.clearPressedDisabledTexture(item:getChildByName('ButtonChat'))
  --   ddz.clearPressedDisabledTexture(item:getChildByName('ButtonYZ'))
  -- end

  
  local snow = cc.ParticleSystemQuad:create('snow.plist')
  snow:setPosition(200, 480)
  rootLayer:addChild(snow)

  snow = cc.ParticleSystemQuad:create('snow.plist')
  snow:setPosition(600, 480)
  rootLayer:addChild(snow)

  --require('utils.UIVariableBinding').bind(ui, self, self)

  -- local sprite = cc.Sprite:create('images/menu_icon_02.png')
  -- sprite:setPosition(400,240)
  -- rootLayer:addChild(sprite, 1000)

  --self:grayButtonStore(sprite)
  --dialog = require('chat.ChatLayer').new()
  --dialog = require('everydaylogin.EveryDayLoginDialog').new({"getted","getted","get","get","disable","disable","disable"})
  --self:addChild(dialog)
end

function HallScene2:updateUserInfo()
  local user = AccountInfo.getCurrentUser();
  
  local idNickName = string.format("%s (%s)", user.nickName, user.userId)
  self.LabelNickName:setString(idNickName)
  local coins = user.ddzProfile.coins or 0
  self.LabelCoins:setString(coins)

  local iconIndex = tonumber(user.headIcon) or 1
  if iconIndex < 1 then
    iconIndex = 1
  end

  self.ImageHeadIcon:loadTexture(
      string.format('NewRes/idImg/idImg_head_%02d.jpg', iconIndex),
      ccui.TextureResType.localType
    )

  -- if user.headIcon then
  --   self.ButtonHead:loadTextureNormal(Resources.getHeadIconPath(user.headIcon), ccui.TextureResType.localType)
  -- end
end

function HallScene2:loadPlayedList(refresh)
  local this = self
  local listview = this.ListViewPlayed

  local function fillPlayedList()
    listview:removeAllItems()
    for i=1, #ddz.playedUsers do
      local userInfo = ddz.playedUsers[i]
      listview:pushBackDefaultItem()
      local item = listview:getItem(i-1)
      item:getChildByName('LabelUserNickName'):setString(string.format('%s (%d)', userInfo.nickName, userInfo.userId))
      local iconIndex = userInfo.headIcon
      if iconIndex == nil or tonumber(iconIndex) < 1 then
        iconIndex = os.time() % 8 + 1
      end
      item:getChildByName('ImageHeadIcon'):loadTexture(
          string.format('NewRes/idImg/idImg_head_%02d.jpg', iconIndex),
          ccui.TextureResType.localType
        )
    end
    this.playedListLoaded = true
  end

  local function loadData(cb)
    if ddz.playedUsers == nil or refresh then
      this.gameConnection:request('ddz.hallHandler.getPlayWithMeUsers', {}, function(data)
          dump(data, 'ddz.hallHandler.getPlayWithMeUsers => data', 3)
          ddz.playedUsers = data.users
          utils.invokeCallback(cb)
        end)
    else
      utils.invokeCallback(cb)
    end
  end

  if this.playedListLoaded then
    return
  end

  loadData(fillPlayedList)

end

function HallScene2:loadFriendsList(refresh)
  local this = self
  local listview = this.ListViewFriends

  local function fillFriendsList()
    listview:removeAllItems()
    for i=1, #ddz.myFriends do
      local userInfo = ddz.myFriends[i]
      listview:pushBackDefaultItem()
      local item = listview:getItem(i-1)
      item:getChildByName('LabelUserNickName'):setString(string.format('%s (%d)', userInfo.nickName, userInfo.userId))
      local iconIndex = userInfo.headIcon
      if iconIndex == nil or iconIndex < 1 then
        iconIndex = os.time() % 8 + 1
      end
      item:getChildByName('ImageHeadIcon'):loadTexture(
          string.format('NewRes/idImg/idImg_head_%02d.jpg', iconIndex),
          ccui.TextureResType.localType
        )
    end
    this.friendsListLoaded = true
  end

  local function loadData(cb)
    if ddz.myFriends == nil or refresh then
      this.gameConnection:request('ddz.hallHandler.getFriends', {}, function(data)
          dump(data, 'ddz.hallHandler.getFriends => data', 3)
          ddz.myFriends = data.users
          utils.invokeCallback(cb)
        end)
    else
      utils.invokeCallback(cb)
    end
  end

  if this.friendsListLoaded then
    return
  end

  loadData(fillFriendsList)
end

function HallScene2:ListViewRooms_onEvent(sender, eventType)
  -- local this = self
  -- local curIndex = this.ListViewRooms:getCurSelectedIndex()
  -- if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END and curIndex >= 0 then
  --   local item = this.ListViewRooms:getItem(curIndex)
  --   local gameRoom = item.gameRoom
  --   dump(gameRoom, 'selected room: ')
  --   this:tryEnterRoom(gameRoom)
  -- end
end

function HallScene2:tryEnterRoom(gameRoom)
  local this = self
  local coins = 0
  local currentUser = AccountInfo.getCurrentUser()
  if currentUser and currentUser.ddzProfile then
    coins = currentUser.ddzProfile.coins or 0
  end

  this.room = nil
  this.waitingOrderId = nil

  local eventData = {
    roomId = gameRoom.roomId,
    roomName = gameRoom.roomName
  } 
  TalkingDataGA:onEvent("尝试进入房间", eventData) 

  local toastParams = {
    id = 'enteringRoom',
    zorder = 1099,
    showLoading = true, 
    grayBackground = true,
    closeOnTouch = false,
    closeOnBack = false,
    showingTime = 15,
    msg = '正在进入房间, 马上开始...'
  }

  local enterTimeoutActionId = nil
  local enteringRoomToast = showToastBox(this, toastParams)
  enterTimeoutActionId = this:runAction(cc.Sequence:create(
      cc.DelayTime:create(15.1),
      cc.CallFunc:create(function() 
          local enterTimeoutActionId = nil
          if enteringRoomToast:isVisible() then
            enteringRoomToast:close(true)
          end
        end)
    ))

  local onBuyPackage = function(room, pkg)
    dump(pkg, 'try to buy package')
    --local this = self
    local params = {
      pkgId = pkg.packageId
    }
    this.room = room
    this.gameConnection:request('ddz.hallHandler.buyItem', params, function(data)
        dump(data, '[HallScene2:onBuyPackage] ddz.hallHandler.buyItem =>', 20)
        dump(data.pkg.packageData.items, '[HallScene2:onBuyPackage] packageData.items =>')
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

        this.waitingOrderId = purchaseOrder.orderId

        print('[HallScene2:onBuyPackage] tdOrderId: ', tdOrderId, ', pkgId: ', pkgId)
        TDGAVirtualCurrency:onChargeRequest(tdOrderId, pkgId, paidPrice, 'CNY', pkgCoins, paymentMethodId)
        return true
      end)
  end

  local onCancelBuyPackage = function()
  end

  local doTryEnterRoom = function()
    local params = {
      room_id = gameRoom.roomId,
      table_id = gameRoom.tableId
    }

    dump(params, '[doTryEnterRoom] params =>')

    this.gameConnection:request('ddz.entryHandler.tryEnterRoom', params, function(data) 
      dump(data, "[ddz.entryHandler.tryEnterRoom] data =>")
      if enterTimeoutActionId then
        this:stopAction(enterTimeoutActionId)
        enterTimeoutActionId = nil
        if enteringRoomToast:isVisible() then
          enteringRoomToast:close(false)
        end
      end

      if data.retCode == ddz.ErrorCode.SUCCESS then
        ddz.selectedRoom = data.room;
        ddz.selectedRoom.tableId = gameRoom.tableId 
        local createGameScene = require('gaming.GameScene2')
        local gameScene = createGameScene()
        cc.Director:getInstance():pushScene(gameScene)
      elseif data.retCode == ddz.ErrorCode.COINS_NOT_ENOUGH then
        local params = {
          msg = data.recruitMsg
          , grayBackground = true
          , closeOnClickOutside = false
          , buttonType = 'ok|close'
          , closeAsCancel = true
          , onCancel = onCancelBuyPackage
          , onOk = function() onBuyPackage(data.room, data.pkg) end
        }
        showMessageBox(this, params)
      else
        -- 提示用户金币超过准入上限，请进入更高级别的房间
        local params = {
          msg = data.message
          , grayBackground = true
          , closeOnClickOutside = false
          , buttonType = 'ok'
        }

        showMessageBox(this, params)
      end
    end)
  end

  this:runAction(cc.Sequence:create(
      cc.DelayTime:create(0.8),
      cc.CallFunc:create(doTryEnterRoom)
    ))


end

function HallScene2:onChargeCallback(msg)
  local this = self

  if this.waitingOrderId == msg.purchaseOrderId then
    this:tryEnterRoom(this.room)
  end
end

function HallScene2:checkMinCoinsQty(gameRoom, coins) 
  local this = self

  -- 小于等于0，代表不限制
  if gameRoom.minCoinsQty <= 0 then
    return true
  end

  -- 大于最小数，返回
  if coins >= gameRoom.minCoinsQty then
    return true
  end

  -- 提示用户金币不足，需购买
  local params = {
    msg = string.format('您的金币不足, 还差 %d , 请先充值. 谢谢!', gameRoom.minCoinsQty - coins)
    , grayBackground = true
    , closeOnClickOutside = false
    , buttonType = 'ok'
  }

  showMessageBox(self, params)
end

function HallScene2:checkMaxCoinsQty(gameRoom, coins) 
  local this = self

  -- 小于等于0，代表不限制
  if gameRoom.maxCoinsQty <= 0 then
    return true
  end

  -- 大于最大数，返回
  if coins <= gameRoom.maxCoinsQty then
    return true
  end

  -- 提示用户金币超过准入上限，请进入更高级别的房间
  local params = {
    msg = string.format('您的金币已超过准入上限%d, 请移步到更高级别的房间. 谢谢!', gameRoom.maxCoinsQty)
    , grayBackground = true
    , closeOnClickOutside = false
    , buttonType = 'ok'
  }

  showMessageBox(self, params)
end



function HallScene2:initKeypadHandler()
  local this = self
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      event:stopPropagation()
      this:confirmQuit()
    elseif keyCode == cc.KeyCode.KEY_MENU  then
      --label:setString("MENU clicked!")
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function HallScene2:close( ... )
  local this = self

  print('hall scene exit')
  this.gameConnection:request('ddz.entryHandler.quit', {userId = AccountInfo.getCurrentUser().userId}, function(data) 
    dump(data, 'ddz.entryHandler.quit')
  end)
  ddz.endApplication()
end

function HallScene2:confirmQuit( ... )

  local function doQuitGame()
    self:close()
  end

  local msgParams = {
    --msg = '退出游戏?',
    title = '退出游戏?',
    buttonType = 'ok|cancel',
    width = 430,
    height = 250,
    onOk = doQuitGame
  }

  showMessageBox(self, msgParams)
end

function HallScene2:ButtonNormalRoom_onClicked(sender, event)
  local this = self
  local rooms = ddz.GlobalSettings.rooms
  local gameRoom = {roomId=0, roomName='普通房'}
  this:tryEnterRoom(gameRoom)
end


function HallScene2:ButtonAppointPlay_onClicked(sender, event)
  local this = self
  local rooms = ddz.GlobalSettings.rooms
  local gameRoom = {roomId=10000, roomName='约战房', tableId = 1}
  this:tryEnterRoom(gameRoom)
end


function HallScene2:ButtonHead_onClicked(sender, event)
  print('[HallScene2:ButtonHead_onClicked]')
  -- local userProfile = require('profile.UserProfileScene')()
  -- cc.Director:getInstance():pushScene(userProfile)
  local profileLayer = require('profile.UserProfileLayer').new()
  self:addChild(profileLayer)
  profileLayer:show()
end

function HallScene2:ButtonBack_onClicked(sender, eventType)
  self:confirmQuit()
  -- body
end

function HallScene2:ButtonStore_onClicked(sender, eventType)
  local scene = require('shop.ShopScene')()
  cc.Director:getInstance():pushScene(cc.TransitionMoveInR:create(0.25, scene))
end

function HallScene2:ButtonTask_onClicked(sender, eventType)
  local scene = require('task.TaskScene2')()
  cc.Director:getInstance():pushScene(cc.TransitionMoveInR:create(0.25, scene))
end

function HallScene2:ButtonAssets_onClicked(sender, eventType)
  local scene = require('bag.AssetsScene2')()
  cc.Director:getInstance():pushScene(cc.TransitionMoveInR:create(0.25, scene))
end

function HallScene2:ButtonSetting_onClicked(sender, eventType)
  require('sysConfig.AudioConfigLayer').showAudioConfig(self, {})
end

function HallScene2:ButtonQuickStart_onClicked(sender, eventType)
  self:ButtonNormalRoom_onClicked(sender, eventType)
end

function HallScene2:CheckBoxPlayed_onEvent(sender, eventType)
  if self.CheckBoxFriends:isSelected() then
    self.CheckBoxFriends:setSelected(false)    
    self.ListViewPlayed:setVisible(true)
    self.ListViewFriends:setVisible(false)    
    self:loadPlayedList()
  else
    self.CheckBoxPlayed:setSelected(true)
  end
end

function HallScene2:CheckBoxFriends_onEvent(sender, eventType)
  if self.CheckBoxPlayed:isSelected() then
    self.CheckBoxPlayed:setSelected(false)
    self.ListViewPlayed:setVisible(false)
    self.ListViewFriends:setVisible(true)
    self:loadFriendsList()
  else
    self.CheckBoxFriends:setSelected(true)
  end
end


local function createScene()
  local scene = cc.Scene:create()
  return HallScene2.extend(scene)
end

require('network.ConnectionStatusPlugin').bind(HallScene2)
return createScene
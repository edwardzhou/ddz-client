--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

local AccountInfo = require('AccountInfo')
local Resources = require('Resources')
local showMessageBox = require('UICommon.MsgBox').showMessageBox
local showToastBox = require('UICommon.ToastBox2').showToastBox
local hideToastBox = require('UICommon.ToastBox2').hideToastBox
local utils = require('utils.utils')
local HallScene2 = class('HallScene2')
local showAppointPlayList = require('appointPlay.AppointPlayListLayer').showAppointPlayList
local showUserInfo = require('profile.UserInfoLayer').showUserInfo

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

  if self.reloadPlayedData then
    self:loadPlayedList()
  end
end

function HallScene2:on_enterTransitionFinish()
  local this = self

  if ddz.gotoAppointPlay ~= nil then
    self:enterAppointPlay()
  end

  this.gameConnection:getAppointPlays()

  if ddz.needReloadFriendList then
    ddz.needReloadFriendList = false
    self.reloadFriendData = true
    if self.CheckBoxFriends:isSelected() then
      self:loadFriendsList()
    end
  end
end

function HallScene2:enterAppointPlay()
  local this = self
  if ddz.gotoAppointPlay ~= nil then
    local appointPlay = ddz.gotoAppointPlay
    ddz.gotoAppointPlay = nil
    local gameRoom = {roomId=10000, roomName='约战房', tableId=appointPlay.appointId}
    this:tryEnterRoom(gameRoom)
  end
end

function HallScene2:on_cleanup()
end

function HallScene2:init()
  local this = self
  self:initKeypadHandler()
  local rootLayer = cc.Layer:create()
  self:addChild(rootLayer)

  this.reloadPlayedData = true
  this.reloadFriendData = true

  this.appointUsers = {}

  self.gameConnection = require('network.GameConnection')
  self.gameConnection:scheduleUpdateSession()
  local guiReader = ccs.GUIReader:getInstance()
  
  -- local ui = guiReader:widgetFromBinaryFile('gameUI/Hall.csb')
  local ui = cc.CSLoader:createNode('HallScene2.csb')
--  ui:setAnchorPoint(0, 0)
--  ui:setPosition(0, 0)
  rootLayer:addChild(ui)
  require('utils.UIVariableBinding').bind(ui, self, self)

  -- TalkingDataGA:onEvent(ddz.TDEventType.VIEW_EVENT, {
  --     action = ddz.ViewAction.ACTION_ENTER_VIEW,
  --     view = ddz.ViewName.HALL
  --   })

  -- _analytics:logEvent(ddz.TDEventType.VIEW_EVENT, {
  --     action = ddz.ViewAction.ACTION_ENTER_VIEW,
  --     view = ddz.ViewName.HALL
  --   })

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

  -- model = self.PanelAppointItemModel:clone()
  -- self.PanelAppointItemModel:setVisible(false)
  -- model:setVisible(true)
  -- listview = self.ListViewAppointUser
  -- listview:setItemModel(model)

  -- self.PanelAppointPlay:setVisible(false)

  local gameRooms = ddz.GlobalSettings.rooms

  self.CheckBoxFriends:setSelected(false)
  self.CheckBoxPlayed:setSelected(true)

  self.AppointPlaysTip:setVisible(false)
  self.MailBoxTip:setVisible(false)
  self.TasksTip:setVisible(false)

  self:getMyMsgBox()
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

  self:startAppointPlaysUpdater()

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
      userInfo.headIcon = iconIndex
      ccui.Helper:seekWidgetByName(item, 'ImageHeadIcon'):loadTexture(
          string.format('NewRes/idImg/idImg_head_%02d.jpg', iconIndex),
          ccui.TextureResType.localType
        )
      item:getChildByName('LabelUserCoins'):setString(
          ddz.tranlateTimeLapsed(userInfo.lastPlayed, true).cn
        )

      local button = item:getChildByName('ButtonAddFriend')
      button.userInfo = userInfo
      if userInfo.isFriend then
        button:setVisible(false)
      else
        button:addClickEventListener(function(sender) 
            this:addFriend(sender.userInfo)
          end)
      end
      button = item:getChildByName('ButtonUserHead')
      button.userInfo = userInfo
      button:addClickEventListener(function(sender) 
          this:showUserInfo(sender.userInfo)
        end)
    end
    this.playedListLoaded = true
  end

  local function loadData(cb)
    if ddz.playedUsers == nil or this.reloadPlayedData then
      this.gameConnection:request('ddz.friendshipHandler.getPlayWithMeUsers', {}, function(data)
          dump(data, 'ddz.friendshipHandler.getPlayWithMeUsers => data', 3)
          ddz.playedUsers = data.users
          this.reloadPlayedData = false
          utils.invokeCallback(cb)
        end)
    else
      utils.invokeCallback(cb)
    end
  end

  if this.playedListLoaded and not this.reloadPlayedData then
    return
  end

  loadData(fillPlayedList)
end

function HallScene2:createAppointPlay()
  local this = self;
  local params = {
    player1_userId = this.appointUsers[1].userId,
    player2_userId = this.appointUsers[2].userId
  }
  this.gameConnection:request('ddz.appointPlayHandler.createAppointPlay', params, function(data) 
      dump(data, '[ddz.appointPlayHandler.createAppointPlay] resp => ')
      this.PanelAppointPlay:setVisible(false)
      this.appointUsers = {}
      this.ListViewAppointUser:removeAllItems()

      if data.result then
        local gameRoom = {roomId=10000, roomName='约战房', tableId = data.appointPlay.appointId}
        this:tryEnterRoom(gameRoom)
      end
    end)
end

function HallScene2:ButtonCreateAppointPlay_onClicked()
  self:createAppointPlay()
end

function HallScene2:addUserToAppointPlay(userInfo)
  local this = self
  self.PanelAppointPlay:setVisible(true)
  if #self.appointUsers > 1 then
    return
  end

  if table.indexOf(self.appointUsers, userInfo) > 0 then
    return
  end

  table.insert(this.appointUsers, userInfo)
  local listview = this.ListViewAppointUser

  this.ButtonCreateAppointPlay:setEnabled(#this.appointUsers > 1)
  this.ButtonCreateAppointPlay:setBright(#this.appointUsers > 1)

  listview:pushBackDefaultItem()
  local itemIndex = #self.appointUsers
  local item = listview:getItem(itemIndex-1)
  item.userInfo = userInfo
  item:getChildByName('LabelUserNickName'):setString(string.format('%s (%d)', userInfo.nickName, userInfo.userId))
  local iconIndex = tonumber(userInfo.headIcon)
  if iconIndex == nil or iconIndex < 1 then
    iconIndex = math.floor(math.random() * 10000000) % 8 + 1
  end
  item:getChildByName('ImageHeadIcon'):loadTexture(
      string.format('NewRes/idImg/idImg_head_%02d.jpg', iconIndex),
      ccui.TextureResType.localType
    )
  item:getChildByName('LabelUserCoins'):setString(
      ddz.tranlateTimeLapsed(userInfo.addDate, true).cn
    )
  local button = item:getChildByName('ButtonRemove')
  button:addClickEventListener(function(sender) 
      table.removeItem(this.appointUsers, userInfo)
      listview:removeChild(item, true)
      if #this.appointUsers == 0 then
        self.PanelAppointPlay:setVisible(false)
      end
      this.ButtonCreateAppointPlay:setEnabled(#this.appointUsers > 1)
      this.ButtonCreateAppointPlay:setBright(#this.appointUsers > 1)
    end)
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
      local iconIndex = tonumber(userInfo.headIcon)
      if iconIndex == nil or iconIndex < 1 then
        iconIndex = math.floor(math.random() * 10000000) % 8 + 1
      end
      userInfo.headIcon = iconIndex
      ccui.Helper:seekWidgetByName(item, 'ImageHeadIcon'):loadTexture(
          string.format('NewRes/idImg/idImg_head_%02d.jpg', iconIndex),
          ccui.TextureResType.localType
        )
      item:getChildByName('LabelUserCoins'):setString(
          ddz.tranlateTimeLapsed(userInfo.addDate, true).cn
        )
      local button = item:getChildByName('ButtonYZ')
      button.userInfo = userInfo
      button:addClickEventListener(function(sender) 
          this:addUserToAppointPlay(userInfo)
        end)
      button = item:getChildByName('ButtonUserHead')
      button.userInfo = userInfo
      button:addClickEventListener(function(sender) 
          this:showUserInfo(sender.userInfo)
        end)

      button = item:getChildByName('ButtonChat')
      button.userInfo = userInfo
      button:addClickEventListener(function(sender)
          local chatLayer = require('chat.TextChatLayer').new(this.gameConnection, sender.userInfo)
          this:addChild(chatLayer)
        end)
    end
    this.friendsListLoaded = true
  end

  local function loadData(cb)
    if ddz.myFriends == nil or this.reloadFriendData then
      this.gameConnection:request('ddz.friendshipHandler.getFriends', {}, function(data)
          dump(data, 'ddz.friendshipHandler.getFriends => data', 5)
          ddz.myFriends = data.users
          this.reloadFriendData = false
          utils.invokeCallback(cb)
        end)
    else
      utils.invokeCallback(cb)
    end
  end

  if this.friendsListLoaded and not this.reloadFriendData then
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

function HallScene2:addFriend(userInfo)
  local this = self
  local params = {
    friend_userId = userInfo.userId
  }
  this.gameConnection:request('ddz.friendshipHandler.addFriend', params, function(data) 
      dump(data, '[ddz.friendshipHandler.addFriend] data => ', 5)
      local msgBoxParams = {
        msg = '好友申请已送到, 等待对方确认!'
        , grayBackground = true
        , closeOnClickOutside = true
        , autoClose = 3
        , buttonType = 'ok | close'
      }
      showMessageBox(self, msgBoxParams)
    end)
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
  -- TalkingDataGA:onEvent("尝试进入房间", eventData) 
  -- _analytics:logEvent("尝试进入房间", eventData) 

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
        this.reloadPlayedData = true
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
  local appointPlay = nil

  if ddz.appointPlays == nil or #ddz.appointPlays == 0 then
    local msgParams = {
      msg = '尚未有约战发起或约战已过期, 请在好友列表中选取两名好友并创建约战。'
      , grayBackground = true
      , closeOnClickOutside = true
      , buttonType = 'ok | close'
    }
    showMessageBox(self, msgParams)
    return
  end

  if #ddz.appointPlays > 1 then
    showAppointPlayList(this, function(appointPlay) 
        local gameRoom = {roomId=10000, roomName='约战房', tableId = appointPlay.appointId}
        this:tryEnterRoom(gameRoom)
      end)
  else
    appointPlay = ddz.appointPlays[1]
    local gameRoom = {roomId=10000, roomName='约战房', tableId = appointPlay.appointId}
    this:tryEnterRoom(gameRoom)
  end

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

function HallScene2:ButtonMsg_onClicked(sender, eventType)
  local scene = require('mailbox.MailBoxScene')()
  cc.Director:getInstance():pushScene(cc.TransitionMoveInR:create(0.25, scene))
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

function HallScene2:ButtonHelp_onClicked(sender, eventType)
  require('help.HelpLayer').showHelp(self, {})
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


function HallScene2:onReplyFriend(data)
  self.reloadFriendData = true
  if self.CheckBoxFriends:isSelected() then
    self:loadFriendsList()
  end
end

function HallScene2:ButtonAddFriend_onClicked()
  local params = {
    msg = string.format('请先输入好友ID!')
    , grayBackground = true
    , closeOnClickOutside = false
    , buttonType = 'ok'
  }

  showMessageBox(self, params)

end

function HallScene2:backToHallForAppointPlay()
  self:enterAppointPlay()
end

function HallScene2:startTips(tipObj)
  if tipObj:isVisible() then
    return
  end

  tipObj:setVisible(true)
  tipObj:stopAllActions()
  tipObj:runAction(cc.RepeatForever:create(
      cc.Sequence:create(
          cc.EaseElasticInOut:create(cc.ScaleTo:create(0.5, 0.2), 0.2),
          cc.DelayTime:create(0.1),
          cc.EaseElasticInOut:create(cc.ScaleTo:create(0.5, 0.15), 0.2),
          cc.DelayTime:create(0.1)
        )
    ))
end

function HallScene2:stopTips(tipObj)
  if not tipObj:isVisible() then
    return 
  end
  tipObj:stopAllActions()
  tipObj:setVisible(false)
end

function HallScene2:onAppointPlaysUpdated()
  --dump(ddz.appointPlays, '[HallScene2:onAppointPlaysUpdated] appointPlays =>')
  local this = self

  if ddz.appointPlays and #ddz.appointPlays > 0 then
    this:startTips(this.AppointPlaysTip)
  else
    this:stopTips(this.AppointPlaysTip)
  end
end

function HallScene2:startAppointPlaysUpdater()
  local this = self

  local function isExpired(expired_at)
    -- 如果是带微秒的，保留到秒级别
    if expired_at > 5000000000 then
      expired_at = math.floor(expired_at / 1000)
    end

    -- 3秒内即将过期的，都视为过期
    return (expired_at - os.time() <= 3);
  end

  local function checkAppointPlays()
    if ddz.appointPlays == nil or #ddz.appointPlays == 0 then
      this:stopTips(this.AppointPlaysTip)
      return
    end

    -- if this.AppointPlaysTip:isVisible() then
    --   return
    -- end

    -- this.AppointPlaysTip:setVisible(true)

    local appointPlay
    local hasChanges = false

    for index = #ddz.appointPlays, 1, -1 do
      appointPlay = ddz.appointPlays[index]
      if isExpired(appointPlay.expired_at) then
        table.remove(ddz.appointPlays, index)
        hasChanges = true
      end
    end

    if hasChanges then
      this:onAppointPlaysUpdated()
    end
  end

  local function checkMailBox()
    local showMailBoxTips = false
    -- if ddz.myMsgBox == nil or ddz.myMsgBox.addFriendMsgs == nil or #ddz.myMsgBox.addFriendMsgs == 0 then
    --   this:stopTips(this.MailBoxTip)
    --   return
    -- end

    if ddz.myMsgBox and ddz.myMsgBox.addFriendMsgs then
      for index=#ddz.myMsgBox.addFriendMsgs, 1, -1 do
        local msg = ddz.myMsgBox.addFriendMsgs[index]
        if msg.msgData.status ~= 0 then
          table.remove(ddz.myMsgBox.addFriendMsgs, index)
        end
      end
      if #ddz.myMsgBox.addFriendMsgs > 0 then
        showMailBoxTips = true
      end
    end

    if ddz.myMsgBox and ddz.myMsgBox.chatMsgs then
      if #ddz.myMsgBox.chatMsgs > 0 then
        showMailBoxTips = true
      end
    end

    if not showMailBoxTips then
      this:stopTips(this.MailBoxTip)
    else
      this:startTips(this.MailBoxTip)
    end

    -- if #ddz.myMsgBox.addFriendMsgs > 0 then
    --   this:startTips(this.MailBoxTip)
    -- end
  end

  self:runAction(cc.RepeatForever:create(
      cc.Sequence:create(
          cc.DelayTime:create(1),
          cc.CallFunc:create(function() 
              checkAppointPlays()
              checkMailBox()
            end)
        )
    )) 
end

function HallScene2:getMyMsgBox()
  self.gameConnection:request('ddz.messageHandler.getMyMessageBox', {}, function(data) 
    dump(data, '[ddz.messageHandler.getMyMessageBox] response => ', 5)
    if data.result then
      --ddz.myMsgBox = data.myMsgBox
      ddz.myMsgBox = {}
      ddz.myMsgBox["addFriendMsgs"] = table.select(data.myMsgBox, function(item)
          return item.msgType == 2
        end)
      ddz.myMsgBox.chatMsgs = table.select(data.myMsgBox, function(item)
           return item.msgType == 3
         end)

      dump(ddz.myMsgBox, '[HallScene2:getMyMsgBox] myMsgBox', 6)
    end
  end)
end

function HallScene2:showUserInfo(userInfo)
  showUserInfo(self, userInfo)
end

local function createScene()
  local scene = cc.Scene:create()
  return HallScene2.extend(scene)
end

require('network.ConnectionStatusPlugin').bind(HallScene2)
return createScene
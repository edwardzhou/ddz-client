require 'GuiConstants'
local AccountInfo = require('AccountInfo')
local Resources = require('Resources')

local HallScene = class('HallScene')

function HallScene.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, HallScene)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function HallScene:ctor(...)
  local this = self
  this.hidenRetries = 4
  self:registerScriptHandler(function(event)
    print('[HallScene] event => ', event)
    local on_event = 'on_' .. event
    if type(this[on_event]) == 'function' then
      this[on_event](this)
    end
  end)

  self:init()

end

function HallScene:on_enter()
  print('[HallScene:on_enter] ...')
  self:updateUserInfo()
  self.gameConnection.needReconnect = false
end

function HallScene:on_enterTransitionFinish()
end

function HallScene:on_cleanup()
end

function HallScene:init()
  self:initKeypadHandler()
  local rootLayer = cc.Layer:create()
  self:addChild(rootLayer)

  self.gameConnection = require('network.GameConnection')

  local guiReader = ccs.GUIReader:getInstance()
  
  local ui = guiReader:widgetFromBinaryFile('gameUI/Hall.csb')
--  ui:setAnchorPoint(0, 0)
--  ui:setPosition(0, 0)
  rootLayer:addChild(ui)
  require('utils.UIVariableBinding').bind(ui, self, self)
  
  local textureCache = cc.Director:getInstance():getTextureCache()
  
  textureCache:addImage('images/room1.png')
  textureCache:addImage('images/room2.png')
  textureCache:addImage('images/room3.png')
  textureCache:addImage('images/room4.png')
  textureCache:addImage('images/room5.png')

  textureCache:addImage('images/room11.png')
  textureCache:addImage('images/room12.png')
  textureCache:addImage('images/room13.png')
  textureCache:addImage('images/room14.png')
  textureCache:addImage('images/room15.png')
  
  local modelPanel = ccui.Helper:seekWidgetByName(ui, 'model_Panel')
  local model = self.PanelRoomModel:clone()
  self.PanelRoomModel:setVisible(false)
  local listview = self.ListViewRooms
  listview:setItemModel(model)

  local gameRooms = ddz.GlobalSettings.rooms

  for i=1, #gameRooms do
    listview:pushBackDefaultItem()
  end

  local items = listview:getItems()
  for i=1, #(items) do
    local gameRoom = gameRooms[i]
    local item = items[i]
    local n = 1

    item.gameRoom = gameRoom

    local roomTitle = item:getChildByName('roomTitle_Image')
    local roomIcon = item:getChildByName('roomIcon_Image')
    local roomTitleFilename = string.format("images/room1%d.png", n)
    local roomIconFilename = string.format('images/room%d.png', n)
    roomTitle:loadTexture(roomTitleFilename)
    roomIcon:loadTexture(roomIconFilename)

    local labelRoomName = tolua.cast(ccui.Helper:seekWidgetByName(item, 'Label_RoomName'), 'ccui.Text')
    local labelRoomDesc = tolua.cast(ccui.Helper:seekWidgetByName(item, 'Label_RoomDesc'), 'ccui.Text')

    labelRoomName:setString(gameRoom.roomName)
    labelRoomDesc:setString(gameRoom.roomDesc)

    local roomArea = item:getChildByName('Image_RoomArea')
    roomArea:setTag(n)
    --roomArea:addTouchEventListener(touchEventHandler)
  end
  
  local snow = cc.ParticleSystemQuad:create('snow.plist')
  snow:setPosition(200, 480)
  rootLayer:addChild(snow)

  snow = cc.ParticleSystemQuad:create('snow.plist')
  snow:setPosition(600, 480)
  rootLayer:addChild(snow)

  require('utils.UIVariableBinding').bind(ui, self, self)

end

function HallScene:updateUserInfo()
  local user = AccountInfo.getCurrentUser();
  
  self.LabelNickName:setString(user.nickName)
  local coins = user.ddzProfile.coins or 0
  self.LabelCoins:setString(coins)

  if user.headIcon then
    self.ButtonHead:loadTextureNormal(Resources.getHeadIconPath(user.headIcon), ccui.TextureResType.localType)
  end
end

function HallScene:ListViewRooms_onEvent(sender, eventType)
  local this = self
  local curIndex = this.ListViewRooms:getCurSelectedIndex()
  if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END and curIndex >= 0 then
    local item = this.ListViewRooms:getItem(curIndex)
    local gameRoom = item.gameRoom
    dump(gameRoom, 'selected room: ')
    this.gameConnection:request('ddz.entryHandler.tryEnterRoom', {room_id = gameRoom.roomId}, function(data) 
      dump(data, "[ddz.entryHandler.tryEnterRoom] data =>")
      ddz.selectedRoom = gameRoom
      local createGameScene = require('gaming.GameScene')
      local gameScene = createGameScene()
      cc.Director:getInstance():pushScene(gameScene)
    end)
  end
end

function HallScene:initKeypadHandler()
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
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

function HallScene:ButtonHead_onClicked(sender, event)
  print('[HallScene:ButtonHead_onClicked]')
  local userProfile = require('profile.UserProfileScene')()
  cc.Director:getInstance():pushScene(userProfile)
end

function HallScene:ButtonBack_onClicked(sender, eventType)
  cc.Director:getInstance():replaceScene(require('login.LoginScene')())
  -- body
end

function HallScene:ButtonStore_onClicked(sender, eventType)
  local scene = require('shop.ShopScene')()
  cc.Director:getInstance():pushScene(scene)
end

local function createScene()
  local scene = cc.Scene:create()
  return HallScene.extend(scene)
end

require('network.ConnectionStatusPlugin').bind(HallScene)

return createScene
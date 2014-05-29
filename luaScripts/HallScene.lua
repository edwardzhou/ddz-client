require 'GuiConstants'

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
  self:registerScriptHandler(function(event)
    print('event => ', event)
    if event == "enterTransitionFinish" then
      self:init()
    elseif event == 'exit' then
     end
  end)
end

function HallScene:init()
  self:initKeypadHandler()
  local rootLayer = cc.Layer:create()
  self:addChild(rootLayer)

  local guiReader = ccs.GUIReader:getInstance()
  
  local ui = guiReader:widgetFromJsonFile('UI/Hall.json')
--  ui:setAnchorPoint(0, 0)
--  ui:setPosition(0, 0)
  rootLayer:addChild(ui)
  
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
  local model = modelPanel:clone()
  modelPanel:setVisible(false)
  local listview = ccui.Helper:seekWidgetByName(ui, 'ListView_53')
  listview = tolua.cast(listview, 'ccui.ListView')
  listview:setItemModel(model)

  local gameRooms = ddz.GlobalSettings.rooms

  for i=1, #gameRooms do
    listview:pushBackDefaultItem()
  end

  local touchEventHandler = __bind(self.onRoomTouchEvent, self)

  local listItemSelected = true
  local selectedIndex = -1
  local moveTimes = 0

  local function listViewEvent(sender, eventType)
    print('[listViewEvent] eventType => ', eventType)
    if eventType == ccui.ListViewEventType.onsSelectedItem then
      listItemSelected = true
      moveTimes = 0
      selectedIndex = sender:getCurSelectedIndex()
      -- print("select child index = ", itemIndex)
      -- local item = sender:getItem(itemIndex)
      -- local gameRoom = item.gameRoom
      -- dump(gameRoom, 'selected room: ')
    elseif eventType == 1 and listItemSelected and selectedIndex >=0 then
      local item = sender:getItem(selectedIndex)
      local gameRoom = item.gameRoom
      dump(gameRoom, 'selected room: ')
      ddz.pomeloClient:request('ddz.entryHandler.tryEnterRoom', {room_id = gameRoom.roomId}, function(data) 
          dump(data, "[ddz.entryHandler.tryEnterRoom] data =>")
          --ddz.selectedRoomId = gameRoom.roomId
          ddz.selectedRoom = gameRoom
          local createGameScene = require('gaming.GameScene')
          local gameScene = createGameScene()
          cc.Director:getInstance():replaceScene(gameScene)
        end)
    end
  end

  local function scrollViewEvent(sender, eventType)
    print('[scrollViewEvent] eventType => ', eventType)
    --listItemSelected = false

    moveTimes = moveTimes + 1
    listItemSelected = moveTimes < 20
  end

  listview:addEventListenerListView(listViewEvent)
  listview:addEventListenerScrollView(scrollViewEvent)

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

    labelRoomName:setText(gameRoom.roomName)
    labelRoomDesc:setText(gameRoom.roomDesc)

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
  
  
end

function HallScene:initKeypadHandler()
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
--      if type(self.onMainMenu) == 'function' then
--        self.onMainMenu()
--      end
      cc.Director:getInstance():popScene() 
    elseif keyCode == cc.KeyCode.KEY_MENU  then
      --label:setString("MENU clicked!")
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function HallScene:onRoomTouchEvent(sender, event)
  dump(sender, '[HallScene:onRoomTouchEvent] sender ')
  dump(event, '[HallScene:onRoomTouchEvent] event ')
end

local function createScene()
  local scene = cc.Scene:create()
  return HallScene.extend(scene)
end

return createScene
local AccountInfo = require('AccountInfo')
local Resources = require('Resources')
local showMessageBox = require('UICommon.MessageBox').showMessageBox

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
  
  -- local ui = guiReader:widgetFromBinaryFile('gameUI/Hall.csb')
  local ui = cc.CSLoader:createNode('HallScene.csb')
--  ui:setAnchorPoint(0, 0)
--  ui:setPosition(0, 0)
  rootLayer:addChild(ui)
  require('utils.UIVariableBinding').bind(ui, self, self)

  ddz.clearPressedDisabledTexture(self.ButtonStore)
  ddz.clearPressedDisabledTexture(self.ButtonTask)
  ddz.clearPressedDisabledTexture(self.ButtonAssets)
  ddz.clearPressedDisabledTexture(self.ButtonBack)
  ddz.clearPressedDisabledTexture(self.ButtonHead)

  --self.ButtonTask:setBright(false)

  -- local listView = ccui.ListView:create()
  -- listView:setContentSize(800, 236)
  -- listView:setPosition(0, 145)
  -- listView:setDirection(ccui.ScrollViewDir.horizontal)
  -- listView:setGravity(ccui.ListViewGravity.top)
  -- listView:addEventListener(__bind(self.ListViewRooms_onEvent, self))
  -- self.ListViewRooms = listView
  -- ui:addChild(listView)
  
  --self.ButtonStore:set

  
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
  
  --local modelPanel = ccui.Helper:seekWidgetByName(ui, 'model_Panel')
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

    -- local roomTitle = item:getChildByName('roomTitle_Image')
    -- local roomIcon = item:getChildByName('roomIcon_Image')
    -- local roomTitleFilename = string.format("images/room1%d.png", n)
    -- local roomIconFilename = string.format('images/room%d.png', n)
    -- roomTitle:loadTexture(roomTitleFilename)
    -- roomIcon:loadTexture(roomIconFilename)

    local labelRoomName = tolua.cast(ccui.Helper:seekWidgetByName(item, 'Label_RoomName'), 'ccui.Text')
    local labelRoomDesc = tolua.cast(ccui.Helper:seekWidgetByName(item, 'Label_RoomDesc'), 'ccui.Text')

    --labelRoomDesc:ignoreContentAdaptWithSize(false)
    labelRoomName:setString(gameRoom.roomName)
    labelRoomDesc:setString(gameRoom.roomDesc)

    -- -- local textArea = ccui.Text:create()
    local textArea = labelRoomDesc
    -- textArea:ignoreContentAdaptWithSize(false)
    --textArea:setContentSize(cc.size(200, 100))
    -- textArea:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    -- textArea:setString(gameRoom.roomDesc)
    -- --textArea:setFontName("AmericanTypewriter")
    -- textArea:setFontSize(20)
    -- textArea:setAnchorPoint(0.5, 0.5)
    -- textArea:setPosition(cc.p(135, 108))  
    -- item:addChild(textArea) 

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

  --require('utils.UIVariableBinding').bind(ui, self, self)

  -- local sprite = cc.Sprite:create('images/menu_icon_02.png')
  -- sprite:setPosition(400,240)
  -- rootLayer:addChild(sprite, 1000)

  --self:grayButtonStore(sprite)
  --dialog = require('everydaylogin.EveryDayLoginDialog').new()
  --self:addChild(dialog)
end

function HallScene:grayButtonStore(s)
  do return end
  dump(cc.GLProgram, "cc.GLProgram")
  print("cc.GLProgram.SHADER_NAME_POSITION_TEXTURE_COLOR => ", cc.GLProgram.SHADER_NAME_POSITION_TEXTURE_COLOR)
  local program = cc.GLProgram:create("ccShader_PositionTextureColor_noMVP.vert", "gray.fsh")
  --print("program.SHADER_NAME_POSITION_TEXTURE_COLOR => ", program.SHADER_NAME_POSITION_TEXTURE_COLOR)
  program:link()
  program:updateUniforms()
  s:setGLProgram(program)

  s:runAction(cc.Sequence:create(
      cc.DelayTime:create(3),
      cc.CallFunc:create(function() 
          s:setGLProgram(cc.GLProgramCache:getInstance():getGLProgram('ShaderPositionTextureColor_noMVP'))
        end)
    ))

  local node = tolua.cast(self.ButtonStore:getVirtualRenderer(), "ccui.Scale9Sprite"):getSprite()
  program = cc.GLProgram:create("ccShader_PositionTextureColor_noMVP.vert", "gray.fsh")
  program:link()
  program:updateUniforms()
  node:setGLProgram(program)  
end

function HallScene:updateUserInfo()
  local user = AccountInfo.getCurrentUser();
  
  local idNickName = string.format("%s (%d)", user.nickName, user.userId)
  self.LabelNickName:setString(idNickName)
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

    local coins = 0
    local currentUser = AccountInfo.getCurrentUser()
    if currentUser and currentUser.ddzProfile then
      coins = currentUser.ddzProfile.coins or 0
    end

    -- if not self:checkMinCoinsQty(gameRoom, coins) then
    --   return
    -- end

    -- if not self:checkMaxCoinsQty(gameRoom, coins) then
    --   return
    -- end

    this.gameConnection:request('ddz.entryHandler.tryEnterRoom', {room_id = gameRoom.roomId}, function(data) 
      dump(data, "[ddz.entryHandler.tryEnterRoom] data =>")
      if data.retCode == ddz.ErrorCode.SUCCESS then
        ddz.selectedRoom = gameRoom
        local createGameScene = require('gaming.GameScene')
        local gameScene = createGameScene()
        cc.Director:getInstance():pushScene(gameScene)
      else
        -- 提示用户金币超过准入上限，请进入更高级别的房间
        local params = {
          msg = data.message
          , grayBackground = true
          , closeOnClickOutside = false
          , buttonType = 'ok'
        }

        showMessageBox(self, params)
      end
    end)
  end
end

function HallScene:checkMinCoinsQty(gameRoom, coins) 
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

function HallScene:checkMaxCoinsQty(gameRoom, coins) 
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
  cc.Director:getInstance():pushScene(cc.TransitionMoveInR:create(0.25, scene))
end

function HallScene:ButtonTask_onClicked(sender, eventType)
  local scene = require('task.TaskScene')()
  cc.Director:getInstance():pushScene(cc.TransitionMoveInR:create(0.25, scene))
end

function HallScene:ButtonAssets_onClicked(sender, eventType)
  local scene = require('bag.AssetsScene')()
  cc.Director:getInstance():pushScene(cc.TransitionMoveInR:create(0.25, scene))
end


local function createScene()
  local scene = cc.Scene:create()
  return HallScene.extend(scene)
end

require('network.ConnectionStatusPlugin').bind(HallScene)

return createScene
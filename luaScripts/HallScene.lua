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
  
  local ui = ccs.GUIReader:getInstance():widgetFromJsonFile('UI/Hall/Hall.json')
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
  listview:pushBackDefaultItem()
  listview:pushBackDefaultItem()
  listview:pushBackDefaultItem()
  listview:pushBackDefaultItem()
  listview:pushBackDefaultItem()
  local items = listview:getItems()
  
  for i=1, #(items) do
    local item = items[i]
    local n = i % 5
    if n == 0 then
      n = 5
    end
    local roomTitle = item:getChildByName('roomTitle_Image')
    local roomIcon = item:getChildByName('roomIcon_Image')
    local roomTitleFilename = string.format("images/room1%d.png", n)
    local roomIconFilename = string.format('images/room%d.png', n)
    roomTitle:loadTexture(roomTitleFilename)
    roomIcon:loadTexture(roomIconFilename)
  end
  
  local snow = cc.ParticleSystemQuad:create('scenes/Resources/snow.plist')
  snow:setPosition(200, 480)
  rootLayer:addChild(snow)

  snow = cc.ParticleSystemQuad:create('scenes/Resources/snow.plist')
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

local function createScene()
  local scene = cc.Scene:createWithPhysics()
  return HallScene.extend(scene)
end

return createScene
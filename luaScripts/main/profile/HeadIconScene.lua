--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]


local HeadIconScene = class('HeadIconScene')
local AccountInfo = require('AccountInfo')

local showMessageBox = require('UICommon.MessageBox').showMessageBox;

function HeadIconScene.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, HeadIconScene)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function HeadIconScene:ctor(...)
  local this = self
  self:registerScriptHandler(function(event)
    print('[HeadIconScene] event => ', event)
    local on_event = 'on_' .. event
    if type(this[on_event]) == 'function' then
      this[on_event](this)
    end
  end)

  self:init()
end

function HeadIconScene:init()
  local rootLayer = cc.Layer:create()
  self:addChild(rootLayer)
  self.rootLayer = rootLayer

  local guiReader = ccs.GUIReader:getInstance()
  -- local uiRoot = guiReader:widgetFromBinaryFile('gameUI/UP_HeadIcon.csb')
  local uiRoot = cc.CSLoader:createNode('UP_HeadIconScene.csb')
  rootLayer:addChild(uiRoot)
  self.uiRoot = uiRoot

  self:initKeypadHandler()

  self.headIconChanged = false

  require('utils.UIVariableBinding').bind(uiRoot, self, self)

  self.user = AccountInfo.getCurrentUser()
  self.selectedIconName = self.user.headIcon

  local headIcon_event = __bind(self.HeadIcon_onEvent, self) 

  for i = 0, 7 do 
    local headName = 'HeadIcon_' .. i
    local head = self[headName]
    print('headName => ', headName, ' ==> ', head)
    --head:setTouchEnabled(true)
    head:addTouchEventListener(headIcon_event)
  end
end

function HeadIconScene:on_enter()
  if self.user.headIcon then
    local n = string.sub(self.user.headIcon, -1)
    local uiName = 'HeadIcon_' .. n
    self:tickHeadIcon(self[uiName])
  end
end

function HeadIconScene:initKeypadHandler()
  local this = self
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
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

function HeadIconScene:close()

  if self.user.headIcon ~= self.selectedIconName then
    self.user.headIcon = self.selectedIconName
    local reqParams = {headIcon = self.selectedIconName}
    ddz.pomeloClient:request('auth.userHandler.updateHeadIcon', reqParams, function(data) 
        dump(data, 'auth.userHandler.updateHeadIcon -> resp')
      end)
  end

  cc.Director:getInstance():popScene()
end

function HeadIconScene:tickHeadIcon(ui)
  local boundingBox = ui:getParent():getBoundingBox()
  self.ImageCheck:setPosition( boundingBox.x + boundingBox.width, boundingBox.y)
end

function HeadIconScene:HeadIcon_onEvent(sender, eventType)
  local btnName = sender:getName()
  print(btnName , 'eventType:', eventType)
  if eventType == ccui.TouchEventType.ended then
    self:tickHeadIcon(sender)
    local n = string.sub(btnName, -1)
    self.selectedIconName = 'head' .. n
  end
end

function HeadIconScene:ButtonBack_onClicked()
  self:close()
end


local function createScene()
  local scene = cc.Scene:create()

  return HeadIconScene.extend(scene)
end

return createScene
--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

local UIVarBinding = require('utils.UIVariableBinding')

local RoomListLayer = class('RoomListLayer', function() 
  return cc.Layer:create()
end)

function RoomListLayer:ctor(curRoomId)
  self.curRoomId = curRoomId
  self:init()
end

function RoomListLayer:init()

  local uiRoot = cc.CSLoader:createNode('RoomListLayer.csb')
  self:addChild(uiRoot)
  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  -- self:initTouch()
  self:initKeypadHandler()

  local itemModel = self.RoomItemModel:clone()
  self.RoomItemModel:setVisible(false)
  self.ListViewRooms:setItemModel(itemModel)
  
  local gameRooms = ddz.GlobalSettings.rooms

  for index=1, #gameRooms do
    local roomInfo = gameRooms[index]
    self.ListViewRooms:pushBackDefaultItem()
    local item = self.ListViewRooms:getItem(index - 1)
    local label = ccui.Helper:seekWidgetByName(item, 'LabelRoomName')
    label:setString(roomInfo.roomName)
    local focused = ccui.Helper:seekWidgetByName(item, 'ImageFocus')
    focused:setVisible(roomInfo.roomId == self.curRoomId)
    local grey = ccui.Helper:seekWidgetByName(item, 'PanelGrey')
    grey:setVisible(roomInfo.roomId ~= self.curRoomId)
    label = ccui.Helper:seekWidgetByName(item, 'LabelEnterLimit')
    label:setString(roomInfo.criteriaText)
    label = ccui.Helper:seekWidgetByName(item, 'LabelAnte')
    label:setString(roomInfo.ante)
    label = ccui.Helper:seekWidgetByName(item, 'LabelRake')
    label:setString(string.format('佣金: %d' , roomInfo.rake))
  end

end

function RoomListLayer:initKeypadHandler()
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      event:stopPropagation()
      self:close()
    end
  end
  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function RoomListLayer:PanelBg_onClicked()
  self:close()
end


function RoomListLayer:close()
  self:runAction(cc.RemoveSelf:create())
end

return RoomListLayer
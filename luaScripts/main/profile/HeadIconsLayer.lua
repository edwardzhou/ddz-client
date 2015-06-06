--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]


local HeadIconsLayer = class('HeadIconsLayer', function() 
  return cc.Layer:create()
end)

local AccountInfo = require('AccountInfo')
local utils = require('utils.utils')

local showMessageBox = require('UICommon.MessageBox').showMessageBox;

function HeadIconsLayer:ctor(...)
  local this = self
  self:registerScriptHandler(function(event)
    print('[HeadIconsLayer] event => ', event)
    local on_event = 'on_' .. event
    if type(this[on_event]) == 'function' then
      this[on_event](this)
    end
  end)

  self:init()
end

function HeadIconsLayer:init()
  local rootLayer = self

  self:setVisible(false)

  local uiRoot = cc.CSLoader:createNode('UP_HeadIconsLayer.csb')
  rootLayer:addChild(uiRoot)
  self.uiRoot = uiRoot

  self:initKeypadHandler()

  self.headIconChanged = false

  require('utils.UIVariableBinding').bind(uiRoot, self, self)

  self.user = AccountInfo.getCurrentUser()
  self.selectedIconName = self.user.headIcon

  local headIcon_event = __bind(self.HeadIcon_onSelectedEvent, self) 

  for i = 1, 15 do 
    local headName = string.format('chkHead_%02d', i)
    local headBox = self[headName]
    print('headName => ', headName, ' ==> ', headBox)
    headBox:addEventListener(headIcon_event)
  end
end

function HeadIconsLayer:on_enter()
end

function HeadIconsLayer:show()
  self.closing = false
  self.user = AccountInfo.getCurrentUser()

  self.lastIconIndex = tonumber(self.user.headIcon) or 0

  if self.lastIconIndex > 0 then
    local n = self.lastIconIndex
    local uiName = string.format('chkHead_%02d', n)
    dump(uiName, 'uiName')
    self[uiName]:setSelected(true)
  end

  self.lastIconIndex = tonumber(self.user.headIcon) or 0

  self:setVisible(true)
  self.PanelHeadIcons:setScale(0.001)
  self.PanelHeadIcons:runAction(cc.EaseElasticInOut:create(cc.ScaleTo:create(0.5, 1.0), 0.5))

end

function HeadIconsLayer:initKeypadHandler()
  local this = self
  local function onKeyReleased(keyCode, event)
    if not this:isVisible() then
      return
    end
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

function HeadIconsLayer:close()
  local this = self

  if this.closing then
    return
  end

  this.closing = true

  if self.user.headIcon ~= self.lastIconIndex then
    self.user.headIcon = self.lastIconIndex
    local reqParams = {headIcon = self.lastIconIndex}
    ddz.pomeloClient:request('auth.userHandler.updateHeadIcon', reqParams, function(data) 
        dump(data, 'auth.userHandler.updateHeadIcon -> resp')
      end)
    utils.invokeCallback(this.onHeadChanged)
  end

  self.PanelHeadIcons:runAction(cc.Sequence:create(
    cc.EaseElasticInOut:create(cc.ScaleTo:create(0.5, 0.01), 0.5),
    cc.TargetedAction:create(this, cc.Hide:create())
  ))

  --self:setVisible(false)
end

function HeadIconsLayer:unselectedLastHeadIcon()
  if self.lastIconIndex > 0 then
    local iconBoxName = string.format('chkHead_%02d', self.lastIconIndex)
    self[iconBoxName]:setSelected(false)
  end
end

function HeadIconsLayer:HeadIcon_onSelectedEvent(sender,eventType)
  local iconIndex = 1
  if eventType == ccui.CheckBoxEventType.selected then
    self:unselectedLastHeadIcon()
    self.lastIconIndex = sender:getTag()
  elseif eventType == ccui.CheckBoxEventType.unselected then
    sender:setSelected(true)
  end
end  


function HeadIconsLayer:ButtonClose_onClicked()
  self:close()
end

function HeadIconsLayer:PanelBg_onClicked()
  self:close()
end

return HeadIconsLayer
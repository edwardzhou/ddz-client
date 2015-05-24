local AppointPlayListLayer = class('AppointPlayListLayer')
local utils = require('utils.utils')
local AccountInfo = require('AccountInfo')


function AppointPlayListLayer.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, AppointPlayListLayer)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function AppointPlayListLayer:ctor(appointPlayEnterCallback)

  -- self.requester = requester
  -- self.appointPlay = appointPlay

  -- self.msg = string.format('%s (%d) 邀您与TA对战, 是否开始对战?', requester.nickName, requester.userId)


  self.showCloseButton = true
  self.autoClose = false
  self.appointPlayEnterCallback = appointPlayEnterCallback
  self.grayBackground = true
  self.closeOnClickOutside = true
  self.closeAsCancel = true

  self:init()
end

function AppointPlayListLayer:init()
  local this = self
  local rootLayer = self
  local currentUser = AccountInfo.getCurrentUser()
  local selfUserId = currentUser.userId

  local uiRoot = cc.CSLoader:createNode('AppointPlayListLayer.csb')
  self.uiRoot = uiRoot
  rootLayer:addChild(uiRoot)
--  self.uiRoot:setOpacity(0)

  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initKeypadHandler()

  self.PanelGray:setVisible(self.grayBackground)

  this.MsgPanel:setVisible(true)
  this.MsgPanel:setScale(0.001)

  self:registerScriptHandler(function(event)
    --print('event => ', event)
    utils.invokeCallback(this["on_" .. event], this)
  end)

  local listview = self.ListView_AppointPlays
  local itemModel = self.AppointPlayItemModel:clone()
  self.AppointPlayItemModel:setVisible(false)

  listview:setItemModel(itemModel)

  local item
  local appointPlay
  local player1, player2

  local appointPlays = table.copy(ddz.appointPlays)
  --table.append(appointPlays, ddz.appointPlays)

  for index=1, #appointPlays do
    appointPlay = appointPlays[index]
    listview:pushBackDefaultItem()
    item = listview:getItem(index-1)
    if appointPlay.players[1].userId == selfUserId then
      player1 = appointPlay.players[2]
      player2 = appointPlay.players[3]
    elseif appointPlay.players[2].userId == selfUserId then
      player1 = appointPlay.players[1]
      player2 = appointPlay.players[3]
    else
      player1 = appointPlay.players[1]
      player2 = appointPlay.players[2]
    end

    player1.headIcon = tonumber(player1.headIcon) or 1
    if player1.headIcon < 1 then
      player1.headIcon = 1
    end
    player2.headIcon = tonumber(player2.headIcon) or 1
    if player2.headIcon < 1 then
      player2.headIcon = 1
    end

    item:getChildByName('Player1_NickName'):setString(string.format('%s (%d)', player1.nickName, player1.userId))
    item:getChildByName('Player1_HeadIcon'):loadTexture(
        string.format('NewRes/idImg/idImg_head_%02d.jpg', player1.headIcon),
        ccui.TextureResType.localType
      )

    item:getChildByName('Player2_NickName'):setString(string.format('%s (%d)', player2.nickName, player2.userId))
    item:getChildByName('Player2_HeadIcon'):loadTexture(
        string.format('NewRes/idImg/idImg_head_%02d.jpg', player2.headIcon),
        ccui.TextureResType.localType
      )
    local button = item:getChildByName('ButtonEnter')
    button.appointPlay = appointPlay
    button:addClickEventListener(function (sender)
      this:close()
      utils.invokeCallback(this.appointPlayEnterCallback, button.appointPlay)
    end)
  end

end

function AppointPlayListLayer:on_enter()
  local this = self

  this.MsgPanel:runAction(
    cc.Sequence:create(
        cc.EaseElasticInOut:create(cc.ScaleTo:create(0.5, 1.0), 0.5),
        cc.CallFunc:create(function() 
              -- if this.autoClose then
              --   this:runAction(cc.Sequence:create(
              --       cc.DelayTime:create(this.autoClose),
              --       cc.CallFunc:create(__bind(this.close, this))
              --     ))
              -- end
          end)
      )
  )
end

function AppointPlayListLayer:on_cleanup()
  local this = self

end

function AppointPlayListLayer:close()
  local this = self
  --self.uiRoot:setOpacity(0)
  if this.closing then
    return
  end

  this.closing = true

  this.PanelGray:setVisible(false)
  this.MsgPanel:runAction(
    cc.Sequence:create(
        cc.EaseElasticInOut:create(cc.ScaleTo:create(0.5, 0.001), 0.5),
        cc.TargetedAction:create(this, cc.RemoveSelf:create())
      )
    )
  -- self.MsgPanel:setVisible(false)
  -- self.ImageBox:setVisible(true)
  -- self.ImageBox:runAction( 
  --   cc.Sequence:create(
  --     cc.ScaleTo:create(0.15, 1),
  --     cc.TargetedAction:create(this, cc.RemoveSelf:create())
  --   )
  -- )
end

function AppointPlayListLayer:initKeypadHandler()
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      event:stopPropagation()
      self:ButtonClose_onClicked(self.ButtonClose_onClicked)
    elseif keyCode == cc.KeyCode.KEY_MENU  then
      --label:setString("MENU clicked!")
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function AppointPlayListLayer:ButtonCancel_onClicked(sender, eventType)
  if utils.invokeCallback(self.onCancelCallback) == false then
    return
  else
    self:close()
  end
end

function AppointPlayListLayer:ButtonOk_onClicked(sender, eventType)
  local this = self
  if this.closing then
    return
  end
  if utils.invokeCallback(self.onOkCallback) == false then
    return
  else
    self:close()
  end
end

function AppointPlayListLayer:ButtonClose_onClicked(sender, eventType)
  local this = self
  if this.closing then
    return
  end

  self:close()
end

function AppointPlayListLayer:RootBox_onClicked(sender, eventType)
  if self.closeOnClickOutside then
    if self.ButtonCancel:isVisible() then
      self:ButtonCancel_onClicked(self.ButtonCancel)
    elseif self.ButtonOk:isVisible() then
      self:ButtonOk_onClicked(self.ButtonOk)
    end
  end
end

local function showAppointPlayList(container, onOkCallback)
  local layer = cc.Layer:create()
  local newPlayer = AppointPlayListLayer.extend(layer, onOkCallback)

  newPlayer:setLocalZOrder(1000)
  container:addChild(newPlayer)
end

return {
  showAppointPlayList = showAppointPlayList
}
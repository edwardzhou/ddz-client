--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

local UIVarBinding = require('utils.UIVariableBinding')
local utils = require('utils.utils')

local AccountInfo = require('AccountInfo')

local simpleTexts = {
  '我等的假花儿都谢了！',
  '真怕猪一样的队友！',
  '一走一停真有型，一秒一卡好',
  '我炸你个桃花朵朵开！',
  '姑娘，你真是条汉子。',
  '风吹鸡蛋壳，牌去人安乐。',
  '搏一搏，单车变摩托。',
  '炸得好！',
  '壕，交个盆友吧！'
}

local GamingTextChatLayer = class('GamingTextChatLayer', function() 
  return cc.Layer:create()
end)


function GamingTextChatLayer:ctor(chatServer, userIds)
  self.chatServer = chatServer
  self.userIds = userIds
  self:init()
end

function GamingTextChatLayer:init()
  local this = self

  local uiRoot = cc.CSLoader:createNode('GamingChatLayer.csb')
  self:addChild(uiRoot)
  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initTouch()
  self:initKeypadHandler()
  
  local itemModel = self.TextItemModel:clone()
  self.TextItemModel:setVisible(false)
  self.TextList:setItemModel(itemModel)

  for index = 1, #simpleTexts do
    self.TextList:pushBackDefaultItem()
    local item = self.TextList:getItem(index-1)
    local text = item:getChildByName('ChatText')
    text:setString(simpleTexts[index])
    text:addTouchEventListener(function(sender, event) 
        this:onDefaultMsgClicked(sender, event)
      end)
  end

end

function GamingTextChatLayer:onDefaultMsgClicked(sender, eventType)
  if eventType == ccui.TouchEventType.ended then
    local text = sender:getString()
    self:sendTextMessage(text)
    self:close()
  end
end

function GamingTextChatLayer:sendTextMessage(msg)
  local currentUser = AccountInfo.getCurrentUser()
  local params = {
    chatText = msg,
    to = self.userIds
  }

  self.chatServer:sendGamingChatText(params)
  -- local showToastBox = require('UICommon.ToastBox2').showToastBox
  -- local params = {
  --   msg = msg,
  --   grayBackground = false,
  --   showLoading = false,
  --   showingTime = 3
  -- }

  -- showToastBox(cc.Director:getInstance():getRunningScene(), params)
end

function GamingTextChatLayer:initTouch()
  -- local onTouchBegan = function() return true end
  -- local touchListener = cc.EventListenerTouchOneByOne:create()
  -- touchListener:setSwallowTouches(true)
  -- touchListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
  -- self:getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, self) 
end

function GamingTextChatLayer:initKeypadHandler()
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

function GamingTextChatLayer:PanelBg_onClicked()
  self:close()
end

function GamingTextChatLayer:ButtonClose_onClicked()
  self:close()
end

function GamingTextChatLayer:ButtonSend_onClicked()
  if self.InputMsg:getString() ~= "" then
    self:sendTextMessage(self.InputMsg:getString())
  end
  self:close()
end

function GamingTextChatLayer:close()
  self:runAction(cc.RemoveSelf:create())
end


return GamingTextChatLayer
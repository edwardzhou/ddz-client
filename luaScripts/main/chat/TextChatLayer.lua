local UIVarBinding = require('utils.UIVariableBinding')
local utils = require('utils.utils')
local showToastBox = require('UICommon.ToastBox2').showToastBox
local display = require('cocos.framework.display')

local AccountInfo = require('AccountInfo')

local TextChatLayer = class('TextChatLayer', function() 
  return cc.Layer:create()
end)


function TextChatLayer:ctor(chatServer, toUserId)
  self.chatServer = chatServer
  self.toUserId = toUserId
  self:init()
end

function TextChatLayer:init()
  local this = self

  local uiRoot = cc.CSLoader:createNode('TextChatLayer.csb')
  self:addChild(uiRoot)
  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initTouch()
  self:initKeypadHandler()

end

function TextChatLayer:sendTextMessage(msg)
  local this = self
  local currentUser = AccountInfo.getCurrentUser()
  local params = {
    chatText = msg,
    toUserId = self.toUserId
  }

  self.chatServer:sendTextChat(params, function(data)
      local msgboxParams = {
        id = 'sendTextChatToast',
        zorder = 1099,
        showLoading = true, 
        grayBackground = true,
        closeOnTouch = true,
        closeOnBack = true,
        showingTime = 1,
        showLoading = false,
        msg = '消息已发送'
      }
      showToastBox(display.getRunningScene(), msgboxParams)
      this:close()
    end)
  -- local showToastBox = require('UICommon.ToastBox2').showToastBox
  -- local params = {
  --   msg = msg,
  --   grayBackground = false,
  --   showLoading = false,
  --   showingTime = 3
  -- }

  -- showToastBox(cc.Director:getInstance():getRunningScene(), params)
end

function TextChatLayer:initTouch()
  -- local onTouchBegan = function() return true end
  -- local touchListener = cc.EventListenerTouchOneByOne:create()
  -- touchListener:setSwallowTouches(true)
  -- touchListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
  -- self:getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, self) 
end

function TextChatLayer:initKeypadHandler()
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

function TextChatLayer:PanelBg_onClicked()
  self:close()
end

function TextChatLayer:ButtonClose_onClicked()
  self:close()
end

function TextChatLayer:ButtonSend_onClicked()
  if self.InputMsg:getString() ~= "" then
    self:sendTextMessage(self.InputMsg:getString())
  end
  self:close()
end

function TextChatLayer:close()
  self:runAction(cc.RemoveSelf:create())
end


return TextChatLayer
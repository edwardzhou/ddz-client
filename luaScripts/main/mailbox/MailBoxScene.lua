
local MailBoxScene = class('MailBoxScene')
local gameConnection = require('network.GameConnection')
local AccountInfo = require('AccountInfo')

local showToastBox = require('UICommon.ToastBox2').showToastBox
local showMessageBox = require('UICommon.MsgBox').showMessageBox

function MailBoxScene.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, MailBoxScene)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function MailBoxScene:ctor(...)
  local this = self
  self:registerScriptHandler(function(event)
    print('[MailBoxScene] event => ', event)
    local on_event = 'on_' .. event
    if type(this[on_event]) == 'function' then
      this[on_event](this)
    end
  end)

  self:init()

end

function MailBoxScene:init()
  local this = self
  local rootLayer = cc.Layer:create()

  this.gameConnection = require('network.GameConnection')

  self.rootLayer = rootLayer
  self:addChild(rootLayer)

  local guiReader = ccs.GUIReader:getInstance()
  -- local uiRoot = guiReader:widgetFromBinaryFile('gameUI/Shop.csb')
  local uiRoot = cc.CSLoader:createNode('MailBoxScene.csb')
  self.uiRoot = guiReader
  rootLayer:addChild(uiRoot)

  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initKeypadHandler()
  self.SysMsgItemModel:setVisible(false)
  self.AddFriendItemModel:setVisible(false)
  self.ChatMsgItemModel:setVisible(false)

  self:updateUserInfo()

  -- local scrollSize = self.MsgHolder:getContentSize()

  -- local label = cc.Label:create()
  -- label:setAlignment(cc.TEXT_ALIGNMENT_LEFT)
  -- label:setDimensions(scrollSize.width, scrollSize.height)
  -- local text = 'Cocos2d-x是全球知名的开源跨平台游戏引擎, 在这里你可以与其它开发者自由交流，分享心得，互帮互助，欢迎在本社区讨论和提问，官方技术支持人员提供解答。'
  -- text = text .. text
  -- --text = 'Cocos2d-x是全球知名的开源跨平台游戏引擎, 在这里你'
  -- label:setString(text)
  -- label:setSystemFontSize(20)
  -- label:setMaxLineWidth(scrollSize.width)
  -- label:setHeight(0)
  -- label:setLineBreakWithoutSpace(true)
  -- label:setAnchorPoint(cc.p(0, 0))
  -- label:setPosition(cc.p(0, 0))
  -- label:setTextColor(cc.c4b(0xB7, 0x9C, 0x58, 255))

  -- local labelSize = label:getContentSize()

  -- if labelSize.height < scrollSize.height then
  --   label:setPosition(cc.p(0, scrollSize.height - labelSize.height))
  -- else
  --   self.MsgHolder:setInnerContainerSize(cc.size(0, labelSize.height))
  -- end

  -- self.MsgHolder:addChild(label)

end


function MailBoxScene:on_enterTransitionFinish()
  local this = self

  this:SysMsg_onClicked(this.SysMsg)
  --self:loadMsgBoxItem()
end

function MailBoxScene:on_exit()
end

function MailBoxScene:addChatMsgItem(listView, itemData, pos)
  local this = self

  --local itemData = items[index]
  local itemModel = this.ChatMsgItemModel:clone()
  itemModel.itemData = itemData
  itemModel:setVisible(true)
  local uiObj = ccui.Helper:seekWidgetByName(itemModel, 'UserNickName')
  uiObj:setString(string.format('%s (%d)', itemData.userInfo.nickName, itemData.userInfo.userId))
  uiObj = ccui.Helper:seekWidgetByName(itemModel, 'sentTime')
  uiObj:setString(ddz.tranlateTimeLapsed(itemData.date, true).cn)

  local iconIndex = itemData.userInfo.headIcon or 1
  uiObj = ccui.Helper:seekWidgetByName(itemModel, 'ImageHeadIcon')
  uiObj:loadTexture(
      string.format('NewRes/idImg/idImg_head_%02d.jpg', iconIndex),
      ccui.TextureResType.localType
    )

  uiObj = ccui.Helper:seekWidgetByName(itemModel, 'MsgHolder')

  local scrollSize = uiObj:getContentSize()
  local label = cc.Label:create()
  label:setAlignment(cc.TEXT_ALIGNMENT_LEFT)
  label:setDimensions(scrollSize.width, scrollSize.height)
  local text = itemData.chatMsg
  --text = 'Cocos2d-x是全球知名的开源跨平台游戏引擎, 在这里你'
  label:setString(text)
  label:setSystemFontSize(20)
  label:setMaxLineWidth(scrollSize.width)
  label:setHeight(0)
  label:setLineBreakWithoutSpace(true)
  label:setAnchorPoint(cc.p(0, 0))
  label:setPosition(cc.p(0, 0))
  label:setTextColor(cc.c4b(0xB7, 0x9C, 0x58, 255))

  local labelSize = label:getContentSize()

  if labelSize.height < scrollSize.height then
    label:setPosition(cc.p(0, scrollSize.height - labelSize.height))
  else
    uiObj:setInnerContainerSize(cc.size(0, labelSize.height))
  end
  uiObj:addChild(label)

  local button = ccui.Helper:seekWidgetByName(itemModel, 'ButtonReply')
  button.userInfo = itemData.userInfo
  button:addClickEventListener(function(sender)
      local chatServer = require('network.GameConnection')
      local chatLayer = require('chat.TextChatLayer').new(chatServer, sender.userInfo.userId)
      this:addChild(chatLayer)
    end)

  listView:pushBackCustomItem(itemModel)
  -- if pos == nil then
  --   listView:pushBackCustomItem(itemModel)
  -- else
  --   listView:insertCustomItem(itemModel, pos - 1)
  -- end
end

function MailBoxScene:loadChatMsgs()
  local this = self
  local listView = self.ChatMsgList

  local function addItems(items)
    for index=1, #items do
      this:addChatMsgItem(listView, items[index])
      -- local itemData = items[index]
      -- local itemModel = this.ChatMsgItemModel:clone()
      -- itemModel.itemData = itemData
      -- itemModel:setVisible(true)
      -- local uiObj = ccui.Helper:seekWidgetByName(itemModel, 'UserNickName')
      -- uiObj:setString(string.format('%s (%d)', itemData.userInfo.nickName, itemData.userInfo.userId))
      -- uiObj = ccui.Helper:seekWidgetByName(itemModel, 'sentTime')
      -- uiObj:setString(ddz.tranlateTimeLapsed(itemData.date, true).cn)

      -- local iconIndex = itemData.userInfo.headIcon or 1
      -- uiObj = ccui.Helper:seekWidgetByName(itemModel, 'ImageHeadIcon')
      -- uiObj:loadTexture(
      --     string.format('NewRes/idImg/idImg_head_%02d.jpg', iconIndex),
      --     ccui.TextureResType.localType
      --   )

      -- uiObj = ccui.Helper:seekWidgetByName(itemModel, 'MsgHolder')

      -- local scrollSize = uiObj:getContentSize()
      -- local label = cc.Label:create()
      -- label:setAlignment(cc.TEXT_ALIGNMENT_LEFT)
      -- label:setDimensions(scrollSize.width, scrollSize.height)
      -- local text = itemData.chatMsg
      -- --text = 'Cocos2d-x是全球知名的开源跨平台游戏引擎, 在这里你'
      -- label:setString(text)
      -- label:setSystemFontSize(20)
      -- label:setMaxLineWidth(scrollSize.width)
      -- label:setHeight(0)
      -- label:setLineBreakWithoutSpace(true)
      -- label:setAnchorPoint(cc.p(0, 0))
      -- label:setPosition(cc.p(0, 0))
      -- label:setTextColor(cc.c4b(0xB7, 0x9C, 0x58, 255))

      -- local labelSize = label:getContentSize()

      -- if labelSize.height < scrollSize.height then
      --   label:setPosition(cc.p(0, scrollSize.height - labelSize.height))
      -- else
      --   uiObj:setInnerContainerSize(cc.size(0, labelSize.height))
      -- end
      -- uiObj:addChild(label)

      -- local button = ccui.Helper:seekWidgetByName(itemModel, 'ButtonReply')
      -- button.userInfo = itemData.userInfo
      -- button:addClickEventListener(function(sender)
      --     local chatServer = require('network.GameConnection')
      --     local chatLayer = require('chat.TextChatLayer').new(chatServer, sender.userInfo.userId)
      --     this:addChild(chatLayer)
      --   end)

      -- listView:pushBackCustomItem(itemModel)
    end

    setTimeout(function()
        listView:jumpToTop()
      end, {}, 0.1)
  end

  listView:removeAllItems()
  local msgCount = 0
  if ddz.myMsgBox and ddz.myMsgBox.chatMsgs and #ddz.myMsgBox.chatMsgs > 0 then
    addItems(ddz.myMsgBox.chatMsgs)
    msgCount = #ddz.myMsgBox.chatMsgs
  end

  this.MsgCount:setString(string.format('共 %d 条消息', msgCount))

end

function MailBoxScene:loadMsgBoxItem()
  local this = self
  local listView = self.MsgList

  local function addAddFriendMsgItems(items)
 
    for index=1, #items do
      local itemData = items[index]
      local itemModel = this.AddFriendItemModel:clone()
      itemModel:setVisible(true)
      itemModel:getChildByName('RequesterNickName'):setString(
        string.format('%s (%d)', itemData.userInfo.nickName, itemData.userInfo.userId))
      itemModel.itemData = itemData
      listView:pushBackCustomItem(itemModel)

      itemModel:getChildByName('ButtonReject'):addClickEventListener(function(sender) 
          this:rejectAddFriend(itemModel, itemData)
        end)

      itemModel:getChildByName('ButtonAccept'):addClickEventListener(function(sender) 
          this:acceptAddFriend(itemModel, itemData)
        end)

    end

    setTimeout(function()
        listView:jumpToTop()
      end, {}, 0.1)
  end
  
  local msgCount = 0
  listView:removeAllItems()
  if ddz.myMsgBox and ddz.myMsgBox.addFriendMsgs and #ddz.myMsgBox.addFriendMsgs > 0 then
    addAddFriendMsgItems(ddz.myMsgBox.addFriendMsgs)
    msgCount = #ddz.myMsgBox.chatMsgs
  end

  this.MsgCount:setString(string.format('共 %d 条消息', msgCount))
end

function MailBoxScene:initKeypadHandler()
  local this = self
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
--      if type(self.onMainMenu) == 'function' then
--        self.onMainMenu()
--      end
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

function MailBoxScene:ButtonBack_onClicked(sender, eventType)
  self:close()
end

function MailBoxScene:close()
  cc.Director:getInstance():popScene()
end

function MailBoxScene:rejectAddFriend(itemModel, itemData)
  local this = self
  local userId = itemData.userInfo.userId

  this.gameConnection:confirmAddFriend(userId, false, function(data)
      itemData.status = 2
      local itemIndex = this.MsgList:getIndex(itemModel)
      this.MsgList:removeItem(itemIndex)
    end)
end

function MailBoxScene:acceptAddFriend(itemModel, itemData)
  local this = self
  local userId = itemData.userInfo.userId

  this.gameConnection:confirmAddFriend(userId, true, function(data)
      itemData.status = 2
      local itemIndex = this.MsgList:getIndex(itemModel)
      this.MsgList:removeItem(itemIndex)

      ddz.needReloadFriendList = true
    end)
end


function MailBoxScene:updateUserInfo()
  -- local user = AccountInfo.getCurrentUser();
  
  -- -- local idNickName = string.format("%s (%s)", user.nickName, user.userId)
  -- -- self.LabelNickName:setString(idNickName)
  -- local coins = user.ddzProfile.coins or 0
  -- self.LabelCoins:setString(coins)

  -- local iconIndex = tonumber(user.headIcon) or 1
  -- if iconIndex < 1 then
  --   iconIndex = 1
  -- end

  -- self.ImageHeadIcon:loadTexture(
  --     string.format('NewRes/idImg/idImg_head_%02d.jpg', iconIndex),
  --     ccui.TextureResType.localType
  --   )

  -- if user.headIcon then
  --   self.ButtonHead:loadTextureNormal(Resources.getHeadIconPath(user.headIcon), ccui.TextureResType.localType)
  -- end
end


function MailBoxScene:ListView_onScrollViewEvent(sender, evenType)
  local this = self
  if evenType == ccui.ScrollviewEventType.scrollToBottom then
      print("SCROLL_TO_BOTTOM")
  elseif evenType ==  ccui.ScrollviewEventType.scrollToTop then
      print("SCROLL_TO_TOP")
  end

    -- float minY = _contentSize.height - _innerContainer->getContentSize().height;
    -- float h = - minY;
    -- jumpToDestination(Vec2(_innerContainer->getPosition().x, minY + percent * h / 100.0f));

  local innerContainer = sender:getInnerContainer()
  local contentSize = sender:getContentSize()
  local innerContainerSize = sender:getInnerContainerSize()
  local minY = contentSize.height - innerContainerSize.height
  local h = - minY
  local percent = cc.p(innerContainer:getPosition()).y / h

  local thumbMinY = 10
  local thumbMaxY = 300
  local thumbHeight = thumbMaxY - thumbMinY
  local y = thumbHeight * (-percent) + thumbMinY

  if y > thumbMaxY then
    y = thumbMaxY
  elseif y < thumbMinY then
    y = thumbMinY
  end

  -- cclog('[MailBoxScene:ListView_onScrollViewEvent] h: %0.2f, minY: %0.2f, percent: %0.2f, y: %0.2f',
  --   h, minY, percent, y)

  if this.ImageThumb then
    this.ImageThumb:setPosition(3, y)
  end
  -- this.ImageThumb:setPosition(3, y)

end

function MailBoxScene:FriendsMsg_onClicked(sender, eventType)
  local this = self

  if self.isChatMsgShow then
    return
  end

  self.isSysMsgShow = false
  self.isChatMsgShow = true

  self.FriendsMsg:loadTexture(
      'NewRes/bg/bg_tab_focus_activity.png',
      ccui.TextureResType.localType
    )

  self.SysMsg:loadTexture(
      'NewRes/bg/bg_tab_blur_activity.png',
      ccui.TextureResType.localType
    )

  self.ChatMsgList:setVisible(true)
  self.MsgList:setVisible(false)

  self:loadChatMsgs()
end

function MailBoxScene:SysMsg_onClicked(sender, eventType)
  local this = self

  if self.isSysMsgShow then
    return
  end

  self.isSysMsgShow = true
  self.isChatMsgShow = false

  self.SysMsg:loadTexture(
      'NewRes/bg/bg_tab_focus_activity.png',
      ccui.TextureResType.localType
    )

  self.FriendsMsg:loadTexture(
      'NewRes/bg/bg_tab_blur_activity.png',
      ccui.TextureResType.localType
    )

  self.ChatMsgList:setVisible(false)
  self.MsgList:setVisible(true)

  self:loadMsgBoxItem()
end

function MailBoxScene:onServerChatMsg(data)
  if self.isChatMsgShow then
    self:addChatMsgItem(self.ChatMsgList, data, 1)
  end
end

local function createScene()
  local scene = cc.Scene:create()
  return MailBoxScene.extend(scene)
end

require('network.ConnectionStatusPlugin').bind(MailBoxScene)

return createScene
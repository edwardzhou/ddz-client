--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

local GamingChatPlugin = {}
local display = require('cocos.framework.display')
local utils = require('utils.utils')

function GamingChatPlugin.bind(theClass)
  function theClass:sendGamingChatText(params)
    local this = self
    this:request('ddz.chatHandler.sendGamingChatText', params, function(data)
      end)

  end

  function theClass:sendTextChat(params, callback)
    local this = self
    this:request('ddz.chatHandler.sendChatMsg', params, function(data)
        utils.invokeCallback(callback, data)
      end)
  end

  function theClass:onServerGamingChat(data)
    local scene = display.getRunningScene()
    utils.invokeCallback(scene.onServerGamingChat, scene, data)
  end

  function theClass:onServerChatMsg(data)
    local this = self
    local scene = display.getRunningScene()
    dump(data, '[theClass:onServerChatMsg] data =>')
    if ddz.myMsgBox and ddz.myMsgBox.chatMsgs then
      table.insert(ddz.myMsgBox.chatMsgs, data)
      utils.invokeCallback(scene.onServerChatMsg, scene, data)
      this:notify('ddz.messageHandler.ackMessage', {msgId = data.msgId})
    end
  end

  function theClass:hookServerGamingChatEvents()
    local this = self
    if this._onServerGamingChatText == nil then
      this._onServerGamingChatText = __bind(this.onServerGamingChat, this)
    end
    if this._onServerChatMsg == nil then
      this._onServerChatMsg = __bind(this.onServerChatMsg, this)
    end

    if this.pomeloClient and not this._onServerGamingChatTextHooked then
      this.pomeloClient:on('onGamingChatText', this._onServerGamingChatText)
      this.pomeloClient:on('onChatMsg', this._onServerChatMsg)
      this._onServerGamingChatTextHooked = true
    end
  end

  function theClass:unhookServerGamingChatEvents()
    local this = self
    if this._onServerGamingChatTextHooked and this.pomeloClient then
      this.pomeloClient:off('onGamingChatText', this._onServerGamingChatText)
      this.pomeloClient:off('onChatMsg', this._onServerChatMsg)
      this._onServerGamingChatTextHooked = false
    end
  end

  
end

return GamingChatPlugin
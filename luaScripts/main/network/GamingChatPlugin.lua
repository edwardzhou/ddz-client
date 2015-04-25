local GamingChatPlugin = {}
local display = require('cocos.framework.display')
local utils = require('utils.utils')

function GamingChatPlugin.bind(theClass)
  function theClass:sendGamingChatText(params)
    local this = self
    this:request('ddz.chatHandler.sendGamingChatText', params, function(data)
      end)

  end

  function theClass:onServerGamingChat(data)
    local scene = display.getRunningScene()
    utils.invokeCallback(scene.onServerGamingChat, scene, data)
  end

  function theClass:hookServerGamingChatEvents()
    local this = self
    if this._onServerGamingChatText == nil then
      this._onServerGamingChatText = __bind(this.onServerGamingChat, this)
    end

    if this.pomeloClient and not this._onServerGamingChatTextHooked then
      this.pomeloClient:on('onGamingChatText', this._onServerGamingChatText)
      this._onServerGamingChatTextHooked = true
    end
  end

  function theClass:unhookServerGamingChatEvents()
    local this = self
    if this._onServerGamingChatTextHooked and this.pomeloClient then
      this.pomeloClient:off('onGamingChatText', this._onServerGamingChatText)
      this._onServerGamingChatTextHooked = false
    end
  end

  
end

return GamingChatPlugin
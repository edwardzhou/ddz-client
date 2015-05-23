local AppointPlayEventPlugin = {}
local AccountInfo = require('AccountInfo')
local showMessageBox = require('UICommon.MsgBox').showMessageBox
local showToastBox = require('UICommon.ToastBox2').showToastBox
local showAppointPlayInform = require('appointPlay.AppointPlayInformLayer').showAppointPlayInform
local display = require('cocos.framework.display')
local utils = require('utils.utils')

function AppointPlayEventPlugin.bind (theClass)

  function theClass:getAppointPlays()
    local this = self

    this:request('ddz.appointPlayHandler.getAppointPlays', {}, function(data) 
        if data.result then
          ddz.appointPlays = data.appointPlays
          local runningScene = display.getRunningScene()
          utils.invokeCallback(runningScene.onAppointPlaysUpdated, runningScene)
        end
      end)
  end

  function theClass:onAppointPlayRequest(data)
    local this = self
    dump(data, '[AppointPlayEventPlugin:onAppointPlayRequest]')
    local runningScene = display.getRunningScene()

    if runningScene.noPops or runningScene.noAppointPlayRequest then
      return
    end

    local requester = data.requester
    local appointPlay = data.appointPlay
    local newPlay = true

    if ddz.appointPlays == nil then
      ddz.appointPlays = {}
    end
    for index = 1, #ddz.appointPlays do
      if ddz.appointPlays[index].appointId == ddz.appointPlay.appointId then
        newPlay = false
        break
      end
    end
    if newPlay then
      table.insert(ddz.appointPlays, appointPlay)
      utils.invokeCallback(runningScene.onAppointPlaysUpdated, runningScene)
    end

    local function onOkCallback()
      ddz.gotoAppointPlay = appointPlay
      utils.invokeCallback(runningScene.backToHallForAppointPlay, runningScene)
    end

    showAppointPlayInform(runningScene, appointPlay, requester, onOkCallback)
  end

  function theClass:hookAppointPlayEvent()
    local this = self
    if this._onAppointPlayRequest == nil then
      this._onAppointPlayRequest = __bind(this.onAppointPlayRequest, this)
    end

    -- if this._onReplyFriend == nil then
    --   this._onReplyFriend = __bind(this.onReplyFriend, this)
    -- end

    if this.pomeloClient and not this._onAppointPlayRequestHooked then
      this.pomeloClient:on('onAppointPlayRequest', this._onAppointPlayRequest)
      -- this.pomeloClient:on('replyFriendRequest', this._onReplyFriend)
      this._onAddFriendHooked = true
    end
  end

  function theClass:unhookAppointPlayEventEvent()
    local this = self
    if this._onAppointPlayRequest and this.pomeloClient then
      this.pomeloClient:off('onAppointPlayRequest', this._onAppointPlayRequest)
      -- this.pomeloClient:off('replyFriendRequest', this._onReplyFriend)
      this._onAppointPlayRequestHooked = false
    end
  end
end

return AppointPlayEventPlugin
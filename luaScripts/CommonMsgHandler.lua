local CommonMsgHandler = class('CommonMsgHandler')
local pomeloClient = ddz.pomeloClient
local AccountInfo = require('AccountInfo')
local showToastBox = require('UICommon.ToastBox').showToastBox

function CommonMsgHandler:ctor(...)
  self._onServerUserInfoUpdate = __bind(self.onUserInfoUpdate, self)
  self._onServerMessage = __bind(self.onMessage, self)
end

function CommonMsgHandler:hookMessages()
  pomeloClient:on('onUserInfoUpdate', self._onServerUserInfoUpdate)
  pomeloClient:on('onMessage', self._onServerMessage)
end

function CommonMsgHandler:unhookMessages()
  pomeloClient:off('onUserInfoUpdate', self._onServerUserInfoUpdate)
  pomeloClient:off('onMessage', self._onServerMessage)
end

function CommonMsgHandler:onUserInfoUpdate(data)
  table.merge(AccountInfo.getCurrentUser(), data.user)
  
  local runningScene = cc.Director:getInstance():getRunningScene()  
  if runningScene.updateUserInfo then
    runningScene:updateUserInfo()
  end
end

function CommonMsgHandler:onMessage(data)
  local msg = data.msg
  local runningScene = cc.Director:getInstance():getRunningScene()

  if runningScene.noPops or runningScene.noChargeResult then
    return
  end

  local params = {
    msg = msg,
    grayBackground = false,
    showLoading = false,
    -- autoClose = 2,
    showingTime = 3
  }

  showToastBox(runningScene, params)

end


local instance = CommonMsgHandler.new()

return instance
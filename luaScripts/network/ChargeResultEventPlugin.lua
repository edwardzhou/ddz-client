local ChargeChargeEventPlugin = {}

local AccountInfo = require('AccountInfo')
local showMessageBox = require('UICommon.MessageBox').showMessageBox
local showToastBox = require('UICommon.ToastBox').showToastBox

function ChargeChargeEventPlugin.bind (theClass)
  function theClass:onChargeResult(data)
    dump(data, '[theClass:onChargeResult]')
    local runningScene = cc.Director:getInstance():getRunningScene()
    if data.success and data.user then
      table.merge(AccountInfo.getCurrentUser(), data.user)
      --AccountInfo.getCurrentUser(data.userInfo)
    end

    if runningScene.updateUserInfo then
      runningScene:updateUserInfo()
    end

    if runningScene.noPops or runningScene.noChargeResult then
      return
    end

    local params = {
      msg = '充值成功，您的金币数量已增加。谢谢！',
      grayBackground = false,
      showLoading = false,
      autoClose = 2,
      showingTime = 2
    }

    showToastBox(runningScene, params)
  end

  function theClass:hookChargeResultEvent()
    local this = self
    if this._onChargeResult == nil then
      this._onChargeResult = __bind(this.onChargeResult, this)
    end

    if this.pomeloClient then
      this.pomeloClient:on('onChargeResult', this._onChargeResult)
    end
  end

  function theClass:unhookChargeResultEvent()
    local this = self
    if this._onChargeResult and this.pomeloClient then
      this.pomeloClient:off('onChargeResult', this._onChargeResult)
    end
  end
end

return ChargeChargeEventPlugin

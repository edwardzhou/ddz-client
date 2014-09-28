local ChargeChargeEventPlugin = {}

local AccountInfo = require('AccountInfo')

function ChargeChargeEventPlugin.bind (theClass)
  function theClass:onChargeResult(data)
    dump(data, '[theClass:onChargeResult]')
    local runningScene = cc.Director:getInstance():getRunningScene()
    if data.success and data.user then
      table.merge(AccountInfo.getCurrentUser(), data.user)
      --AccountInfo.getCurrentUser(data.userInfo)
    end

    if runningScene.noPops or runningScene.noChargeResult then
      return
    end

    if runningScene.updateUserInfo then
      runningScene:updateUserInfo()
    end

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

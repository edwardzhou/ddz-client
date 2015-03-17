local BankruptAwardPlugin = {}
local AccountInfo = require('AccountInfo')
local showMessageBox = require('UICommon.MessageBox').showMessageBox
local showToastBox = require('UICommon.ToastBox').showToastBox

function BankruptAwardPlugin.bind (theClass)
  function theClass:onBankruptReward(data)
    dump(data, '[theClass:onBankruptReward]')
    local runningScene = cc.Director:getInstance():getRunningScene()
    local currentUser = AccountInfo.getCurrentUser()
    if currentUser.ddzProfile.coins ~= data.coins then
      currentUser.ddzProfile.coins = data.coins
    end

    if runningScene.updateUserInfo then
      runningScene:updateUserInfo()
    end

    if runningScene.noPops or runningScene.noBankruptReward then
      return
    end
    local params = {
      msg = string.format('您的金币数量已不多, 系统第 %d 次发放救济粮, 免费赠送您 %d 金币。', data.save_times, data.save_coins) , 
      grayBackground = false
    }

    showMessageBox(runningScene, params)
  end

  function theClass:hookBankruptRewardEvent()
    local this = self
    if this._onBankruptReward == nil then
      this._onBankruptReward = __bind(this.onBankruptReward, this)
    end

    if this.pomeloClient and not this._onBankruptRewardHooked then
      this.pomeloClient:on('onUserBankruptSaved', this._onBankruptReward)
      this._onBankruptRewardHooked = true
    end
  end

  function theClass:unhookBankruptRewardEvent()
    local this = self
    if this._onBankruptReward and this.pomeloClient then
      this.pomeloClient:off('onUserBankruptSaved', this._onBankruptReward)
      this._onBankruptRewardHooked = false
    end
  end
end

return BankruptAwardPlugin

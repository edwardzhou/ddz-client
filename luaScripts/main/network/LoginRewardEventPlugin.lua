local LoginRewardEventPlugin = {}

function LoginRewardEventPlugin.bind (theClass)
  function theClass:onLoginReward(data)
    dump(data, '[theClass:onLoginReward]')
    local runningScene = cc.Director:getInstance():getRunningScene()
    if runningScene.noPops or runningScene.noLoginReward then
      return
    end
    require('everydaylogin.EveryDayLoginLogic').check(data)
  end

  function theClass:hookLoginRewardEvent()
    local this = self
    if this._onLoginReward == nil then
      this._onLoginReward = __bind(this.onLoginReward, this)
    end

    if this.pomeloClient then
      this.pomeloClient:on('onLoginReward', this._onLoginReward)
    end
  end

  function theClass:unhookLoginRewardEvent()
    local this = self
    if this._onLoginReward and this.pomeloClient then
      this.pomeloClient:off('onLoginReward', this._onLoginReward)
    end
  end
end

return LoginRewardEventPlugin

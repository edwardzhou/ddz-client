--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

local LoginRewardEventPlugin = {}

function LoginRewardEventPlugin.bind (theClass)
  function theClass:onLoginReward(data)
    dump(data, '[theClass:onLoginReward]')
    local runningScene = cc.Director:getInstance():getRunningScene()
    if runningScene.noPops or runningScene.noLoginReward then
    	LoginRewardEventPlugin.data = data
      return
    end
    LoginRewardEventPlugin.data = nil
    require('everydaylogin.EveryDayLoginLogic').check(data)
  end

  function theClass:checkLoginRewardEvent()
  	LoginRewardEventPlugin.data = LoginRewardEventPlugin.data or ddz.GlobalSettings.session.currentUser
  	if LoginRewardEventPlugin.data and LoginRewardEventPlugin.data.ddzLoginRewards then
  		require('everydaylogin.EveryDayLoginLogic').check(LoginRewardEventPlugin.data)
  		LoginRewardEventPlugin.data = nil
  		ddz.GlobalSettings.session.currentUser.ddzLoginRewards = nil
  	end
  end

  function theClass:hookLoginRewardEvent()
    local this = self
    if this._onLoginReward == nil then
      this._onLoginReward = __bind(this.onLoginReward, this)
    end

    if this.pomeloClient and not this._onLoginRewardHooked then
      this.pomeloClient:on('onLoginReward', this._onLoginReward)
      this._onLoginRewardHooked = true
    end
  end

  function theClass:unhookLoginRewardEvent()
    local this = self
    if this._onLoginReward and this.pomeloClient then
      this.pomeloClient:off('onLoginReward', this._onLoginReward)
      this._onLoginRewardHooked = false
    end
  end
end

return LoginRewardEventPlugin

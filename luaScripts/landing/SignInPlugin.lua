local SignInPlugin = {}

function SignInPlugin.bind(theClass)
  local function handleSignInResponse(signInParams, respData, callback)
    dump(respData, '[handleSignInResponse][auth.userHandler.signIn] response')
    if respData.err then
      -- sign in failed
      callback(false, respData)
      return
    end

    local userInfo = respData.user
    ddz.GlobalSettings.userInfo = userInfo
    ddz.GlobalSettings.session.userId = userInfo.userId
    ddz.GlobalSettings.session.authToken = userInfo.authToken
    ddz.GlobalSettings.session.sessionToken = userInfo.sessionToken
    ddz.saveSessionInfo(userInfo)
    callback(true, userInfo)
  end

  function theClass:signIn(sessionInfo, callback)
    local this = self

    local signInParams = {}
    signInParams.appVersion = ddz.GlobalSettings.appInfo.appVersion
    signInParams.resVersion = ddz.GlobalSettings.appInfo.resVersion
    signInParams.handsetInfo = ddz.GlobalSettings.handsetInfo
    signInParams.authToken = sessionInfo.authToken
    signInParams.userId = sessionInfo.userId
    signInParams.signInType = 1
    this.pomeloClient:request('auth.userHandler.signIn', signInParams, function(data) 
      handleSignInResponse(signInParams, data, callback)
    end)
  end
end

return SignInPlugin

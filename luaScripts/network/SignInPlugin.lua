local SignInType = require('consts').SignInType
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
    local serverInfo = respData.server
    ddz.updateUserSession(respData)
    -- ddz.GlobalSettings.userInfo = userInfo
    -- ddz.GlobalSettings.session.userId = userInfo.userId
    -- ddz.GlobalSettings.session.authToken = userInfo.authToken
    -- ddz.GlobalSettings.session.sessionToken = respData.sessionToken
    -- ddz.GlobalSettings.serverInfo = table.dup(respData.server)
    -- userInfo.sessionToken = respData.sessionToken
    -- ddz.saveSessionInfo(userInfo)
    callback(true, userInfo, serverInfo)
  end

  function theClass:signIn(sessionInfo, userId, password, callback)
    local this = self
    local signInType
    if callback == nil and password == nil then
      callback = userId
      signInType = SignInType.BY_AUTH_TOKEN
      userId = sessionInfo.userId
    else
      signInType = SignInType.BY_PASSWORD
    end

    local signInParams = {}
    signInParams.appVersion = ddz.GlobalSettings.appInfo.appVersion
    signInParams.resVersion = ddz.GlobalSettings.appInfo.resVersion
    signInParams.handsetInfo = ddz.GlobalSettings.handsetInfo
    signInParams.authToken = sessionInfo.authToken
    signInParams.userId = sessionInfo.userId
    signInParams.signInType = signInType
    signInParams.password = password

    ddz.pomeloClient:request('auth.userHandler.signIn', signInParams, function(data) 
      handleSignInResponse(signInParams, data, callback)
    end)
  end
end

return SignInPlugin

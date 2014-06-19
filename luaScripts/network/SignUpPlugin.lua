local SignUpType = require('consts').SignUpType
local SignUpPlugin = {}

function SignUpPlugin.bind(theClass)
  local function handleSignUpResponse(signUpParams, respData, callback)
    dump(respData, '[handleSignUpResponse][auth.userHandler.signUp] response')
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

  function theClass:signUp(callback)
    local this = self

    local signUpParams = {}
    signUpParams.appVersion = ddz.GlobalSettings.appInfo.appVersion
    signUpParams.resVersion = ddz.GlobalSettings.appInfo.resVersion
    signUpParams.handsetInfo = ddz.GlobalSettings.handsetInfo

    ddz.pomeloClient:request('auth.userHandler.signUp', signUpParams, function(data) 
      handleSignUpResponse(signUpParams, data, callback)
    end)
  end
end

return SignUpPlugin

local SignUpType = require('consts').SignUpType
local SignUpPlugin = {}
local AccountInfo = require('AccountInfo')

function SignUpPlugin.bind(theClass)
  local function handleSignUpResponse(gameConn, signUpParams, respData, callback)
    local this = gameConn
    dump(respData, '[handleSignUpResponse][auth.userHandler.signUp] response')
    if respData.err then
      -- sign in failed
      callback(false, respData)
      return
    end

    local userInfo = respData.user
    local serverInfo = respData.server
    --ddz.updateUserSession(respData)
    AccountInfo.setCurrentUser(respData)
    -- ddz.GlobalSettings.userInfo = userInfo
    -- ddz.GlobalSettings.session.userId = userInfo.userId
    -- ddz.GlobalSettings.session.authToken = userInfo.authToken
    -- ddz.GlobalSettings.session.sessionToken = respData.sessionToken
    -- ddz.GlobalSettings.serverInfo = table.dup(respData.server)
    -- userInfo.sessionToken = respData.sessionToken
    -- ddz.saveSessionInfo(userInfo)
    callback(true, userInfo, serverInfo)

    if not serverInfo then
      this:emit('connected')
      this:emit('connectionReady', this, this.pomeloClient, respData)
      this:emit('selfConnectionOk')
    end

  end

  function theClass:signUp(callback)
    local this = self

    local signUpParams = {}
    signUpParams.appVersion = ddz.GlobalSettings.appInfo.appVersion
    signUpParams.resVersion = ddz.GlobalSettings.appInfo.resVersion
    signUpParams.appid = ddz.GlobalSettings.appInfo.appid
    signUpParams.handsetInfo = ddz.GlobalSettings.handsetInfo

    this:request('auth.userHandler.signUp', signUpParams, function(data) 
      handleSignUpResponse(this, signUpParams, data, callback)
    end)
  end
end

return SignUpPlugin

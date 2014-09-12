local SignInType = require('consts').SignInType
local SignInPlugin = {}
local AccountInfo = require('AccountInfo');

function SignInPlugin.bind(theClass)
  local function handleSignInResponse(gameConn, signInParams, respData, callback)
    local this = gameConn
    dump(respData, '[handleSignInResponse][auth.userHandler.signIn] response')
    if respData.err then
      -- sign in failed
      callback(false, respData, signInParams)
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
    callback(true, userInfo, serverInfo, signInParams, respData)

    if not serverInfo then
      this:emit('connected')
      this:emit('connectionReady', this, this.pomeloClient, respData)
      this:emit('selfConnectionOk')
    end

  end

  function theClass:signIn(signInInfo, userId, password, callback)
    local this = self
    local signInType
    if callback == nil and password == nil then
      callback = userId
      signInType = SignInType.BY_AUTH_TOKEN
      userId = signInInfo.userId
    elseif callback ~= nil and password == nil then
      userId = userId or signInInfo.userId
      signInType = SignInType.BY_AUTH_TOKEN
    else
      signInType = SignInType.BY_PASSWORD
    end

    local signInParams = {}
    signInParams.appVersion = ddz.GlobalSettings.appInfo.appVersion
    signInParams.resVersion = ddz.GlobalSettings.appInfo.resVersion
    signInParams.handsetInfo = ddz.GlobalSettings.handsetInfo
    signInParams.authToken = signInInfo.authToken
    signInParams.userId = userId
    signInParams.signInType = signInType
    signInParams.password = password

    this:request('auth.userHandler.signIn', signInParams, function(data) 
      handleSignInResponse(this, signInParams, data, callback)
    end)
  end
end

return SignInPlugin

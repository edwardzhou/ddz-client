require('extern')
require('pomelo.pomelo')
local Emitter = require('pomelo.emitter')
local SignInType = require('consts').SignInType
local AccountInfo = require('AccountInfo')
local GameConnection = class('GameConnection', Emitter)

function GameConnection:ctor(userId, sessionToken)
  self.super.ctor(self)
  self.userId = userId or ddz.GlobalSettings.session.userId
  self.sessionToken = sessionToken or ddz.GlobalSettings.session.sessionToken
  self.autoSignUp = true
  self.isConnectionReady = false
  self.isAuthed = false
end

function GameConnection:authConnection()
  local this = self

  local function onSignResult(success, userInfo, server, signParams)
    if success then
      this:connectToServer({
        host = server.host,
        port = server.port
      });
    else
      local msg = userInfo.message
      local params = {
        title = '无法登录',
        msg = msg
      }
      require('UICommon.ToastBox').showToastBox(cc.Director:getInstance():getRunningScene(), params)
      -- this:signUp(onSignResult);
    end
  end

  local currentUser = AccountInfo.getCurrentUser() or {}

  local authParams = {
    appVersion = ddz.GlobalSettings.appInfo.appVersion,
    resVersion = ddz.GlobalSettings.appInfo.resVersion,
--    handsetInfo = ddz.GlobalSettings.handsetInfo,
    mac = ddz.GlobalSettings.handsetInfo.mac,
    userId = currentUser.userId,
    authToken = currentUser.authToken,
    sessionToken = currentUser.sessionToken
  }

  this.pomeloClient:request('auth.connHandler.authConn', authParams, function(data)
      this.isAuthed = true
      if data.needSignIn then
        print('[auth.connHandler.authConn] server request to sign in')
        this:emit('signInRequired', data)
      --  this:signIn(ddz.GlobalSettings.session, onSignResult)
      --   local goSignIn, signParams = self.signinCallback(this, pomeloClient, data)
      --   if goSignIn then
      --     this:doSignIn(signParams)
      --   end
      elseif data.needSignUp and this.autoSignUp then
        print('[auth.connHandler.authConn] server request to sign up')
        this:emit('signUpRequired', data)
      --  this:signUp(onSignResult)
        -- local goSignUp, signParams = self.signupCallback(this, pomeloClient, data)
        -- if goSignUp then
        --   this:doSignUp(signParams)
        -- end
      else
        --ddz.updateUserSession(data)
        AccountInfo.setCurrentUser(data)
        --this:saveSessionInfo(data)
        if data.server then
          this:connectToServer({
            host = data.server.host, 
            port = data.server.port, 
            userId = data.user.userId, 
            sessionToken = data.sessionToken})
        else
          this.isConnectionReady = true
          this:emit('connected')
          this:emit('connectionReady', this, this.pomeloClient, data)
          -- if this.readyCallback then
          --   this.readyCallback(this, this.pomeloClient, data)
          -- end
        end
      end
  end)
end

function GameConnection:reconnect()
  local this = self

  local serverParams = {
    host = ddz.GlobalSettings.serverInfo.host,
    port = ddz.GlobalSettings.serverInfo.port
  }

  print('[GameConnection:reconnect] ......................')

  this.pomeloClient:init(serverParams, function()
    this:authConnection()
  end)
end

function GameConnection:connectToServer(params)
  local this = self

  -- self.signinCallback = params.signinCallback
  -- self.signupCallback = params.signupCallback
  -- if params.readyCallback then
  --   self.readyCallback = params.readyCallback
  -- end

  if websocketClass == nil then
    websocketClass = require('pomelo.cocos2dx_websocket')
  end

  if not ddz.pomeloClient then
    ddz.pomeloClient = Pomelo.new(websocketClass)
  end

  this.pomeloClient = ddz.pomeloClient

  if not this._connectionEventHooked then
    this._connectionEventHooked = true
    this.pomeloClient:on('connecting', function(event) 
        dump(event, '[GameConnection:connectToServer] on connecting')
        this:emit('connecting', event)
      end)
    this.pomeloClient:on('connected', function() 
        print('[GameConnection:connectToServer] on connected')
        this:emit('connected')
      end)
    this.pomeloClient:on('connection_failure', function() 
        print('[GameConnection:connectToServer] on connection_failure')
        this:emit('connection_failure')
      end)
  end

  local serverParams = {
    host = params.host,
    port = params.port
  }

  this.isAuthed = false
  this.isConnectionReady = false
  this.pomeloClient:init(serverParams, function()
    this:authConnection()
  end)

end

require('network.SignInPlugin').bind(GameConnection)
require('network.SignUpPlugin').bind(GameConnection)

local gameConn = GameConnection.new()

return gameConn
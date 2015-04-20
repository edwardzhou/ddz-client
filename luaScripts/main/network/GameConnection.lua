require('extern')
require('pomelo.pomelo')
local Emitter = require('pomelo.emitter')
local SignInType = require('consts').SignInType
local AccountInfo = require('AccountInfo')
local GameConnection = class('GameConnection', Emitter)
local utils = require('utils.utils')

function GameConnection:ctor(userId, sessionToken)
  local this = self
  self.super.ctor(self)
  self.userId = userId or ddz.GlobalSettings.session.userId
  self.sessionToken = sessionToken or ddz.GlobalSettings.session.sessionToken
  self.autoSignUp = false
  self.isConnectionReady = false
  self.isAuthed = false
  self.isStartConnecting = false
  self.needReconnect = false
  self.autoSignIn = true

  self:on('connectionReady', function() 
      this:hookChargeResultEvent()
      this:hookLoginRewardEvent()
      this:hookBankruptRewardEvent()
    end)
end

function GameConnection:authConnection(autoLogin)
  local this = self
  if autoLogin == nil then
    autoLogin = true
  end

  local function doSignIn()
    local currentUser = AccountInfo.getCurrentUser()
    local signInParam = {}
    signInParam.userId = currentUser.userId
    signInParam.signType = SignInType.BY_AUTH_TOKEN
    signInParam.authToken = currentUser.authToken
    password = nil
    print('[GameConnection:authConnection:doSignIn] start to auto signin by auth key')
    this:signIn(signInParam, function(success, userInfo, serverInfo, signInParams, respData)
        dump(userInfo, 'sign result ' .. tostring(success))
        this.isStartConnecting = false
        if success then
        	if userInfo.ddzLoginRewards then
        		this:onLoginReward(userInfo)
        	end
          if serverInfo then
            this:connectToServer(serverInfo)
            return
          end

          return
        end

        local boxParams = {
          title = '无法自动登录',
          msg = userInfo.message,
          onOk = function() cc.Director:getInstance():replaceScene(require('login.LoginScene')()) end,            
        }
        require('UICommon.MessageBox').showMessageBox(cc.Director:getInstance():getRunningScene(), boxParams)
      end)
  end


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
      require('UICommon.ToastBox2').showToastBox(cc.Director:getInstance():getRunningScene(), params)
      -- this:signUp(onSignResult);
    end
  end

  local currentUser = AccountInfo.getCurrentUser() or {}

  local authParams = {
    appVersion = ddz.GlobalSettings.appInfo.appVersion,
    resVersion = ddz.GlobalSettings.appInfo.resVersion,
    appid = ddz.GlobalSettings.appInfo.appid,
--    handsetInfo = ddz.GlobalSettings.handsetInfo,
    mac = ddz.GlobalSettings.handsetInfo.mac,
  }

  if autoLogin then
    authParams.userId = currentUser.userId
    authParams.authToken = currentUser.authToken
    authParams.sessionToken = currentUser.sessionToken
  end    

  this.pomeloClient:request('auth.connHandler.authConn', authParams, function(data)
      this.isAuthed = true
      this:emit('connected')
      
      if data.needSignIn then
        print('[auth.connHandler.authConn] server request to sign in')
        --this:emit('signInRequired', data)
        doSignIn()
      --  this:signIn(ddz.GlobalSettings.session, onSignResult)
      --   local goSignIn, signParams = self.signinCallback(this, pomeloClient, data)
      --   if goSignIn then
      --     this:doSignIn(signParams)
      --   end
      elseif data.needSignUp then        
        print('[auth.connHandler.authConn] server request to sign up')
        if this.autoSignUp then
          this:emit('signUpRequired', data)
        end
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
          this.isStartConnecting = false
          this.isConnectionReady = true
          this:emit('connectionReady', this, this.pomeloClient, data)
          this:emit('selfConnectionOk')
          -- if this.readyCallback then
          --   this.readyCallback(this, this.pomeloClient, data)
          -- end
        end
      end
  end)
end

function GameConnection:reconnect(autoLogin)
  local this = self

  self.isStartConnecting = true

  local serverInfo = ddz.GlobalSettings.serverInfo or ddz.GlobalSettings.servers

  local serverParams = {
    host = serverInfo.host,
    port = serverInfo.port,
    user = {
      aa = _aa,
      ab = _ab, 
      ac = _ac,
      mac = ddz.GlobalSettings.handsetInfo.mac,
      userId = AccountInfo.getCurrentUser().userId,
      sessionToken = ddz.GlobalSettings.session.sessionToken,
      v = _v
    }
  }

  print('[GameConnection:reconnect] ......................')

  if this.pomeloClient then
    this.pomeloClient:init(serverParams, function()
      this:authConnection(autoLogin)
    end)
  else
    this:connectToServer(serverParams)
  end
end

function GameConnection:connectToServer(params)
  local this = self

  -- self.signinCallback = params.signinCallback
  -- self.signupCallback = params.signupCallback
  -- if params.readyCallback then
  --   self.readyCallback = params.readyCallback
  -- end

  self.isStartConnecting = true

  if websocketClass == nil then
    websocketClass = require('pomelo.cocos2dx_websocket')
  end

  if not ddz.pomeloClient then
    ddz.pomeloClient = Pomelo.new(websocketClass)
  end

  this.pomeloClient = ddz.pomeloClient
  this.pomeloClient.onTryReconnect = __bind(this.onTryReconnect, this)

  if not this._connectionEventHooked then
    this._connectionEventHooked = true
    this.pomeloClient:on('connecting', function(event) 
        dump(event, '[GameConnection:connectToServer] on connecting')
        this:emit('connecting', this, event)
      end)
    this.pomeloClient:on('connected', function() 
        print('[GameConnection:connectToServer] on connected')
        this:emit('connected', this)
      end)
    this.pomeloClient:on('connection_failure', function() 
        print('[GameConnection:connectToServer] on connection_failure')
        this:emit('connection_failure', this)
      end)
  end

  local serverParams = {
    host = params.host,
    port = params.port,
    user = {
      aa = _aa,
      ab = _ab, 
      ac = _ac,
      mac = ddz.GlobalSettings.handsetInfo.mac,
      userId = AccountInfo.getCurrentUser().userId,
      sessionToken = ddz.GlobalSettings.session.sessionToken,
      v = _v
    }
  }

  local autoLogin = params.autoLogin
  if autoLogin == nil then
    autoLogin = true
  end

  this.isAuthed = false
  this.isConnectionReady = false
  this.pomeloClient:init(serverParams, function()
    this:authConnection(autoLogin)
  end)

end

function GameConnection:scheduleUpdateSession()
	if ddz.updateSessionHandler then return end
	local updateUserSession = function()
		self:request('ddz.entryHandler.updateSession',{userId=AccountInfo.getCurrentUser().userId}, function(data) 
			dump(data, 'on update user session')
		end)
	end
	ddz.updateSessionHandler = require('framework.scheduler').scheduleGlobal(updateUserSession, 5*60)
end

function GameConnection:request(route, msg, cb)
  local this = self
  local status = self:checkConnection()

  if not status.result then
    --if status.errorCode == 2 then
      this:reconnect()
      this:once('selfConnectionOk', function()
          this:request(route, msg, cb)
        end)
    --end

    return false
  end

  --this.inRequesting = true
  this.pomeloClient:request(route, msg, cb)

end

function GameConnection:notify(route, msg)
  local this = self
  local status = self:checkConnection()

  if not status.result then
    --if status.errorCode == 2 then
      this:reconnect()
      this:once('selfConnectionOk', function()
          this:notify(route, msg)
        end)
    --end

    return false
  end

  this.pomeloClient:notify(route, msg)
end

function GameConnection:checkConnection()
  if not self.pomeloClient then
    return {result = false, errorCode=1, errorMsg = '尚未连接服务器'}
  end

  if not self.pomeloClient.connected then
    return {result = false, errorCode=2, errorMsg = '连接被断开'}
  end

  return {result = true}
end

function GameConnection:onTryReconnect(retries)
  print('[GameConnection:onTryReconnect] self.isStartConnecting => ', self.isStartConnecting, 
    ', retries => ', retries, ', self.needReconnect => ', self.needReconnect)
  if self.isStartConnecting or retries < 3 then
    return true
  end

  return self.needReconnect
end

function GameConnection:doHeartbeat()
  local status = self:checkConnection()

  if not status.result then
    return
  end

  self.pomeloClient:sendHeartbeat()
end


function GameConnection:signOut(cb)
  local this = self
  this.autoSignUp = false
  this.autoSignIn = false
  if this.pomeloClient then
    this:request('ddz.entryHandler.leave', {}, function()
        this.pomeloClient:disconnect()
        utils.invokeCallback(cb)
      end)
  end
end

function GameConnection:resetBytesStat()
  if self.pomeloClient then
    self.pomeloClient:resetBytesStat()
  end
end

function GameConnection:dumpBytesStat()
  if self.pomeloClient then
    self.pomeloClient:dumpBytesStat()
  end
end


require('network.SignInPlugin').bind(GameConnection)
require('network.SignUpPlugin').bind(GameConnection)
require('network.ChargeResultEventPlugin').bind(GameConnection)
require('network.LoginRewardEventPlugin').bind(GameConnection)
require('network.BankruptAwardPlugin').bind(GameConnection)


local gameConn = GameConnection.new()

return gameConn
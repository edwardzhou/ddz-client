local AccountInfo = require('AccountInfo')
local SignInType = require('consts').SignInType
local utils = require('utils.utils')

local LandingConnectionPlugin = {}

function LandingConnectionPlugin.bind(theClass)

  function theClass:removeConnectionHooks()
    if self._onConnectionReady ~= nil and self.gameConnection ~= nil then
      self.gameConnection:off('connectionReady', self._onConnectionReady)
      self.gameConnection:off('signInRequired', self._onSignInUpRequired)
      self.gameConnection:off('signUpRequired', self._onSignInUpRequired)
    end
  end

  function theClass:connectToServer()
    local this = self

    local currentUser = AccountInfo.getCurrentUser()
    local signInInfo = {}
    --sign
    local sessionToken = currentUser.sessionToken
    local lastSessionToken = currentUser.sessionToken
    local userId = currentUser.userId

    local function queryRooms()
      self.gameConnection:request('ddz.entryHandler.queryRooms', {}, function(data) 
        dump(data, 'queryRooms => ')
        if data.err == nil then
          ddz.GlobalSettings.rooms = data.rooms
          --this.ButtonStart:setVisible(true)
          local scene = require('hall.HallScene2')()
          cc.Director:getInstance():replaceScene(scene)
        end

        require('CommonMsgHandler'):hookMessages()
      end)
    end

    local function onGameServerConnected(sender, pomelo, data)
      queryRooms()
    end

    local function connectToGameServer(success, userInfo)
      if not success then
        this:signUp(connectToGameServer)
        return
      end

      local userId = ddz.GlobalSettings.session.userId
      if ddz.GlobalSettings.session and ddz.GlobalSettings.session.sessionToken then
        sessionToken = ddz.GlobalSettings.session.sessionToken 
      else
        sessionToken = lastSessionToken
      end
      local serverInfo = ddz.GlobalSettings.serverInfo
      self:connectTo(serverInfo.host, serverInfo.port, userId, sessionToken, onGameServerConnected)
    end

    local onConnectionReady = function(sender, pomelo, data)
      if userId == nil or data.needSignUp == true then
        this:signUp(connectToGameServer)
      elseif data.needSignIn == true then
        this:signIn(sessionInfo, connectToGameServer)
      else
        local newUserInfo = data.user
        local serverInfo = data.server
        -- TDGAAccount:setAccount(newUserInfo.userId)
        -- TDGAAccount:setAccountName(newUserInfo.nickName)
        -- TDGAAccount:setAccountType(TDGAAccount.kAccountRegistered)
        -- TDGAAccount:setLevel(2) 
        -- TDGAAccount:setGender(TDGAAccount.kGenderFemale)
        -- TDGAAccount:setAge(29)
        -- TDGAAccount:setGameServer("国服 2")

        -- ddz.GlobalSettings.userInfo = newUserInfo
        -- ddz.GlobalSettings.session.userId = newUserInfo.userId
        -- ddz.GlobalSettings.session.authToken = newUserInfo.authToken
        -- ddz.GlobalSettings.session.sessionToken = data.sessionToken
        -- ddz.GlobalSettings.serverInfo = table.dup(data.server)
        newUserInfo.sessionToken = data.sessionToken
        sessionToken = data.sessionToken
        --ddz.saveSessionInfo(newUserInfo)
        connectToGameServer(true, newUserInfo, serverInfo)
      end
    end

    local function doSignUp()
      this.gameConnection:signUp(function(success, userInfo, serverInfo, signUpParams)
          if success then
            this.gameConnection:connectToServer(serverInfo)
            return
          end

          local boxParams = {
            title = '无法自动注册',
            msg = userInfo.message,
            onOk = function() cc.Director:getInstance():replaceScene(require('login.LoginScene')()) end,            
          }
          require('UICommon.MessageBox').showMessageBox(this, boxParams)

        end)
    end

    --self:connectTo('192.168.1.165', '4001', sessionInfo.userId, sessionInfo.sessionToken, onConnectionReady)
    if self.gameConnection == nil then
      self.gameConnection = require('network.GameConnection')
      self.gameConnection.needReconnect = true
      self.gameConnection.autoSignUp = true
      self.gameConnection.autoSignIn = true
      if self._onConnectionReady == nil then
        self._onConnectionReady = function()
          queryRooms()
        end
      end
      if self._onSignInUpRequired == nil then
        self._onSignInUpRequired = function(data)
          if data.needSignUp then
          --   doSignIn()
          -- else
            doSignUp()
          end
          -- local scene = require('login.LoginScene')()
          -- cc.Director:getInstance():replaceScene(scene)
        end
      end
      self.gameConnection:on('connectionReady', self._onConnectionReady)
      self.gameConnection:on('signInRequired', self._onSignInUpRequired)
      self.gameConnection:on('signUpRequired', self._onSignInUpRequired)

      self:hookConnectionEvents()
    end

    dump(ddz.GlobalSettings, '[LandingScene:connectToServer] ddz.GlobalSettings')

    self.gameConnection:connectToServer({
      --host = '118.26.229.45'
      host = ddz.GlobalSettings.servers.host
      , port = ddz.GlobalSettings.servers.port
    });

  end
end

return LandingConnectionPlugin
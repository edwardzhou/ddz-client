local LoginScene = class('LoginScene')
local SignInType = require('consts').SignInType
local AccountInfo = require('AccountInfo')

local showToastBox = require('UICommon.ToastBox').showToastBox
local hideToastBox = require('UICommon.ToastBox').hideToastBox

function LoginScene.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, LoginScene)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function LoginScene:ctor(...)
  local this = self
  self.gameConnection = require('network.GameConnection')

  self:registerScriptHandler(function(event)
    print('[LoginScene] event => ', event)
    local on_event = 'on_' .. event
    if type(this[on_event]) == 'function' then
      this[on_event](this)
    end
    -- if event == "enterTransitionFinish" then
    --   self:initKeypadHandler()
    --   self:onEnter()
    -- elseif event == 'exit' then
    --   -- umeng:stopSession()
    -- end
  end)

  self:init()

end

function LoginScene:init()
  local rootLayer = cc.Layer:create()
  self.rootLayer = rootLayer
  self:addChild(rootLayer)

  local guiReader = ccs.GUIReader:getInstance()
  local uiRoot = guiReader:widgetFromBinaryFile('gameUI/Login.csb')
  self.uiRoot = uiRoot
  rootLayer:addChild(uiRoot)

  require('utils.UIVariableBinding').bind(uiRoot, self, self, true)
  self:initKeypadHandler()

  self:bindPanelInput(self.PanelUserId, self.InputUserId)
  self:bindPanelInput(self.PanelPassword, self.InputPassword)

  local lastUser = AccountInfo.getCurrentUser()
  if lastUser and lastUser.userId ~= nil then
    self.InputUserId:setString(lastUser.userId)
    self.InputPassword:setString('**TOKEN**')
  else
    self.InputUserId:setString('')
    self.InputPassword:setString('')
  end

  -- local uiEditBox = ccui.EditBox:create(cc.size(300, 40), 'images/green_edit.png')

  -- uiEditBox:setPosition(100, 100)
  -- self.uiRoot:addChild(uiEditBox)

end

function LoginScene:on_enterTransitionFinish()
  local this = self
  self._onConnectionReady = function()
    this.gameConnection:request('ddz.entryHandler.queryRooms', {}, function(data) 
      dump(data, 'queryRooms => ')
      if data.err == nil then
        this:showSignInProgress(false)
        ddz.GlobalSettings.rooms = data.rooms
        local scene = require('hall.HallScene')()
        cc.Director:getInstance():replaceScene(scene)
      end
    end)
  end
  this.gameConnection:on('connectionReady', self._onConnectionReady)
end

function LoginScene:on_exit()
  local this = self
  this.gameConnection:off('connectionReady', self._onConnectionReady)
end

function LoginScene:bindPanelInput(panel, input)
  panel:addTouchEventListener( function(sender, eventType) 
      if eventType == ccui.TouchEventType.ended then
        input:attachWithIME()
      end
    end)
end

function LoginScene:initKeypadHandler()
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
--      if type(self.onMainMenu) == 'function' then
--        self.onMainMenu()
--      end
      event:stopPropagation()
      cc.Director:getInstance():popScene() 
    elseif keyCode == cc.KeyCode.KEY_MENU  then
      --label:setString("MENU clicked!")
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function LoginScene:ButtonSignIn_onClicked(sender, event)
  local this = self
  local params = {buttonType = 'ok'}

  local userId = string.trim(self.InputUserId:getString())
  local password = string.trim(self.InputPassword:getString())
  if #userId == 0 and #password == 0 then
    params.msg = '请输入账户ID和密码'
  elseif #userId == 0 then
    params.msg = '请输入账户ID'
  elseif #password == 0 then
    params.msg = '请输入密码'
  end

  if params.msg then
    require('UICommon.MessageBox').showMessageBox(self.rootLayer, params)
    return
  end

  local signInParam = {}
  signInParam.userId = userId
  local account = AccountInfo.getAccountByUserId(userId)
  dump(account, 'accout for ' .. userId)
  if account and password == '**TOKEN**' then
    signInParam.signType = SignInType.BY_AUTH_TOKEN
    signInParam.authToken = account.authToken
    password = nil
  else
    signInParam.signType = SignInType.BY_PASSWORD
    signInParam.password = password
  end

  self:showSignInProgress(true)

  this.gameConnection:signIn(signInParam, userId, password, function(success, userInfo, server, signParams)
      print('signIn result ', success)
      dump(userInfo, 'userInfo')
      if not success then
        params.msg = userInfo.message
        this:showSignInProgress(false)
        require('UICommon.MessageBox').showMessageBox(self.rootLayer, params)
      else
        if server then
          this.gameConnection:connectToServer(server)
        else
          this:showSignInProgress(false)          
        end
      end
    end)

end

function LoginScene:showSignInProgress(show, msg)
  local this = self
  msg = msg or '努力登录中...'
  if show then
    local param = {
      msg = msg,
      showingTime = 0,
      showLoading = true,
      closeOnTouch = false,
      --closeOnBack = false,
      fadeInTime = 0.03
    }
    showToastBox(this.rootLayer, param)
  else
    hideToastBox(this.rootLayer)
    -- if this.rootLayer.taostBox then
    --   this.rootLayer.taostBox:close()
    -- end
  end
end

function LoginScene:ButtonQuickSignUp_onClicked(sender, event)
  local this = self
  self:showSignInProgress(true, '快速注册中...')

  this.gameConnection:signUp(function(success, userInfo, server, signParams)
      print('signUp result ', success)
      dump(userInfo, 'userInfo')
      if not success then
        params.msg = userInfo.message
        this:showSignInProgress(false)
        require('UICommon.MessageBox').showMessageBox(self.rootLayer, params)
      else
        if server then
          this.gameConnection:connectToServer(server) 
        else
          this:showSignInProgress(false)
        end
      end
    end)
end

function LoginScene:ButtonSwitchAccount_onClicked(sender, eventType)

  local accounts = AccountInfo.getAccounts()

  if #self.ListViewAccounts:getItems() == 0 then
    local panelSpan = ccui.Layout:create()
    panelSpan:setContentSize(cc.size(180, 5))
    --self.ListViewAccounts:pushBackCustomItem(panelSpan)
    for _, account in ipairs(accounts) do 
      print('[LoginScene:ButtonSwitchAccount_onClicked] userId => ', account.userId)
      local button = self.ButtonModel:clone()
      button:setTitleText(account.userId)
      button:setVisible(true)
      button:setTouchEnabled(true)
      button:setScale9Enabled(true)
      button:setContentSize(cc.size(180, 40))
      button:setTitleFontSize(22)

      button:addTouchEventListener(__bind(self.Account_onClicked, self))

      self.ListViewAccounts:pushBackCustomItem(button)
    end
  end

  self.PanelAccounts:setVisible(true)
end

function LoginScene:Account_onClicked(sender, eventType)
  local btn = sender
  if eventType == ccui.TouchEventType.ended then
    print('[LoginScene:Account_onClicked] userId => ' , btn:getTitleText())
    self.InputUserId:setString(btn:getTitleText())
    self.InputPassword:setString('**TOKEN**')
  end
end

function LoginScene:PanelAccounts_onClicked(sender, eventType)
  self.PanelAccounts:setVisible(false)
end

function LoginScene:ListViewAccounts_onEvent(sender, eventType)
  if eventType == 1 then
    self.PanelAccounts:setVisible(false)
  end
end


local function createScene()
  local scene = cc.Scene:create()
  return LoginScene.extend(scene)
end

return createScene
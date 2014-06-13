--require 'CCBReaderLoad'
require 'GuiConstants'
require 'PokeCard'

local cjson = require('cjson.safe')

local LandingScene = class('LandingScene')

function LandingScene.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, LandingScene)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function LandingScene:ctor(...)
  self:init()
end

function LandingScene:init()
  local this = self

  umeng.MobClickCpp:beginScene('landing scene')
  umeng.MobClickCpp:beginEvent('test')
  umeng.MobClickCpp:pay(10, 2, 1000)


  self:registerScriptHandler(function(event)
    print('event => ', event)
    if event == "enterTransitionFinish" then
      self:initKeypadHandler()
    elseif event == 'exit' then
      -- umeng:stopSession()
    end
  end)

  local rootLayer = cc.Layer:create()

  self:addChild(rootLayer)
  self.rootLayer = rootLayer
  
  local uiRoot = ccs.GUIReader:getInstance():widgetFromJsonFile('UI/Landing.json')
  print( 'uiRoot => ', uiRoot)
  rootLayer:addChild(uiRoot)
  local buttonHolder = ccui.Helper:seekWidgetByName(uiRoot, 'buttonHolder')
  local loadingBar = ccui.Helper:seekWidgetByName(uiRoot, 'loadingBar')
  loadingBar = tolua.cast(loadingBar, 'ccui.LoadingBar')
  local percent = 0
  uiRoot:runAction( cc.Sequence:create(
    cc.Repeat:create(
      cc.Sequence:create(
        cc.DelayTime:create(0.02),
        cc.CallFunc:create(function()
          percent = percent + 1
          loadingBar:setPercent(percent) 
        end)), 
      100),
    cc.CallFunc:create(function()
        loadingBar:setVisible(false)
        buttonHolder:setVisible(true)
        umeng.MobClickCpp:endEvent('test')
      end)
  ))
  
  local snow = cc.ParticleSystemQuad:create('snow.plist')
  snow:setPosition(200, 480)
  rootLayer:addChild(snow)

  snow = cc.ParticleSystemQuad:create('snow.plist')
  snow:setPosition(600, 480)
  rootLayer:addChild(snow)
  
  local function touchEvent(sender, eventType)
    local buttonName = sender:getName()
    if eventType == ccui.TouchEventType.ended then
      if buttonName == 'ButtonS' then
        print('button clicked')
        local scene = require('HallScene')()
        cc.Director:getInstance():pushScene(scene)
      elseif buttonName == 'buttonStart' then
        print('button holder clicked!')
        local scene = require('gaming.GameScene')()
        cc.Director:getInstance():pushScene(scene)
      elseif buttonName == 'v_ButtonConnect' then
        self:connectToServer()
      elseif buttonName == 'v_ButtonSignIn' then
        cc.Director:getInstance():endToLua()
      end
    end
  end
  
  local buttonS = ccui.Helper:seekWidgetByName(uiRoot, 'ButtonS')
  buttonS:addTouchEventListener(touchEvent)
  self.buttonS = buttonS
  
  local buttonHolder = ccui.Helper:seekWidgetByName(uiRoot, 'buttonStart')
  buttonHolder:addTouchEventListener(touchEvent)

  local buttonConnect = ccui.Helper:seekWidgetByName(uiRoot, 'v_ButtonConnect')
  buttonConnect:addTouchEventListener(touchEvent)

  local buttonConnect = ccui.Helper:seekWidgetByName(uiRoot, 'v_ButtonSignIn')
  buttonConnect:addTouchEventListener(touchEvent)
  
  buttonS:setVisible(false)

  -- self:initKeypadHandler()
  
--  local proxy = cc.CCBReader
  self:runAction(cc.Sequence:create(
    cc.DelayTime:create(0.3),
    cc.CallFunc:create(function()
      local cjson = require('cjson.safe')
      print('start to load allCardTypes.json')
      local jsonStr = cc.FileUtils:getInstance():getStringFromFile('allCardTypes.json')
      print('start to decode allCardTypes.json')
      AllCardTypes = cjson.decode(jsonStr)
      print('decode allCardTypes.json finished')
    end),
    cc.DelayTime:create(0.1),
    cc.CallFunc:create(function()
      cc.SpriteFrameCache:getInstance():addSpriteFrames('poke_cards.plist')
      PokeCard.sharedPokeCard()
    end)
  ))
  
--  dump(AllCardTypes["3333"])
--  
--  local c = Card.new(AllCardTypes["3333"])
--  dump(c)
--  print('c.isBomb? ', c:isBomb(), '\n', c:toString())
--  dump(c:getPokeValues(true))
  
end

function LandingScene:connectToServer()
  local this = self

  local sessionInfo = ddz.loadSessionInfo() or {}
  local sessionToken = sessionInfo.sessionToken
  local lastSessionToken = sessionInfo.sessionToken
  local userId = sessionInfo.userId

  local function queryRooms()
    ddz.pomeloClient:request('ddz.entryHandler.queryRooms', {}, function(data) 
      dump(data, 'queryRooms => ')
      if data.err == nil then
        ddz.GlobalSettings.rooms = data.rooms
        self.buttonS:setVisible(true)
      end
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
      ddz.GlobalSettings.userInfo = newUserInfo
      ddz.GlobalSettings.session.userId = newUserInfo.userId
      ddz.GlobalSettings.session.authToken = newUserInfo.authToken
      ddz.GlobalSettings.session.sessionToken = data.sessionToken
      ddz.GlobalSettings.serverInfo = table.dup(data.server)
      newUserInfo.sessionToken = data.sessionToken
      sessionToken = data.sessionToken
      ddz.saveSessionInfo(newUserInfo)
      connectToGameServer(true, newUserInfo, serverInfo)
    end
  end

  if ddz.pomeloClient then
    ddz.pomeloClient:disconnect()
  end
  self:connectTo('192.168.1.165', '4001', sessionInfo.userId, sessionInfo.sessionToken, onConnectionReady)
end

function LandingScene:initKeypadHandler()
  local function onKeyReleased(keyCode, event)
    print('[LandingScene:initKeypadHandler] keyCode : ', keyCode, 'event: ', event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      --      if type(self.onMainMenu) == 'function' then
      --        self.onMainMenu()
      --      end
      umeng.MobClickCpp:endScene('landing scene')
      umeng.MobClickCpp:endToLua()
      cc.Director:getInstance():endToLua()
    elseif keyCode == cc.KeyCode.KEY_MENU  then
      self:connectToServer()
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)

end

require('network.ConnectionPlugin').bind(LandingScene)
require('landing.SignInPlugin').bind(LandingScene)
require('landing.SignUpPlugin').bind(LandingScene)

local function createScene()
  local scene = cc.Scene:create()
  return LandingScene.extend(scene)
end

return createScene
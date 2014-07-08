require 'CCBReaderLoad'
require 'GuiConstants'
require 'PokeCard'

local cjson = require('cjson.safe')

local LoginScene = class('LoginScene')

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
  self:init()
end

function LoginScene:init()
  local this = self

  require('pomelo.cocos2dx_websocket')

  require('testPomelo')
  -- testPomelo(Cocos2dxWebsocket)

  umeng.MobClickCpp:beginScene('landing scene')

  umeng.MobClickCpp:beginEvent('test')

  umeng.MobClickCpp:pay(10, 2, 1000)

  local handsetInfo = ddz.GlobalSettings.handsetInfo
  -- local luaj = require('luaj')
  -- local ok, ret = luaj.callStaticMethod("com/fungame/DDZ/MobileInfoGetter", "getAllInfoString", {}, "()Ljava/lang/String;")
  -- print('[MobileInfoGetter] ok: ', ok, ' ret: ', ret)
  -- if ok then
  --   handsetInfo = cjson.decode(ret)
  --   dump(handsetInfo, 'handsetInfo')
  -- end

  local fungamePath = ddz.GlobalSettings.ddzSDPath

  -- local pomelo = nil
  local fu = cc.FileUtils:getInstance()

  local function queryRooms(sender, pomelo)
    pomelo:request('connector.entryHandler.queryRooms', {}, function(data)
      dump(data, "rooms => ")
    end)
  end  

  local SignIn = function(sessionInfo, callback)
    local userInfo = {}
    userInfo.appVersion = "1.0"
    userInfo.resVersion = "1.0.0"
    userInfo.handsetInfo = handsetInfo
    --userInfo.authToken = sessionInfo.authToken
    userInfo.password = 'abc123';
    userInfo.userId = sessionInfo.userId
    userInfo.signInType = 3
    this.pomeloClient:request('auth.userHandler.signIn', userInfo, function(data) 
      -- if err ~= nil then
      --   dump(err, 'Failed to call gate.gateHandler.signIn')
      --   return
      -- end

      dump(data, '[auth.userHandler.signIn] data =>')
      local userData = cjson.encode(data.user)
      --fu:writeToFile(data.user, 'userinfo.plist')
      local file = io.open(fungamePath .. '/userinfo.json', 'w+')
      file:write(userData)
      file:close()

      callback(this, this.pomeloClient, data.user.userId, data.user.sessionToken);

    end)
 
  end

  local function queryEntry(sender, pomelo, userId, sessionToken)
    pomelo:request('gate.gateHandler.queryEntry', {uid = userId}, function(data)
      dump(data, "[LoginScene->queryEntry] data =>")
    -- pomelo:request('auth.userHandler.signIn', {uid = 10001}, function(data)
    --   dump(data, "[auth.userHandler.signIn] data =>")
      if data.err == nil then
        self:connectTo(data.hosts[1].host, data.hosts[1].port, userId, sessionToken, queryRooms)
      end
    end)
  end

  local SignUp = function(callback)
    local userInfo = {}
    userInfo.appVersion = "1.0"
    userInfo.resVersion = "1.0.0"
    userInfo.handsetInfo = handsetInfo
    this.pomeloClient:request('auth.userHandler.signUp', userInfo, function(data) 
      
      -- if err ~= nil then
      --   dump(err, 'Failed to call gate.gateHandler.signIn')
      --   return
      -- end

      dump(data, '[auth.userHandler.signUp] data =>')
      local userData = cjson.encode(data.user)
      --fu:writeToFile(data.user, 'userinfo.plist')
      local userDataFilename = fungamePath .. '/userinfo.json'
      dump(userDataFilename, 'userinfo path')
      local file = io.open(userDataFilename, 'w+')
      file:write(userData)
      file:close()
      callback(this, this.pomeloClient, data.user.userId, data.user.sessionToken);
    end)
   end

  local userId, sessionToken = nil, nil
  local sessionInfo = nil
  local filepath = fungamePath .. '/userinfo.json'
  print('filepath => ', filepath)
  local userinfoString = fu:getStringFromFile(filepath)
  dump(userinfoString, 'userinfoString')
  if userinfoString ~= nil and userinfoString ~= 'null' then
    --local userinfoString = fu:getStringFromFile('userinfo.json')
    sessionInfo = cjson.decode(userinfoString)
    userId = sessionInfo.userId
    sessionToken = sessionInfo.sessionToken
  end
  dump(sessionInfo, 'sessionInfo')

  local doSignInUp = function(sender, pomelo)

    if sessionInfo == nil or sessionInfo == cjson.null then
      SignUp()
    else
      SignIn(sessionInfo)
    end
  end

  local onConnectionReady = function(sender, pomelo, data)
    if userId == nil then
      SignUp(queryEntry)
    elseif data.needSignIn then
      SignIn(sessionInfo, queryEntry)
    else
      queryEntry(sender, pomelo, userId, sessionToken)
    end
  end


  self:connectTo('192.168.1.165', '4001', userId, sessionToken, onConnectionReady)

  -- self:runAction(cc.Sequence:create(
  --   cc.DelayTime:create(2),
  --   cc.CallFunc:create(doSignInUp)
  -- ))


  -- local pluginName = 'AnalyticsUmeng'
  -- local appKey = '5351dee256240b09f604ee4c'

  -- local _pluginAnalytics = plugin.PluginManager:getInstance():loadPlugin(pluginName)
  -- print( '_pluginAnalytics => ' , _pluginAnalytics)
  -- local umeng = tolua.cast(_pluginAnalytics, 'plugin.ProtocolAnalytics')
  -- umeng:setDebugMode(true)
  -- umeng:startSession(appKey)
  -- umeng:logEvent('test')

  -- local param = plugin.PluginParam:new("1.1")
  -- umeng:callFuncWithParam('setVersionName', param)

  self:registerScriptHandler(function(event)
    print('event => ', event)
    if event == "enterTransitionFinish" then
      --self:init()
    elseif event == 'exit' then
      -- umeng:stopSession()
    end
  end)

  local rootLayer = cc.Layer:create()

  self:addChild(rootLayer)
  
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
      end
    end
  end
  
  local buttonS = ccui.Helper:seekWidgetByName(uiRoot, 'ButtonS')
  buttonS:addTouchEventListener(touchEvent)
  
  local buttonHolder = ccui.Helper:seekWidgetByName(uiRoot, 'buttonStart')
  buttonHolder:addTouchEventListener(touchEvent)
  
  self:initKeypadHandler()
  
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

    local imageView = ccui.ImageView:create()
    imageView:setScale9Enabled(true)
    imageView:loadTexture("images/sound.9.png")
    imageView:setContentSize(cc.size(200, 40))
    imageView:setPosition(cc.p(500, 370))
    imageView:setLocalZOrder(100)
    uiRoot:addChild(imageView)

end

function LoginScene:initKeypadHandler()
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      --      if type(self.onMainMenu) == 'function' then
      --        self.onMainMenu()
      --      end
      umeng.MobClickCpp:endScene('landing scene')
      umeng.MobClickCpp:endToLua()
      cc.Director:getInstance():endToLua()
    elseif keyCode == cc.KeyCode.KEY_MENU  then
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

require('network.ConnectionPlugin').bind(LoginScene)

local function createScene()
  local scene = cc.Scene:create()
  return LoginScene.extend(scene)
end

return createScene
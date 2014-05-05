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

  require('pomelo.cocos2dx_websocket')

  require('testPomelo')
  testPomelo(Cocos2dxWebsocket)

  umeng.MobClickCpp:beginScene('landing scene')

  umeng.MobClickCpp:beginEvent('test')

  umeng.MobClickCpp:pay(10, 2, 1000)

  local handsetInfo = {}
  local luaj = require('luaj')
  local ok, ret = luaj.callStaticMethod("com/fungame/DDZ/MobileInfoGetter", "getAllInfoString", {}, "()Ljava/lang/String;")
  print('[MobileInfoGetter] ok: ', ok, ' ret: ', ret)
  if ok then
    handsetInfo = cjson.decode(ret)
    dump(handsetInfo, 'handsetInfo')
  end

  local sdcardPath, fungamePath
  ok, sdcardPath = luaj.callStaticMethod("com/fungame/DDZ/Utils", "getExternalStorageDirectory", {}, "()Ljava/lang/String;")
  print('sdcardPath => ', ok, sdcardPath)
  ok, fungamePath = luaj.callStaticMethod("com/fungame/DDZ/Utils", "mkdir", {"fungame/DDZ"}, "(Ljava/lang/String;)Ljava/lang/String;")
  print('ddzPath => ', ok, fungamePath)

  local pomelo = nil
  local fu = cc.FileUtils:getInstance()

  local SignIn = function()
    local userInfo = {}
    userInfo.appVersion = "1.0"
    userInfo.resVersion = "1.0.0"
    userInfo.handsetInfo = handsetInfo
    pomelo:request('gate.gateHandler.signIn', userInfo, function(data) 
      -- if err ~= nil then
      --   dump(err, 'Failed to call gate.gateHandler.signIn')
      --   return
      -- end

      dump(data, '[gate.gateHandler.signIn] data =>')
      local userData = cjson.encode(data.user)
      --fu:writeToFile(data.user, 'userinfo.plist')
      local file = io.open(fu:getWritablePath() .. '/userinfo.json', 'w+')
      file:write(userData)
      file:close()

    end)
 
  end

  local SignUp = function()
  end


  local doSignInUp = function()
    local sessionInfo = nil
    local filepath = fu:getWritablePath() .. 'userinfo.json'
    print('filepath => ', filepath)
    local userinfoString = fu:getStringFromFile(filepath)
    if userinfoString ~= nil then
      --local userinfoString = fu:getStringFromFile('userinfo.json')
      sessionInfo = cjson.decode(userinfoString)
      dump(sessionInfo, 'sessionInfo')
    end

    initCocos2dxPomelo(nil, function(p) 
      pomelo = p

      if sessionInfo == nil then
        SignIn()
      end
    end)
  end

  self:runAction(cc.Sequence:create(
    cc.DelayTime:create(2),
    cc.CallFunc:create(doSignInUp)
  ))


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


local function createScene()
  local scene = cc.Scene:create()
  return LoginScene.extend(scene)
end

return createScene
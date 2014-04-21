require 'CCBReaderLoad'
require 'GuiConstants'
require 'PokeCard'

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

  umeng.MobClickCpp:beginScene('landing scene')

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
      umeng.MobClickCpp:endScene('landing scene')
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
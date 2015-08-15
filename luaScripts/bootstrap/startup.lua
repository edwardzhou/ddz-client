--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

CC_USE_DEPRECATED_API = false
require "cocos.init"
require('extern')
require 'GlobalSettings'
require 'DebugSetting'


cc.KeyCode.KEY_BACKSPACE    = 0x0006
cc.KeyCode.KEY_MENU         = 0x000F

local function startup()
  local director = cc.Director:getInstance()
  local glview = director:getOpenGLView()
  if nil == glview then
      glview = cc.GLView:createWithRect("DDZ", cc.rect(0, 0, 800, 480))
      director:setOpenGLView(glview)       
  end

  glview:setDesignResolutionSize(800, 480, cc.ResolutionPolicy.EXACT_FIT)

  -- turn on display FPS
  director:setDisplayStats(false)

  --set FPS. the default value is 1.0/60 if you't call this
  director:setAnimationInterval(1.0 / 60)

  local fileUtils = cc.FileUtils:getInstance()

  --support debug
  local targetPlatform = cc.Application:getInstance():getTargetPlatform()
  if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or 
     (cc.PLATFORM_OS_ANDROID == targetPlatform) or (cc.PLATFORM_OS_WINDOWS == targetPlatform) or
     (cc.PLATFORM_OS_MAC == targetPlatform) then
      local host = '192.168.0.90' -- please change localhost to your PC's IP for on-device debugging
      --require('src.mobdebug').start(host)
  end

  _aa, _ab, _ac = ___appsig('abcde')
  -- print('===== subjectMd5: ', subjectMd5)
  -- print('===== data: ', data)
  -- print('===== dataMd5: ', dataMd5)

  _xa, _xb, _xc = ___appxxx('D4DB1295EA1B3298DD256AF4BEBCFC0C')
  -- print('===== xa: ', _xa)
  -- print('===== xb: ', _xb)
  -- print('===== xc: ', _xc)

  __appPkgName, __appVersionName, __appVersionCode = ___appver()
  -- print('===== appPkgName: ', appPkgName)
  -- print('===== appVersionName: ', appVersionName)
  -- print('===== appVersionCode: ', appVersionCode)

  -- print('===== a?b base64: ', ___tobase64('a?b'))
  -- print('===== YT9i debase64: ', ___frombase64('YT9i'))
  -- print('===== YT9ibx debase64: ', ___frombase64('YT9ibx?./{}'))
  -- print('===== "YT9ibx?./{}" md5: ', ___md5('YT9ibx?./{}'))

  ddz.GlobalSettings.handsetInfo = ddz.getHandsetInfo()
  ddz.GlobalSettings.sdcardPath = ddz.getSDCardPath()
  ddz.GlobalSettings.ddzSDPath = ddz.mkdir('fungame/DDZ')
  ddz.GlobalSettings.appPrivatePath = fileUtils:getWritablePath()
  ddz.GlobalSettings.session = ddz.loadSessionInfo() or {}

  local audioInfo = ddz.loadAudioInfo()
  if audioInfo then
    ddz.GlobalSettings.audioInfo.musicEnabled = audioInfo.musicEnabled
    ddz.GlobalSettings.audioInfo.musicVolume = audioInfo.musicVolume
    ddz.GlobalSettings.audioInfo.effectEnabled = audioInfo.effectEnabled
    ddz.GlobalSettings.audioInfo.effectVolume = audioInfo.effectVolume
  end
  
  dump(ddz.GlobalSettings, 'GlobalSettings')

  -- require('httpTest')
  -- doHttpTest()

  -- umeng.MobClickCpp:startWithAppkey("5351dee256240b09f604ee4c", "my_channel_lua")

  -- local eventDict = {hello = "world", demo = "ok " .. os.date()}

  -- umeng.MobClickCpp:event('test event')
  -- umeng.MobClickCpp:event('test event with label', 'test label')
  -- umeng.MobClickCpp:event('test event with dict', eventDict)
  -- umeng.MobClickCpp:event('test event with dict3', {hello = "world", demo = "ok " .. os.date()}, 1)

  local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
  local function onNetworkChanged(event)
      print('[onNetworkChanged] ', event:getEventName())
  end

  local listener1 = cc.EventListenerCustom:create("on_network_change_available",onNetworkChanged)
  eventDispatcher:addEventListenerWithFixedPriority(listener1, 1)

  local listener2 = cc.EventListenerCustom:create("on_network_change_disable",onNetworkChanged)
  eventDispatcher:addEventListenerWithFixedPriority(listener2, 2)

  local function onEventComeToForeground()
    print("[onEventComeToForeground] ...")
    cc.Director:getInstance():getRunningScene():runAction(cc.CallFunc:create(function() 
        ccexp.AudioEngine:resumeAll()
      end))
  end
  local function onEventComeToBackground()
    print("[onEventComeToBackground] ...")
    ccexp.AudioEngine:pauseAll()
  end

  local listener3 = cc.EventListenerCustom:create("event_come_to_background", onEventComeToBackground)
  eventDispatcher:addEventListenerWithFixedPriority(listener3, 3)

  local listener4 = cc.EventListenerCustom:create("event_come_to_foreground", onEventComeToForeground)
  eventDispatcher:addEventListenerWithFixedPriority(listener4, 4)


  ddz.GlobalSettings.scaleFactor = director:getContentScaleFactor()

  local talkingDataInfo = fileUtils:getValueMapFromFile('talkingdata.plist')

  --fileUtils:writeToFile({appkey = 'D4DB1295EA1B3298DD256AF4BEBCFC0C', channel = 'official'}, '/sdcard/fungame/DDZ/td.plist')
  local tdInitParams = {talkingDataInfo.appkey, talkingDataInfo.channel}

  local luaj = require('cocos.cocos2d.luaj')
  local ok, ret = luaj.callStaticMethod("com/fungame/DDZ/TalkingDataUtils", "init", tdInitParams, "(Ljava/lang/String;Ljava/lang/String;)V")
  -- TalkingDataGA:onStart(talkingDataInfo.appkey, talkingDataInfo.channel)

  ddz.onEnd(function() 
      print('==== call TalkingDataGA:onKill()')
      -- TalkingDataGA:onKill()
    end)

  -- local eventData = {key1="value1", key2="value2", key3="value3"} 
  -- TalkingDataGA:onEvent("event1", eventData) 
  -- TalkingDataGA:setLocation(39.9497, 116.4137)
  -- local deviceId = TalkingDataGA:getDeviceId() 
  print('======= deviceId: ', deviceId)
  -- TalkingDataGA:onKill()
  -- run
  local createLoginScene = require('landing.LandingScene')
  local sceneGame = createLoginScene()
  director:runWithScene(sceneGame)  
end

return startup
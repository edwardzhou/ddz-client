--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

require 'socket'
require 'GlobalSettings'
local utils = require('utils.utils')
local cjson = require('cjson.safe')

local _audioInfo = ddz.GlobalSettings.audioInfo
local LandingScene = class('LandingScene')
local display = require('cocos.framework.display')

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

  this.hidenRetries = 1

  self:registerScriptHandler(function(event)
    print('[LandingScene] event => ', event)
    local on_event = 'on_' .. event
    if type(this[on_event]) == 'function' then
      this[on_event](this)
    end
  end)

  local rootLayer = cc.Layer:create()

  self:addChild(rootLayer)
  self.rootLayer = rootLayer
  
  --local uiRoot = ccs.GUIReader:getInstance():widgetFromBinaryFile('gameUI/Landing.csb')
  local uiRoot = cc.CSLoader:createNode('LandingScene2.csb')
  print( 'uiRoot => ', uiRoot)
  rootLayer:addChild(uiRoot)
  self.uiRoot = uiRoot

  require('utils.UIVariableBinding').bind(uiRoot, self, self)

  if self.Version then
    self.Version:setString('v'  .. require('version'))
  end

  self.MainPanel:setScale(0.001)
  self.MainPanel:runAction(cc.EaseElasticInOut:create(cc.ScaleTo:create(0.5, 1.0), 0.5))


  local percent = 10

  local function progressEffect()
    local startWidth = 70
    local width = startWidth
    local height = 36
    this.ImageProgressLight:setContentSize(cc.size(70, 36))
    this.ImageProgressLight:setVisible(true)
    local animateFunc = function()
      width = width + 3
      if width > (340 * percent / 100 - 20) then
        width = startWidth
      end
      this.ImageProgressLight:setContentSize(cc.size(width, height))
    end
    this:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.CallFunc:create(animateFunc)
          )
      ))
  end

  this:runAction(cc.RepeatForever:create(
      cc.Sequence:create(
        cc.CallFunc:create(function()
          this:updateLoadingProgress()
        end),
        cc.DelayTime:create(0.016)
        )
    ))

  this.progress = 10
  this.lastProgress = 0

  this.ImageProgressLight:setVisible(false)
  --this.ImageProgress:setVisible(false)
  this.ImageProgress:setContentSize(cc.size(340 * percent / 100, 36))
  uiRoot:runAction( cc.Sequence:create(
    cc.Repeat:create(
      cc.Sequence:create(
        cc.DelayTime:create(0.03),
        cc.CallFunc:create(function()
          this.progress = this.progress + 1
        end)), 
      20),
    cc.CallFunc:create(function()
        --this.LoadingBar:setVisible(false)
--        umeng.MobClickCpp:endEvent('test')
      end)
  ))
  
  local snow = cc.ParticleSystemQuad:create('snow.plist')
  snow:setPosition(200, 480)
  rootLayer:addChild(snow)

  snow = cc.ParticleSystemQuad:create('snow.plist')
  snow:setPosition(600, 480)
  rootLayer:addChild(snow)

  cc.SpriteFrameCache:getInstance():addSpriteFrames('dialogs.plist')
  cc.SpriteFrameCache:getInstance():addSpriteFrames('loading.plist')

  local loadingAnimation = display.getAnimationCache('loadingAnimation')
  if loadingAnimation == nil then
    loadingAnimation = display.newAnimation('loading_animate_%02d.png', 1, 8, 12.0 / 60.0)
    display.setAnimationCache('loadingAnimation', loadingAnimation)
  end
  this.LoadingAnimation:runAction(
      cc.RepeatForever:create(
        cc.Animate:create(loadingAnimation)
        )
    )

  local dotAnimation = display.newAnimation('loading_text_animate_%02d.png', 1, 3, 24.0 / 60.0)
  this.LoadingDot:runAction(
      cc.RepeatForever:create(
        cc.Animate:create(dotAnimation)
        )
    )

  require('MusicPlayer').playBgMusic()

  local nextStep = null

  local function onPokeCardTextureReady()
    --this:connectToServer()
    nextStep()
  end

  local function loadMain()
    main_path = cc.FileUtils:getInstance():fullPathForFilename('main.zip')
    print('main.zip =====> ', main_path)
    local lastStep = 0

    this:runAction(cc.Sequence:create(
        cc.CallFunc:create(function() 
            cc.LuaLoadChunksFromZIP(main_path)
            this.progress = this.progress + 10
          end ),
        cc.DelayTime:create(0.2),
        cc.CallFunc:create(function()
            require('landing.LandingConnectionPlugin').bind(LandingScene)
            require('network.ConnectionStatusPlugin').bind(LandingScene)
            this.progress = this.progress + 5
          end),
        cc.DelayTime:create(0.2),
        cc.CallFunc:create(function()
            require('CardTypeLoader').loadAllCardTypeX(this, 
                function(step)
                  this.progress = this.progress + (step - lastStep) * 50 / 100
                  lastStep = step
                end,
                function()
                  print('----- start to PokeCardTexture.loadPokeCardTextures')
                  require('PokeCardTexture'):loadPokeCardTextures(this, onPokeCardTextureReady)
                end
              )
          end)
        -- ,
        -- cc.DelayTime:create(0.2),
        -- cc.CallFunc:create(function()
        --     require('PokeCardTexture'):loadPokeCardTextures(this, onPokeCardTextureReady)
        --   end)
      ))

    -- cc.LuaLoadChunksFromZIP(main_path)
    -- require('landing.LandingConnectionPlugin').bind(LandingScene)
    -- require('network.ConnectionStatusPlugin').bind(LandingScene)
    -- require('CardTypeLoader').loadAllCardType()
    -- require('PokeCardTexture'):loadPokeCardTextures(this, onPokeCardTextureReady)
  end

  local function onUpdateEvent(event)
    local eventCode = event:getEventCode()
    print('[onUpdateEvent] event => ', event)
    if eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST or 
        eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST or
        eventCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE or
        eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then

      local searchPaths = cc.FileUtils:getInstance():getSearchPaths()
      dump(searchPaths, '=====searchPaths=========')
      loadMain()
    end
  end

  local onLoginFailed = function(respData)
    local msg = respData.message
    local boxParams = {
      title = '无法自动登录',
      msg = msg,
      buttonType = 'ok|close',
      onOk = function() cc.Director:getInstance():replaceScene(require('login.LoginScene')()) end,            
    }
    require('UICommon.MsgBox').showMessageBox(cc.Director:getInstance():getRunningScene(), boxParams)
  end

  local function connectToServerAfterUpdate()
    this:connectToServer()
  end

  this:runAction(cc.CallFunc:create( function()
    this:startToLogin(function(succ, respData, extra) 
      if not succ then
        nextStep = function() onLoginFailed(respData) end
      else
        nextStep = connectToServerAfterUpdate
      end

      print("respData.forceUpdateRes: ", respData.forceUpdateRes)
      print("respData.updateVersionUrl: ", respData.updateVersionUrl)
      if respData.forceUpdateRes or respData.updateVersionUrl then
        print(string.format('got UpdateUrl[%s], need to update', respData.updateVersionUrl))
        local updateManager = require('update.UpdateManager').new()
        updateManager:startCheckUpdate(onUpdateEvent)
      else
        loadMain()
      end

    end)
  end))
end

function LandingScene:updateLoadingProgress()
  local this = self

  if this.progress == this.lastProgress then
    return
  end
  this.lastProgress = this.progress

  local width = 340 * this.progress / 100

  this.ImageProgress:setContentSize(cc.size(width, 36))
  if width > 95 then
    this.ImageProgressLight:setContentSize(cc.size(width - 30, 36))
    this.ImageProgressLight:setVisible(true)
  else
    this.ImageProgressLight:setVisible(false)
  end

end

function LandingScene:on_enterTransitionFinish()
  -- body
  print('[LandingScene:on_enterTransitionFinish]')
  self:initKeypadHandler()


end

function LandingScene:startToLogin(cb)
  print('LandingScene:startToLogin')

  local AccountInfo = require('AccountInfo')
  local EntryService = require('EntryService')

  local sendLogin, onLoginResult, onFailure , onPluginLoginResult
  local userInfo = {}

  onLoginResult = function(succ, respData, extra)
    dump(respData, '[LandingScene:startToLogin] onLoginResult: respData', 5)
    if succ then
      AccountInfo.setCurrentUser(respData)
    end
    utils.invokeCallback(cb, succ, respData, extra)
  end
  -- onFailure = function( ... )
  --   -- body
  -- end

  sendLogin = function()
    local loginService = EntryService.new({showProgress=false})
    loginService:requestSignInUp(__appUrl, ddz.GlobalSettings.handsetInfo, userInfo, 5, onLoginResult)
  end

  onPluginLoginResult = function(success, plugin, code, msg) 

    print('plugin_channel login result: ', success, ', code: ', code)
    dump(msg, '[plugin_channel:login] resp')
    local sdk_msg, error = cjson.decode(msg)
    if error then
      print('[plugin_channel:login] cjson decode error: ', error)
      sdk_msg = {}
    end

      if success then        
        userInfo = {}
        userInfo.anySDK = {
          user_sdk = sdk_msg.user_sdk,
          uid = sdk_msg.uid,
          channel = sdk_msg.channel,
          access_token = sdk_msg.access_token
        }
        if sdk_msg.userId and sdk_msg.authToken then
          userInfo.userId = sdk_msg.userId
          userInfo.authToken =  sdk_msg.authToken
        end

        setTimeout(sendLogin, {}, 0.1)

        --sendLogin()
      else
        ddz.endApplication()
      end

    end


  plugin_channel:login(function(success, plugin, code, msg)
      setTimeout(function() 
          onPluginLoginResult(success, plugin, code, msg)
        end, {}, 0.15)
    end)

  --sendLogin()
end

function LandingScene:on_exit()
  utils.invokeCallback(self.removeConnectionHooks, self)
end

function LandingScene:initKeypadHandler()
  local function onKeyReleased(keyCode, event)
    print('[LandingScene:initKeypadHandler] keyCode : ', keyCode, 'event: ', event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      --      if type(self.onMainMenu) == 'function' then
      --        self.onMainMenu()
      --      end
      -- umeng.MobClickCpp:endScene('landing scene')
      -- umeng.MobClickCpp:endToLua()
      ddz.endApplication()
    -- elseif keyCode == cc.KeyCode.KEY_MENU  then
    --   self:connectToServer()
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)

end

local function createScene()
  local scene = cc.Scene:create()
  return LandingScene.extend(scene)
end

--require('network.ConnectionStatusPlugin').bind(LandingScene)

return createScene
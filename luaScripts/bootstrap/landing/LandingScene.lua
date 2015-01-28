require 'socket'
require 'GlobalSettings'
local utils = require('utils.utils')
local cjson = require('cjson.safe')

local _audioInfo = ddz.GlobalSettings.audioInfo
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
  local uiRoot = cc.CSLoader:createNode('LandingScene.csb')
  print( 'uiRoot => ', uiRoot)
  rootLayer:addChild(uiRoot)
  self.uiRoot = uiRoot

  require('utils.UIVariableBinding').bind(uiRoot, self, self, true)

  local percent = 0
  uiRoot:runAction( cc.Sequence:create(
    cc.Repeat:create(
      cc.Sequence:create(
        cc.DelayTime:create(0.02),
        cc.CallFunc:create(function()
          percent = percent + 1
          this.LoadingBar:setPercent(percent) 
        end)), 
      100),
    cc.CallFunc:create(function()
        this.LoadingBar:setVisible(false)
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

  -- self:runAction(cc.Sequence:create(
  --   cc.DelayTime:create(0.3),
  --   cc.CallFunc:create(function()

  --   end),
  --   cc.DelayTime:create(0.1),
  --   cc.CallFunc:create(function()

  --     this:connectToServer()
  --   end)
  -- ))

  require('MusicPlayer').playBgMusic()

  local function onPokeCardTextureReady()
    this:connectToServer()
  end

  local function onUpdateEvent(event)
    local eventCode = event:getEventCode()
    if eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST or 
        eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST or
        eventCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE or
        eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then

      local searchPaths = cc.FileUtils:getInstance():getSearchPaths()
      dump(searchPaths, '=====searchPaths=========')

      main_path = cc.FileUtils:getInstance():fullPathForFilename('main.zip')
      print('main.zip =====> ', main_path)
      cc.LuaLoadChunksFromZIP(main_path)
      require('landing.LandingConnectionPlugin').bind(LandingScene)
      require('network.ConnectionStatusPlugin').bind(LandingScene)
      require('CardTypeLoader').loadAllCardType()
      require('PokeCardTexture'):loadPokeCardTextures(this, onPokeCardTextureReady)
    end
  end

  local updateManager = require('update.UpdateManager').new()
  updateManager:startCheckUpdate(onUpdateEvent)
end

function LandingScene:on_enterTransitionFinish()
  -- body
  print('[LandingScene:on_enterTransitionFinish]')
  self:initKeypadHandler()
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
      cc.Director:getInstance():endToLua()
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
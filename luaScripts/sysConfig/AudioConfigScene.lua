
local AudioConfigScene = class('AudioConfigScene')
local AccountInfo = require('AccountInfo')
local Resources = require('Resources')
local showMessageBox = require('UICommon.MessageBox').showMessageBox;

local _audioInfo = ddz.GlobalSettings.audioInfo

function AudioConfigScene.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, AudioConfigScene)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function AudioConfigScene:ctor(...)
  local this = self
  self:registerScriptHandler(function(event)
    print('[AudioConfigScene] event => ', event)
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

function AudioConfigScene:init()
  local rootLayer = self

  local guiReader = ccs.GUIReader:getInstance()
  print('[AudioConfigScene:init] start to load gameUI/SysConfig.csb')
  local uiRoot = guiReader:widgetFromBinaryFile('gameUI/SysConfig.csb')
  print('[AudioConfigScene:init] add to rootLayer')
  rootLayer:addChild(uiRoot)
  self.uiRoot = uiRoot

  require('utils.UIVariableBinding').bind(uiRoot, self, self, true)

  self:initKeypadHandler()

end

function AudioConfigScene:on_enter()
  local user = AccountInfo.getCurrentUser()
  dump(user, '[AudioConfigScene:on_enter] user')
  self.MusicVolume:setPercent(_audioInfo.musicVolume * 100)
  self.MusicEnabled:setSelected(_audioInfo.musicEnabled)
  self.EffectVolume:setPercent(_audioInfo.effectVolume * 100)
  self.EffectEnabled:setSelected(_audioInfo.effectEnabled)
end

function AudioConfigScene:on_exit()
 ddz.saveAudioInfo( _audioInfo )
end

function AudioConfigScene:initKeypadHandler()
  local this = self
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      event:stopPropagation()
      this:close()
    elseif keyCode == cc.KeyCode.KEY_MENU  then
      --label:setString("MENU clicked!")
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end



function AudioConfigScene:close()
  local this = self
   this:runAction(cc.RemoveSelf:create())
  --self.uiRoot:setOpacity(0)
  -- self.MsgPanel:setVisible(false)
  -- self.ImageBox:setVisible(true)
  -- self.ImageBox:runAction( 
  --   cc.Sequence:create(
  --     cc.ScaleTo:create(0.15, 1),
  --     cc.TargetedAction:create(this, cc.RemoveSelf:create())
  --   )
  -- )
end

function AudioConfigScene:ButtonBack_onClicked()
  self:close()
end

function AudioConfigScene:BgPanel_onClicked()
  self:close()
end

function AudioConfigScene:MusicVolume_onEvent(sender, eventType)
  --print('[AudioConfigScene:MusicVolume_onEvent] eventType: ', eventType, ', ccui.SliderEventType.percentChanged: ', ccui.SliderEventType.percentChanged)
  local player = require('MusicPlayer')
  if eventType == ccui.SliderEventType.percentChanged then
    local slider = sender
    local percent = slider:getPercent()
    _audioInfo.musicVolume = percent / 100.0
    print('MusicVolume => Percent ' , percent)
    player.setBgMusicVolume()
  end
end

function AudioConfigScene:EffectVolume_onEvent(sender, eventType)
  --print('[AudioConfigScene:EffectVolume_onEvent] eventType: ', eventType, ', ccui.SliderEventType.percentChanged: ', ccui.SliderEventType.percentChanged)
  if eventType == ccui.SliderEventType.percentChanged then
    local slider = sender
    local percent = slider:getPercent()
    _audioInfo.effectVolume = percent / 100.0
    print('EffectVolumn => Percent ' , percent)
  end
end

function AudioConfigScene:MusicEnabled_onEvent(sender, eventType)
  local player = require('MusicPlayer')
  _audioInfo.musicEnabled = eventType == ccui.CheckBoxEventType.selected
  if _audioInfo.musicEnabled then
    player.playBgMusic()
  else
    player.stopBgMusic()
  end
end

function AudioConfigScene:EffectEnabled_onEvent(sender, eventType)
  _audioInfo.effectEnabled = eventType == ccui.CheckBoxEventType.selected
end

local function createScene()
  local scene = cc.Scene:create()

  return AudioConfigScene.extend(scene)
end

local function showAudioConfig(container, params)
  local layer = cc.Layer:create()
  local msgBox = AudioConfigScene.extend(layer, params)

  msgBox:setLocalZOrder(900)
  container:addChild(msgBox)
end

return {
  showAudioConfig = showAudioConfig
}


local AudioConfigLayer = class('AudioConfigLayer2', function() 
  return cc.Layer:create()
end)

local AccountInfo = require('AccountInfo')
local Resources = require('Resources')
local showMessageBox = require('UICommon.MsgBox').showMessageBox;

local _audioInfo = ddz.GlobalSettings.audioInfo


function AudioConfigLayer:ctor(...)
  local this = self
  self:registerScriptHandler(function(event)
    print('[AudioConfigLayer] event => ', event)
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

function AudioConfigLayer:init()
  local rootLayer = self

  self:setVisible(false)

  local uiRoot = cc.CSLoader:createNode('AudioSettingLayer.csb')
  
  print('[AudioConfigLayer:init] add to rootLayer')
  rootLayer:addChild(uiRoot)
  self.uiRoot = uiRoot

  require('utils.UIVariableBinding').bind(uiRoot, self, self)

  self:initKeypadHandler()

end

function AudioConfigLayer:on_enter()
  local user = AccountInfo.getCurrentUser()
  dump(user, '[AudioConfigLayer:on_enter] user')
  --self.MusicVolume:setPercent(_audioInfo.musicVolume * 100)
  -- self.MusicEnabled:setSelected(_audioInfo.musicEnabled)
  -- --self.EffectVolume:setPercent(_audioInfo.effectVolume * 100)
  -- self.EffectEnabled:setSelected(_audioInfo.effectEnabled)

  -- self.PanelMusicValue:setSizePercent(cc.p(_audioInfo.musicVolume * 100, 100))
  -- self.PanelEffectValue:setSizePercent(cc.p(_audioInfo.effectVolume * 100 * 0.5, 100))
end

function AudioConfigLayer:on_exit()
end

function AudioConfigLayer:initKeypadHandler()
  local this = self
  local function onKeyReleased(keyCode, event)
    if not this:isVisible() then
      return
    end
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

function AudioConfigLayer:show()
  local this = self

  if this.showing then 
    return
  end

  this.showing = true
  this.closing = false

  this:setMusicVolume(_audioInfo.musicVolume)
  this:setEffectVolume(_audioInfo.effectVolume)

  this.CheckBoxMusicEnabled:setSelected(_audioInfo.musicEnabled)
  this.CheckBoxEffectEnabled:setSelected(_audioInfo.effectEnabled)

  self:setVisible(true)
  self.PanelSetting:setScale(0.001)
  self.PanelSetting:runAction(cc.Sequence:create(
    cc.EaseElasticInOut:create(cc.ScaleTo:create(0.5, 1.0), 0.5),
    cc.CallFunc:create(function()
        this.showing = false
      end)
  ))
end

function AudioConfigLayer:setMusicVolume(percent)
  local this = self
  local player = require('MusicPlayer')
  percent = percent
  this.PanelMusicValue:setSizePercent(cc.p(percent, 1))
  this.ImageMusicPos:setPositionPercent(cc.p(percent, 0.5))
  _audioInfo.musicVolume = percent
  player.setBgMusicVolume()
end

function AudioConfigLayer:setEffectVolume(percent)
  local this = self
  percent = percent
  this.PanelEffectValue:setSizePercent(cc.p(percent, 1))
  this.ImageEffectPos:setPositionPercent(cc.p(percent, 0.5))
  _audioInfo.effectVolume = percent
end

function AudioConfigLayer:close()
  local this = self

  if this.closing then
    return
  end

  this.closing = true
  ddz.saveAudioInfo( _audioInfo )

  self.PanelSetting:runAction(cc.Sequence:create(
    cc.EaseElasticInOut:create(cc.ScaleTo:create(0.5, 0.01), 0.5),
    --cc.TargetedAction:create(this, cc.Hide:create())
    cc.TargetedAction:create(this, cc.RemoveSelf:create())
  ))
end

function AudioConfigLayer:ButtonClose_onClicked()
  print('[AudioConfigLayer:ButtonClose_onClicked]')
  self:close()
end

function AudioConfigLayer:PanelSettingBg_onClicked()
  print('[AudioConfigLayer:PanelSettingBg_onClicked]')
  if self.showing then
    return
  end

  self:close()
end

function AudioConfigLayer:PanelMusicVolume_onTouchEvent(sender, eventType)
  -- body
  local this = self
  if eventType == ccui.TouchEventType.moved then
    local pos = sender:getTouchMovePosition()
    pos = sender:convertToNodeSpace(pos)
    local size = sender:getContentSize()
    local xper = cc.clampf(pos.x / size.width, 0, 1)
    this:setMusicVolume(xper)
  end
end

function AudioConfigLayer:PanelEffectVolume_onTouchEvent(sender, eventType)
  -- body
  local this = self
  if eventType == ccui.TouchEventType.moved then
    local pos = sender:getTouchMovePosition()
    pos = sender:convertToNodeSpace(pos)
    local size = sender:getContentSize()
    local xper = cc.clampf(pos.x / size.width, 0, 1)
    this:setEffectVolume(xper)
  end
end

function AudioConfigLayer:CheckBoxMusicEnabled_onEvent(sender, eventType)
  local player = require('MusicPlayer')
  _audioInfo.musicEnabled = eventType == ccui.CheckBoxEventType.selected
  if _audioInfo.musicEnabled then
    player.playBgMusic()
  else
    player.stopBgMusic()
  end
end

function AudioConfigLayer:CheckBoxEffectEnabled_onEvent(sender, eventType)
  _audioInfo.effectEnabled = eventType == ccui.CheckBoxEventType.selected
end

local function showAudioConfig(container, params)
  -- if container.audioConfigLayer == nil then
  --   container.audioConfigLayer = AudioConfigLayer.new()
  --   container:addChild(container.audioConfigLayer, 900)
  -- end
    container.audioConfigLayer = AudioConfigLayer.new()
    container:addChild(container.audioConfigLayer)

  container.audioConfigLayer:show()
end

return {
  showAudioConfig = showAudioConfig
}

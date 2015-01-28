local _bgMusicId = cc.AUDIO_INVAILD_ID

local bgMusicFile = 'sounds/bg1.mp3'

local stopBgMusic

local function playBgMusic()
  local _audioInfo = ddz.GlobalSettings.audioInfo
  dump(_audioInfo, '[playBgMusic] _audioInfo')
  if _audioInfo.musicEnabled and _audioInfo.musicVolume > 0.0 then

    if _bgMusicId ~= cc.AUDIO_INVAILD_ID then
      print('[playBgMusic] _bgMusicId => ', _bgMusicId, ', stop first.')
      stopBgMusic()
    end
    print('[playBgMusic] bgMusicFile => ', bgMusicFile)
    _bgMusicId = ccexp.AudioEngine:play2d(bgMusicFile, true, _audioInfo.musicVolume)
  end
end

local function stopBgMusic()
  local _audioInfo = ddz.GlobalSettings.audioInfo
  if _bgMusicId ~= cc.AUDIO_INVAILD_ID then
    ccexp.AudioEngine:stop(_bgMusicId)
  end
  _bgMusicId = cc.AUDIO_INVAILD_ID
end

local function setBgMusicVolume()
  local _audioInfo = ddz.GlobalSettings.audioInfo
  if _bgMusicId ~= cc.AUDIO_INVAILD_ID then
    ccexp.AudioEngine:setVolume(_bgMusicId, _audioInfo.musicVolume)
  end
end

return {
  playBgMusic = playBgMusic,
  stopBgMusic = stopBgMusic,
  setBgMusicVolume = setBgMusicVolume
}
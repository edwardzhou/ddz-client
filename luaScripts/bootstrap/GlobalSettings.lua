--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

ddz = ddz or {}
ddz.GlobalSettings = ddz.GlobalSettings or {}

local settings = ddz.GlobalSettings

settings.session = {
  authToken = nil,
  sessionToken = nil,
  userId = nil
}

settings.appInfo = {
  appVersion = '1.0.0',
  resVersion = '1.0.0.0',
  appid = 1000
}

settings.handsetInfo = {
  
}

settings.servers = {
  host = '118.26.229.45',
  -- host = '192.168.1.200',
  -- host = '192.168.1.165',
  -- host = '192.168.1.166',
  -- host = '192.168.0.163',
  port = '14001'
}

settings.audioInfo = {
  musicVolume = 1.0,
  musicEnabled = true,
  effectVolume = 1.0,
  effectEnabled = true
}

settings.mode = 'dev'

settings.tags = 'testing'

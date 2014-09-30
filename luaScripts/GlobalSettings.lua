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
  resVersion = '1.0.0.0'
}

settings.handsetInfo = {
  
}

settings.servers = {
  host = '118.26.229.45',
  --host = '192.168.1.165',
  --host = '192.168.0.163',
  port = '4001'
}

settings.mode = 'dev'

settings.tags = 'testing'

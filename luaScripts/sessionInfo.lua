local cjson = require('cjson.safe')
local SessionInfo = class('SessionInfo')

local _info = {}

function SessionInfo.create()
  _info = {
    currentUser = {},
    accounts = {}
  }

  local fu = cc.FileUtils:getInstance()
  local cjson = require('cjson.safe')
  local sessionInfo = nil
  local filepath = ddz.getDataStorePath() .. '/userinfo.json'
  print('filepath => ', filepath)
  local userinfoString = fu:getStringFromFile(filepath)
  dump(userinfoString, 'userinfoString')
  if userinfoString ~= nil and userinfoString ~= 'null' and #userinfoString > 0 then
    --local userinfoString = fu:getStringFromFile('userinfo.json')
    sessionInfo = cjson.decode(userinfoString)
    table.merge(_info, sessionInfo)
  else
    sessionInfo = nil
  end
  dump(_info, '_info')
  return _info
end

function SessionInfo.save(filename)
  filename = filename or 'userinfo.json'
  local filepath = ddz.getDataStorePath() .. '/' .. filename
  print('filepath => ', filepath)
  local file = io.open(filepath, 'w+')
  file:write(cjson.encode(sessionInfo))
  file:close()
end

function SessionInfo.getAccounts()
  return _info.accounts
end

function SessionInfo.getCurrentUser()
  return _info.currentUser
end

function SessionInfo.setCurrentUser(session)
  for n=#_info.accounts, 1, -1 do
    if _info.accounts[n].userId == session.user.userId then
      table.remove(_info.accounts, n)
    end
  end

  local newSession = {
    userId = session.user.userId, 
    authToken = session.user.auth,
    sessionToken = session.sessionToken
  }

  table.insert(_info.accounts, 1, newSession)

  _info.currentUser = table.dup( session.user )
  _info.currentUser.sessionToken = session.sessionToken

  SessionInfo.save()
end

return SessionInfo
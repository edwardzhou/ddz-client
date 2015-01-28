local cjson = require('cjson.safe')
local AccountInfo = class('AccountInfo')

local _info = {}

function AccountInfo.create()
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

function AccountInfo.save(filename)
  filename = filename or 'userinfo.json'
  local filepath = ddz.getDataStorePath() .. '/' .. filename
  print('filepath => ', filepath)
  local file = io.open(filepath, 'w+')
  file:write(cjson.encode(_info))
  file:close()
end

function AccountInfo.getAccounts()
  return _info.accounts
end

function AccountInfo.getAccountByUserId(userId)
  for _,account in ipairs(_info.accounts) do
    print('account.userId => ', account.userId , '  userId => ', userId, account.userId == userId)
    if tonumber(account.userId) == tonumber(userId) then
      return account
    end
  end

  return nil
end

function AccountInfo.getCurrentUser()
  return _info.currentUser
end

function AccountInfo.setCurrentUser(session)
  for n=#_info.accounts, 1, -1 do
    if tonumber(_info.accounts[n].userId) == tonumber(session.user.userId) then
      table.remove(_info.accounts, n)
    end
  end

  local newSession = {
    userId = session.user.userId, 
    authToken = session.user.authToken,
    sessionToken = session.sessionToken
  }

  table.insert(_info.accounts, 1, newSession)

  _info.currentUser = table.dup( session.user )
  _info.currentUser.sessionToken = session.sessionToken
  ddz.GlobalSettings.userInfo = _info.currentUser
  ddz.GlobalSettings.session.userId = _info.currentUser.userId
  ddz.GlobalSettings.session.authToken = _info.currentUser.authToken
  ddz.GlobalSettings.session.sessionToken = _info.currentUser.sessionToken
  if session.server then
    ddz.GlobalSettings.serverInfo = table.dup(session.server)
  end

  for i=#_info.accounts, 6, -1 do
    table.remove(_info.accounts, i)
  end

  AccountInfo.save()
end

AccountInfo.create()

return AccountInfo
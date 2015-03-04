local AccountInfo = require('AccountInfo')
local cjson = require('cjson.safe')
local EntryService = class('EntryService')
local utils = require('utils.utils')

function EntryService:ctor()
end

function EntryService:prepareParams(handsetInfo, userInfo)
  local params = {}
  params.appPkgName = __appPkgName
  params.appVersionName = __appVersionName
  params.appVersionCode = __appVersionCode
  params.appResVersion = __appResVersion
  params.appAffiliate = __appAffiliate
  params.appChannel = __appChannel
  params.handsetInfo = handsetInfo
  params.tm = os.time()
  local currentUser = userInfo
  if currentUser ~= nil then
    params.userId = currentUser.userId
    params.sessionToken = currentUser.sessionToken
    params.authToken = currentUser.authToken
  end

  return params
end

function EntryService:signInWithToken(url, handsetInfo, userInfo, callback)
  local xhr = cc.XMLHttpRequest:new()
  xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
  --xhr:open("GET", "http://192.168.1.165:8080/upd/assets_md5.json")
  xhr:open("POST", url)

  --local params = self:prepareParams(handsetInfo, userInfo)
  local p = cjson.encode( self:prepareParams(handsetInfo, userInfo) )
  local params = {
    "p=" .. ___tobase64(p),
    "s=" .. ___md5(p),
    "a=" .. _aa
  }

  local data = table.concat(params, "&")
  print('data len: ', #data)

  local function onReadyStateChange()
    print(string.format('xhr.readyState: %d, xhr.status: %d', xhr.readyState, xhr.status))
    if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 300) then
        local statusString = "Http Status Code:"..xhr.statusText
        print(statusString)
        print("[EntryService:signInWithToken] response: ", xhr.response)

        local respData = cjson.decode(xhr.response)
        local a, b, c = ___appxxx(ddz.GlobalSettings.handsetInfo.mac .. respData.sk, respData.sk)
        _v = b

        utils.invokeCallback(callback, true, respData)
    else
        print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        utils.invokeCallback(callback, false, xhr.readyState, xhr.status)
    end
  end

  xhr:registerScriptHandler(onReadyStateChange)
  xhr:send(data)

  print("waiting...")
end

function EntryService:signInWithPassword(url, handsetInfo, userInfo)
end

function EntryService:signUp(url, handsetInfo)
end

return EntryService
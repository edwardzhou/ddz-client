local AccountInfo = require('AccountInfo')
local cjson = require('cjson.safe')
local EntryService = class('EntryService')
local utils = require('utils.utils')
local showConnectingBox = require('UICommon.ConnectingBox').showConnectingBox
local hideConnectingBox = require('UICommon.ConnectingBox').hideConnectingBox
local scheduler = require('framework.scheduler')

function EntryService:ctor(params)
  self.cancelled = false
  self.showProgress = true
  if params and params.showProgress ~= nil then
    self.showProgress = params.showProgress
  end
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
    params.password = currentUser.password
  end

  return params
end

function EntryService:sendRequest(url, handsetInfo, userInfo, callback, onFailure)
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
    print(string.format('[EntryService:sendRequest] xhr.readyState: %d, xhr.status: %d', xhr.readyState, xhr.status))
    if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 300) then
        local statusString = "Http Status Code:" .. xhr.statusText
        print(statusString)
        print("[EntryService:sendRequest] response: ", xhr.response)

        local respData = cjson.decode(xhr.response)
        local succ = respData.errCode == 0
        if succ then
          local a, b, c = ___appxxx(ddz.GlobalSettings.handsetInfo.mac .. respData.sk, respData.sk)
          _v = b
          if respData.updateManifestUrl then
            _updateManifestUrl = respData.updateManifestUrl or ""
            _updateVersionUrl = respData.updateVersionUrl or ""
            _updatePackageUrl = respData.updatePackageUrl or ""
            _updateManifestUrl = string.gsub(_updateManifestUrl, ':affiliate:', __appAffiliate)
            _updateVersionUrl = string.gsub(_updateVersionUrl, ':affiliate:', __appAffiliate)
            _updatePackageUrl = string.gsub(_updatePackageUrl, ':affiliate:', __appAffiliate)
            if #_updatePackageUrl > 0 and string.sub(_updatePackageUrl, -1) ~= '/' then
              _updatePackageUrl = _updatePackageUrl .. '/'
            end
          end
        end

        utils.invokeCallback(callback, succ, respData)
    else
        print("[EntryService:sendRequest] xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        utils.invokeCallback(onFailure, xhr.readyState, xhr.status)
    end
  end

  xhr:registerScriptHandler(onReadyStateChange)
  xhr:send(data)
end

function EntryService:requestSignInUp(url, handsetInfo, userInfo, retryCount, callback, onFailure)
  local this = self
  local currentRetry = 1

  local director = cc.Director:getInstance()
  local doRequest, onReqFailure, onReqCb

  onReqFailure = function()
    if this.cancelled then
      return
    end
    currentRetry = currentRetry + 1
    if currentRetry <= retryCount then
      print('[EntryService:signInWithToken] retry to send request');
      setTimeout(doRequest, {}, 2)
      --doRequest()
    else
      local box = director:getRunningScene().connectingBox
      if box then
        box:setFailure()
      end
    end
  end

  onReqCb = function (succ, respData)
    hideConnectingBox(director:getRunningScene(), false)
    utils.invokeCallback(callback, succ, respData)
  end

  onRetry = function()
    currentRetry = 1
    hideConnectingBox(director:getRunningScene(), false)
    doRequest()
  end

  doRequest = function()
    local params = {
      showLoading = true,
      grayBackground = false,
      closeOnTouch = false,
      showingTime = 0,
      closeOnBack = false,
      onRetry = onRetry,
      msg = '正在努力连接中...'
    }

    if currentRetry < 2 then
      params.msg = '正在努力连接中... #' .. currentRetry
    else
      params.msg = '网络不给力, 加倍努力连接中... #' .. currentRetry
    end

    if not this.cancelled then
      print('director:getRunningScene() => ', director:getRunningScene());
      if this.showProgress then
        local box = showConnectingBox(director:getRunningScene(), params)
        box:setCurrentRetries(currentRetry)
      end

      this:sendRequest(url, handsetInfo, userInfo, onReqCb, onReqFailure)
    end
  end

  doRequest()
  
end

function EntryService:cancel()
  self.cancelled = true
  local director = cc.Director:getInstance()
  local scene = director.getRunningScene()
  if scene.connectingBox then
    scene.connectingBox:close()
  end
end

return EntryService
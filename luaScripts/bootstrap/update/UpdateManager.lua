--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

local UpdateManager = class('UpdateManager')
local utils = require('utils.utils')

function UpdateManager:ctor(...)
end

function UpdateManager:startCheckUpdate(callback)
  local this = self
  print('storagePath: ', cc.FileUtils:getInstance():getWritablePath() )
  local am = cc.AssetsManagerEx:create('project.manifest', cc.FileUtils:getInstance():getWritablePath())
  am:retain()
  self.am = am
  if _updateManifestUrl then
    print('set am remote urls:', _updateManifestUrl, _updateVersionUrl, _updatePackageUrl)
    am:setRemoteUrls(_updateManifestUrl, _updateVersionUrl, _updatePackageUrl)
  end

  if not am:getLocalManifest():isLoaded() then
      print("Fail to update assets, step skipped.")
  else
      local function onUpdateEvent(event)
          local eventCode = event:getEventCode()
          if eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST then
              print("No local manifest file found, skip assets update.")
          elseif  eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION then
              local assetId = event:getAssetId()
              local percent = event:getPercent()
              local strInfo = ""

              if assetId == cc.AssetsManagerExStatic.VERSION_ID then
                  strInfo = string.format("Version file: %d%%", percent)
              elseif assetId == cc.AssetsManagerExStatic.MANIFEST_ID then
                  strInfo = string.format("Manifest file: %d%%", percent)
              else
                  strInfo = string.format("%d%%", percent)
              end
              print('UPDATE_PROGRESSION: ', strInfo)
          elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST or 
                 eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST then
              print("Fail to download manifest file, update skipped.")
          elseif eventCode == cc.EventAssetsManagerEx.EventCode.ASSET_UPDATED then 
                  print("ASSET_UPDATED: ", event:getAssetId())
          elseif eventCode == cc.EventAssetsManagerEx.EventCode.NEW_VERSION_FOUND then 
                  print("NEW_VERSION_FOUND.")
          elseif eventCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE then 
                  print("ALREADY_UP_TO_DATE.")
          elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then
                  print("Update finished.")
          elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING then
                  print("Asset ", event:getAssetId(), ", ", event:getMessage())
          end

          utils.invokeCallback(callback, event)
      end
      local listener = cc.EventListenerAssetsManagerEx:create(am,onUpdateEvent)
      cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
      
      am:update()
  end
end

function UpdateManager:close()
  if self.am ~= nil then
    self.am:release()
    self.am = nil
  end
end

return UpdateManager
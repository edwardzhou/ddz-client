--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

local GameRoomEnterPlugin = {}
local utils = require('utils.utils')

function GameRoomEnterPlugin.bind(theClass)

  local doTryEnterRoom = function(this, roomId, callback)
    this.gameConnection:request('ddz.entryHandler.tryEnterRoom', {room_id = roomId}, function(data) 
      dump(data, "[GameRoomEnterPlugin: ddz.entryHandler.tryEnterRoom] data =>")
      --utils.invokeCallback(this.onTryEnterRoomReponse, this, data)
      if enterTimeoutActionId then
        this:stopAction(enterTimeoutActionId)
        enterTimeoutActionId = nil
        if enteringRoomToast:isVisible() then
          enteringRoomToast:close(false)
        end
      end

      if data.retCode == ddz.ErrorCode.SUCCESS then
        -- utils.invokeCallback(this.onTryEnterRoomSuccess, this, data)
        -- this.room = data.room;
        -- local createGameScene = require('gaming.GameScene2')
        -- local gameScene = createGameScene()
        -- cc.Director:getInstance():pushScene(gameScene)
      elseif data.retCode == ddz.ErrorCode.COINS_NOT_ENOUGH then
        local params = {
          msg = data.recruitMsg
          , grayBackground = true
          , closeOnClickOutside = false
          , buttonType = 'ok|close'
          , closeAsCancel = true
          , onCancel = onCancelBuyPackage
          , onOk = function() onBuyPackage(data.room, data.pkg) end
        }
        showMessageBox(this, params)
        -- utils.invokeCallback(this.onTryEnterRoomRecharge, this, data, callback)
      else
        -- 提示用户金币超过准入上限，请进入更高级别的房间
        -- local params = {
        --   msg = data.message
        --   , grayBackground = true
        --   , closeOnClickOutside = false
        --   , buttonType = 'ok'
        -- }

        -- showMessageBox(this, params)
        utils.invokeCallback(this.onTryEnterRoomFailed, this, data)
      end
    end)
  end

  function theClass:tryEnterRoom(roomId, tableId, callback)
    local this = self

    this.gameConnection:request('ddz.entryHandler.tryEnterRoom', {room_id = roomId, table_id = tableId}, function(data) 
      dump(data, "[ddz.entryHandler.tryEnterRoom] data =>")
      if enterTimeoutActionId then
        this:stopAction(enterTimeoutActionId)
        enterTimeoutActionId = nil
        if enteringRoomToast:isVisible() then
          enteringRoomToast:close(false)
        end
      end
    end)
  end

  function theClass:enterRoom(roomId, tableId, callback)
    local this = self

    this.gameService:enterRoom(roomId, tableId, function(data) 
        this.room = data.room
        local scene = cc.Director:getInstance():getRunningScene()
        utils.invokeCallback(scene.onRoomEntered, scene, this.room)
        utils.invokeCallback(scene.updateRoomInfo, scene, this.room)
      end)
  end
end


return GameRoomEnterPlugin
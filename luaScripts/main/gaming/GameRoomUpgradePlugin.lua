local GameRoomUpgradePlugin = {}
local showMessageBox = require('UICommon.MsgBox').showMessageBox

function GameRoomUpgradePlugin.bind(theClass)

  local function enterRoom(this, room)
    this.gameService:enterRoom(room.roomId, room.tableId, function(respData) 
        ddz.selectedRoom = respData.room
        this.ButtonRoomList:setTitleText(respData.room.roomName)
        this.ButtonRoomList:runAction(cc.RotateBy:create(1, 360))
        this.LabelBetBase:setString(respData.room.ante)
      end)
  end

  local function doBuyPkg(this, room, pkg)
    dump(pkg, 'try to buy package')
    --local this = self
    local params = {
      pkgId = pkg.packageId
    }
    this.room = room
    this.gameConnection:request('ddz.hallHandler.buyItem', params, function(data)
        dump(data, '[GameRoomUpgradePlugin:doBuyPkg] ddz.hallHandler.buyItem =>', 20)
        --dump(data.pkg.packageData.items, '[GameRoomUpgradePlugin:doBuyPkg] packageData.items =>')
        local purchaseOrder = data.pkg
        local pkgData = purchaseOrder.packageData
        local tdOrderId = purchaseOrder.userId .. '-' .. purchaseOrder.orderId
        local pkgId = pkgData.packageId .. '-' .. pkgData.packageName
        local pkgCoins = pkgData.packageCoins
        local paidPrice = purchaseOrder.paidPrice
        local paymentMethodId = 'unknown'
        if purchaseOrder.payment then 
          paymentMethodId = purchaseOrder.payment.paymentMethod.methodId
        end

        this.waitingOrderId = purchaseOrder.orderId

        print('[GameRoomUpgradePlugin:doBuyPkg] tdOrderId: ', tdOrderId, ', pkgId: ', pkgId)
        TDGAVirtualCurrency:onChargeRequest(tdOrderId, pkgId, paidPrice, 'CNY', pkgCoins, paymentMethodId)
        return true
      end)
  end

  local function roomUpgrade(this, data)
    print('[GameRoomUpgradePlugin.bind:roomUpgrade]')
    local onClose = function()
      enterRoom(this, data.room)
    end
    local msgParams = {
      msg = data.msg,
      buttonType = 'ok',
      width = 430,
      height = 250,
      onOk = onClose,
      okCancel = onClose
    }

    showMessageBox(this, msgParams)

  end

  local function roomDowngrade(this, data)
    print('[GameRoomUpgradePlugin.bind:roomDowngrade]')
    local pkg = data.curRoomDdzPkg
    local msgParams = {
      msg = data.msg,
      buttonType = 'ok|close',
      width = 430,
      height = 250,
      closeAsCancel = true,
      onCancel = function()
          if data.needRecharge ~= nil and data.needRecharge > 0 then
            this:onBackClicked()
            return
          end

          enterRoom(this, data.room)
        end,
      onOk = function()
          doBuyPkg(this, data.curRoom, pkg)
        end
    }

    showMessageBox(this, msgParams)
  end

  local function roomNeedRecharge(this, data)
    print('[GameRoomUpgradePlugin.bind:roomNeedRecharge]')
    local pkg = data.curRoomDdzPkg
    local msgParams = {
      msg = data.msg,
      buttonType = 'ok|close',
      width = 430,
      height = 250,
      closeAsCancel = true,
      onCancel = function()
          this:onBackClicked()
          return
        end,
      onOk = function()
          doBuyPkg(this, data.room, pkg)
        end
    }

    showMessageBox(this, msgParams)
  end

  function theClass:onRoomUpgrade(data)
    local this = self
    if data.roomUpgrade > 0 then
      roomUpgrade(this, data)
    elseif data.roomUpgrade < 0 then
      roomDowngrade(this, data)
    else
      roomNeedRecharge(this, data)
    end

  end

  function theClass:onChargeCallback(msg)
    local this = self
    dump(msg, 'GameRoomUpgradePlugin:onChargeCallback', 5)
    if this.waitingOrderId == msg.purchaseOrderId then
      enterRoom(this, this.room)
    end
  end
end

return GameRoomUpgradePlugin
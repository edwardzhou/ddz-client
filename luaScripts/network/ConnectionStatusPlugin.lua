local ConnectionStatusPlugin = {}
local showToastBox = require('UICommon.ToastBox').showToastBox
local hideToastBox = require('UICommon.ToastBox').hideToastBox
local showConnectingBox = require('UICommon.ConnectingBox').showConnectingBox
local hideConnectingBox = require('UICommon.ConnectingBox').hideConnectingBox
local showMessageBox = require('UICommon.MessageBox').showMessageBox

function ConnectionStatusPlugin.bind(theClass)
  local _priorOnEnter, _priorOnExit
  _priorOnEnter = theClass.on_enter
  _priorOnExit = theClass.on_exit

  function theClass:hookConnectionEvents()
    local this = self
    this.hidenRetries = this.hidenRetries or 4
    print('[hookConnectionEvents] start to hook')
    if not this._onConnectingEvent then
      this._onConnectingEvent = function(gameConn, event)
        dump(event, '[hookConnectionEvents] this._onConnectingEvent')
        print('[hookConnectionEvents] this.hidenRetries => ', this.hidenRetries, 
          ', gameConn.isStartConnecting => ', gameConn.isStartConnecting)
        if not gameConn.isStartConnecting and event.retries <= this.hidenRetries then
          return
        end

        local onRetry = function()
          hideConnectingBox(this, false)
          this:runAction(
            cc.Sequence:create(
              cc.DelayTime:create(0.1),
              cc.CallFunc:create(function() 
                this.gameConnection:reconnect()
              end)
            )
          )
        end

        --print('[hookConnectionEvents] this._onConnectingEvent')
        local params = {
          showLoading = true,
          grayBackground = false,
          closeOnTouch = false,
          showingTime = 0,
          closeOnBack = event.retries > 3,
          onRetry = onRetry,
          msg = '正在努力连接中...'
        }

        if event.retries < 4 then
          params.msg = '正在努力连接中... #' .. event.retries
        else
          params.msg = '网络不给力, 加倍努力连接中... #' .. event.retries
        end

        --if event.retries <= 2 then
          this.connectingBox = showConnectingBox(this, params)
          this.connectingBox:setCurrentRetries(event.retries)
        --end
        
      end
    end

    if not this._onConnectedEvent then
      this._onConnectedEvent = function()
        print('[hookConnectionEvents] this._onConnectedEvent')
        -- hideToastBox(this)
        hideConnectingBox(this)
      end
    end

    if not this._onConnectionFailureEvent then
      this._onConnectionFailureEvent = function()
        print('[hookConnectionEvents] this._onConnectionFailureEvent')
        --hideToastBox(this, false)
        local params = {
          msg = '喔~ 网络不给力, 臣妾做不到啊! \n请检查网络设置。'
        }
        this.connectingBox:setFailure()
        --showMessageBox(this, params)

      end
    end

    print('this.gameConnection => ', this.gameConnection, ' this.connectionEventHooked => ', this.connectionEventHooked)

    if this.gameConnection and not this.connectionEventHooked then
      this.connectionEventHooked = true
      if not this.firstTime then
        this.gameConnection:on('connecting', this._onConnectingEvent)
        this.gameConnection:on('connected', this._onConnectedEvent)
        this.gameConnection:on('connection_failure', this._onConnectionFailureEvent)
        --this.firstTime = true
      end

    else
      print('[hookConnectionEvents] WARNING: no this.gameConnection instance')
    end

  end

  function theClass:unhookConnectionEvents()
    local this = self
    print('[unhookConnectionEvents] start to unhook')
    if this.gameConnection and this.connectionEventHooked then
      this.gameConnection:off('connecting', this._onConnectingEvent)
      this.gameConnection:off('connected', this._onConnectedEvent)
      this.gameConnection:off('connection_failure', this._onConnectionFailureEvent)
      this.connectionEventHooked = false
    end
  end


  function theClass:on_enter()
    print('[ConnectionStatusPlugin:on_enter] ...')
    local this = self
    if _priorOnEnter then
      _priorOnEnter(this)
    end
    this:hookConnectionEvents()
    hideConnectingBox(this, false)
  end

  function theClass:on_exit()
    local this = self
    if _priorOnExit then
      _priorOnExit(this)
    end
    this:unhookConnectionEvents()    
  end

end

return ConnectionStatusPlugin
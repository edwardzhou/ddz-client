local ConnectionStatusPlugin = {}
local showToastBox = require('UICommon.ToastBox').showToastBox
local hideToastBox = require('UICommon.ToastBox').hideToastBox
local showMessageBox = require('UICommon.MessageBox').showMessageBox

function ConnectionStatusPlugin.bind(theClass)
  local _priorOnEnter, _priorOnExit
  _priorOnEnter = theClass.on_enter
  _priorOnExit = theClass.on_exit

  function theClass:hookConnectionEvents()
    local this = self
    this.hidenRetries = this.hidenRetries or 3
    print('[hookConnectionEvents] start to hook')
    if not this._onConnectingEvent then
      this._onConnectingEvent = function(gameConn, event)
        dump(event, '[hookConnectionEvents] this._onConnectingEvent')
        print('[hookConnectionEvents] this.hidenRetries => ', this.hidenRetries, 
          ', gameConn.isStartConnecting => ', gameConn.isStartConnecting)
        if event.retries <= this.hidenRetries then
          return
        end

        --print('[hookConnectionEvents] this._onConnectingEvent')
        local params = {
          showLoading = true,
          grayBackground = false,
          closeOnTouch = false,
          showingTime = 0,
          closeOnBack = event.retries > 3,
          msg = '正在努力连接中...'
        }

        if event.retries < 4 then
          params.msg = '正在努力连接中... #' .. event.retries
        else
          params.msg = '网络不给力, 加倍努力连接中... #' .. event.retries
        end

        showToastBox(this, params)
      end
    end

    if not this._onConnectedEvent then
      this._onConnectedEvent = function()
        print('[hookConnectionEvents] this._onConnectedEvent')
        hideToastBox(this)
      end
    end

    if not this._onConnectionFailureEvent then
      this._onConnectionFailureEvent = function()
        print('[hookConnectionEvents] this._onConnectionFailureEvent')
        hideToastBox(this, false)
        local params = {
          msg = '喔~ 网络不给力, 臣妾做不到啊! \n请检查网络设置。'
        }
        showMessageBox(this, params)
      end
    end

    print('this.gameConnection => ', this.gameConnection, ' this.connectionEventHooked => ', this.connectionEventHooked)

    if this.gameConnection and not this.connectionEventHooked then
      this.connectionEventHooked = true
      this.gameConnection:on('connecting', this._onConnectingEvent)
      this.gameConnection:on('connected', this._onConnectedEvent)
      this.gameConnection:on('connection_failure', this._onConnectionFailureEvent)
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
    local this = self
    if _priorOnEnter then
      _priorOnEnter(this)
    end
    this:hookConnectionEvents()
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
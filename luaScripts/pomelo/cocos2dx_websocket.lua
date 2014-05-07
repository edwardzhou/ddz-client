local scheduler = require('framework.scheduler')
local Protocol = require('pomelo.protocol.protocol')

Cocos2dxWebsocket = class('Cocos2dxWebsocket')

local WS = Cocos2dxWebsocket

function WS:ctor(url, wsprotocol)
	local _this = self
  self.websocket = cc.WebSocket:create(url)
  self.close = function() _this:do_close() end
  --dump(self.websocket, 'Cocos2dxWebsocket.websocket')
  
  --print(' WebSocketScriptHandler ', kWebSocketScriptHandlerOpen, kWebSocketScriptHandlerClose, kWebSocketScriptHandlerMessage )
  
  self.websocket:registerScriptHandler(function(event)
  		--dump(event, 'websocket.open')
      if type(_this.onopen) == 'function' then
          _this.onopen(event)
      end
    end, kWebSocketScriptHandlerOpen)
  
  self.websocket:registerScriptHandler(function(event)
  		--dump(event, 'websocket.close')
      if type(_this.onclose) == 'function' then
        _this.onclose(event)
      end
    end, kWebSocketScriptHandlerClose)
  
  self.websocket:registerScriptHandler(function(event)
  		--dump(event, 'websocket.error')
      if type(_this.onerror) == 'function' then
        _this.onerror(event)
      end
    end, kWebSocketScriptHandlerError)
  
  self.websocket:registerScriptHandler(function(message)
		--print('websocket.message => ', table.concat(message, ','))
    if type(message) == 'string' then
      -- message = {string.byte(message, 1, len)}
      message = Protocol.strencode(message)
    end
		--dump(message, 'websocket.message')
    dump_bin(Protocol.strdecode(message), 'websocket received: ')
    if type(_this.onmessage) == 'function' then
      _this.onmessage({data=message})
    end
  end, kWebSocketScriptHandlerMessage)

	--self.websocket:connect(url, wsprotocol)		
end

function WS:send(data)
--	if type(data) ~= 'table' then
--		--data = {string.byte(data, 1, -1)}
--		data = Protocol.strencode(data)
--	end
	if type(data) == 'table' then
		data = Protocol.strdecode(data)
	end

  dump_bin(data, '[Cocos2dxWebsocket] sent: ')
	self.websocket:sendString(data)
end

function WS:do_close()
  print('Cocos2dxWebsocket close...')
  self.websocket:close()
end

return Cocos2dxWebsocket
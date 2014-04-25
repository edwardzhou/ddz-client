local Protocol = require('pomelo.protocol.protocol')

Cocos2dxWebsocket = class('Cocos2dxWebsocket')

local WS = Cocos2dxWebsocket

function WS:ctor(url, wsprotocol)
	local _this = self
  self.websocket = cc.WebSocket:create(url)
  self.close = function() self:do_close() end
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
  		--dump(message, 'websocket.message')
      if type(_this.onmessage) == 'function' then
        if type(message) == 'string' then
          -- message = {string.byte(message, 1, len)}
          message = Protocol.strdecode(message)
        end
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
	self.websocket:sendString(data)
end

function WS:do_close()
  print('DefaultLuaWebSocket close...')
  self.websocket:close()
end

return Cocos2dxWebsocket
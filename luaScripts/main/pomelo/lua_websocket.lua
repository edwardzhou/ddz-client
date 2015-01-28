require('framework.functions')
local Protocol = require('pomelo.protocol.protocol')
DefaultLuaWebSocket = class('DefaultLuaWebSocket')

local WS = DefaultLuaWebSocket
local BINARY = require('websocket').BINARY

function WS:ctor(url, wsprotocol)
	local _this = self
  self.websocket = require('websocket').client.ev()
  self.close = function() self:do_close() end
  self.websocket:on_open(function(socket)
  		if type(_this.onopen) == 'function' then
  			_this.onopen()
  		end
    end)
  self.websocket:on_close(function(socket, was_clean, code, reason)
  		if type(_this.onclose) == 'function' then
  			_this.onclose(was_clean, code, reason)
  		end  			
  	end)
  self.websocket:on_error(function(socket, err)
  		if type(_this.onerror) == 'function' then
  			_this.onerror(err)
  		end 
  	end)
	self.websocket:on_message(function(socket, message, op_code)
			if type(_this.onmessage) == 'function' then
        if op_code == BINARY then
          message = Protocol.strencode(message)
        end
				_this.onmessage({data = message, op_code = op_code})
			end
		end)

	self.websocket:connect(url, wsprotocol)		
end

function WS:send(data)
	if type(data) == 'table' then
		data = Protocol.strdecode(data)
	end
	self.websocket:send(data, BINARY)
end

function WS:do_close()
  print('DefaultLuaWebSocket close...')
  self.websocket.close()
end

return DefaultLuaWebSocket
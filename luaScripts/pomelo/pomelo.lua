local Protocol = require('pomelo.protocol.protocol')
local ProtobufFactory = require('pomelo.protobuf.protobuf')
local Emitter = require('pomelo.emitter')

local cjson = require('cjson.safe')

local JS_WS_CLIENT_TYPE = 'lua-websocket'
local JS_WS_CLIENT_VERSION = '0.0.1'

local Package = Protocol.Package
local Message = Protocol.Message
local EventEmitter = Emitter

local RES_OK = 200
local RES_FAIL = 500
local RES_OLD_CLIENT = 501

Pomelo = class('Pomelo', Emitter)

if true or setTimeout == nil then
	setTimeout = function()
		print('WARNING: setTimeout is not defined.')
	end
end

if true or clearTimeout == nil then
	clearTimeout = function()
		print('WARNING: clearTimeout is not defined.')
	end
end

function Pomelo:ctor(WebSocketClass)
  self.super.ctor(self)
  
  self.Protobuf = ProtobufFactory.getProtobuf()
  
	self.socket = nil
  if WebSocketClass ~= nil then    
    self.WebSocketClass = WebSocketClass 
  else
    self.WebSocketClass = require('pomelo.lua_websocket')
  end
	print('[Pomelo:ctor] self=> ', self, 'self.socket =>', self.socket)
	self.reqId = 0
	self.callbacks = {}
	self.handlers = {}
	self.routeMap = {}
	
	self.data = {
		dict = {},
		abbrs = {},
		protos = {
			server = {},
			client = {}
		}
	}
	
	self.heartbeatInterval = 3
	self.heartbeatTimeout = 30
	self.nextHeartbeatTimeout = 0
	self.gapThreshold = 30
	self.heartbeatId = nil
	self.heartbeatTimeoutId = nil
	
	self.handshakeCallback = nil
	self.handshakeBuffer = {
		sys = {
			type = JS_WS_CLIENT_TYPE,
			version = JS_WS_CLIENT_VERSION
		},
		user = {
		}
	}
	
	self.initCallback = nil
	
	self.handlers[Package.TYPE_HANDSHAKE] = self.handshake
	self.handlers[Package.TYPE_HEARTBEAT] = self.heartbeat
	self.handlers[Package.TYPE_DATA] = self.onData
	self.handlers[Package.TYPE_KICK] = self.onKick
	
end

function Pomelo:init(params, cb)
	self.initCallback = cb
	local host = params.host
	local port = params.port
	
	local url = 'ws://' .. host
	if port then
		url = url .. ':' .. port
	end
  
	self.handshakeBuffer.user = params.user
	self.handshakeCallback = params.hanshakeCallback
	self:initWebSocket(url, cb)
end

function Pomelo:initWebSocket(url, cb)
  if self.socket ~= nil then
    print('already has a socket opened, disconnect first')
    self:disconnect()
  end
  
	print('connect to ' .. url)
	local _this = self
	local onopen = function(event)
		local obj = Package.encode(Package.TYPE_HANDSHAKE, Protocol.strencode(cjson.encode(_this.handshakeBuffer)))
		_this:send(obj) 
	end
	
	local onmessage = function(event)
		_this:processPackage(Package.decode(event.data), cb)
		if _this.heartbeatTimeout then
			_this.nextHeartbeatTimeout = os.time() + _this.heartbeatTimeout
		end
	end
	
	local onerror = function(event)
		_this:emit('io-error', event)
		print('[error] socket error: ', event)
	end
	
	local onclose = function(event)
    print('[Pomelo] local onclose')
		_this:emit('close', event)
	end
	
	self.socket = self.WebSocketClass.new(url)
	self.binaryType = 'arraybuffer'
	self.socket.onopen = onopen
	self.socket.onmessage = onmessage
	self.socket.onerror = onerror
	self.socket.onclose = onclose
end

function Pomelo:disconnect()
	print('[Pomelo:disconnect]')
	if self.socket then
		if self.socket.disconnect then
			self.socket:disconnect()
		end
		if self.socket.close then
			self.socket:close()
		end
		
		self.socket.onmessage = nil
		self.socket = nil
	end
	
	if self.heartbeatId then
		clearTimeout(self.heartbeatId)
		self.heartbeatId = nil
	end
	if self.heartbeatTimeoutId then
		clearTimeout(heartbeatTimeoutId)
		slef.heartbeatTimeoutId = nil
	end	
end

function Pomelo:request(route, msg, cb)
	if type(msg) == 'function' and cb == nil then
		cb = msg
		msg = {}
	else
		msg = msg or {}
	end
	
	route = route or msg.route
	if route == nil then
		do return end
	end
	
	self.reqId = self.reqId + 1
	self:sendMessage(self.reqId, route, msg)
	
	self.callbacks[self.reqId] = cb
	self.routeMap[self.reqId] = route
end

function Pomelo:notify(route, msg)
	msg = msg or {}
	self:sendMessage(0, route, msg)
end

function Pomelo:sendMessage(reqId, route, msg)
	local type = Message.TYPE_NOTIFY
	if reqId > 0 then
		type = Message.TYPE_REQUEST
	end
	
	-- compress message by protobuf
	local protos = {}
	if self.data.protos then
		protos = self.data.protos.client
	end
	if protos[route] then
		dump(Protocol, '[Polemo:sendMessage] Protocol')
		dump(msg, '[Polemo:sendMessage] msg before')
		msg = self.Protobuf.encode(route, msg)
		dump(msg, '[Pomelo:sendMessage] msg after encoded')
	else
--		print('msg => ', cjson.encode(msg))
		msg = Protocol.strencode(cjson.encode(msg))
--		dump(msg, 'msg')
	end
	
	local compressRoute = 0
	if self.dict and self.dict[route] then
		route = self.dict[route]
		compressRoute = 1
	end
	
	msg = Message.encode(reqId, type, compressRoute, route, msg)
	-- dump(msg, '[Pomelo:sendMessage] msg after Message.encoded')
	local packet = Package.encode(Package.TYPE_DATA, msg)
	self:send(packet)	
end

function Pomelo:send(packet)
--	print("self, ", self, 'self.socket', self.socket, packet)
--	dump(self.socket, 'self.socket')
	self.socket:send(packet)
end

function Pomelo:heartbeat(data)
--	if not self.heartbeatInterval then
--		do return end
--	end
	--dump(data, '[Pomelo:heartbeat]')
	local obj = Package.encode(Package.TYPE_HEARTBEAT)
  self:send(obj)
	if self.heartbeatTimeoutId then
		clearTimeOut(self.heartbeatTimeoutId)
		self.heartbeatTimeoutId = nil
	end
	
	if self.heartbeatId then
		-- already in a heartbeat interval
		do return end
	end
	
	self.heartbeatId = setTimeout(function()
		self.heartbeatId = nil
		self:send(obj)
		
		self.nextHeartbeatTimeout = os.time() + self.heartbeatTimeout
		self.heartbeatTimeoutId = setTimeout(function() 
					self:heartbeatTimeoutCb() 
				end, self.heartbeatTimeout)
	end, self.heartbeatInterval)
end

function Pomelo:heartbeatTimeoutCb()
	local gap = self.nextHeartbeatTimeout - os.time()
	if gap > self.gapThreshold then
		self.heartbeatTimeoutId = setTimeout(function() self:heartbeatTimeoutCb() end, gap)
	else
		self:emit('heartbeat timeout')
		self:disconnect()
	end
end

function Pomelo:handshake(data)
	data = cjson.decode(Protocol.strdecode(data))
	if data.code == RES_OLD_CLIENT then
		self:emit('error', 'client version not fullfil')
		do return end
	end
	
	if data.code ~= RES_OK then
		self:emit('error', 'handshake fail')
		do return end
	end
	
	self:handshakeInit(data)
	
	local obj = Package.encode(Package.TYPE_HANDSHAKE_ACK)
	self:send(obj)
	if self.initCallback then
		self.initCallback(self)
		self.initCallback = nil
	end
end

function Pomelo:onData(data)
	-- protobuf decode
	local msg = Message.decode(data)
	
	if msg.id > 0 then
		msg.route = self.routeMap[msg.id]
		self.routeMap[msg.id] = nil
		if not msg.route then
			do return end
		end
	end
	
	msg.body = self:deCompose(msg)
	
	self:processMessage(msg)
end

function Pomelo:onKick(data)
	self:emit('onKick')
end

function Pomelo:processPackage(msg)
	self.handlers[msg.type](self, msg.body)
end

function Pomelo:processMessage(msg)
	if msg.id == nil or msg.id < 1 then
		-- server push message
		self:emit(msg.route, msg.body)
		do return end
	end
	
	-- if have a id then find the callback function with the request
	local cb = self.callbacks[msg.id]
	
	self.callbacks[msg.id] = nil
	if type(cb) ~= 'function' then
		do return end
	end
	
	cb(msg.body) 
end

function Pomelo:deCompose(msg)
	local protos = {}
	if self.data and self.data.protos then
		protos = self.data.protos.server
	end
	local abbrs = self.data.abbrs
	local route = msg.route
	
	-- Decompose route from dict
	if msg.compressRoute > 0 then
		if not abbrs[route] then
			do return {} end
		end
		
		msg.route = abbrs[route]
		route = msg.route	
	end
	
	if protos[route] then
		do return self.Protobuf.decode(route, msg.body) end
	else
		do return cjson.decode(Protocol.strdecode(msg.body)) end
	end
	
	return msg
end

function Pomelo:handshakeInit(data)
	dump(data, '[Pomelo:handshakeInit] data ==>')
	if data.sys and data.sys.heartbeat then
		self.heartbeatInterval = data.sys.heartbeat
	end
	
	self:initData(data)
	
	if type(self.handshakeCallback) == 'function' then
		self.handshakeCallback(data.user)
	end
end

function Pomelo:initData(data)
	if not data or not data.sys then
		do return end
	end
	
	self.data = self.data or {}
	local dict = data.sys.dict
	local protos = data.sys.protos
	
	-- Init compress dict
	if dict then
		self.data.dict = dict
		self.data.abbrs = {}
		for _k, _v in pairs(dict) do
			self.data.abbrs[_v] = _k
		end
	end
	
	-- Init protobuf protos
	if protos then
		self.data.protos = {
			server = protos.server or {},
			client = protos.client or {}
		}
		
		if self.Protobuf then
			self.Protobuf.init({
				encoderProtos = protos.client, 
				decoderProtos = protos.server
			})
		end
	end
end

return Pomelo
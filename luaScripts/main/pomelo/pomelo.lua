local Protocol = require('pomelo.protocol.protocol')
local ProtobufFactory = require('pomelo.protobuf.protobuf')
local Emitter = require('pomelo.emitter')
local socket = require('socket')

local cjson = require('cjson.safe')

local JS_WS_CLIENT_TYPE = 'lua-websocket'
local JS_WS_CLIENT_VERSION = '0.0.1'

local Package = Protocol.Package
local Message = Protocol.Message
local EventEmitter = Emitter

local RES_OK = 200
local RES_FAIL = 500
local RES_OLD_CLIENT = 501

local function getTime()
	return socket.gettime() 
end

Pomelo = class('Pomelo', Emitter)
Pomelo.debug = {
	pomelo = true,
	decoder = false,
	encoder = false,
}

if setTimeout == nil then
	setTimeout = function()
		print('WARNING: setTimeout is not defined.')
	end
end

if clearTimeout == nil then
	clearTimeout = function()
		print('WARNING: clearTimeout is not defined.')
	end
end

function Pomelo:ctor(WebSocketClass)
  self.super.ctor(self)

  self.connected = false
  self.protoVersion = 0
  self.dictVersion = 0

  self.totalBytesReceived = 0
  self.totalBytesSent = 0
  self.bytesReceived = 0
  self.bytesSent = 0
  
  self.Protobuf = ProtobufFactory.getProtobuf()
  
	self.socket = nil
  if WebSocketClass ~= nil then    
    self.WebSocketClass = WebSocketClass 
  else
    self.WebSocketClass = require('pomelo.lua_websocket')
  end
  if Pomelo.debug.pomelo then
		print('[Pomelo:ctor] self=> ', self, 'self.socket =>', self.socket)
	end
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

	local _protos = ddz.readFromFile('protos.json')
	if _protos ~= nil and #_protos > 0 then
		self.data.protos = cjson.decode(_protos)
		self.protoVersion = self.data.protos.version
		if self.Protobuf then
			self.Protobuf.init({
				encoderProtos = self.data.protos.client, 
				decoderProtos = self.data.protos.server,
				protoVersion = self.data.protos.version
			})
		end

	end

	local _dictInfoStr = ddz.readFromFile('dicts.json')
	if _dictInfoStr ~= nil and #_dictInfoStr > 0 then
		local _dictInfo = cjson.decode(_dictInfoStr)
		self.data.dict = _dictInfo.dict
		self.dictVersion = _dictInfo.dictVersion

		self.data.abbrs = {}
		for _k, _v in pairs(self.data.dict) do
			self.data.abbrs[_v] = _k
		end

	end

	
	self.heartbeatInterval = 0
	self.heartbeatTimeout = 0
	self.nextHeartbeatTimeout = 0
	self.gapThreshold = 0.1
	self.heartbeatId = nil
	self.heartbeatTimeoutId = nil
	
	self.handshakeCallback = nil

	self.initCallback = nil
	
	self.handlers[Package.TYPE_HANDSHAKE] = self.handshake
	self.handlers[Package.TYPE_HEARTBEAT] = self.heartbeat
	self.handlers[Package.TYPE_DATA] = self.onData
	self.handlers[Package.TYPE_KICK] = self.onKick
	
end

function Pomelo:init(params, cb)
	if Pomelo.debug.pomelo then
		dump(params, "[Pomelo:init] params =>")
	end

	self.handshakeBuffer = {
		sys = {
			type = JS_WS_CLIENT_TYPE,
			version = JS_WS_CLIENT_VERSION,
			protoVersion = self.protoVersion,
			dictVersion = self.dictVersion,
		},
		user = {
		}
	}

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
  
	local _this = self
	local onopen = function( event)
		_this.selfDisconnected = false
	
		if _this.connectTimeout then
			clearTimeout(_this.connectTimeout)
			_this.connectTimeout = nil
		end

		if _this.connectGuardTimeout then
			clearTimeout(_this.connectGuardTimeout)
			_this.connectGuardTimeout = nil
		end

		if self.heartbeatId then
			clearTimeout(self.heartbeatId)
			self.heartbeatId = nil
		end
		if self.heartbeatTimeoutId then
			clearTimeout(self.heartbeatTimeoutId)
			self.heartbeatTimeoutId = nil
		end	

		dump(_this.handshakeBuffer, '[Pomelo:InitWebSocket:onopen] _this.handshakeBuffer')
		local obj = Package.encode(Package.TYPE_HANDSHAKE, Protocol.strencode(cjson.encode(_this.handshakeBuffer)))
		_this:send(obj) 
	end
	
	local onmessage = function( event)
		local bytes = #event.data
		_this.totalBytesReceived = _this.totalBytesReceived + bytes
		_this.bytesReceived = _this.bytesReceived + bytes

		_this:processPackage(Package.decode(event.data), cb)
		if _this.heartbeatTimeout then
			_this.nextHeartbeatTimeout = getTime() + _this.heartbeatTimeout
		end
	end
	
	local onerror = function(event)
		_this:emit('io-error', event)
		print('[error] socket error: ', event)
	end

	self.url = url
	self.maxRetries = self.maxRetries or 10
	self.retries = 0
	self.connected = false
	local doConnect

	local clearSocket = function(sock)
		if sock then
			sock.onopen = nil
			sock.onerror = nil
			sock.onmessage = nil
			sock.onclose = nil
		end
		if self.heartbeatId then
			clearTimeout(self.heartbeatId)
			self.heartbeatId = nil
		end
		if self.heartbeatTimeoutId then
			clearTimeout(self.heartbeatTimeoutId)
			self.heartbeatTimeoutId = nil
		end	
	end

	
	local onclose = function(event)
		self.connected = false
		if self.selfDisconnected then
			_this:emit('close', event)
			return
		end

		if Pomelo.debug.pomelo then
    	dump(event, '[Pomelo] local onclose, event => ')
    end
    clearSocket(self.socket)
    self.socket = nil
		-- if self.socket then
		-- 	self.socket.onopen = nil
		-- 	self.socket.onerror = nil
		-- 	self.socket.onopen = nil
		-- 	self.socket.onmessage = nil
		-- end
		if self.heartbeatId then
			clearTimeout(self.heartbeatId)
			self.heartbeatId = nil
		end
		if self.heartbeatTimeoutId then
			clearTimeout(self.heartbeatTimeoutId)
			self.heartbeatTimeoutId = nil
		end	
		_this:emit('close', event)

		print('[pomelo] onclose event')
		if _this.retries <= _this.maxRetries then
			if _this.connectTimeout then
				clearTimeout(_this.connectTimeout)
				_this.connectTimeout = nil
			end

			if _this.onTryReconnect then
				local noReconnect = _this.onTryReconnect(_this.retries) 
				-- 不需要再重连 退出
				print('[pomelo] onclose : noReconnect => ', noReconnect)
				if not noReconnect then
					print('[pomelo] onclose : no need to try to reconnect')
					return
				end
			end

			local delayTime = 2 --* (_this.retries)
			print(string.format('[pomelo] connection closed, delay %d seconds to retry', delayTime))
			_this.connectGuardTimeout = setTimeout(doConnect, delayTime)
		else
			_this:emit('connection_failure')
		end

	end


	doConnect = function()	
		print(string.format('[pomelo] #%d, connect to %s', _this.retries, url))
	  -- print('[pomelo:doConnect] --------------')
  	-- cclog(debug.traceback())
  	-- print('[pomelo:doConnect] --------------')

  	local initSocket = _this.WebSocketClass.new(url)
		_this.binaryType = 'arraybuffer'
		initSocket.onopen = onopen
		initSocket.onmessage = onmessage
		initSocket.onerror = onerror
		initSocket.onclose = onclose
		_this.socket = initSocket
		_this.retries = _this.retries + 1

		_this:emit('connecting', {retries = _this.retries})

		local timeoutCb = function()
			print(string.format('[pomelo] #%d, connect to [%s] timeout', _this.retries, _this.url))
			if _this.connected then
				print('[pomelo] already connected. return.')
				return
			end

			_this.connectTimeout = nil
			_this:disconnect(true)
			clearSocket(_this.socket)
			_this.socket = nil
			-- if _this.socket then
			-- 	_this.socket.onopen = nil
			-- 	_this.socket.onerror = nil
			-- 	_this.socket.close = nil
			-- 	_this.socket.onmessage = nil
			-- 	_this.socket = nil
			-- end

			if _this.retries <= _this.maxRetries then
				doConnect()
			end
		end

		_this.connectTimeout = setTimeout(timeoutCb, 10)
	end

	doConnect()


end

function Pomelo:disconnect(isTimeout)
	print('[Pomelo:disconnect]')
	self.selfDisconnected = true
	self.connected = false
	if self.socket then
		if self.socket.disconnect then
			self.socket:disconnect()
		end
		if self.socket.close then
			self.socket:close()
		end
		if self.socket and self.socket.onmessage then
			self.socket.onmessage = nil
		end
		self.socket = nil
	end
	
	if self.heartbeatId then
		clearTimeout(self.heartbeatId)
		self.heartbeatId = nil
	end
	if self.heartbeatTimeoutId then
		clearTimeout(self.heartbeatTimeoutId)
		self.heartbeatTimeoutId = nil
	end	
	self.selfDisconnected = false
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
		if Pomelo.debug.pomelo then
			--dump(Protocol, '[Polemo:sendMessage] Protocol')
			dump_bin(msg, '[Polemo:sendMessage] msg before')
		end
		msg = self.Protobuf.encode(route, msg)
		if Pomelo.debug.pomelo then
			dump_bin(Protocol.strdecode(msg), '[Pomelo:sendMessage] msg after encoded')
		end
	else
--		print('msg => ', cjson.encode(msg))
		msg = Protocol.strencode(cjson.encode(msg))
--		dump(msg, 'msg')
	end
	
	local compressRoute = 0
	if self.data and self.data.dict and self.data.dict[route] then
		route = self.data.dict[route]
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
	local bytes = #packet
	self.totalBytesSent = self.totalBytesSent + bytes
	self.bytesSent = self.bytesSent + bytes
	if self.socket then
		self.socket:send(packet)
	end
end

function Pomelo:sendHeartbeat()
	local obj = Package.encode(Package.TYPE_HEARTBEAT)
	self:send(obj)
end

function Pomelo:heartbeat(data)
	if not self.heartbeatInterval or self.heartbeatInterval <= 0 then
		do return end
	end
	-- dump(data, '[Pomelo:heartbeat]')
	local obj = Package.encode(Package.TYPE_HEARTBEAT)
	if self.heartbeatTimeoutId then
		clearTimeout(self.heartbeatTimeoutId)
		self.heartbeatTimeoutId = nil
	end
	
	if self.heartbeatId then
		-- already in a heartbeat interval
		--do return end
		return
		-- clearTimeout(self.heartbeatId)
		-- self.hearbeatId = nil
	end

  --self:send(obj)
	
	self.heartbeatId = setTimeout(function()
		print('self.hearbeatId with setTimeout. send...')
		self.heartbeatId = nil
		self:send(obj)
		
		self.nextHeartbeatTimeout = getTime() + self.heartbeatTimeout
		self.heartbeatTimeoutId = setTimeout(function() 
					self:heartbeatTimeoutCb() 
				end, self.heartbeatTimeout)
	end, self.heartbeatInterval + 1)
end

function Pomelo:heartbeatTimeoutCb()
	local gap = self.nextHeartbeatTimeout - getTime()
	if gap > self.gapThreshold then
		self.heartbeatTimeoutId = setTimeout(function() self:heartbeatTimeoutCb() end, gap)
	else
		print('ERROR: heartbeat timeout')
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
	self.connected = true
	self.retries = 0
	if self.connectTimeout then
		clearTimeout(self.connectTimeout)
		self.connectTimeout = nil
	end
	if self.initCallback then
		self.initCallback(self)	
		--self.initCallback = nil
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
		if not self:hasListeners(msg.route) then
			print('[Pomelo:processMessage] WARNING: no listener(s) for the event "' .. msg.route .. '", with Data =>')
			dump(msg.bogy)
		end

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
	if Pomelo.debug.pomelo then
		dump(data, '[Pomelo:handshakeInit] data ==>')
	end
	if data.sys and data.sys.heartbeat then
		self.heartbeatInterval = data.sys.heartbeat  -- heartbeat interval
		self.heartbeatTimeout = self.heartbeatInterval * 2  -- max heartbeat timeout
	else
		self.heartbeatInterval = 0
		self.heartbeatTimeout = 0
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
		self.dictVersion = data.sys.dictVersion
		self.handshakeBuffer.sys.dictVersion = self.dictVersion

		self.data.dict = dict
		self.data.abbrs = {}
		for _k, _v in pairs(dict) do
			self.data.abbrs[_v] = _k
		end

		local dictInfo = {dictVersion = self.dictVersion, dict = dict}
		ddz.writeToFile('dicts.json', cjson.encode(dictInfo))
	end
	
	-- Init protobuf protos
	if protos then

		ddz.writeToFile('protos.json', cjson.encode(protos))

		self.data.protos = {
			server = protos.server or {},
			client = protos.client or {},
			version = protos.version or 0
		}

		self.protoVersion = self.data.protos.version
		self.handshakeBuffer.sys.protoVersion = self.protoVersion
		
		if self.Protobuf then
			self.Protobuf.init({
				encoderProtos = protos.client, 
				decoderProtos = protos.server,
				protoVersion = self.data.protos.version
			})
		end
	end
end

function Pomelo:resetBytesStat()
	self.bytesSent = 0
	self.bytesReceived = 0
end

function Pomelo:dumpBytesStat()
	local mb, kb, bytes
	bytes = self.totalBytesReceived
	kb = bytes / 1024
	mb = kb / 1024
	print(string.format('[pomelo] totalBytesReceived: %0.2f Mb, %0.2f Kb, %d bytes', mb, kb, bytes))

	bytes = self.totalBytesSent
	kb = bytes / 1024
	mb = kb / 1024
	print(string.format('[pomelo] totalBytesSent: %0.2f Mb, %0.2f Kb, %d bytes', mb, kb, bytes))

	bytes = self.totalBytesReceived + self.totalBytesSent
	kb = bytes / 1024
	mb = kb / 1024
	print(string.format('[pomelo] totalBytes(Rx+Tx): %0.2f Mb, %0.2f Kb, %d bytes', mb, kb, bytes))

	bytes = self.bytesReceived
	kb = bytes / 1024
	mb = kb / 1024
	print(string.format('[pomelo] bytesReceived: %0.2f Mb, %0.2f Kb, %d bytes', mb, kb, bytes))

	bytes = self.bytesSent
	kb = bytes / 1024
	mb = kb / 1024
	print(string.format('[pomelo] bytesSent: %0.2f Mb, %0.2f Kb, %d bytes', mb, kb, bytes))

	bytes = self.bytesReceived + self.bytesSent
	kb = bytes / 1024
	mb = kb / 1024
	print(string.format('[pomelo] bytes(Rx+Tx): %0.2f Mb, %0.2f Kb, %d bytes', mb, kb, bytes))
end


return Pomelo
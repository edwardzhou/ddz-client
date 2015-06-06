--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

local bit = require('bit')
local struct = require('struct')

local Protocol = {}

local typeof = type

local PKG_HEAD_BYTES = 4
local MSG_FLAG_BYTES = 1
local MSG_ROUTE_CODE_BYTES = 2
local MSG_ID_MAX_BYTES = 5
local MSG_ROUTE_LEN_BYTES = 1

local MSG_ROUTE_CODE_MAX = 0xffff

local MSG_COMPRESS_ROUTE_MASK = 0x01
local MSG_TYPE_MASK = 0x7

Protocol.Package = {}
Protocol.Message = {}

local Package = Protocol.Package
local Message = Protocol.Message

Package.TYPE_HANDSHAKE = 1
Package.TYPE_HANDSHAKE_ACK = 2
Package.TYPE_HEARTBEAT = 3
Package.TYPE_DATA = 4
Package.TYPE_KICK = 5

Message.TYPE_REQUEST = 0
Message.TYPE_NOTIFY = 1
Message.TYPE_RESPONSE = 2
Message.TYPE_PUSH = 3

copyArray = function(target, offset, source, from, count)
	local copy_size = 0
	
	if source == nil then
		return copy_size
	end
	
	local max_src_length = #source
	for i = 0, count-1 do
		if from + i > max_src_length then
			return copy_size
		end
		target[offset + i] = source[from + i]
		copy_size = copy_size + 1
	end	
	
	return copy_size
end

function Protocol.strencode(str)
  
  local byteArray = {}
  local offset = 1
  local str_length = #str
  local batch_size = 1000
  local batch = math.ceil(#str / batch_size)
  for i=1, batch do
    local tmp_str = string.sub(str, offset, offset + batch_size -1)
    copyArray(byteArray, offset, {string.byte(tmp_str, 1, -1)}, 1, batch_size)
    offset = offset + batch_size
  end
  --print('str_length:', str_length, 'byteArray len: ', #byteArray)
  return byteArray
  
end

function Protocol.strdecode(buffer)
	--print('[Protocol.strdecode] buffer length: ', #buffer)
	--local msg = ''
	local msg_buffer = {}
	local batch_size = 1000
	local batch = math.ceil(#buffer / batch_size)
	local offset = 1
	for i = 1, batch do
		local tmp = {}
		copyArray(tmp, 1, buffer, offset, batch_size)
		table.insert(msg_buffer, string.char(unpack(tmp)))
		offset = offset + batch_size 
	end
	
	local msg = table.concat(msg_buffer, '')
--	print('[Protocol.strdecode] msg.length', #msg)
--	dump(msg, '[Protocol.strdecode] msg:')
	return msg
	--return string.char(unpack(buffer))
end



local msgHasId = function(type)
	return type == Message.TYPE_REQUEST or type == Message.TYPE_RESPONSE
end

local msgHasRoute = function(type)
    return type == Message.TYPE_REQUEST or type == Message.TYPE_NOTIFY or
           type == Message.TYPE_PUSH
end

local calculateMsgIdBytes = function(id)
	local len = 0
	local tmp_id = id
    repeat
      len = len + 1
      tmp_id = bit.rshift(tmp_id, 7)
    until tmp_id == 0
    return len
end

local encodeMsgFlag = function(type, compressRoute, buffer, offset)
    if type ~= Message.TYPE_REQUEST and type ~= Message.TYPE_NOTIFY and
    	type ~= Message.TYPE_RESPONSE and type ~= Message.TYPE_PUSH then
    	error('unknown message type: ' .. type)
    end
    
    buffer[offset] = bit.lshift(type, 1)
    if compressRoute > 0 then
    	buffer[offset] = bit.bor(buffer[offset], 1)
    end
    
    return offset + MSG_FLAG_BYTES
end

local encodeMsgId = function(id, idBytes, buffer, offset)
--    var index = offset + idBytes - 1;
--    buffer[index--] = id & 0x7f;
--    while(index >= offset) {
--      id >>= 7;
--      buffer[index--] = id & 0x7f | 0x80;
--    }
--    return offset + idBytes;
	local index = offset + idBytes - 1
	buffer[index] = bit.band(id, 0x7f)
	index = index - 1
	while index >= offset do
		id = bit.rshift(id, 7)
		buffer[index] = bit.bor(bit.band(id, 0x7f), 0x80)
		index = index - 1
	end
	
	return offset + idBytes
end

local encodeMsgRoute = function(compressRoute, route, buffer, offset)
	if compressRoute > 0 then
		if route > MSG_ROUTE_CODE_MAX then
			error('route number is overflow')
		end
		
		buffer[offset] = bit.band(bit.rshift(route, 8), 0xff)
		offset = offset + 1
		buffer[offset] = bit.band(route, 0xff)
		offset = offset + 1
	else
		if route ~= nil then
			buffer[offset] = bit.band(string.len(route), 0xff)
			offset = offset + 1
			local routeArray = {string.byte(route, 1, -1)}
			copyArray(buffer, offset, routeArray, 1, #routeArray)
			offset = offset + #routeArray
		else
			buffer[offset] = 0
			offset = offset + 1
		end
	end
	
	return offset
end

local encodeMsgBody = function(msg, buffer, offset)
--    copyArray(buffer, offset, msg, 0, msg.length);
--    return offset + msg.length;
	local msgArray = msg
	if typeof(msg) == 'string' then
		msgArray = {string.byte(msg, 1, -1)}
	end
	copyArray(buffer, offset, msgArray, 1, #msgArray)
	return offset + #msgArray
end


--  /**
--   * Package protocol encode.
--   *
--   * Pomelo package format:
--   * +------+-------------+------------------+
--   * | type | body length |       body       |
--   * +------+-------------+------------------+
--   *
--   * Head: 4bytes
--   *   0: package type,
--   *      1 - handshake,
--   *      2 - handshake ack,
--   *      3 - heartbeat,
--   *      4 - data
--   *      5 - kick
--   *   1 - 3: big-endian body length
--   * Body: body length bytes
--   *
--   * @param  {Number}    type   package type
--   * @param  {ByteArray} body   body content in bytes
--   * @return {ByteArray}        new byte array that contains encode result
--   */
function Package.encode(type, body)
    local length = 0
    local offset = 1
    if body then
    	length = #body
    end

    local buffer = {}
	
    buffer[offset] = bit.band(0xff, type)
    offset = offset + 1
    buffer[offset] = bit.band(0xff, bit.rshift(length, 16))
    offset = offset + 1
    buffer[offset] = bit.band(0xff, bit.rshift(length, 8))
    offset = offset + 1
    buffer[offset] = bit.band(0xff, length)
    offset = offset + 1
    copyArray(buffer, offset, body, 1, length)
    
    return buffer
end


 --  /**
--   * Package protocol decode.
--   * See encode for package format.
--   *
--   * @param  {ByteArray} buffer byte array containing package content
--   * @return {Object}           {type: package type, buffer: body byte array}
--   */
function Package.decode(buffer)
    local type = buffer[1]
    local index = 2
    local length = bit.lshift(buffer[index], 16) + bit.lshift(buffer[index+1], 8) + buffer[index+2]
    local body = nil
    if length > 0 then
    	body = {}
    	copyArray(body, 1, buffer, PKG_HEAD_BYTES + 1, length)
    end 
    
    return {type = type, body = body}
end

--  /**
--   * Message protocol encode.
--   *
--   * @param  {Number} id            message id
--   * @param  {Number} type          message type
--   * @param  {Number} compressRoute whether compress route
--   * @param  {Number|String} route  route code or route string
--   * @param  {Buffer} msg           message body bytes
--   * @return {Buffer}               encode result
--   */
function Message.encode(id, type, compressRoute, route, msg)
    -- calculate message max length
 	local idBytes = 0
	if msgHasId(type) then idBytes = calculateMsgIdBytes(id) end
	local msgLen = MSG_FLAG_BYTES + idBytes
	
	if msgHasRoute(type) then
		if compressRoute > 0 then
			if typeof(route) ~= 'number' then
				error('error flag for number route!')
			end
			msgLen = msgLen + MSG_ROUTE_CODE_BYTES
		else
			msgLen = msgLen + MSG_ROUTE_LEN_BYTES
			if string.len(route) > 255 then
				error('route maxlength is overflow')
			end
			msgLen = msgLen + string.len(route)
		end
	end
	
	if msg ~= nil then
		msgLen = msgLen + #{msg} + 1
	end

	local buffer = {}
	local offset = 1
	
	-- add flag
	offset = encodeMsgFlag(type, compressRoute, buffer, offset)
	
	-- add message id
	if msgHasId(type) then
		offset = encodeMsgId(id, idBytes, buffer, offset)
	end
	
	-- add route
	if msgHasRoute(type) then
		offset = encodeMsgRoute(compressRoute, route, buffer, offset)
	end
	
	-- add body
	if msg ~= nil then
		offset = encodeMsgBody(msg, buffer, offset)
	end
	
    return buffer
 end
 
--   /**
--   * Message protocol decode.
--   *
--   * @param  {Buffer|Uint8Array} buffer message bytes
--   * @return {Object}            message object
--   */
Message.decode = function(buffer)
	local bytesLen = #buffer
	local offset = 1
	local id = 0
	local route = nil
	
	-- parse flag
	local flag = buffer[offset]
	offset = offset + 1
	local compressRoute = bit.band(flag, MSG_COMPRESS_ROUTE_MASK)
	local type = bit.band(bit.rshift(flag, 1), MSG_TYPE_MASK)
	
	-- parse id
	if msgHasId(type) then
		local byte = buffer[offset]
		offset = offset + 1
		id = bit.band(byte, 0x7f)
		while bit.band(byte, 0x80) > 0 do
			id = bit.lshift(id, 7)
			byte = buffer[offset]
			offset = offset + 1
			id = bit.bor(id, bit.band(byte, 0x7f))
		end
	end
	
	-- parse route
	if msgHasRoute(type) then
		if compressRoute > 0 then
			route = bit.lshift(buffer[offset], 8) + buffer[offset+1]
			offset = offset + 2
		else
			local routeLen = buffer[offset]
			offset = offset + 1
			if routeLen > 0 then
				route = {}
				copyArray(route, 1, buffer, offset, routeLen)
				route = Protocol.strdecode(route)
			else
				route = ''
			end
			offset = offset + routeLen
		end
	end
	
	-- parse body
	local bodyLen = bytesLen - offset + 1
	local body = {}
	copyArray(body, 1, buffer, offset, bodyLen)
	body = body
	
	local decodedMsg = {id = id, type = type, compressRoute = compressRoute,
			route = route, body = body}
  return decodedMsg
end
 
return Protocol
local codec = require("pomelo.protobuf.codec")
local util = require('pomelo.protobuf.util')
local constant = require('pomelo.protobuf.constant')
local cjson = require('cjson.safe')
local EncoderFactory = {}

EncoderFactory.getEncoder = function()
  local Encoder = {}
  
  local checkMsg, encodeMsg, encodeProp, encodeArray, writeBytes, encodeTag
  
  function Encoder.init(protos)
    Encoder.protos = protos or {} 
  end
  
  function Encoder.encode(route, msg)
    if not (route and msg) then
      print('[Pomelo Encoder.encode] WARNING: Route or msg can not be null! route: ', route, ' msg ', msg)
      return nil
    end
    -- Get protos from protos map use the route as key
    local protos = Encoder.protos[route]
    --dump(protos, '----Encoder---- protos:')
    -- Check msg
    if not checkMsg(msg, protos) then
      print('[Encoder.encode] check msg failed!');
      dump(msg, 'msg')
      dump(protos, 'protos')
      return nil
    end
    
    -- Set the length of the buffer
    local json_str = cjson.encode(msg)
    local length = codec.byteLength(json_str)
    if Pomelo.debug.encoder then
      print('length => ', length, json_str)
    end
    
    -- Init buffer and offset
    local buffer = {}
    local offset = 1
    if protos ~= nil then
      offset = encodeMsg(buffer, offset, protos, msg)
      if Pomelo.debug.encoder then
        print('encodeMsg return ', offset)
      end
      if offset <= 1 then
        buffer = nil
      end
    end
    
    return buffer
  end
  
  checkMsg = function(msg, protos)
    if not (protos and msg) then
      return false
    end
    
    for _name, _proto in pairs(protos) do
      -- All required element must exists
      if _proto.option == 'required' then
        if msg[_name] == nil then
          print('[Pomelo Encoder.checkMsg] WARNING: no property exists for required! name: %s, \n proto: %s \n msg: %s',
            name, dump(_proto, '', true), dump(msg, '', true))
          return false
        end
        local message = protos.__messages[_proto.type] or Encoder.protos['message ' .. _proto.type]
        if message and not checkMsg(msg[_name], message) then
          print('[Pomelo Encoder.checkMsg] WARNING: inner proto error! name: %s, \n proto: %s \n msg: %s',
            name, dump(_proto, '', true), dump(msg, '', true))
          return false;
          --checkMsg(msg[_name], protos.__messages[_proto.type])
        end
      elseif _proto.option == 'optional' then
        if msg[_name] ~= nil then
          local message = protos.__messages[_proto.type] or Encoder.protos['message ' .. _proto.type]
          if message and not checkMsg(msg[_name], message) then
            print('[Pomelo Encoder.checkMsg] WARNING: inner proto error! name: %s, \n proto: %s \n msg: %s',
              name, dump(_proto, '', true), dump(msg, '', true))
            return false;
            --checkMsg(msg[_name], protos.__messages[_proto.type])
          end
        end
      elseif _proto.option == 'repeated' then
        -- Check nest message in repeated elements
         local message = protos.__messages[_proto.type] or Encoder.protos['message ' .. _proto.type]
         if msg[_name] and message then
          local nested = msg[_name]
          for _, _value in ipairs(nested) do
            if not checkMsg(_value, message) then
              return false
            end
          end
        end
      end     
    end
    
    return true
  end
  
  encodeMsg = function(buffer, offset, protos, msg)
    --print('[encodeMsg] ', buffer, offset, protos, msg)
    for _name, _data in pairs(msg) do
      if Pomelo.debug.encoder then
        print('_name:', _name, '_data' , _data, " --- ", protos[_name])
      end
      if protos[_name] then
        local proto = protos[_name]
        if Pomelo.debug.encoder then
          print( _name .. ' proto:[option => ' .. proto.option .. ", type => " .. proto.type .. ', tag => ', proto.tag )
        end
        if proto.option == 'required' or proto.option == 'optional' then
          local e_tag = encodeTag(proto.type, proto.tag)
          local proto = protos[_name]
          if Pomelo.debug.encoder then
            dump(e_tag, _name .. "'s tag")
          end
          offset = writeBytes(buffer, offset, e_tag)
          offset = encodeProp(_data, proto.type, offset, buffer, protos)
        elseif proto.option == 'repeated' then
          if #_data > 0 then
            offset = encodeArray(_data, proto, offset, buffer, protos)
          end
        end
      end
    end
    
    return offset
  end
  
  encodeProp = function(value, type, offset, buffer, protos)
    if type == 'uInt32' then
      offset = writeBytes(buffer, offset, codec.encodeUInt32(value))
    elseif type == 'int32' or type == 'sInt32' then
      offset = writeBytes(buffer, offset, codec.encodeSInt32(value))
    elseif type == 'float' then
      writeBytes(buffer, offset, codec.encodeFloat(value))
      offset = offset + 4
    elseif type == 'double' then
      writeBytes(buffer, offset, codec.encodeDouble(value))
      offset = offset + 8
    elseif type == 'string' then
      local length = codec.byteLength(value)
      -- Encode length
      offset = writeBytes(buffer, offset, codec.encodeUInt32(length))
      -- write string
      codec.encodeStr(buffer, offset, value)
      offset = offset + length
    else
      local message = protos.__messages[type] or Encoder.protos['message ' .. type]
      if message then
        -- Use a tmp buffer to build an internal msg
        local tmpBuffer = {}
        local length = 1
        length = encodeMsg(tmpBuffer, length, message, value)
        -- Encode length
        offset = writeBytes(buffer, offset, codec.encodeUInt32(length))
        -- contact the object
        for i = 1, #tmpBuffer do
          buffer[offset] = tmpBuffer[i]
          offset = offset + 1
        end
      end
    end
    
    return offset
  end
  
  encodeArray = function(array, proto, offset, buffer, protos)
    local i = 0
    
    if util.isSimpleType(proto.type) then
      offset = writeBytes(buffer, offset, encodeTag(proto.type, proto.tag))
      offset = writeBytes(buffer, offset, codec.encodeUInt32(#array))
      for _, element in ipairs(array) do
        offset = encodeProp(element, proto.type, offset, buffer)
      end
    else
      for _, element in ipairs(array) do
        offset = writeBytes(buffer, offset, encodeTag(proto.type, proto.tag))
        offset = encodeProp(element, proto.type, offset, buffer, protos) 
      end
    end
    
    return offset
  end
  
  writeBytes = function(buffer, offset, bytes)
    for _, byte in ipairs(bytes) do
      buffer[offset] = byte
      offset = offset + 1
    end
    
    return offset
  end
  
  encodeTag = function(type, tag)
    local value = constant.TYPES[type] or 2
    return codec.encodeUInt32(bit.bor(bit.lshift(tag, 3), value))
  end
  
  return Encoder
end

return EncoderFactory
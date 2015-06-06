--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

local struct = require('struct')
local Codec = {}

Codec.encodeUInt32 = function(n)
  local n = math.floor(tonumber(n))
  if n < 0 then
    return nil
  end
  
  local result = {}
  repeat
    local tmp = n % 128
    local next = math.floor(n/128)
    if next ~= 0 then
      tmp = tmp + 128
    end
    table.insert(result, tmp)
    n = next
  until n == 0
  
  return result
end

Codec.encodeSInt32 = function(n)
  local n = math.floor(tonumber(n))
  
  if n < 0 then
    n = math.abs(n) * 2 -1      
  else
    n = n * 2
  end
  
  return Codec.encodeUInt32(n)    
end

Codec.decodeUInt32 = function(bytes)
  local n = 0
  
  for index=0 , #bytes - 1 do
    local m = bytes[index+1]
    n = n + (bit.band(m, 0x7f)) * math.pow(2, (7* index))
    if (m < 128) then
      do return n end
    end     
  end
  
  return n
end

Codec.decodeSInt32 = function(bytes)
  local n = Codec.decodeUInt32(bytes)
  local flag = 1
  if (n % 2) == 1 then
    flag = -1
  end
  
  n = ((n%2 + n)/2) * flag
  
  return n
end

Codec.encodeFloat = function(float)
  local floatPack = struct.pack('f', float)
  return {string.byte(floatPack, 1, -1)}
end

Codec.decodeFloat = function(bytes)
  local float = struct.unpack('f', string.char(unpack(bytes)))
  return float
end

Codec.encodeDouble = function(double)
  local str = struct.pack('d', double)
  return {string.byte(str, 1, -1)}
end

Codec.decodeDouble = function(bytes)
  local double = struct.unpack('d', string.char(unpack(bytes)))
  return double
end

Codec.encodeStr = function(bytes, offset, str)
  local strBytes = {string.byte(str, 1, -1)}
  for _k, _byte in ipairs(strBytes) do
    bytes[offset] = _byte
    offset = offset + 1
  end
  
  return offset
end

Codec.decodeStr = function(bytes, offset, length)
  local tmp = {}
  for i = 0, length-1 do
    table.insert(tmp, bytes[offset + i])
  end
  
  return string.char(unpack(tmp))
end

Codec.byteLength = function(str)
  if type(str) ~= 'string' then
    do return -1 end
  end
  
  return #({string.byte(str, 1, -1)})
end

return Codec
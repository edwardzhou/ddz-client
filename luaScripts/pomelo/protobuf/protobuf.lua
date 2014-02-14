local encoderFactory = require('pomelo.protobuf.encoder')
local decoderFactory = require('pomelo.protobuf.decoder')
local codec = require('pomelo.protobuf.codec')

local ProtobufFactory = {}

ProtobufFactory.getProtobuf = function()
  local Protobuf = {}
  Protobuf.encoder = encoderFactory.getEncoder()
  Protobuf.decoder = decoderFactory.getDecoder()
  Protobuf.codec = codec
  
  Protobuf.init = function(opts)
    Protobuf.encoder.init(opts.encoderProtos)
    Protobuf.decoder.init(opts.decoderProtos)
  end
  
  Protobuf.encode = function(key, msg)
    return Protobuf.encoder.encode(key, msg)
  end
  
  Protobuf.decode = function(key, msg)
    return Protobuf.decoder.decode(key, msg)
  end
  
  return Protobuf
end

return ProtobufFactory
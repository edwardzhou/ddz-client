local Parser = {}

Parser.parse = function(protos)
  local maps = {}
  for key, obj in pairs(protos) do
    maps[key] = Parser.parseObject(obj)
  end
  
  return maps
end

Parser.parseObject = function(obj)
  local proto = {}
  local nestProtos = {}
  local tags = {}
  
  for name, tag in pairs(obj) do
    local params = string.split(name, ' ')
    if params[1] == 'required' or params[1] == 'optional' or params[1] == 'repeated' then
      if #params == 3 and not tags[tag] then
        proto[params[3]] = {
          option = params[1],
          type = params[2],
          tag = tag
        }
        tags[tag] = params[3]
      end
    elseif params[1] == 'message' then
      if #params == 2 then
        nestProtos[params[2]] = Parser.parseObject(tag)
      end
    end
  end
  
  proto.__messages = nestProtos
  proto.__tags = tags
  return proto
end

return Parser
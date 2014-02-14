local util = {}

util.isSimpleType = function(type)
  return (type == 'uInt32' or
          type == 'sInt32' or
          type == 'int32'  or
          type == 'uInt64' or
          type == 'sInt64' or
          type == 'float'  or
          type == 'double')
end

util.equal = function(obj0, obj1)
  for k0,v0 in pairs(obj0) do
    local v1 = obj1[k0]
    if type(v0) == 'table' and type(v1) == 'table' then
      if not util.equal(v0, v1) then
        return false
      end
    elseif type(v0) ~= 'function' and v0 ~= v1 then
      return false
    end
  end
  
  return true
end

util.ref = 1

return util
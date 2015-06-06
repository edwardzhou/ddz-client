--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

local utils = {}

function utils.invokeCallback(cb, ...)
  if cb ~= nil and type(cb) == 'function' then
    return cb(...)
  end
  return nil
  
end

return utils
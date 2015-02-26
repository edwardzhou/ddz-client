local utils = {}

function utils.invokeCallback(cb, ...)
  if cb ~= nil and type(cb) == 'function' then
    return cb(...)
  end
end

return utils
local utils = {}

function utils.invokeCallback(cb, ...)
  if cb ~= nil then
    cb(...)
  end
end

return utils
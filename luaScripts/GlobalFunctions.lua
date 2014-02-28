function table.deepCopy(src)
  local newTable = {}
  for k, v in pairs(src) do
    if type(v) ~= 'table' then
      newTable[k] = v
    elseif type(v.clone) == 'function' then
      newTable[k] = v:clone()
    else
      newTable[k] = table.deepCopy(v)
    end
  end
  return newTable
end


function shuffleArray(array)
    local arrayCount = #array
    for i = arrayCount, 2, -1 do
        local j = math.random(1, i)
        array[i], array[j] = array[j], array[i]
    end
    return array
end
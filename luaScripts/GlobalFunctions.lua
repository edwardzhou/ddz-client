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

function table.dup(src)
  local newTable = {}
  for k, v in pairs(src) do
    newTable[k] = v
  end
  
  return newTable
end

function table.append(dst, src)
  for _, value in pairs(src) do
    table.insert(dst, value)
  end
  return dst
end

function table.removeItems(src, items)
  for _, item in pairs(items) do
    table.removeItem(src, item)
  end
end

function table.tableFromField(src, field, from, to)
  local newTable = {}
  from = from or 1
  to = to or #src
  if to > #src then
    to = #src
  end
  for i=from, to do
    table.insert(newTable, src[i][field])
  end
--  for _, item in pairs(src) do
--    table.insert(newTable, item[field])
--  end
  
  return newTable
end

function table.partial(src, from, to)
  local newTable = {}
  for i=from, to do
    table.insert(newTable, src[i])
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

table.shuffle = shuffleArray

function sortAscBy(field)
  return function(a, b)
    return a[field] < b[field]
  end
end

function sortDescBy(field)
  return function(a, b)
    return a[field] > b[field]
  end
end

function getContent(filename)
  local base = '../Resources/'
  local content = nil
  if cc then
    content = cc.FileUtils:getInstance():getStringFromFile(filename)
  else
    local f = io.open(base .. filename, "r")
    content = f:read("*a")
    f:close()
  end
  
  return content
end
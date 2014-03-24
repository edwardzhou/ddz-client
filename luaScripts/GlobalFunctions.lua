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

function table.copy(src, from, to)
  from = from or 1
  to = to or #src
  if from > to then
    from, to = to, from
  end

  if to > #src then
    to = #src
  end

  local newTable = {}
  for index = from, to do
    table.insert(newTable, src[index])
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

function table.filter(src, fn)
  local result = {}
  for _,v in pairs(src) do
    if fn(v) then
      table.insert(result, v)
    end
  end
  return result
end

function table.combine(dest, src)
  for _, value in pairs(src) do
    table.insert(dest, value)
  end
end

function table.copy_kv(dest, src)
  for k,v in pairs(src) do
    dest[k] = v
  end
end

function clone_table(array)
  local result = {}
  table.merge(result, array)
  return result
end

function table.join(table, s)
  s = tostring(s)
  local str = ""
  for _, _v in pairs(table) do
    if str == "" then 
      str = str .. tostring(_v)
    else 
      str = str .. s .. tostring(_v)
    end
  end
  return str
end

function table.toString(table)
  local str = "[ "
  for _, _v in pairs(table) do
    str = str .. tostring(_v) .. ",  "
  end
  str = str .. "]"
  return str
end

function table.reverse(array)
  local result = {}
  for index = -#array, -1 do
    table.insert(result, array[-index])
  end
  return result
end

function table.some(array, func)
  local result = false
  for _, obj in pairs(array) do
    if func(obj) then
      result = true
      break
    end
  end
  return result
end

function table.unique(array, getObjectValueFuc)
  local newArray = {}
  for elementIndex,_ in pairs(array) do
    local elementValue = getObjectValueFuc(array[elementIndex])
    local search = function(obj) return (getObjectValueFuc(obj) == elementValue) end
    local exist = table.some(newArray, search)
    if not exist then
      table.insert(newArray, array[elementIndex])
    end
  end
  return newArray
end


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

function __bind(fn, this)
  return function(...)
    fn(this, ...)
  end
end
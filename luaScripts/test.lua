--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

require('framework.functions')
require('framework.debug')

cjson = require('cjson.safe')

file = io.open('../Resources/allCardTypes.json')
data = file:read('*a')
file:close()

allCardTypes = cjson.decode(data)

outfile = io.open('allCardTypes.lua', 'w+')
outfile:write('g_allCardTypes = {}\n')

for cardId, cardType in pairs(allCardTypes) do
  outfile:write('g_allCardTypes["' .. cardId .. '"] = {\n')
  for key, value in pairs(cardType) do
    outfile:write(key .. ' = ' .. tostring(value) .. ', \n')
  end
  outfile:write('}\n')
end
--outfile:write('}\n')

outfile:close()
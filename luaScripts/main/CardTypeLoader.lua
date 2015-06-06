--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

local CardTypeLoader = class('CardTypeLoader')
require 'socket'
local cjson = require('cjson.safe')

function CardTypeLoader.loadFromLua()
  local s1, s2, s3
  print('start to load allCardTypes.lua')
  s1 = socket.gettime() 
  require('allCardTypes')
  s2 = socket.gettime()

  print('loaded allCardTypes.lua => ' , s2 - s1)
  -- print('decode json => ', s3 - s2)
  -- print('total => ', s3 - s1)

end

function CardTypeLoader.loadAllCardType(name)
  --CardTypeLoader.loadFromLua()

  local s1, s2, s3
  -- print('start to load ' , name)
  s1 = socket.gettime() 
  local jsonStr = cc.FileUtils:getInstance():getStringFromFile(name)
  s2 = socket.gettime()
  -- print('start to decode ' , name)

  table.merge(AllCardTypes, cjson.decode(jsonStr) )
  s3 = socket.gettime()
  -- print('decode ' , name, ' finished')

  -- print('load json => ' , s2 - s1)
  -- print('decode json => ', s3 - s2)
  -- print('total => ', s3 - s1)
end

function CardTypeLoader.loadAllCardTypeX(scene, progressCb, finishCb)
  --CardTypeLoader.loadFromLua()

  AllCardTypes = {}
  local s1, s2, s3
  print('start to load allCardTypes.json')
  s1 = socket.gettime() 

  local curIndex = 1
  local count = 177

  scene:runAction(cc.Repeat:create(
      cc.Sequence:create(
          cc.CallFunc:create(function() 
              if (curIndex <= count) then 
                local name = string.format('cardTypes/allCardTypes_%d.json', curIndex)
                CardTypeLoader.loadAllCardType(name)
              end
              progressCb(curIndex * 100 / count)
              curIndex = curIndex + 1

              if (curIndex > count) then
                s2 = socket.gettime()

                print('total load json => ' , s2 - s1)
                allCardTypes = AllCardTypes
                finishCb()
              end
            end)
          , cc.DelayTime:create(0.02)
        )
    , count))


  -- local jsonStr = cc.FileUtils:getInstance():getStringFromFile('allCardTypes_1.json')
  -- s2 = socket.gettime()

  -- print('load json => ' , s2 - s1)
  -- print('decode json => ', s3 - s2)
  -- print('total => ', s3 - s1)
end

return CardTypeLoader
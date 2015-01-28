local CardTypeLoader = class('CardTypeLoader')
require 'socket'
local cjson = require('cjson.safe')

function CardTypeLoader.loadAllCardType()
  local s1, s2, s3
  print('start to load allCardTypes.json')
  s1 = socket.gettime() 
  local jsonStr = cc.FileUtils:getInstance():getStringFromFile('allCardTypes.json')
  s2 = socket.gettime()
  print('start to decode allCardTypes.json')
  AllCardTypes = cjson.decode(jsonStr)
  s3 = socket.gettime()
  print('decode allCardTypes.json finished')

  print('load json => ' , s2 - s1)
  print('decode json => ', s3 - s2)
  print('total => ', s3 - s1)
end

return CardTypeLoader
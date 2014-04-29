require 'extern'
require 'framework.functions'
require 'framework.debug'
require 'pomelo.pomelo'
--local ev = require 'ev'

function testPomelo(websocketClass)
  p = Pomelo.new(websocketClass)
  local params = {host='192.168.0.165', port='4001'}


  p:init(params, function(x)
    dump(x, 'p.init callback')
    p:request('gate.gateHandler.queryEntry', {uid=10001}, function(...)
      local args = {...}
      dump(args, 'data---') 
      --dump(data, 'data---') 
    end)
  end)
end

function initCocos2dxPomelo(params, callback)
  if Cocos2dxWebsocket == nil then
    require('pomelo.cocos2dx_websocket')
  end

  params = params or {host='192.168.0.165', port='4001'}
  local pomelo = Pomelo.new(Cocos2dxWebsocket)
  pomelo:init(params, function(pomelo)
    callback(pomelo)
  end)
end

--ev.Loop.default:loop()

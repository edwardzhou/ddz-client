require 'extern'
require 'framework.functions'
require 'framework.debug'
require 'pomelo.pomelo'
--local ev = require 'ev'

function testPomelo(websocketClass)
  p = Pomelo.new(websocketClass)
  local params = {host='192.168.0.165', port='4001'}

  local function queryRooms()
    p:request('connector.entryHandler.queryRooms', {}, function(data)
      dump(data, "queryRooms => ")
    end)
  end

  local function connectToConnector(host, port, cb)
    p:init({host = host, port = port}, function()
      cb()
    end)
  end

  p:init(params, function(x)
    dump(x, 'p.init callback')
    p:request('gate.gateHandler.queryEntry', {uid=10001}, function(data)
      --local args = {...}
      dump(data, 'data---') 
      p:disconnect();
      --dump(data, 'data---') 
      connectToConnector(data.hosts[1].host, data.hosts[1].port, queryRooms )
    end)
  end)

  return p
end

function initCocos2dxPomelo(params, callback)
  if Cocos2dxWebsocket == nil then
    require('pomelo.cocos2dx_websocket')
  end

  params = params or {}

  if params.host == nil then
    table.merge(params, {host='192.168.0.165', port='4001'})
  end

  --params = params or {host='192.168.0.165', port='4001'}
  local pomelo = Pomelo.new(Cocos2dxWebsocket)
  pomelo:init(params, function(pomelo)
    callback(pomelo)
  end)
end

--ev.Loop.default:loop()

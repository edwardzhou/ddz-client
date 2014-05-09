require 'pomelo.pomelo'
local ConnectionPlugin = {}

function ConnectionPlugin.bind(theClass, websocketClass)
  if websocketClass == nil then
    websocketClass = require('pomelo.cocos2dx_websocket')
  end

  function theClass:connectTo(host, port, readyCallback)
    local this = self

    if not self.pomeloClient then
      self.pomeloClient = Pomelo.new(websocketClass)
    end

    local pomeloClient = self.pomeloClient

    local params = {
      host = host,
      port = port
    }

    local function authConnection()
      pomeloClient:request('auth.connHandler.authConn', {}, function(data)
        readyCallback(this, pomeloClient)
      end)
    end

    pomeloClient:init(params, function()
      authConnection()
    end)
  end
end

return ConnectionPlugin
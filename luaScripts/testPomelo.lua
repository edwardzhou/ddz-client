require 'extern'
require 'framework.functions'
require 'framework.debug'
require 'pomelo.pomelo'
--local ev = require 'ev'

function testPomelo(websocketClass)
  p = Pomelo.new(websocketClass)
  params = {host='192.168.0.165', port='4001'}


  p:init(params, function(x)
    dump(x, 'p.init callback')
    p:request('gate.gateHandler.queryEntry', {uid=10001}, function(...)
      local args = {...}
      dump(args, 'data---') 
      --dump(data, 'data---') 
    end)
  end)
end

--ev.Loop.default:loop()

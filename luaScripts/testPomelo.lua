require 'extern'
require 'framework.functions'
require 'framework.debug'
require 'pomelo.pomelo'
local ev = require 'ev'

p = Pomelo.new()
params = {host='localhost', port='4001'}

p:init(params, function(x)
  dump(x, 'p.init callback')
  p:request('gate.gateHandler.queryEntry', {uid=10001}, function(...)
    local args = {...}
    dump(args, 'data---') 
    --dump(data, 'data---') 
  end)
end)

ev.Loop.default:loop()

local JipaiqiComponent = class('JipaiqiComponent')
local bit = require('bit')

function JipaiqiComponent.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, JipaiqiComponent)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function JipaiqiComponent:ctor(...)
  local this = self
  this.hidenRetries = 4
  self:registerScriptHandler(function(event)
    print('[JipaiqiComponent] event => ', event)
    local on_event = 'on_' .. event
    if type(this[on_event]) == 'function' then
      this[on_event](this)
    end
  end)

  self:init()
end

function JipaiqiComponent:on_enter()
  print('[JipaiqiComponent:on_enter] ...')
end

function JipaiqiComponent:on_enterTransitionFinish()
end

function JipaiqiComponent:on_cleanup()
end

function JipaiqiComponent:init()
  -- local rootLayer = self

  -- local ui = cc.CSLoader:createNode('JipaiqiLayer.csb')
  -- rootLayer:addChild(ui)
  -- require('utils.UIVariableBinding').bind(ui, self, self)
end

function JipaiqiComponent:reset()
  local pokeIds = {'3', '4', '5', '6', '7', '8', '9', '0', 'J', 'Q', 'K', 'A', '2'}
  for _, v in ipairs(pokeIds) do
    self['Poke_' .. v]:setString('4')
  end
  self['Poke_w']:setString(1)
  self['Poke_W']:setString(1)
end

function JipaiqiComponent:updateStatus(playedPokeBits)
  local pokeIds = {'3', '4', '5', '6', '7', '8', '9',   '0', 'J', 'Q', 'K', 'A', '2'}
  local id
  local count 
  for index, v in ipairs(pokeIds) do
    count = 4
    id = 'Poke_' .. v
    if index < 8 then
      if (bit.band(playedPokeBits[1], bit.lshift(1, (index-1) * 4 ))) > 0 then
        count = count - 1
      end
      if (bit.band(playedPokeBits[1], bit.lshift(1, (index-1) * 4 + 1 ))) > 0 then
        count = count - 1
      end
      if (bit.band(playedPokeBits[1], bit.lshift(1, (index-1) * 4 + 2 ))) > 0 then
        count = count - 1
      end
      if (bit.band(playedPokeBits[1], bit.lshift(1, (index-1) * 4 + 3 ))) > 0 then
        count = count - 1
      end
    else

      if (bit.band(playedPokeBits[2], bit.lshift(1, (index - 8) * 4 ))) > 0 then
        count = count - 1
      end
      if (bit.band(playedPokeBits[2], bit.lshift(1, (index - 8) * 4 + 1 ))) > 0 then
        count = count - 1
      end
      if (bit.band(playedPokeBits[2], bit.lshift(1, (index - 8) * 4 + 2 ))) > 0 then
        count = count - 1
      end
      if (bit.band(playedPokeBits[2], bit.lshift(1, (index - 8) * 4 + 3 ))) > 0 then
        count = count - 1
      end
    end

    self[id]:setString(count)
  end

  count = 1
  if bit.band(playedPokeBits[2], bit.lshift(1, 0x18)) > 0 then
    count = count - 1
  end
  self['Poke_w']:setString(count)

  count = 1
  if bit.band(playedPokeBits[2], bit.lshift(1, 0x19)) > 0 then
    count = count - 1
  end
  self['Poke_W']:setString(count)


end

local function createJipaiqi()
  local ui = cc.CSLoader:createNode('JipaiqiLayer.csb')
  local root = JipaiqiComponent.extend(ui)
  require('utils.UIVariableBinding').bind(ui, root, root)
  return root
end

return createJipaiqi

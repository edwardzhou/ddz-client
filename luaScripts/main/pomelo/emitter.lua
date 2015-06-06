--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

if not class then
	require('framework.functions')
end

if not table.indexOf then
	table.indexOf = function(t, e)
		for _index, _value in ipairs(t) do
			if _value == e then
				do return _index end
			end
		end
		
		return 0
	end
end

Emitter = class('Emitter')

function Emitter:ctor()
	self._callbacks = {}
	
end

function Emitter:on(event, fn)
	if not self._callbacks[event] then
		self._callbacks[event] = {} 
	end
	
	table.insert(self._callbacks[event], fn)
	
	return self
end

function Emitter:once(event, fn)
	local _this = self

	local _on = nil
	_on = function(...)
		_this:off(event, _on)
		fn(...)
	end
	
	return self:on(event, _on)
end

function Emitter:off(...)
	local args = {...}
	-- remove all if no arguments
	if #args == 0 then
		self._callbacks = {}
		do return self end
	end
	
	local event = args[1]
	local fn = args[2]
	
	local callbacks = self._callbacks[event]
	if not callbacks then
		do return self end
	end
	
	if fn == nil then
		self._callbacks[event] = nil
		do return self end
	end
	
	local i = table.indexOf(callbacks, fn)
	if i > 0 then
		table.remove(callbacks, i)
	end
	
	return self
end

Emitter.addListener = Emitter.on
Emitter.addListenerOnce = Emitter.once
Emitter.removeListener = Emitter.off
Emitter.removeAllListeners = Emitter.off

function Emitter:emit(event, ...)
  self._callbacks = self._callbacks or {}
	local args = {...}
	local callbacks = self._callbacks[event]
	
	if callbacks ~= nil then
		for _i, fn in ipairs(callbacks) do
			--print(string.format('[Emitter:emit] invoke callback for [%s]', event))
			local result, err = pcall(fn, ...)
			if not result then
				print('[Emitter.emit] Error to call fn for event "' .. event .. '"')
				dump(err)
			end
			--fn(...)
		end
	end
	
	return self
end

function Emitter:listeners(event)
	return self._callbacks[event] or {}
end

function Emitter:hasListeners(event)
	return #(self:listeners(event)) > 0
end

return Emitter
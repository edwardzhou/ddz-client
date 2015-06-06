--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

EveryDayLoginLogic = {}

EveryDayLoginLogic.check = function(data)
	data = data.ddzLoginRewards.dayRewards
	dump(data, 'ddzLoginRewards.dayRewards')
	if data == nil then
		return
	end
	
	local  status = {}
	local total = 0
	for k,v in pairs(data) do
		local arr = string.split(v.day, "_")
		local day = tonumber(arr[2])
		if v.status == 1 then
			v.statusText = 'get'
			status[day] = 'get'
			total = total + v.bonus
		elseif v.status == 0 then
			v.statusText = 'disable'
			status[day] = 'disable'
		else
			v.statusText = 'getted'
			status[day] = 'getted'
		end
	end
	if total > 0 then
		local dialog = require('everydaylogin.DailyLoginLayer').new(data, total)
		local scene = cc.Director:getInstance():getRunningScene()
		scene:addChild(dialog)
	end
end

return EveryDayLoginLogic
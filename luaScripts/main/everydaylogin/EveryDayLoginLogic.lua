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
			status[day] = 'get'
			total = total + v.bonus
		elseif v.status == 0 then
			status[day] = 'disable'
		else
			status[day] = 'getted'
		end
	end
	if total > 0 then
		local dialog = require('everydaylogin.EveryDayLoginDialog').new(status, total)
		local scene = cc.Director:getInstance():getRunningScene()
		scene:addChild(dialog)
	end
end

return EveryDayLoginLogic
local Res = require('Resources')
local AccountInfo = require('AccountInfo')
local TaskUpdatePlugin = {}

function TaskUpdatePlugin.bind(theClass)

  function theClass:updateTask()
  	local this = self
  	self.gameConnection:request('ddz.taskHandler.getOneDayPlayTaskInfo', {userId = AccountInfo.getCurrentUser().userId}, function (data)
    	if data.result then
    		this:updateTaskLabel(data)
    	end
  	end)
  end

  function theClass:updateTaskLabel(data)
  	self.TaskProgress:setString(tostring(data.task_info.current) .. '/' .. tostring(data.task_info.count))
  end

end

return TaskUpdatePlugin
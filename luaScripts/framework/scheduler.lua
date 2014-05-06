
local scheduler = {}

local sharedScheduler = cc.Director:getInstance():getScheduler()

function scheduler.scheduleUpdateGlobal(listener)
    return sharedScheduler:scheduleScriptFunc(listener, 0, false)
end

function scheduler.scheduleGlobal(listener, interval)
    return sharedScheduler:scheduleScriptFunc(listener, interval, false)
end

function scheduler.unscheduleGlobal(handle)
    if handle then
        sharedScheduler:unscheduleScriptEntry(handle)
    end
end

function scheduler.performWithDelayGlobal(listener, params, time)
    local handle
    if time == nil then
      time = params
      params = {}
    end
    handle = sharedScheduler:scheduleScriptFunc(function()
        scheduler.unscheduleGlobal(handle)
        listener(unpack(params))
    end, time, false)
    return handle
end

setTimeout = function (fn, params, timeout)
    -- if timeout == nil then
    --     timeout = params
    --     params = {}
    -- end
    -- timeout = timeout / 1000.0 -- convert milliseconds into seconds, because cocos2d-x uses seconds
    return scheduler.performWithDelayGlobal(fn, params, timeout)
end

clearTimeout = function (timeoutId)
    scheduler.unscheduleGlobal(timeoutId)
end


return scheduler

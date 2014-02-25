require "Cocos2d"
require 'framework.functions'
require 'framework.debug'

-- cclog
cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
end

local function main()
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    --support debug
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or 
       (cc.PLATFORM_OS_ANDROID == targetPlatform) or (cc.PLATFORM_OS_WINDOWS == targetPlatform) or
       (cc.PLATFORM_OS_MAC == targetPlatform) then
        local host = 'localhost' -- please change localhost to your PC's IP for on-device debugging
        -- require('mobdebug').start(host)
    end

    -- run
    local createLoginScene = require('LoginScene')
    local sceneGame = createLoginScene()
    cc.Director:getInstance():runWithScene(sceneGame)
end

xpcall(main, __G__TRACKBACK__)

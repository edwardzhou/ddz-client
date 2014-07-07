require "Cocos2d"
require 'framework.functions'
require 'framework.debug'
require 'GlobalFunctions'
require 'consts'
require 'GlobalSettings'
require 'DebugSetting'

cc.KeyCode.KEY_BACKSPACE    = 0x0006
cc.KeyCode.KEY_MENU         = 0x000F

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
    
    math.randomseed(os.time())

    --support debug
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or 
       (cc.PLATFORM_OS_ANDROID == targetPlatform) or (cc.PLATFORM_OS_WINDOWS == targetPlatform) or
       (cc.PLATFORM_OS_MAC == targetPlatform) then
        local host = '192.168.0.90' -- please change localhost to your PC's IP for on-device debugging
        --require('src.mobdebug').start(host)
    end

    ddz.GlobalSettings.handsetInfo = ddz.getHandsetInfo()
    ddz.GlobalSettings.sdcardPath = ddz.getSDCardPath()
    ddz.GlobalSettings.ddzSDPath = ddz.mkdir('fungame/DDZ')
    ddz.GlobalSettings.appPrivatePath = cc.FileUtils:getInstance():getWritablePath()
    ddz.GlobalSettings.session = ddz.loadSessionInfo() or {}
    
    dump(ddz.GlobalSettings, 'GlobalSettings')

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local function onNetworkChanged(event)
        print('[onNetworkChanged] ', event:getEventName())
    end

    local listener1 = cc.EventListenerCustom:create("on_network_change_available",onNetworkChanged)
    eventDispatcher:addEventListenerWithFixedPriority(listener1, 1)

    local listener2 = cc.EventListenerCustom:create("on_network_change_disable",onNetworkChanged)
    eventDispatcher:addEventListenerWithFixedPriority(listener2, 2)

    local function onEventComeToForeground()
        print("[onEventComeToForeground] ...")
    end
    local function onEventComeToBackground()
        print("[onEventComeToBackground] ...")
    end

    local listener3 = cc.EventListenerCustom:create("event_come_to_background", onEventComeToBackground)
    eventDispatcher:addEventListenerWithFixedPriority(listener3, 3)

    local listener4 = cc.EventListenerCustom:create("event_come_to_foreground", onEventComeToForeground)
    eventDispatcher:addEventListenerWithFixedPriority(listener4, 4)

    -- run
    local createLoginScene = require('landing.LandingScene')
    local sceneGame = createLoginScene()
    cc.Director:getInstance():runWithScene(sceneGame)
end

xpcall(main, __G__TRACKBACK__)

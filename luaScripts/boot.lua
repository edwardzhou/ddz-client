require "Cocos2d"
require "Cocos2dConstants"
require 'framework.functions'
require 'framework.debug'
require 'GlobalFunctions'
require 'GuiConstants'

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

    local fileUtils = cc.FileUtils:getInstance()
    local searchPaths = fileUtils:getSearchPaths()
    local sdpath = ddz.getSDCardPath()
    sdpath = sdpath .. '/fungame/DDZ'
    table.insert(searchPaths, 1, fileUtils:getWritablePath())
    table.insert(searchPaths, 1, sdpath)
    table.insert(searchPaths, 1, sdpath .. '/Resources')
    table.insert(searchPaths, 1, sdpath .. '/luaScripts')
    --fileUtils:addSearchPath()
    
    fileUtils:setSearchPaths(searchPaths)
    fileUtils:addSearchPath('src')
    --fileUtils:addSearchPath('cocos2d')

    local resPaths = fileUtils:getSearchResolutionsOrder()
    dump(resPaths, 'Search Resolutions Order')

    require('startup')();

 end

xpcall(main, __G__TRACKBACK__)

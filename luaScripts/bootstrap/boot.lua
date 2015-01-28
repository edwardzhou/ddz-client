require 'framework.functions'
require 'framework.debug'
require 'GlobalFunctions'

local debug_file = io.open('/sdcard/fungame/ddz_debug.txt')
if debug_file ~= nil then
    print = release_print
    debug_file:close()
end
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
    local privatePath = fileUtils:getWritablePath()
    sdpath = sdpath .. '/fungame/DDZ'
    ddz.mkdir(sdpath)
    -- table.insert(searchPaths, 1, sdpath)
    -- table.insert(searchPaths, 1, sdpath .. '/Resources')
    -- table.insert(searchPaths, 1, sdpath .. '/Resources/NewUI')
    -- table.insert(searchPaths, 1, sdpath .. '/luaScripts')
    -- table.insert(searchPaths, 'NewUI')
    -- --fileUtils:addSearchPath()
    
    -- fileUtils:setSearchPaths(searchPaths)
    -- fileUtils:addSearchPath(privatePath, true)
    -- fileUtils:addSearchPath(privatePath .. 'res/NewUI', true)
    -- fileUtils:addSearchPath(privatePath .. 'res', true)
    -- fileUtils:addSearchPath(privatePath .. 'prog', true)
    fileUtils:addSearchPath(sdpath .. 'Resources')
    fileUtils:addSearchPath(sdpath .. 'Resources/NewUI')
    fileUtils:addSearchPath(sdpath .. 'luaScripts')
    fileUtils:addSearchPath('NewUI')
    
    searchPaths = fileUtils:getSearchPaths()
    dump(searchPaths, '=====searchPaths=========')
    --fileUtils:addSearchPath('src')
    --fileUtils:addSearchPath('cocos2d')

    local resPaths = fileUtils:getSearchResolutionsOrder()
    dump(resPaths, 'Search Resolutions Order')
    require('startup')();

end

xpcall(main, __G__TRACKBACK__)

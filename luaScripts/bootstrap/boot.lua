require 'framework.functions'
require 'framework.debug'
require 'GlobalFunctions'
require 'resver'
require 'appurl'
require 'appAffiliate'

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


local function checkSDCardConf()
	if not debug_file then print('debug file not exist') return end
	local ret, serverInfo = pcall(function() return require "ddz_server" end)
	if not ret then print('ddz_server not exist') return end
	-- require 'GlobalSettings'
	-- if serverInfo.host then ddz.GlobalSettings.servers.host = serverInfo.host end
	-- if serverInfo.port then ddz.GlobalSettings.servers.port = serverInfo.port end
	-- dump(ddz.GlobalSettings.servers, 'settings.servers')
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
    fileUtils:addSearchPath(sdpath .. '/fungame')
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

    checkSDCardConf()

    require('startup')();

end

xpcall(main, __G__TRACKBACK__)

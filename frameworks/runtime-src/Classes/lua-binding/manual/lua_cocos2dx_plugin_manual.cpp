#include "lua_cocos2dx_plugin_manual.hpp"
#include "PluginManager.h"
#include "PluginProtocol.h"
#include "ProtocolAnalytics.h"
#include "PluginParam.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"

int tolua_Cocos2d_plugin_PluginProtocol_callFuncWithParam00(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::plugin::PluginProtocol* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"plugin.PluginProtocol",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::plugin::PluginProtocol*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'tolua_Cocos2d_plugin_PluginProtocol_callFuncWithParam00'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        CCLOG("%s has wrong number of arguments: %d, was expecting at least %d \n", "callFuncWithParam",argc, 1);
        return 0;
    }

    std::std::vector<cocos2d::plugin::PluginParam*> params;
    for (int i=0; i<argc; i++) {
      if (lua_istable(tolua_S, i+2) > 0) {
        // table
      }
    }

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_Cocos2d_plugin_PluginProtocol_callFuncWithParam00'.",&tolua_err);
#endif

    return 0;
}

static void extendPluginProtocol(lua_State* L)
{
    lua_pushstring(L, "plugin.PluginProtocol");
    lua_rawget(L, LUA_REGISTRYINDEX);
    if (lua_istable(L,-1))
    {
        tolua_function(L, "callFuncWithParam", tolua_Cocos2d_plugin_PluginProtocol_callFuncWithParam00);
    }
    lua_pop(L, 1);
}

int register_all_cocos2dx_plugin_manual(lua_State* L)
{
    if (nullptr == L)
        return 0;

    extendPluginProtocol(L);
    
    return 0;
}

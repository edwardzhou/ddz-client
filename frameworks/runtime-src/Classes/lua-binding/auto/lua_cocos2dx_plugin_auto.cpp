#include "lua_cocos2dx_plugin_auto.hpp"
#include "PluginManager.h"
#include "PluginProtocol.h"
#include "ProtocolAnalytics.h"
#include "PluginParam.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"



int lua_cocos2dx_plugin_PluginParam_getMapValue(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::plugin::PluginParam* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"plugin.PluginParam",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::plugin::PluginParam*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_PluginParam_getMapValue'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        std::map<std::basic_string<char>, cocos2d::plugin::PluginParam *, std::less<std::basic_string<char> >, std::allocator<std::pair<const std::basic_string<char>, cocos2d::plugin::PluginParam *> > > ret = cobj->getMapValue();
        object_to_luaval<std::map<std::basic_string<char>, cocos2d::plugin::PluginParam , std::less<std::basic_string<char> >, std::allocator<std::pair<std::basic_string<char>, cocos2d::plugin::PluginParam > > >>(tolua_S, "std::map<std::basic_string<char>, plugin.PluginParam , std::less<std::basic_string<char> >, std::allocator<std::pair<std::basic_string<char>, plugin.PluginParam > > >",(std::map<std::basic_string<char>, cocos2d::plugin::PluginParam *, std::less<std::basic_string<char> >, std::allocator<std::pair<std::basic_string<char>, cocos2d::plugin::PluginParam *> > >)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getMapValue",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_PluginParam_getMapValue'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_plugin_PluginParam_getBoolValue(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::plugin::PluginParam* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"plugin.PluginParam",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::plugin::PluginParam*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_PluginParam_getBoolValue'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        bool ret = cobj->getBoolValue();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getBoolValue",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_PluginParam_getBoolValue'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_plugin_PluginParam_getIntValue(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::plugin::PluginParam* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"plugin.PluginParam",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::plugin::PluginParam*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_PluginParam_getIntValue'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        int ret = cobj->getIntValue();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getIntValue",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_PluginParam_getIntValue'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_plugin_PluginParam_getFloatValue(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::plugin::PluginParam* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"plugin.PluginParam",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::plugin::PluginParam*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_PluginParam_getFloatValue'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        double ret = cobj->getFloatValue();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getFloatValue",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_PluginParam_getFloatValue'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_plugin_PluginParam_getStringValue(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::plugin::PluginParam* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"plugin.PluginParam",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::plugin::PluginParam*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_PluginParam_getStringValue'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        const char* ret = cobj->getStringValue();
        tolua_pushstring(tolua_S,(const char*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getStringValue",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_PluginParam_getStringValue'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_plugin_PluginParam_getStrMapValue(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::plugin::PluginParam* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"plugin.PluginParam",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::plugin::PluginParam*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_PluginParam_getStrMapValue'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        std::map<std::basic_string<char>, std::basic_string<char>, std::less<std::basic_string<char> >, std::allocator<std::pair<const std::basic_string<char>, std::basic_string<char> > > > ret = cobj->getStrMapValue();
        object_to_luaval<std::map<std::basic_string<char>, std::basic_string<char>, std::less<std::basic_string<char> >, std::allocator<std::pair<std::basic_string<char>, std::basic_string<char> > > >>(tolua_S, "std::map<std::basic_string<char>, std::basic_string<char>, std::less<std::basic_string<char> >, std::allocator<std::pair<const std::basic_string<char>, std::basic_string<char> > > >",(std::map<std::basic_string<char>, std::basic_string<char>, std::less<std::basic_string<char> >, std::allocator<std::pair<std::basic_string<char>, std::basic_string<char> > > >)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getStrMapValue",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_PluginParam_getStrMapValue'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_plugin_PluginParam_getCurrentType(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::plugin::PluginParam* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"plugin.PluginParam",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::plugin::PluginParam*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_PluginParam_getCurrentType'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        int ret = (int)cobj->getCurrentType();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getCurrentType",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_PluginParam_getCurrentType'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_plugin_PluginParam_constructor(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::plugin::PluginParam* cobj = nullptr;
    bool ok  = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

    argc = lua_gettop(tolua_S)-1;
    do{
        if (argc == 1) {
            int arg0;
            ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0);

            if (!ok) { break; }
            cobj = new cocos2d::plugin::PluginParam(arg0);
            tolua_pushusertype(tolua_S,(void*)cobj,"plugin.PluginParam");
            tolua_register_gc(tolua_S,lua_gettop(tolua_S));
            return 1;
        }
    }while(0);
    ok  = true;
    do{
        if (argc == 0) {
            cobj = new cocos2d::plugin::PluginParam();
            tolua_pushusertype(tolua_S,(void*)cobj,"plugin.PluginParam");
            tolua_register_gc(tolua_S,lua_gettop(tolua_S));
            return 1;
        }
    }while(0);
    ok  = true;
    do{
        if (argc == 1) {
            double arg0;
            ok &= luaval_to_number(tolua_S, 2,&arg0);

            if (!ok) { break; }
            cobj = new cocos2d::plugin::PluginParam(arg0);
            tolua_pushusertype(tolua_S,(void*)cobj,"plugin.PluginParam");
            tolua_register_gc(tolua_S,lua_gettop(tolua_S));
            return 1;
        }
    }while(0);
    ok  = true;
    do{
        if (argc == 1) {
            double arg0;
            ok &= luaval_to_number(tolua_S, 2,&arg0);

            if (!ok) { break; }
            cobj = new cocos2d::plugin::PluginParam(arg0);
            tolua_pushusertype(tolua_S,(void*)cobj,"plugin.PluginParam");
            tolua_register_gc(tolua_S,lua_gettop(tolua_S));
            return 1;
        }
    }while(0);
    ok  = true;
    do{
        if (argc == 1) {
            bool arg0;
            ok &= luaval_to_boolean(tolua_S, 2,&arg0);

            if (!ok) { break; }
            cobj = new cocos2d::plugin::PluginParam(arg0);
            tolua_pushusertype(tolua_S,(void*)cobj,"plugin.PluginParam");
            tolua_register_gc(tolua_S,lua_gettop(tolua_S));
            return 1;
        }
    }while(0);
    ok  = true;
    do{
        if (argc == 1) {
            const char* arg0;
            std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();

            if (!ok) { break; }
            cobj = new cocos2d::plugin::PluginParam(arg0);
            tolua_pushusertype(tolua_S,(void*)cobj,"plugin.PluginParam");
            tolua_register_gc(tolua_S,lua_gettop(tolua_S));
            return 1;
        }
    }while(0);
    ok  = true;
    do{
        if (argc == 1) {
            std::map<std::basic_string<char>, std::basic_string<char>, std::less<std::basic_string<char> >, std::allocator<std::pair<const std::basic_string<char>, std::basic_string<char> > > > arg0;
            ok &= luaval_to_object<std::map<std::basic_string<char>, std::basic_string<char>, std::less<std::basic_string<char> >, std::allocator<std::pair<const std::basic_string<char>, std::basic_string<char> > > >>(tolua_S, 2, "std::map<std::basic_string<char>, std::basic_string<char>, std::less<std::basic_string<char> >, std::allocator<std::pair<const std::basic_string<char>, std::basic_string<char> > > >",&arg0);

            if (!ok) { break; }
            cobj = new cocos2d::plugin::PluginParam(arg0);
            tolua_pushusertype(tolua_S,(void*)cobj,"plugin.PluginParam");
            tolua_register_gc(tolua_S,lua_gettop(tolua_S));
            return 1;
        }
    }while(0);
    ok  = true;
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "PluginParam",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_PluginParam_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_cocos2dx_plugin_PluginParam_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (PluginParam)");
    return 0;
}

int lua_register_cocos2dx_plugin_PluginParam(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"plugin.PluginParam");
    tolua_cclass(tolua_S,"PluginParam","plugin.PluginParam","",nullptr);

    tolua_beginmodule(tolua_S,"PluginParam");
        tolua_function(tolua_S,"getMapValue",lua_cocos2dx_plugin_PluginParam_getMapValue);
        tolua_function(tolua_S,"getBoolValue",lua_cocos2dx_plugin_PluginParam_getBoolValue);
        tolua_function(tolua_S,"getIntValue",lua_cocos2dx_plugin_PluginParam_getIntValue);
        tolua_function(tolua_S,"getFloatValue",lua_cocos2dx_plugin_PluginParam_getFloatValue);
        tolua_function(tolua_S,"getStringValue",lua_cocos2dx_plugin_PluginParam_getStringValue);
        tolua_function(tolua_S,"getStrMapValue",lua_cocos2dx_plugin_PluginParam_getStrMapValue);
        tolua_function(tolua_S,"getCurrentType",lua_cocos2dx_plugin_PluginParam_getCurrentType);
        tolua_function(tolua_S,"new",lua_cocos2dx_plugin_PluginParam_constructor);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(cocos2d::plugin::PluginParam).name();
    g_luaType[typeName] = "plugin.PluginParam";
    g_typeCast["PluginParam"] = "plugin.PluginParam";
    return 1;
}

int lua_cocos2dx_plugin_PluginProtocol_getPluginName(lua_State* tolua_S)
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
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_PluginProtocol_getPluginName'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        const char* ret = cobj->getPluginName();
        tolua_pushstring(tolua_S,(const char*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getPluginName",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_PluginProtocol_getPluginName'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_plugin_PluginProtocol_getPluginVersion(lua_State* tolua_S)
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
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_PluginProtocol_getPluginVersion'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        std::string ret = cobj->getPluginVersion();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getPluginVersion",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_PluginProtocol_getPluginVersion'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_plugin_PluginProtocol_getSDKVersion(lua_State* tolua_S)
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
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_PluginProtocol_getSDKVersion'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        std::string ret = cobj->getSDKVersion();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getSDKVersion",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_PluginProtocol_getSDKVersion'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_plugin_PluginProtocol_setDebugMode(lua_State* tolua_S)
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
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_PluginProtocol_setDebugMode'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        cobj->setDebugMode(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setDebugMode",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_PluginProtocol_setDebugMode'.",&tolua_err);
#endif

    return 0;
}
static int lua_cocos2dx_plugin_PluginProtocol_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (PluginProtocol)");
    return 0;
}

int lua_register_cocos2dx_plugin_PluginProtocol(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"plugin.PluginProtocol");
    tolua_cclass(tolua_S,"PluginProtocol","plugin.PluginProtocol","",nullptr);

    tolua_beginmodule(tolua_S,"PluginProtocol");
        tolua_function(tolua_S,"getPluginName",lua_cocos2dx_plugin_PluginProtocol_getPluginName);
        tolua_function(tolua_S,"getPluginVersion",lua_cocos2dx_plugin_PluginProtocol_getPluginVersion);
        tolua_function(tolua_S,"getSDKVersion",lua_cocos2dx_plugin_PluginProtocol_getSDKVersion);
        tolua_function(tolua_S,"setDebugMode",lua_cocos2dx_plugin_PluginProtocol_setDebugMode);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(cocos2d::plugin::PluginProtocol).name();
    g_luaType[typeName] = "plugin.PluginProtocol";
    g_typeCast["PluginProtocol"] = "plugin.PluginProtocol";
    return 1;
}

int lua_cocos2dx_plugin_PluginManager_unloadPlugin(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::plugin::PluginManager* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"plugin.PluginManager",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::plugin::PluginManager*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_PluginManager_unloadPlugin'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        const char* arg0;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();
        if(!ok)
            return 0;
        cobj->unloadPlugin(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "unloadPlugin",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_PluginManager_unloadPlugin'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_plugin_PluginManager_loadPlugin(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::plugin::PluginManager* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"plugin.PluginManager",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::plugin::PluginManager*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_PluginManager_loadPlugin'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        const char* arg0;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();
        if(!ok)
            return 0;
        cocos2d::plugin::PluginProtocol* ret = cobj->loadPlugin(arg0);
        object_to_luaval<cocos2d::plugin::PluginProtocol>(tolua_S, "plugin.PluginProtocol",(cocos2d::plugin::PluginProtocol*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "loadPlugin",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_PluginManager_loadPlugin'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_plugin_PluginManager_end(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"plugin.PluginManager",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
            return 0;
        cocos2d::plugin::PluginManager::end();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "end",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_PluginManager_end'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_plugin_PluginManager_getInstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"plugin.PluginManager",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
            return 0;
        cocos2d::plugin::PluginManager* ret = cocos2d::plugin::PluginManager::getInstance();
        object_to_luaval<cocos2d::plugin::PluginManager>(tolua_S, "plugin.PluginManager",(cocos2d::plugin::PluginManager*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "getInstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_PluginManager_getInstance'.",&tolua_err);
#endif
    return 0;
}
static int lua_cocos2dx_plugin_PluginManager_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (PluginManager)");
    return 0;
}

int lua_register_cocos2dx_plugin_PluginManager(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"plugin.PluginManager");
    tolua_cclass(tolua_S,"PluginManager","plugin.PluginManager","",nullptr);

    tolua_beginmodule(tolua_S,"PluginManager");
        tolua_function(tolua_S,"unloadPlugin",lua_cocos2dx_plugin_PluginManager_unloadPlugin);
        tolua_function(tolua_S,"loadPlugin",lua_cocos2dx_plugin_PluginManager_loadPlugin);
        tolua_function(tolua_S,"endToLua", lua_cocos2dx_plugin_PluginManager_end);
        tolua_function(tolua_S,"getInstance", lua_cocos2dx_plugin_PluginManager_getInstance);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(cocos2d::plugin::PluginManager).name();
    g_luaType[typeName] = "plugin.PluginManager";
    g_typeCast["PluginManager"] = "plugin.PluginManager";
    return 1;
}

int lua_cocos2dx_plugin_ProtocolAnalytics_logTimedEventBegin(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::plugin::ProtocolAnalytics* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"plugin.ProtocolAnalytics",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::plugin::ProtocolAnalytics*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_ProtocolAnalytics_logTimedEventBegin'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        const char* arg0;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();
        if(!ok)
            return 0;
        cobj->logTimedEventBegin(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "logTimedEventBegin",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_ProtocolAnalytics_logTimedEventBegin'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_plugin_ProtocolAnalytics_logError(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::plugin::ProtocolAnalytics* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"plugin.ProtocolAnalytics",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::plugin::ProtocolAnalytics*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_ProtocolAnalytics_logError'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        const char* arg0;
        const char* arg1;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();

        std::string arg1_tmp; ok &= luaval_to_std_string(tolua_S, 3, &arg1_tmp); arg1 = arg1_tmp.c_str();
        if(!ok)
            return 0;
        cobj->logError(arg0, arg1);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "logError",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_ProtocolAnalytics_logError'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_plugin_ProtocolAnalytics_setCaptureUncaughtException(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::plugin::ProtocolAnalytics* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"plugin.ProtocolAnalytics",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::plugin::ProtocolAnalytics*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_ProtocolAnalytics_setCaptureUncaughtException'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        cobj->setCaptureUncaughtException(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setCaptureUncaughtException",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_ProtocolAnalytics_setCaptureUncaughtException'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_plugin_ProtocolAnalytics_setSessionContinueMillis(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::plugin::ProtocolAnalytics* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"plugin.ProtocolAnalytics",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::plugin::ProtocolAnalytics*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_ProtocolAnalytics_setSessionContinueMillis'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        long arg0;

        ok &= luaval_to_long(tolua_S, 2, &arg0);
        if(!ok)
            return 0;
        cobj->setSessionContinueMillis(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setSessionContinueMillis",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_ProtocolAnalytics_setSessionContinueMillis'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_plugin_ProtocolAnalytics_logEvent(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::plugin::ProtocolAnalytics* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"plugin.ProtocolAnalytics",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::plugin::ProtocolAnalytics*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_ProtocolAnalytics_logEvent'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        const char* arg0;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();
        if(!ok)
            return 0;
        cobj->logEvent(arg0);
        return 0;
    }
    if (argc == 2) 
    {
        const char* arg0;
        std::map<std::basic_string<char>, std::basic_string<char>, std::less<std::basic_string<char> >, std::allocator<std::pair<const std::basic_string<char>, std::basic_string<char> > > >* arg1;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();

        ok &= luaval_to_object<std::map<std::basic_string<char>, std::basic_string<char>, std::less<std::basic_string<char> >, std::allocator<std::pair<const std::basic_string<char>, std::basic_string<char> > > >>(tolua_S, 3, "std::map<std::basic_string<char>, std::basic_string<char>, std::less<std::basic_string<char> >, std::allocator<std::pair<const std::basic_string<char>, std::basic_string<char> > > >*",&arg1);
        if(!ok)
            return 0;
        cobj->logEvent(arg0, arg1);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "logEvent",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_ProtocolAnalytics_logEvent'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_plugin_ProtocolAnalytics_startSession(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::plugin::ProtocolAnalytics* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"plugin.ProtocolAnalytics",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::plugin::ProtocolAnalytics*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_ProtocolAnalytics_startSession'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        const char* arg0;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();
        if(!ok)
            return 0;
        cobj->startSession(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "startSession",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_ProtocolAnalytics_startSession'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_plugin_ProtocolAnalytics_stopSession(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::plugin::ProtocolAnalytics* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"plugin.ProtocolAnalytics",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::plugin::ProtocolAnalytics*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_ProtocolAnalytics_stopSession'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->stopSession();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "stopSession",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_ProtocolAnalytics_stopSession'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_plugin_ProtocolAnalytics_logTimedEventEnd(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::plugin::ProtocolAnalytics* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"plugin.ProtocolAnalytics",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::plugin::ProtocolAnalytics*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_plugin_ProtocolAnalytics_logTimedEventEnd'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        const char* arg0;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();
        if(!ok)
            return 0;
        cobj->logTimedEventEnd(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "logTimedEventEnd",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_ProtocolAnalytics_logTimedEventEnd'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_plugin_ProtocolAnalytics_constructor(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::plugin::ProtocolAnalytics* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj = new cocos2d::plugin::ProtocolAnalytics();
        tolua_pushusertype(tolua_S,(void*)cobj,"plugin.ProtocolAnalytics");
        tolua_register_gc(tolua_S,lua_gettop(tolua_S));
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "ProtocolAnalytics",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_plugin_ProtocolAnalytics_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_cocos2dx_plugin_ProtocolAnalytics_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (ProtocolAnalytics)");
    return 0;
}

int lua_register_cocos2dx_plugin_ProtocolAnalytics(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"plugin.ProtocolAnalytics");
    tolua_cclass(tolua_S,"ProtocolAnalytics","plugin.ProtocolAnalytics","plugin.PluginProtocol",nullptr);

    tolua_beginmodule(tolua_S,"ProtocolAnalytics");
        tolua_function(tolua_S,"logTimedEventBegin",lua_cocos2dx_plugin_ProtocolAnalytics_logTimedEventBegin);
        tolua_function(tolua_S,"logError",lua_cocos2dx_plugin_ProtocolAnalytics_logError);
        tolua_function(tolua_S,"setCaptureUncaughtException",lua_cocos2dx_plugin_ProtocolAnalytics_setCaptureUncaughtException);
        tolua_function(tolua_S,"setSessionContinueMillis",lua_cocos2dx_plugin_ProtocolAnalytics_setSessionContinueMillis);
        tolua_function(tolua_S,"logEvent",lua_cocos2dx_plugin_ProtocolAnalytics_logEvent);
        tolua_function(tolua_S,"startSession",lua_cocos2dx_plugin_ProtocolAnalytics_startSession);
        tolua_function(tolua_S,"stopSession",lua_cocos2dx_plugin_ProtocolAnalytics_stopSession);
        tolua_function(tolua_S,"logTimedEventEnd",lua_cocos2dx_plugin_ProtocolAnalytics_logTimedEventEnd);
        tolua_function(tolua_S,"new",lua_cocos2dx_plugin_ProtocolAnalytics_constructor);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(cocos2d::plugin::ProtocolAnalytics).name();
    g_luaType[typeName] = "plugin.ProtocolAnalytics";
    g_typeCast["ProtocolAnalytics"] = "plugin.ProtocolAnalytics";
    return 1;
}
TOLUA_API int register_all_cocos2dx_plugin(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	lua_getglobal(tolua_S, "_G");
	tolua_module(tolua_S,"plugin",0);
	tolua_beginmodule(tolua_S,"plugin");

	lua_register_cocos2dx_plugin_PluginProtocol(tolua_S);
	lua_register_cocos2dx_plugin_PluginParam(tolua_S);
	lua_register_cocos2dx_plugin_PluginManager(tolua_S);
	lua_register_cocos2dx_plugin_ProtocolAnalytics(tolua_S);

	tolua_endmodule(tolua_S);
    lua_pop(tolua_S, 1);
	return 1;
}


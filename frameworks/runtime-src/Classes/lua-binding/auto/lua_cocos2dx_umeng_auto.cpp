#include "lua_cocos2dx_umeng_auto.hpp"
#include "MobClickCpp.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"



int lua_cocos2dx_umeng_MobClickCpp_updateOnlineConfig(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"umeng.MobClickCpp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
            return 0;
        umeng::MobClickCpp::updateOnlineConfig();
        return 0;
    }
    if (argc == 1)
    {
        umeng::MobClickOnlineConfigUpdateDelegate* arg0;
        ok &= luaval_to_object<umeng::MobClickOnlineConfigUpdateDelegate>(tolua_S, 2, "umeng.MobClickOnlineConfigUpdateDelegate",&arg0);
        if(!ok)
            return 0;
        umeng::MobClickCpp::updateOnlineConfig(arg0);
        return 0;
    }
    if (argc == 2)
    {
        umeng::MobClickOnlineConfigUpdateDelegate* arg0;
        void* arg1;
        ok &= luaval_to_object<umeng::MobClickOnlineConfigUpdateDelegate>(tolua_S, 2, "umeng.MobClickOnlineConfigUpdateDelegate",&arg0);
        #pragma warning NO CONVERSION TO NATIVE FOR void*
		ok = false;
        if(!ok)
            return 0;
        umeng::MobClickCpp::updateOnlineConfig(arg0, arg1);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "umeng.MobClickCpp:updateOnlineConfig",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_updateOnlineConfig'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_umeng_MobClickCpp_setUserLevel(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"umeng.MobClickCpp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        const char* arg0;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "umeng.MobClickCpp:setUserLevel"); arg0 = arg0_tmp.c_str();
        if(!ok)
            return 0;
        umeng::MobClickCpp::setUserLevel(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "umeng.MobClickCpp:setUserLevel",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_setUserLevel'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_umeng_MobClickCpp_use(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"umeng.MobClickCpp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 3)
    {
        const char* arg0;
        int arg1;
        double arg2;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "umeng.MobClickCpp:use"); arg0 = arg0_tmp.c_str();
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "umeng.MobClickCpp:use");
        ok &= luaval_to_number(tolua_S, 4,&arg2, "umeng.MobClickCpp:use");
        if(!ok)
            return 0;
        umeng::MobClickCpp::use(arg0, arg1, arg2);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "umeng.MobClickCpp:use",argc, 3);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_use'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_umeng_MobClickCpp_setSessionIdleLimit(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"umeng.MobClickCpp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        int arg0;
        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "umeng.MobClickCpp:setSessionIdleLimit");
        if(!ok)
            return 0;
        umeng::MobClickCpp::setSessionIdleLimit(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "umeng.MobClickCpp:setSessionIdleLimit",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_setSessionIdleLimit'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_umeng_MobClickCpp_getConfigParam(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"umeng.MobClickCpp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        const char* arg0;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "umeng.MobClickCpp:getConfigParam"); arg0 = arg0_tmp.c_str();
        if(!ok)
            return 0;
        std::string ret = umeng::MobClickCpp::getConfigParam(arg0);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "umeng.MobClickCpp:getConfigParam",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_getConfigParam'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_umeng_MobClickCpp_pay(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"umeng.MobClickCpp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S)-1;

    do 
    {
        if (argc == 5)
        {
            double arg0;
            ok &= luaval_to_number(tolua_S, 2,&arg0, "umeng.MobClickCpp:pay");
            if (!ok) { break; }
            int arg1;
            ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "umeng.MobClickCpp:pay");
            if (!ok) { break; }
            const char* arg2;
            std::string arg2_tmp; ok &= luaval_to_std_string(tolua_S, 4, &arg2_tmp, "umeng.MobClickCpp:pay"); arg2 = arg2_tmp.c_str();
            if (!ok) { break; }
            int arg3;
            ok &= luaval_to_int32(tolua_S, 5,(int *)&arg3, "umeng.MobClickCpp:pay");
            if (!ok) { break; }
            double arg4;
            ok &= luaval_to_number(tolua_S, 6,&arg4, "umeng.MobClickCpp:pay");
            if (!ok) { break; }
            umeng::MobClickCpp::pay(arg0, arg1, arg2, arg3, arg4);
            return 0;
        }
    } while (0);
    ok  = true;
    do 
    {
        if (argc == 3)
        {
            double arg0;
            ok &= luaval_to_number(tolua_S, 2,&arg0, "umeng.MobClickCpp:pay");
            if (!ok) { break; }
            int arg1;
            ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "umeng.MobClickCpp:pay");
            if (!ok) { break; }
            double arg2;
            ok &= luaval_to_number(tolua_S, 4,&arg2, "umeng.MobClickCpp:pay");
            if (!ok) { break; }
            umeng::MobClickCpp::pay(arg0, arg1, arg2);
            return 0;
        }
    } while (0);
    ok  = true;
    CCLOG("%s has wrong number of arguments: %d, was expecting %d", "umeng.MobClickCpp:pay",argc, 3);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_pay'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_umeng_MobClickCpp_beginLogPageView(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"umeng.MobClickCpp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        const char* arg0;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "umeng.MobClickCpp:beginLogPageView"); arg0 = arg0_tmp.c_str();
        if(!ok)
            return 0;
        umeng::MobClickCpp::beginLogPageView(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "umeng.MobClickCpp:beginLogPageView",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_beginLogPageView'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_umeng_MobClickCpp_endLogPageView(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"umeng.MobClickCpp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        const char* arg0;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "umeng.MobClickCpp:endLogPageView"); arg0 = arg0_tmp.c_str();
        if(!ok)
            return 0;
        umeng::MobClickCpp::endLogPageView(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "umeng.MobClickCpp:endLogPageView",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_endLogPageView'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_umeng_MobClickCpp_setProxy(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"umeng.MobClickCpp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        const char* arg0;
        int arg1;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "umeng.MobClickCpp:setProxy"); arg0 = arg0_tmp.c_str();
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "umeng.MobClickCpp:setProxy");
        if(!ok)
            return 0;
        umeng::MobClickCpp::setProxy(arg0, arg1);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "umeng.MobClickCpp:setProxy",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_setProxy'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_umeng_MobClickCpp_buy(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"umeng.MobClickCpp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 3)
    {
        const char* arg0;
        int arg1;
        double arg2;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "umeng.MobClickCpp:buy"); arg0 = arg0_tmp.c_str();
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "umeng.MobClickCpp:buy");
        ok &= luaval_to_number(tolua_S, 4,&arg2, "umeng.MobClickCpp:buy");
        if(!ok)
            return 0;
        umeng::MobClickCpp::buy(arg0, arg1, arg2);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "umeng.MobClickCpp:buy",argc, 3);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_buy'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_umeng_MobClickCpp_failLevel(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"umeng.MobClickCpp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        const char* arg0;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "umeng.MobClickCpp:failLevel"); arg0 = arg0_tmp.c_str();
        if(!ok)
            return 0;
        umeng::MobClickCpp::failLevel(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "umeng.MobClickCpp:failLevel",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_failLevel'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_umeng_MobClickCpp_bonus(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"umeng.MobClickCpp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S)-1;

    do 
    {
        if (argc == 4)
        {
            const char* arg0;
            std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "umeng.MobClickCpp:bonus"); arg0 = arg0_tmp.c_str();
            if (!ok) { break; }
            int arg1;
            ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "umeng.MobClickCpp:bonus");
            if (!ok) { break; }
            double arg2;
            ok &= luaval_to_number(tolua_S, 4,&arg2, "umeng.MobClickCpp:bonus");
            if (!ok) { break; }
            int arg3;
            ok &= luaval_to_int32(tolua_S, 5,(int *)&arg3, "umeng.MobClickCpp:bonus");
            if (!ok) { break; }
            umeng::MobClickCpp::bonus(arg0, arg1, arg2, arg3);
            return 0;
        }
    } while (0);
    ok  = true;
    do 
    {
        if (argc == 2)
        {
            double arg0;
            ok &= luaval_to_number(tolua_S, 2,&arg0, "umeng.MobClickCpp:bonus");
            if (!ok) { break; }
            int arg1;
            ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "umeng.MobClickCpp:bonus");
            if (!ok) { break; }
            umeng::MobClickCpp::bonus(arg0, arg1);
            return 0;
        }
    } while (0);
    ok  = true;
    CCLOG("%s has wrong number of arguments: %d, was expecting %d", "umeng.MobClickCpp:bonus",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_bonus'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_umeng_MobClickCpp_end(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"umeng.MobClickCpp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
            return 0;
        umeng::MobClickCpp::end();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "umeng.MobClickCpp:end",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_end'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_umeng_MobClickCpp_setLogEnabled(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"umeng.MobClickCpp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        bool arg0;
        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "umeng.MobClickCpp:setLogEnabled");
        if(!ok)
            return 0;
        umeng::MobClickCpp::setLogEnabled(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "umeng.MobClickCpp:setLogEnabled",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_setLogEnabled'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_umeng_MobClickCpp_startLevel(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"umeng.MobClickCpp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        const char* arg0;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "umeng.MobClickCpp:startLevel"); arg0 = arg0_tmp.c_str();
        if(!ok)
            return 0;
        umeng::MobClickCpp::startLevel(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "umeng.MobClickCpp:startLevel",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_startLevel'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_umeng_MobClickCpp_applicationDidEnterBackground(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"umeng.MobClickCpp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
            return 0;
        umeng::MobClickCpp::applicationDidEnterBackground();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "umeng.MobClickCpp:applicationDidEnterBackground",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_applicationDidEnterBackground'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_umeng_MobClickCpp_applicationWillEnterForeground(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"umeng.MobClickCpp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
            return 0;
        umeng::MobClickCpp::applicationWillEnterForeground();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "umeng.MobClickCpp:applicationWillEnterForeground",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_applicationWillEnterForeground'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_umeng_MobClickCpp_startWithAppkey(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"umeng.MobClickCpp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        const char* arg0;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "umeng.MobClickCpp:startWithAppkey"); arg0 = arg0_tmp.c_str();
        if(!ok)
            return 0;
        umeng::MobClickCpp::startWithAppkey(arg0);
        return 0;
    }
    if (argc == 2)
    {
        const char* arg0;
        const char* arg1;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "umeng.MobClickCpp:startWithAppkey"); arg0 = arg0_tmp.c_str();
        std::string arg1_tmp; ok &= luaval_to_std_string(tolua_S, 3, &arg1_tmp, "umeng.MobClickCpp:startWithAppkey"); arg1 = arg1_tmp.c_str();
        if(!ok)
            return 0;
        umeng::MobClickCpp::startWithAppkey(arg0, arg1);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "umeng.MobClickCpp:startWithAppkey",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_startWithAppkey'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_umeng_MobClickCpp_setUserInfo(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"umeng.MobClickCpp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 4)
    {
        const char* arg0;
        umeng::MobClickCpp::Sex arg1;
        int arg2;
        const char* arg3;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "umeng.MobClickCpp:setUserInfo"); arg0 = arg0_tmp.c_str();
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "umeng.MobClickCpp:setUserInfo");
        ok &= luaval_to_int32(tolua_S, 4,(int *)&arg2, "umeng.MobClickCpp:setUserInfo");
        std::string arg3_tmp; ok &= luaval_to_std_string(tolua_S, 5, &arg3_tmp, "umeng.MobClickCpp:setUserInfo"); arg3 = arg3_tmp.c_str();
        if(!ok)
            return 0;
        umeng::MobClickCpp::setUserInfo(arg0, arg1, arg2, arg3);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "umeng.MobClickCpp:setUserInfo",argc, 4);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_setUserInfo'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_umeng_MobClickCpp_finishLevel(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"umeng.MobClickCpp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        const char* arg0;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "umeng.MobClickCpp:finishLevel"); arg0 = arg0_tmp.c_str();
        if(!ok)
            return 0;
        umeng::MobClickCpp::finishLevel(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "umeng.MobClickCpp:finishLevel",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_finishLevel'.",&tolua_err);
#endif
    return 0;
}
static int lua_cocos2dx_umeng_MobClickCpp_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (MobClickCpp)");
    return 0;
}

int lua_register_cocos2dx_umeng_MobClickCpp(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"umeng.MobClickCpp");
    tolua_cclass(tolua_S,"MobClickCpp","umeng.MobClickCpp","",nullptr);

    tolua_beginmodule(tolua_S,"MobClickCpp");
        tolua_function(tolua_S,"updateOnlineConfig", lua_cocos2dx_umeng_MobClickCpp_updateOnlineConfig);
        tolua_function(tolua_S,"setUserLevel", lua_cocos2dx_umeng_MobClickCpp_setUserLevel);
        tolua_function(tolua_S,"use", lua_cocos2dx_umeng_MobClickCpp_use);
        tolua_function(tolua_S,"setSessionIdleLimit", lua_cocos2dx_umeng_MobClickCpp_setSessionIdleLimit);
        tolua_function(tolua_S,"getConfigParam", lua_cocos2dx_umeng_MobClickCpp_getConfigParam);
        tolua_function(tolua_S,"pay", lua_cocos2dx_umeng_MobClickCpp_pay);
        tolua_function(tolua_S,"beginLogPageView", lua_cocos2dx_umeng_MobClickCpp_beginLogPageView);
        tolua_function(tolua_S,"endLogPageView", lua_cocos2dx_umeng_MobClickCpp_endLogPageView);
        tolua_function(tolua_S,"setProxy", lua_cocos2dx_umeng_MobClickCpp_setProxy);
        tolua_function(tolua_S,"buy", lua_cocos2dx_umeng_MobClickCpp_buy);
        tolua_function(tolua_S,"failLevel", lua_cocos2dx_umeng_MobClickCpp_failLevel);
        tolua_function(tolua_S,"bonus", lua_cocos2dx_umeng_MobClickCpp_bonus);
        tolua_function(tolua_S,"endToLua", lua_cocos2dx_umeng_MobClickCpp_end);
        tolua_function(tolua_S,"setLogEnabled", lua_cocos2dx_umeng_MobClickCpp_setLogEnabled);
        tolua_function(tolua_S,"startLevel", lua_cocos2dx_umeng_MobClickCpp_startLevel);
        tolua_function(tolua_S,"applicationDidEnterBackground", lua_cocos2dx_umeng_MobClickCpp_applicationDidEnterBackground);
        tolua_function(tolua_S,"applicationWillEnterForeground", lua_cocos2dx_umeng_MobClickCpp_applicationWillEnterForeground);
        tolua_function(tolua_S,"startWithAppkey", lua_cocos2dx_umeng_MobClickCpp_startWithAppkey);
        tolua_function(tolua_S,"setUserInfo", lua_cocos2dx_umeng_MobClickCpp_setUserInfo);
        tolua_function(tolua_S,"finishLevel", lua_cocos2dx_umeng_MobClickCpp_finishLevel);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(umeng::MobClickCpp).name();
    g_luaType[typeName] = "umeng.MobClickCpp";
    g_typeCast["MobClickCpp"] = "umeng.MobClickCpp";
    return 1;
}
TOLUA_API int register_all_cocos2dx_umeng(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,"umeng",0);
	tolua_beginmodule(tolua_S,"umeng");

	lua_register_cocos2dx_umeng_MobClickCpp(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}


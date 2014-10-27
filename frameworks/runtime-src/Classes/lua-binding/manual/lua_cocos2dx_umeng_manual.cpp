#include "lua_cocos2dx_umeng_manual.hpp"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"
#include "MobClickCpp.h"

using namespace std;

int lua_cocos2dx_umeng_MobClickCpp_event(lua_State* tolua_S)
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
      if (argc == 1)
      {
          const char* arg0;
          std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "umeng.MobClickCpp:event"); arg0 = arg0_tmp.c_str();
          if (!ok) { break; }
          umeng::MobClickCpp::event(arg0);
          return 0;
      }

      if (argc == 2 && tolua_iscppstring(tolua_S, 3, 0, &tolua_err))
      {
          const char* arg0;
          std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "umeng.MobClickCpp:event"); arg0 = arg0_tmp.c_str();
          if (!ok) { break; }
          const char* arg1;
          std::string arg1_tmp; ok &= luaval_to_std_string(tolua_S, 3, &arg1_tmp, "umeng.MobClickCpp:event"); arg1 = arg1_tmp.c_str();
          if (!ok) { break; }
          umeng::MobClickCpp::event(arg0, arg1);
          return 0;
      }

      if (argc == 2)
      {
          const char* arg0;
          std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "umeng.MobClickCpp:event"); arg0 = arg0_tmp.c_str();
          if (!ok) { break; }
          cocos2d::ValueMap arg1;
          ok &= luaval_to_ccvaluemap(tolua_S, 3, &arg1, "umeng.MobClickCpp:event");
          if (!ok) { break; }

          umeng::eventDict attrs;
          for(auto iter = arg1.cbegin(); iter != arg1.cend(); ++iter) {
            attrs.insert(attrs.end(), std::pair<std::string, std::string>(iter->first, iter->second.asString()));
            //CCLOG("[MobClickCpp::eventEx] attributes item: %s => %s", iter->first.c_str(), iter->second.asString().c_str());
          }

          umeng::MobClickCpp::event(arg0, &attrs);
          return 0;
      }

       if (argc == 3)
        {
            const char* arg0;
            std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "umeng.MobClickCpp:event"); arg0 = arg0_tmp.c_str();
            if (!ok) { break; }
            cocos2d::ValueMap arg1;
            ok &= luaval_to_ccvaluemap(tolua_S, 3, &arg1, "umeng.MobClickCpp:event");
            if (!ok) { break; }
            int arg2;
            ok &= luaval_to_int32(tolua_S, 4,(int *)&arg2, "umeng.MobClickCpp:event");
            if (!ok) { break; }
            umeng::eventDict attrs;
            for(auto iter = arg1.cbegin(); iter != arg1.cend(); ++iter) {
              attrs.insert(attrs.end(), std::pair<std::string, std::string>(iter->first, iter->second.asString()));
              //CCLOG("[MobClickCpp::eventEx] attributes item: %s => %s", iter->first.c_str(), iter->second.asString().c_str());
            }
            umeng::MobClickCpp::event(arg0, &attrs, arg2);
            return 0;
        }
    } while (0);

    ok  = true;
    CCLOG("%s has wrong number of arguments: %d, was expecting %d", "umeng.MobClickCpp:event",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_umeng_MobClickCpp_event'.",&tolua_err);
#endif
    return 0;
}



static void extendUmeng(lua_State* L)
{
    lua_pushstring(L, "umeng.MobClickCpp");
    lua_rawget(L, LUA_REGISTRYINDEX);
    if (lua_istable(L,-1))
    {
        tolua_function(L, "event", lua_cocos2dx_umeng_MobClickCpp_event);
    }
    lua_pop(L, 1);
}

int register_all_cocos2dx_umeng_manual(lua_State* L)
{
    if (nullptr == L)
        return 0;

    extendUmeng(L);
    
    return 0;
}

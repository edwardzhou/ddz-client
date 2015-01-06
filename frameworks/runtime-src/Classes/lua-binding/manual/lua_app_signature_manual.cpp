#include "tolua_fix.h"
#include "LuaBasicConversions.h"
#include "CCLuaStack.h"
#include "external/xxtea/xxtea.h"
extern "C" {
#include "lua.h"
#include "tolua++.h"
#include "lualib.h"
#include "lauxlib.h"
}
#include "lua_app_signature_manual.hpp"

#include "md5/MD5pp.h"
#include "base64/libbase64.h"

namespace AppSign{
 std::string _sign_subject;
 std::string _sign_subject_md5;
 unsigned char _sign_subject_md5_bin[16];
 std::string _sign_data;
 std::string _sign_data_md5;
 unsigned char _sign_data_md5_bin[16];
}


namespace {
    
int lua_app_sig(lua_State * L)
{
    int nargs = lua_gettop(L);

    if (nargs < 1) 
    {
        return 0;
    }

    std::string param = lua_tostring(L, 1);

    time_t rawtime;
    time (&rawtime);

    char* tm = ctime(&rawtime);
    char* tmMD5 = MD5String(tm);
    param = tmMD5;
    //free(tm);
    free(tmMD5);

    CCLOG("[lua_app_sig] param: %s, len: %d", param.c_str(), param.size());
    CCLOG("[lua_app_sig] AppSign::_sign_data_md5: %s, len: %d", AppSign::_sign_data_md5.c_str(), AppSign::_sign_data_md5.size());

    xxtea_long encryped_param_len = 0;
    xxtea_long decryped_param_len = 0;
    unsigned char* encryped_param = xxtea_encrypt((unsigned char*)param.c_str(), param.size(), 
        (unsigned char*) AppSign::_sign_data_md5.c_str(), AppSign::_sign_data_md5.size(), &encryped_param_len);
    std::string xxteaData = bin2hex(encryped_param, encryped_param_len);
    char base64_string[256];
    memset(base64_string, 0, sizeof(base64_string)/sizeof(char));
    int len = Base64encode(base64_string, (char*)encryped_param, encryped_param_len);
    base64_string[len] = '\0';
    CCLOG("[lua_app_sig] base64_string: %s, len: %d", base64_string, len);
    char *md5_string = MD5String((char*)base64_string);
    CCLOG("[lua_app_sig] data md5_string: %s", md5_string);
    std::string strData = md5_string;
    free(md5_string);
    tolua_pushcppstring(L, AppSign::_sign_subject_md5);
    tolua_pushcppstring(L, param);
    tolua_pushcppstring(L, strData);
     
    return 3;
}
}


TOLUA_API int register_all_app_signiture(lua_State* tolua_S)
{


    // Register our version of the global "print" function
    const luaL_reg global_functions [] = {
        {"___appsig", lua_app_sig},
        {nullptr, nullptr}
    };
    luaL_register(tolua_S, "_G", global_functions);

  return 1;
}


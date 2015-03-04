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

namespace AppInfo{
    std::string _app_pkg_name;
    std::string _app_pkg_version;
    int _app_pkg_version_code;
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
    CCLOG("[lua_app_sig] AppInfo::_sign_data_md5: %s, len: %d", AppInfo::_sign_data_md5.c_str(), AppInfo::_sign_data_md5.size());

    xxtea_long encryped_param_len = 0;
    xxtea_long decryped_param_len = 0;
    unsigned char* encryped_param = xxtea_encrypt((unsigned char*)param.c_str(), param.size(), 
        (unsigned char*) AppInfo::_sign_data_md5.c_str(), AppInfo::_sign_data_md5.size(), &encryped_param_len);
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
    tolua_pushcppstring(L, AppInfo::_sign_subject_md5);
    tolua_pushcppstring(L, param);
    tolua_pushcppstring(L, strData);
     
    return 3;
}

int lua_app_xxx(lua_State * L)
{
    int nargs = lua_gettop(L);

    if (nargs < 1) 
    {
        return 0;
    }

    std::string param = lua_tostring(L, 1);
    std::string key = AppInfo::_sign_data_md5;
    if (nargs > 1)
    {
        key = lua_tostring(L, 2);
    }

    CCLOG("[lua_app_xxx] param: %s, len: %d", param.c_str(), param.size());
    CCLOG("[lua_app_xxx] key: %s, len: %d", key.c_str(), key.size());

    xxtea_long encryped_param_len = 0;
    xxtea_long decryped_param_len = 0;
    unsigned char* encryped_param = xxtea_encrypt((unsigned char*)param.c_str(), param.size(), 
        (unsigned char*) key.c_str(), key.size(), &encryped_param_len);
    std::string xxteaData = param;
    char* base64_string = NULL;

    //memset(base64_string, 0, sizeof(base64_string)/sizeof(char));
    //int len = Base64encode(base64_string, (char*)encryped_param, encryped_param_len);
    int len = Base64encode_len(encryped_param_len);
    base64_string = (char*) malloc(sizeof(char) * len);
    memset(base64_string, 0, sizeof(char) * len);
    len = Base64encode(base64_string, (char*)encryped_param, encryped_param_len);
    CCLOG("[lua_app_xxx] base64_string: %s, len: %d", base64_string, len);
    std::string strData = base64_string;
    free(base64_string);
    base64_string = NULL;
    std::string strDataMD5 = xxteaData + AppInfo::_sign_data_md5;
    char *md5_string = MD5String((char *) strDataMD5.c_str());
    CCLOG("[lua_app_xxx] data md5_string: %s", md5_string);
    strDataMD5 = md5_string;
    free(md5_string);
    tolua_pushcppstring(L, AppInfo::_sign_subject_md5);
    tolua_pushcppstring(L, strData);
    tolua_pushcppstring(L, strDataMD5);
     
    return 3;
}

int lua_app_info(lua_State * L)
{
    tolua_pushcppstring(L, AppInfo::_app_pkg_name);
    tolua_pushcppstring(L, AppInfo::_app_pkg_version);
    tolua_pushnumber(L, AppInfo::_app_pkg_version_code);
    return 3;
}

int lua_base64_encode(lua_State * L)
{
    int nargs = lua_gettop(L);
    if (nargs != 1) 
    {
        tolua_error(L,"lua_base64_encode has wrong number of arguments, expected 1 string argument", nullptr);
        return 0;
    }

    if (lua_isstring(L, 1) == 0) 
    {
        tolua_error(L,"lua_base64_encode expected 1 string argument", nullptr);
        return 0;
    }

    size_t stringLen = 0;
    char* base64_string = NULL;
    const char *string = lua_tolstring(L, 1, &stringLen);
    int len = Base64encode_len((int)stringLen);
    base64_string = (char*) malloc(sizeof(char) * len);
    memset(base64_string, 0, sizeof(char) * len);
    len = Base64encode(base64_string, (char*)string, stringLen);
    std::string data = base64_string;
    free(base64_string);
    base64_string = NULL;

    tolua_pushcppstring(L, data);
    return 1;
}

int lua_base64_decode(lua_State * L)
{
    int nargs = lua_gettop(L);
    if (nargs != 1) 
    {
        tolua_error(L,"lua_base64_decode has wrong number of arguments, expected 1 string argument", nullptr);
        return 0;
    }

    if (lua_isstring(L, 1) == 0) 
    {
        tolua_error(L,"lua_base64_decode expected 1 string argument", nullptr);
        return 0;
    }

    size_t stringLen = 0;
    char* base64_string = NULL;
    const char *string = lua_tolstring(L, 1, &stringLen);
    int len = Base64decode_len(string);
    base64_string = (char*) malloc(sizeof(char) * len);
    memset(base64_string, 0, sizeof(char) * len);
    len = Base64decode(base64_string, (char*)string);
    std::string data = base64_string;
    free(base64_string);
    base64_string = NULL;

    tolua_pushcppstring(L, data);
    return 1;
    
}

int lua_md5(lua_State * L)
{
    int nargs = lua_gettop(L);
    if (nargs != 1) 
    {
        tolua_error(L,"lua_md5 has wrong number of arguments, expected 1 string argument", nullptr);
        return 0;
    }

    if (lua_isstring(L, 1) == 0) 
    {
        tolua_error(L,"lua_md5 expected 1 string argument", nullptr);
        return 0;
    }

    size_t stringLen = 0;
    const char *string = lua_tolstring(L, 1, &stringLen);
    char *md5_string = MD5String((char*)string, (int)stringLen);
    std::string data = md5_string;
    free(md5_string);
    md5_string = NULL;

    tolua_pushcppstring(L, data);
    return 1;
}

}


TOLUA_API int register_all_app_signiture(lua_State* tolua_S)
{
    const luaL_reg global_functions [] = {
        {"___appsig", lua_app_sig},
        {"___appxxx", lua_app_xxx},
        {"___appver", lua_app_info},
        {"___tobase64", lua_base64_encode},
        {"___frombase64", lua_base64_decode},
        {"___md5", lua_md5},

        {nullptr, nullptr}
    };
    luaL_register(tolua_S, "_G", global_functions);

  return 1;
}


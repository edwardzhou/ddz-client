#include "lua_cocos2dx_crypto_auto.hpp"
#include "CCCrypto.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"



int lua_cocos2dx_crypto_CCCrypto_encryptXXTEA(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.extra::CCCrypto",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 5)
    {
        unsigned char* arg0;
        int arg1;
        unsigned char* arg2;
        int arg3;
        int* arg4;
        #pragma warning NO CONVERSION TO NATIVE FOR unsigned char*;
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1);
        #pragma warning NO CONVERSION TO NATIVE FOR unsigned char*;
        ok &= luaval_to_int32(tolua_S, 5,(int *)&arg3);
        #pragma warning NO CONVERSION TO NATIVE FOR int*;
        if(!ok)
            return 0;
        unsigned char* ret = cocos2d::extra::CCCrypto::encryptXXTEA(arg0, arg1, arg2, arg3, arg4);
        #pragma warning NO CONVERSION FROM NATIVE FOR unsigned char*;
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "encryptXXTEA",argc, 5);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_crypto_CCCrypto_encryptXXTEA'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_crypto_CCCrypto_decryptXXTEA(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.extra::CCCrypto",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 5)
    {
        unsigned char* arg0;
        int arg1;
        unsigned char* arg2;
        int arg3;
        int* arg4;
        #pragma warning NO CONVERSION TO NATIVE FOR unsigned char*;
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1);
        #pragma warning NO CONVERSION TO NATIVE FOR unsigned char*;
        ok &= luaval_to_int32(tolua_S, 5,(int *)&arg3);
        #pragma warning NO CONVERSION TO NATIVE FOR int*;
        if(!ok)
            return 0;
        unsigned char* ret = cocos2d::extra::CCCrypto::decryptXXTEA(arg0, arg1, arg2, arg3, arg4);
        #pragma warning NO CONVERSION FROM NATIVE FOR unsigned char*;
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "decryptXXTEA",argc, 5);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_crypto_CCCrypto_decryptXXTEA'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_crypto_CCCrypto_decryptAES256(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.extra::CCCrypto",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 6)
    {
        unsigned char* arg0;
        int arg1;
        unsigned char* arg2;
        int arg3;
        unsigned char* arg4;
        int arg5;
        #pragma warning NO CONVERSION TO NATIVE FOR unsigned char*;
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1);
        #pragma warning NO CONVERSION TO NATIVE FOR unsigned char*;
        ok &= luaval_to_int32(tolua_S, 5,(int *)&arg3);
        #pragma warning NO CONVERSION TO NATIVE FOR unsigned char*;
        ok &= luaval_to_int32(tolua_S, 7,(int *)&arg5);
        if(!ok)
            return 0;
        int ret = cocos2d::extra::CCCrypto::decryptAES256(arg0, arg1, arg2, arg3, arg4, arg5);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "decryptAES256",argc, 6);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_crypto_CCCrypto_decryptAES256'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_crypto_CCCrypto_MD5File(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.extra::CCCrypto",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        const char* arg0;
        unsigned char* arg1;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();
        #pragma warning NO CONVERSION TO NATIVE FOR unsigned char*;
        if(!ok)
            return 0;
        cocos2d::extra::CCCrypto::MD5File(arg0, arg1);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "MD5File",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_crypto_CCCrypto_MD5File'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_crypto_CCCrypto_decodeBase64Len(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.extra::CCCrypto",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        const char* arg0;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();
        if(!ok)
            return 0;
        int ret = cocos2d::extra::CCCrypto::decodeBase64Len(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "decodeBase64Len",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_crypto_CCCrypto_decodeBase64Len'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_crypto_CCCrypto_MD5String(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.extra::CCCrypto",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        void* arg0;
        int arg1;
        #pragma warning NO CONVERSION TO NATIVE FOR void*;
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1);
        if(!ok)
            return 0;
        const std::string ret = cocos2d::extra::CCCrypto::MD5String(arg0, arg1);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "MD5String",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_crypto_CCCrypto_MD5String'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_crypto_CCCrypto_encryptAES256(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.extra::CCCrypto",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 6)
    {
        unsigned char* arg0;
        int arg1;
        unsigned char* arg2;
        int arg3;
        unsigned char* arg4;
        int arg5;
        #pragma warning NO CONVERSION TO NATIVE FOR unsigned char*;
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1);
        #pragma warning NO CONVERSION TO NATIVE FOR unsigned char*;
        ok &= luaval_to_int32(tolua_S, 5,(int *)&arg3);
        #pragma warning NO CONVERSION TO NATIVE FOR unsigned char*;
        ok &= luaval_to_int32(tolua_S, 7,(int *)&arg5);
        if(!ok)
            return 0;
        int ret = cocos2d::extra::CCCrypto::encryptAES256(arg0, arg1, arg2, arg3, arg4, arg5);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "encryptAES256",argc, 6);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_crypto_CCCrypto_encryptAES256'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_crypto_CCCrypto_getAES256KeyLength(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.extra::CCCrypto",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
            return 0;
        int ret = cocos2d::extra::CCCrypto::getAES256KeyLength();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "getAES256KeyLength",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_crypto_CCCrypto_getAES256KeyLength'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_crypto_CCCrypto_encodeBase64(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.extra::CCCrypto",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 4)
    {
        const char* arg0;
        int arg1;
        char* arg2;
        int arg3;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1);
        std::string arg2_tmp; ok &= luaval_to_std_string(tolua_S, 4, &arg2_tmp); arg2 = arg2_tmp.c_str();
        ok &= luaval_to_int32(tolua_S, 5,(int *)&arg3);
        if(!ok)
            return 0;
        int ret = cocos2d::extra::CCCrypto::encodeBase64(arg0, arg1, arg2, arg3);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "encodeBase64",argc, 4);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_crypto_CCCrypto_encodeBase64'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_crypto_CCCrypto_encodeBase64Len(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.extra::CCCrypto",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        const char* arg0;
        int arg1;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1);
        if(!ok)
            return 0;
        int ret = cocos2d::extra::CCCrypto::encodeBase64Len(arg0, arg1);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "encodeBase64Len",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_crypto_CCCrypto_encodeBase64Len'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_crypto_CCCrypto_decodeBase64(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.extra::CCCrypto",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 3)
    {
        const char* arg0;
        char* arg1;
        int arg2;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();
        std::string arg1_tmp; ok &= luaval_to_std_string(tolua_S, 3, &arg1_tmp); arg1 = arg1_tmp.c_str();
        ok &= luaval_to_int32(tolua_S, 4,(int *)&arg2);
        if(!ok)
            return 0;
        int ret = cocos2d::extra::CCCrypto::decodeBase64(arg0, arg1, arg2);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "decodeBase64",argc, 3);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_crypto_CCCrypto_decodeBase64'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_crypto_CCCrypto_MD5(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.extra::CCCrypto",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 3)
    {
        void* arg0;
        int arg1;
        unsigned char* arg2;
        #pragma warning NO CONVERSION TO NATIVE FOR void*;
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1);
        #pragma warning NO CONVERSION TO NATIVE FOR unsigned char*;
        if(!ok)
            return 0;
        cocos2d::extra::CCCrypto::MD5(arg0, arg1, arg2);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "MD5",argc, 3);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_crypto_CCCrypto_MD5'.",&tolua_err);
#endif
    return 0;
}
static int lua_cocos2dx_crypto_CCCrypto_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (CCCrypto)");
    return 0;
}

int lua_register_cocos2dx_crypto_CCCrypto(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"cc.extra::CCCrypto");
    tolua_cclass(tolua_S,"CCCrypto","cc.extra::CCCrypto","",NULL);

    tolua_beginmodule(tolua_S,"CCCrypto");
        tolua_function(tolua_S,"encryptXXTEA", lua_cocos2dx_crypto_CCCrypto_encryptXXTEA);
        tolua_function(tolua_S,"decryptXXTEA", lua_cocos2dx_crypto_CCCrypto_decryptXXTEA);
        tolua_function(tolua_S,"decryptAES256", lua_cocos2dx_crypto_CCCrypto_decryptAES256);
        tolua_function(tolua_S,"MD5File", lua_cocos2dx_crypto_CCCrypto_MD5File);
        tolua_function(tolua_S,"decodeBase64Len", lua_cocos2dx_crypto_CCCrypto_decodeBase64Len);
        tolua_function(tolua_S,"MD5String", lua_cocos2dx_crypto_CCCrypto_MD5String);
        tolua_function(tolua_S,"encryptAES256", lua_cocos2dx_crypto_CCCrypto_encryptAES256);
        tolua_function(tolua_S,"getAES256KeyLength", lua_cocos2dx_crypto_CCCrypto_getAES256KeyLength);
        tolua_function(tolua_S,"encodeBase64", lua_cocos2dx_crypto_CCCrypto_encodeBase64);
        tolua_function(tolua_S,"encodeBase64Len", lua_cocos2dx_crypto_CCCrypto_encodeBase64Len);
        tolua_function(tolua_S,"decodeBase64", lua_cocos2dx_crypto_CCCrypto_decodeBase64);
        tolua_function(tolua_S,"MD5", lua_cocos2dx_crypto_CCCrypto_MD5);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(cocos2d::extra::CCCrypto).name();
    g_luaType[typeName] = "cc.extra::CCCrypto";
    g_typeCast["CCCrypto"] = "cc.extra::CCCrypto";
    return 1;
}
TOLUA_API int register_all_cocos2dx_crypto(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,"crypto",0);
	tolua_beginmodule(tolua_S,"crypto");

	lua_register_cocos2dx_crypto_CCCrypto(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}


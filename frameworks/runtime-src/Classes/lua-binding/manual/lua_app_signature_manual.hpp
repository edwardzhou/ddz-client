#include "base/ccConfig.h"
#ifndef __cocos2dx_app_signiture_digest_h__
#define __cocos2dx_app_signiture_digest_h__

#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif

namespace AppInfo{
extern std::string _app_pkg_name;
extern std::string _app_pkg_version;
extern int _app_pkg_version_code;
extern std::string _sign_subject;
extern std::string _sign_subject_md5;
extern unsigned char _sign_subject_md5_bin[16];
extern std::string _sign_data;
extern std::string _sign_data_md5;
extern unsigned char _sign_data_md5_bin[16];
}

int register_all_app_signiture(lua_State* tolua_S);
extern std::string bin2hex(unsigned char *bin, int size);
#endif

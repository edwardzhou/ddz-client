#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "AudioEngine.h"
#include "cocos2d.h"
#include "lua_module_register.h"
#include "lua_extensions.h"
#include "editor-support/cocostudio/CCSGUIReader.h"
#include "unzip.h"
#include "MobClickCpp.h"
#include "lua_cocos2dx_umeng_auto.hpp"
#include "lua_cocos2dx_umeng_manual.hpp"
#include "platform/android/jni/JniHelper.h"
//#include "auto/lua_cocos2dx_plugin_auto.hpp"
#include "lua_app_signature_manual.hpp"
#include "md5/MD5pp.h"

#ifdef __cplusplus
extern "C" {
LUALIB_API int luaopen_struct (lua_State *L);
}
#endif

#define  LOG_TAG    "AppDelegate"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)

jclass _getClassID_x(const char *className) {
    if (NULL == className) {
        return NULL;
    }

    JNIEnv* env = cocos2d::JniHelper::getEnv();

    jstring _jstrClassName = env->NewStringUTF(className);

    jclass _clazz = (jclass) env->CallObjectMethod(cocos2d::JniHelper::classloader,
                                                   cocos2d::JniHelper::loadclassMethod_methodID,
                                                   _jstrClassName);

    if (NULL == _clazz) {
        LOGD("Classloader failed to find class of %s", className);
    }

    env->DeleteLocalRef(_jstrClassName);
        
    return _clazz;
}

using namespace CocosDenshion;
using namespace cocos2d::experimental;

USING_NS_CC;

typedef struct JniFieldInfo_
{
    JNIEnv *    env;
    jclass      classID;
    jfieldID   fieldID;
} JniFieldInfo;

void releaseMethodInfo(JniMethodInfo &info, bool keepClazz = false)
{
    // info.env->DeleteLocalRef(info.methodID);
    // if (!keepClazz) {
    //     info.env->DeleteLocalRef(info.classID);
    // }
}

void releaseFieldInfo(JniFieldInfo &info, bool keepClazz = false) 
{
    // info.env->DeleteLocalRef(info.fieldID);
    // if (!keepClazz) {
    //     info.env->DeleteLocalRef(info.classID);
    // }
}

bool getFieldInfo(JniFieldInfo &fieldinfo,
                              const char *className,
                              const char *fieldName,
                              const char *paramCode) {
    if ((NULL == className) ||
        (NULL == fieldName) ||
        (NULL == paramCode)) {
        return false;
    }

    JNIEnv *pEnv = JniHelper::getEnv();
    if (!pEnv) {
        return false;
    }

    jclass classID = _getClassID_x(className);
    if (! classID) {
        LOGD("Failed to find class %s", className);
        pEnv->ExceptionClear();
        return false;
    }

    jfieldID fieldID = pEnv->GetFieldID(classID, fieldName, paramCode);
    if (! fieldID) {
        LOGD("Failed to find method id of %s", fieldName);
        pEnv->ExceptionClear();
        return false;
    }

    fieldinfo.classID = classID;
    fieldinfo.env = pEnv;
    fieldinfo.fieldID = fieldID;

    return true;
}

std::string bin2hex(unsigned char *bin, int size)
{
    char buffer[3];
    memset(buffer, 0, 3);
    std::string data;
    for (int i=0; i<size; i++)
    {
        sprintf(buffer, "%02x", bin[i]);
        data.append(buffer);
    }

    return data;
}

std::string getApkSign() {
    std::string packageName;
    std::string apkSign;

    JNIEnv* env = JniHelper::getEnv();

    JniMethodInfo _mi_getContext;
    JniHelper::getStaticMethodInfo(_mi_getContext, "org.cocos2dx.lib.Cocos2dxActivity", "getContext", "()Landroid/content/Context;");
    jobject j_context = env->CallStaticObjectMethod(_mi_getContext.classID, _mi_getContext.methodID);

    JniMethodInfo _mi_getPackageName;
    JniMethodInfo _mi_getPackageManager;
    JniMethodInfo _mi_getPackageInfo;
    JniMethodInfo _mi_toCharsString;
    JniMethodInfo _mi_Sign_toByteArray;
    JniMethodInfo _mi_packgeInfo_toString;
    JniFieldInfo _fi_signatures;
    JniMethodInfo _mi_CertFactory_getInstance;
    JniMethodInfo _mi_CertFactory_generateCertificate;
    JniMethodInfo _mi_X509Certificate_toString;
    JniMethodInfo _mi_X509Certificate_getSubjectX500Principal;
    JniMethodInfo _mi_ByteArrayInputStreamContructor;

    JniHelper::getStaticMethodInfo(_mi_CertFactory_getInstance, "java.security.cert.CertificateFactory", "getInstance", "(Ljava/lang/String;)Ljava/security/cert/CertificateFactory;");
    JniHelper::getMethodInfo(_mi_CertFactory_generateCertificate, "java.security.cert.CertificateFactory", "generateCertificate", "(Ljava/io/InputStream;)Ljava/security/cert/Certificate;");
    JniHelper::getMethodInfo(_mi_X509Certificate_getSubjectX500Principal, "java.security.cert.X509Certificate", "getSubjectX500Principal", "()Ljavax/security/auth/x500/X500Principal;");
    JniHelper::getMethodInfo(_mi_X509Certificate_toString, "java.security.cert.X509Certificate", "toString", "()Ljava/lang/String;");
    JniHelper::getMethodInfo(_mi_ByteArrayInputStreamContructor, "java.io.ByteArrayInputStream", "<init>", "([B)V");

    JniHelper::getMethodInfo(_mi_getPackageName, "android.content.Context", "getPackageName", "()Ljava/lang/String;");
    JniHelper::getMethodInfo(_mi_getPackageManager, "android.content.Context", "getPackageManager", "()Landroid/content/pm/PackageManager;");
    JniHelper::getMethodInfo(_mi_getPackageInfo, "android.content.pm.PackageManager", "getPackageInfo", "(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;");
    JniHelper::getMethodInfo(_mi_toCharsString, "android.content.pm.Signature", "toCharsString", "()Ljava/lang/String;");
    if (!JniHelper::getMethodInfo(_mi_Sign_toByteArray, "android.content.pm.Signature", "toByteArray", "()[B")) {
        CCLOG("[getApkInfo] ERROR: cannot get method info for android.content.pm.Signature#toByteArray");
    };
    getFieldInfo(_fi_signatures, "android.content.pm.PackageInfo", "signatures", "[Landroid/content/pm/Signature;");

    jobject j_packageManager;
    jobject j_packageInfo;
    jobjectArray j_signatures;
    jobject j_signature;
    jstring j_packageName;
    jclass j_classByteArrayInputStream = _getClassID_x("java.io.ByteArrayInputStream");
    jobject j_byteArrayStream;

    jobject objPkgName = env->CallObjectMethod(j_context, _mi_getPackageName.methodID);
    j_packageName = (jstring) objPkgName;
    packageName = JniHelper::jstring2string(j_packageName);
    CCLOG("[getApkInfo] packageName => %s", packageName.c_str());
    env->DeleteLocalRef(objPkgName);

    j_packageManager = env->CallObjectMethod(j_context, _mi_getPackageManager.methodID);
    j_packageInfo = env->CallObjectMethod(j_packageManager, _mi_getPackageInfo.methodID, j_packageName, 64);
    j_signatures = (jobjectArray) env->GetObjectField(j_packageInfo, _fi_signatures.fieldID);

    jstring j_x509_string = env->NewStringUTF("X509");
    jobject j_certFactory = env->CallStaticObjectMethod(_mi_CertFactory_getInstance.classID, _mi_CertFactory_getInstance.methodID, j_x509_string);
    env->DeleteLocalRef(j_x509_string);

    jsize length = env->GetArrayLength(j_signatures);
    for (jsize index=0; index < std::min(length, 1); index++) {
        j_signature = env->GetObjectArrayElement(j_signatures, index);
        jstring j_signStr = (jstring) env->CallObjectMethod(j_signature, _mi_toCharsString.methodID);
        apkSign = JniHelper::jstring2string(j_signStr);
        CCLOG("[getApkInfo] Signature[%d]: %s", index, apkSign.c_str());
        env->DeleteLocalRef(j_signStr);
        jbyteArray j_bytes = (jbyteArray) env->CallObjectMethod(j_signature, _mi_Sign_toByteArray.methodID);
        jsize bytesLength = env->GetArrayLength(j_bytes);
        CCLOG("[getApkInfo] signature[%d]: byte length: %d", index, bytesLength);
        j_byteArrayStream = env->NewObject(j_classByteArrayInputStream, _mi_ByteArrayInputStreamContructor.methodID, j_bytes);

        jobject j_x509Cert = env->CallObjectMethod(j_certFactory, _mi_CertFactory_generateCertificate.methodID, j_byteArrayStream);
        jobject j_subjectPrinncipal = env->CallObjectMethod(j_x509Cert, _mi_X509Certificate_getSubjectX500Principal.methodID);
        jstring j_subjectString = (jstring) env->CallObjectMethod(j_subjectPrinncipal, _mi_X509Certificate_toString.methodID);
        std::string strSubject = JniHelper::jstring2string(j_subjectString);  
        CCLOG("[getApkInfo] subject: %s", strSubject.c_str());

        uchar* digest = NULL;
        char *md5_string = NULL;
        AppSign::_sign_subject = strSubject;
        digest = MD5Digest((char*)strSubject.c_str());
        strncpy((char *)AppSign::_sign_subject_md5_bin, (const char*)digest, 16);
        md5_string = PrintMD5(AppSign::_sign_subject_md5_bin);
        CCLOG("********md5_string for _sign_subject: %s", md5_string);
        AppSign::_sign_subject_md5 = MD5String((char*)AppSign::_sign_subject.c_str());
        free(md5_string);
        md5_string = NULL;

        CCLOG("AppSign::_sign_subject: %s", AppSign::_sign_subject.c_str());
        CCLOG("AppSign::_sign_subject_md5: %s", AppSign::_sign_subject_md5.c_str());
        CCLOG("AppSign::_sign_subject_md5(MD5String): %s", MD5String((char*)AppSign::_sign_subject.c_str()));

        AppSign::_sign_data = apkSign;
        digest = MD5Digest((char*)apkSign.c_str(), apkSign.size());
        strncpy((char *)AppSign::_sign_data_md5_bin, (const char*)digest, 16);
        md5_string = PrintMD5(AppSign::_sign_data_md5_bin);
        AppSign::_sign_data_md5 = MD5String((char*)apkSign.c_str());
        free(md5_string);
        md5_string = NULL;

        env->DeleteLocalRef(j_byteArrayStream);
        env->DeleteLocalRef(j_subjectString);
        env->DeleteLocalRef(j_subjectPrinncipal);
        env->DeleteLocalRef(j_x509Cert);
        env->DeleteLocalRef(j_bytes);
   }

    env->DeleteLocalRef(j_packageManager);
    env->DeleteLocalRef(j_packageInfo);
    env->DeleteLocalRef(j_signatures);
    return apkSign;
}

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
   //MobClickCpp::end();
    //SimpleAudioEngine::end();
    AudioEngine::end();
}

//if you want a different context,just modify the value of glContextAttrs
//it will takes effect on all platforms
void AppDelegate::initGLContextAttrs()
{
    //set OpenGL context attributions,now can only set six attributions:
    //red,green,blue,alpha,depth,stencil
    CCLOG("AppDelegate::initGLContextAttrs");
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8};
    //GLContextAttrs glContextAttrs = {5, 6, 5, 0, 16, 8};

    GLView::setGLContextAttrs(glContextAttrs);
}

bool AppDelegate::applicationDidFinishLaunching()
{

    // register lua engine
    auto engine = LuaEngine::getInstance();
    auto luaState = engine->getLuaStack()->getLuaState();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    // CCLOG("register_all_cocos2dx_pluginx ....");
    // register_all_cocos2dx_plugin(luaState);
    // CCLOG("after register_all_cocos2dx_pluginx ....");
    lua_module_register(luaState);
    register_all_cocos2dx_umeng(luaState);
    register_all_cocos2dx_umeng_manual(luaState);
    luaopen_cjson_extensions(luaState);
    luaopen_struct(luaState);

    register_all_app_signiture(luaState);

    auto fileUtils = FileUtils::getInstance();
    fileUtils->addSearchPath("/sdcard/fungame/DDZ", true);

 //    int nRet;
	// unzFile pFile = NULL;
 //    do {
	// 	pFile = unzOpen("/sdcard/tms/Resources.zip");
	// 	CC_BREAK_IF(!pFile);
	// 	while (unzGoToNextFile(pFile) == UNZ_OK) {
	// 		char szFilePathA[260];
	// 		unz_file_info FileInfo;
	// 		nRet = unzGetCurrentFileInfo(pFile, &FileInfo, szFilePathA, sizeof(szFilePathA), NULL, 0, NULL, 0);
	// 		CC_BREAK_IF(UNZ_OK != nRet);
	// 		CCLOG("File: %s", szFilePathA);
	// 	}

	// 	CCLOG("Try to locate file.");
	// 	//unzGoToFirstFile(pFile);
	// 	nRet = unzLocateFile(pFile, "Resources/UI/Hall/", 2);
	// 	CC_BREAK_IF(UNZ_OK != nRet);
	// 	do {
	// 		char szFilePathA[260];
	// 		unz_file_info FileInfo;
	// 		nRet = unzGetCurrentFileInfo(pFile, &FileInfo, szFilePathA, sizeof(szFilePathA), NULL, 0, NULL, 0);
	// 		CC_BREAK_IF(UNZ_OK != nRet);
	// 		CCLOG("File: %s", szFilePathA);
	// 	} while (unzGoToNextFile(pFile) == UNZ_OK);


 //    } while(false);

 //    if (pFile) {
 //    	unzClose(pFile);
 //    }
	// CCLOG("Close Zip file.");
//    std::string sstr = "中文测试1234";
//    CCLOG("sstr: length %d", sstr.length());
//    int size = sstr.length()*2 + 10;
//    mbstate_t mbs;
//    mbrlen (NULL,0,&mbs);
//    const char* pstr = sstr.c_str();
//    wchar_t wbuf[20];
//    memset(wbuf, 0, 20 * sizeof(wchar_t));
//    CCLOG("wstr: length %d", mbsrtowcs(wbuf, &pstr, 20, &mbs) );
//    CCLOG("wstr1: length %d", mbstowcs(NULL, pstr, 20) );
//    CCLOG("wstrx: length %d", wcslen(wbuf) );
//
//    std::wstring_convert<std::codecvt_utf8<char32_t>,char32_t> cv;
//
//    std::u32string u32s = cv.from_bytes(sstr);
//    CCLOG("w32str length %d", u32s.length());


    //The call was commented because it will lead to ZeroBrane Studio can't find correct context when debugging
    //engine->executeScriptFile("hello.lua");
    //cocostudio::GUIReader::getInstance()->widgetFromJsonFile("UI/Gaming/Gaming.json");

    auto _scheduler = Director::getInstance()->getScheduler();
    _scheduler->schedule([](float dt) {
        umeng::MobClickCpp::mainloop(dt);
    }, this, 0, false, "umeng");

    umeng::MobClickCpp::setLogEnabled(true);
    //umeng::MobClickCpp::setAppVersion("1.2");
    // umeng::MobClickCpp::startWithAppkey("5351dee256240b09f604ee4c", "my_channel");
    // umeng::MobClickCpp::event("test");

    umeng::MobClickCpp::updateOnlineConfig();
    CCLOG("online config> testParam: %s" , umeng::MobClickCpp::getConfigParam("testParam").c_str());

    getApkSign();

    //FileUtils::getInstance()->addSearchPath("src");

    CCLOG("SHADER_NAME_POSITION_TEXTURE_COLOR_NO_MVP: '%s'", GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR_NO_MVP);

    // if (engine->executeScriptFile("boot.lua")) {
    //     return  false;
    // }

    engine->getLuaStack()->loadChunksFromZIP("luaScripts.zip");

    // if (engine->executeGlobalFunction("startup")) {
    //     return false;
    // }
    //if (engine->executeScriptFile("boot")) {
    if(engine->executeString("require 'boot'")) 
    {
        return  false;
    }
   
    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();

    umeng::MobClickCpp::applicationDidEnterBackground();

    AudioEngine::pauseAll();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();

    umeng::MobClickCpp::applicationWillEnterForeground();

    //SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
    AudioEngine::resumeAll();
    Director::getInstance()->getScheduler()->schedule([](float dt) {
            cocos2d::EventCustom foregroundEvent(EVENT_COME_TO_FOREGROUND);
            cocos2d::Director::getInstance()->getEventDispatcher()->dispatchEvent(&foregroundEvent);
    }, this, 0.0, 0, 0.0, false, "EVENT_COME_TO_FOREGROUND");
}


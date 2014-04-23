#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "lua_extensions.h"
#include "editor-support/cocostudio/CCSGUIReader.h"
#include "unzip.h"
#include "MobClickCpp.h"
#include "lua_cocos2dx_umeng_auto.hpp"
//#include "auto/lua_cocos2dx_plugin_auto.hpp"

#ifdef __cplusplus
extern "C" {
LUALIB_API int luaopen_struct (lua_State *L);
}
#endif

using namespace CocosDenshion;

USING_NS_CC;

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
    MobClickCpp::end();
    SimpleAudioEngine::end();
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // initialize director
    auto director = Director::getInstance();
    auto glview = director->getOpenGLView();
    if(!glview) {
        glview = GLView::create("My Game");
        director->setOpenGLView(glview);
    }

    glview->setDesignResolutionSize(800, 480, ResolutionPolicy::EXACT_FIT);

    // turn on display FPS
    director->setDisplayStats(true);

    // set FPS. the default value is 1.0/60 if you don't call this
    director->setAnimationInterval(1.0 / 30);

    FileUtils::getInstance()->addSearchPath("src");
    FileUtils::getInstance()->addSearchPath("luaScripts");
    FileUtils::getInstance()->addSearchPath("res");

    // register lua engine
    auto engine = LuaEngine::getInstance();
    auto luaState = engine->getLuaStack()->getLuaState();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    register_all_cocos2dx_umeng(luaState);
    // CCLOG("register_all_cocos2dx_pluginx ....");
    // register_all_cocos2dx_plugin(luaState);
    // CCLOG("after register_all_cocos2dx_pluginx ....");
    luaopen_cjson_extensions(luaState);
    luaopen_struct(luaState);

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

    // MobClickCpp::setLogEnabled(true);
    // MobClickCpp::setAppVersion("1.2");
    // MobClickCpp::startWithAppkey("5351dee256240b09f604ee4c", "my_channel");
    MobClickCpp::beginEvent("test");

    MobClickCpp::endEvent("test");
    MobClickCpp::updateOnlineConfig();
    CCLOG("online config> testParam: %s" , MobClickCpp::getConfigParams("testParam").c_str());


    engine->executeString("require 'boot.lua'");
    
    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();

    MobClickCpp::applicationDidEnterBackground();

    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();

    MobClickCpp::applicationWillEnterForeground();

    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
}


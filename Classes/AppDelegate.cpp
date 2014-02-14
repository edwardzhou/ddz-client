#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "lua_extensions.h"
#include "string"
#include "wchar.h"
#include "locale"
#include "bits/codecvt.h"

using namespace CocosDenshion;

USING_NS_CC;

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
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
    director->setAnimationInterval(1.0 / 60);

    // register lua engine
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    luaopen_cjson_extensions(engine->getLuaStack()->getLuaState());

//    std::string sstr = "÷–Œƒ≤‚ ‘1234";
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
    engine->executeString("require 'boot.lua'");
    
    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();

    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();

    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
}

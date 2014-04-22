#include "AppDelegate.h"
#include "cocos2d.h"
#include "CCEventType.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>
//#include "PluginJniHelper.h"
#include "MobClickCpp.h"

#define  LOG_TAG    "main"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)

using namespace cocos2d;

void cocos_android_app_init (JNIEnv* env, jobject thiz) {
    LOGD("cocos_android_app_init");
    JniMethodInfo getActivity;
    JniHelper::getStaticMethodInfo(getActivity, "org.cocos2dx.lib.Cocos2dxHelper", "getActivity", "()Landroid/app/Activity;");
    jobject activity = env->CallStaticObjectMethod(getActivity.classID, getActivity.methodID);

    AppDelegate *pAppDelegate = new AppDelegate();
    JavaVM* vm;
    env->GetJavaVM(&vm);
    MobClickCpp::initJniForCocos2dx3((void*)vm, (void*)activity);
    //PluginJniHelper::setJavaVM(vm);
}

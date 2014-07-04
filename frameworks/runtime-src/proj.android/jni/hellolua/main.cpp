#include "AppDelegate.h"
#include "cocos2d.h"
//#include "CCEventType.h"
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


extern "C" {
void Java_com_fungame_DDZ_NetworkListener_messageCpp(JNIEnv* env, jobject thiz,
		jstring text, jstring data) {

	auto dispatcher = Director::getInstance()->getEventDispatcher();

	CCLog("[Java_cn_com_m123_DDZ_DDZJniHelper_test] enter.");

	std::string myText = JniHelper::jstring2string(text);
	std::string myData = JniHelper::jstring2string(data);

	EventCustom event(myText);
	dispatcher->dispatchEvent(&event);

	CCLog("[Java_cn_com_m123_DDZ_DDZJniHelper_test] pText: %s.", myText.c_str());

	CCLog("[Java_cn_com_m123_DDZ_DDZJniHelper_test] return.");
}
}


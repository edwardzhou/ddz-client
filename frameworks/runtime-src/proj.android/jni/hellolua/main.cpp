#include "AppDelegate.h"
#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>
// #include "MobClickJniHelper.h"
// #include "TDGAJniHelper.h"
#include "../../../../runtime-src/proj.android/protocols/android/PluginJniHelper.h"


#define  LOG_TAG    "main"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)

using namespace cocos2d;
using namespace anysdk::framework;

void cocos_android_app_init (JNIEnv* env /*, jobject thiz*/) {
    LOGD("cocos_android_app_init");
    // JniMethodInfo getActivity;
    // JniHelper::getStaticMethodInfo(getActivity, "org.cocos2dx.lib.Cocos2dxHelper", "getActivity", "()Landroid/app/Activity;");
    // jobject activity = env->CallStaticObjectMethod(getActivity.classID, getActivity.methodID);

    JavaVM* vm;
    env->GetJavaVM(&vm);
    // umeng::MobClickJniHelper::setJavaVM(vm);
    // TDGAJniHelper::setJavaVM(vm);

    AppDelegate *pAppDelegate = new AppDelegate();
    // PluginJniHelper::setJavaVM(vm);
    // PluginJniHelper::setJavaVM(vm);
}


extern "C" {
void Java_cn_HuiYou_DDZ_NetworkListener_messageCpp(JNIEnv* env, jobject thiz,
		jstring text, jstring data) {

	auto dispatcher = Director::getInstance()->getEventDispatcher();

	CCLOG("[Java_cn_HuiYou_DDZ_NetworkListener_messageCpp] enter.");

	std::string myText = JniHelper::jstring2string(text);
	std::string myData = JniHelper::jstring2string(data);

	EventCustom event(myText);
	dispatcher->dispatchEvent(&event);

	CCLOG("[Java_cn_HuiYou_DDZ_NetworkListener_messageCpp] pText: %s.", myText.c_str());

	CCLOG("[Java_cn_HuiYou_DDZ_NetworkListener_messageCpp] return.");
}
}


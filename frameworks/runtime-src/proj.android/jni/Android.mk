LOCAL_PATH := $(call my-dir)
$(call import-add-path,$(LOCAL_PATH)/../)

include $(CLEAR_VARS)

LOCAL_MODULE := cocos2dlua_shared

LOCAL_MODULE_FILENAME := libcocos2dlua

LOCAL_SRC_FILES := hellolua/main.cpp \
                   ../../Classes/AppDelegate.cpp \
                   ../../Classes/cjson/fpconv.c \
                   ../../Classes/cjson/lua_cjson.c \
                   ../../Classes/cjson/lua_extensions.c \
                   ../../Classes/cjson/strbuf.c \
                   ../../Classes/struct/struct.c \
                   ../../Classes/crypto/base64/libbase64.c \
                   ../../Classes/crypto/xxtea/xxtea.c \
                   ../../Classes/md5/MD5pp.cpp \
                   ../../Classes/lua-binding/manual/lua_app_signature_manual.cpp \
                   ../../Classes/anysdkbindings.cpp \
                   ../../Classes/anysdk_manual_bindings.cpp \

#                   ../../3rdLibs/TalkingData/platform/android/TDCCAccount.cpp \
#                   ../../3rdLibs/TalkingData/platform/android/TDCCItem.cpp \
#                   ../../3rdLibs/TalkingData/platform/android/TDCCMIssion.cpp \
#                   ../../3rdLibs/TalkingData/platform/android/TDCCTalkingDataGA.cpp \
#                   ../../3rdLibs/TalkingData/platform/android/TDCCVirtualCurrency.cpp \
#                   ../../3rdLibs/TalkingData/platform/android/TDGAJniHelper.cpp \
#                   ../../Classes/lua-binding/auto/lua_cocos2dx_TalkingDataGA_auto.cpp \
#                   ../../Classes/lua-binding/auto/lua_cocos2dx_TDGAAccount_auto.cpp \
#                   ../../Classes/lua-binding/auto/lua_cocos2dx_TDGAItem_auto.cpp \
#                   ../../Classes/lua-binding/auto/lua_cocos2dx_TDGAMission_auto.cpp \
#                   ../../Classes/lua-binding/auto/lua_cocos2dx_TDGAVirtualCurrency_auto.cpp \
#                   ../../Classes/lua-binding/auto/lua_cocos2dx_umeng_auto.cpp \
#                   ../../Classes/lua-binding/manual/lua_cocos2dx_umeng_manual.cpp \


LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../Classes \
                    $(LOCAL_PATH)/../../Classes/cjson \
                    $(LOCAL_PATH)/../../Classes/cjson \
                    $(LOCAL_PATH)/../../Classes/struct \
                    $(LOCAL_PATH)/../../Classes/crypto/base64 \
                    $(LOCAL_PATH)/../../Classes/crypto/xxtea \
                    $(LOCAL_PATH)/../../Classes/crypto \
                    $(LOCAL_PATH)/../../Classes/lua-binding/auto \
                    $(LOCAL_PATH)/../../Classes/lua-binding/manual \
 
#                    $(LOCAL_PATH)/../../3rdLibs/TalkingData/include \
#                    $(LOCAL_PATH)/../../3rdLibs/TalkingData/platform/android \
#                    $(LOCAL_PATH)/../../3rdLibs/umeng/android/libMobClickCpp/include \

          
LOCAL_STATIC_LIBRARIES := cocos2d_lua_static
#LOCAL_WHOLE_STATIC_LIBRARIES += cocos_curl_static
#LOCAL_WHOLE_STATIC_LIBRARIES += mobclickcpp_static
LOCAL_WHOLE_STATIC_LIBRARIES += PluginProtocolStatic

include $(BUILD_SHARED_LIBRARY)

$(call import-module, scripting/lua-bindings/proj.android)
#$(call import-module, curl/prebuilt/android)
#$(call import-module, libMobClickCpp)
$(call import-module, protocols/android)

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := UMengStatic
LOCAL_MODULE_FILENAME := cocos2dx3_libMobClickCpp

LOCAL_SRC_FILES := ./libs/cocos2dx3_libMobClickCpp.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../../include $(LOCAL_PATH)
LOCAL_EXPORT_LDLIBS := -llog

include $(PREBUILT_STATIC_LIBRARY)

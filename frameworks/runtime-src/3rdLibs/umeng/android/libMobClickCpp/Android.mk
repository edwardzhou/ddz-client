LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := mobclickcpp_static
LOCAL_MODULE_FILENAME := mobclickcpp
LOCAL_SRC_FILES := libs/$(APP_STL)/$(TARGET_ARCH_ABI)/libMobClickCpp.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include
include $(PREBUILT_STATIC_LIBRARY)

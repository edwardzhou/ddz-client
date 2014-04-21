LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := UMengPatcher-prebuilt
LOCAL_MODULE_FILENAME := libbspatch

LOCAL_SRC_FILES := ./armeabi/libbspatch.so
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../../../include $(LOCAL_PATH)
LOCAL_EXPORT_LDLIBS := -llog

include $(PREBUILT_SHARED_LIBRARY)

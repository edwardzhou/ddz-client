LOCAL_PATH := $(call my-dir)

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

#                   ../../Classes/crypto/CCCrypto.cpp \
#                   ../../Classes/crypto/CCCryptoAndroid.cpp \


LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../Classes \
                    $(LOCAL_PATH)/../../cocos2d/external/lua/tolua \
                    $(LOCAL_PATH)/../../Classes/cjson \
                    $(LOCAL_PATH)/../../Classes/cjson \
                   	$(LOCAL_PATH)/../../Classes/struct \
                   	$(LOCAL_PATH)/../../Classes/crypto/base64 \
                   	$(LOCAL_PATH)/../../Classes/crypto/xxtea \
                   	$(LOCAL_PATH)/../../Classes/crypto \
                    

LOCAL_WHOLE_STATIC_LIBRARIES := cocos_lua_static

include $(BUILD_SHARED_LIBRARY)

#COCOS2DX_PATH := /Users/edwardzhou/develop/cocos2d-x-3.0

#$(call import-add-path,$(COCOS2DX_PATH))
#$(call import-add-path,$(COCOS2DX_PATH)/cocos)
#$(call import-add-path,$(COCOS2DX_PATH)/external)

$(call import-module, scripting/lua-bindings)
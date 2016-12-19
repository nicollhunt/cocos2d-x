LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE := cocosdenshion_static

LOCAL_MODULE_FILENAME := libcocosdenshion

LOCAL_SRC_FILES := SimpleAudioEngine.cpp \
                   jni/SimpleAudioEngineJni.cpp \
                   opensl/OpenSLEngine.cpp \
                   opensl/SimpleAudioEngineOpenSL.cpp

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../include

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../include \
                    $(LOCAL_PATH)/../../cocos2dx \
                    $(LOCAL_PATH)/../../cocos2dx/include

ifeq ($(ANDROID_SUB_TARGET), ouya)
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../cocos2dx/platform/ouya
LOCAL_CFLAGS += -DOUYA=1
else
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../cocos2dx/platform/android
endif

LOCAL_CFLAGS += -Wno-psabi
LOCAL_EXPORT_CFLAGS += -Wno-psabi
LOCAL_DISABLE_FORMAT_STRING_CHECKS := true

include $(BUILD_STATIC_LIBRARY)

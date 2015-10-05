LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := main

SDL_PATH := ../SDL2
SDL_IMAGE_PATH := ../SDL2_image
SDL_MIXER_PATH := ../SDL2_mixer

LOCAL_C_INCLUDES := $(LOCAL_PATH)/$(SDL_PATH)/include \
	$(LOCAL_PATH)/$(SDL_IMAGE_PATH)/include \
	$(LOCAL_PATH)/$(SDL_MIXER_PATH)/include \
	$(LOCAL_PATH)/../enet/include \
    $(LOCAL_PATH)/../lz4/lib \
    $(LOCAL_PATH)/../yaml-cpp-noboost/include \
	$(LOCAL_PATH)/common \
	$(LOCAL_PATH)/common_netplay \
	$(LOCAL_PATH)/smw

FILE_LIST := \
	$(wildcard $(LOCAL_PATH)/**/*.cpp) \
	$(wildcard $(LOCAL_PATH)/**/*.c) \
	$(wildcard $(LOCAL_PATH)/**/**/*.cpp) \
	$(wildcard $(LOCAL_PATH)/**/**/**/*.cpp) \
	$(wildcard $(LOCAL_PATH)/**/**/**/**/*.cpp)

LOCAL_SRC_FILES := $(SDL_PATH)/src/main/android/SDL_android_main.c \
	$(FILE_LIST:$(LOCAL_PATH)/%=%)

LOCAL_SHARED_LIBRARIES := SDL2 SDL2_image SDL2_mixer enet lz4 yaml-cpp

LOCAL_LDLIBS := -lGLESv1_CM -lGLESv2 -llog

LOCAL_CPPFLAGS += -DUSE_SDL2 -std=c++11 -fexceptions -O3 -fpermissive -ffast-math
LOCAL_CFLAGS += -DUSE_SDL2 -O3 -ffast-math

include $(BUILD_SHARED_LIBRARY)

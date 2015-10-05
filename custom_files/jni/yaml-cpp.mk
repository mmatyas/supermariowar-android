LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := yaml-cpp

LOCAL_C_INCLUDES := $(LOCAL_PATH)/include

LOCAL_CPPFLAGS += -std=c++11 -fexceptions -O3 -ffast-math

FILE_LIST := $(wildcard $(LOCAL_PATH)/src/*.cpp)
LOCAL_SRC_FILES := $(FILE_LIST:$(LOCAL_PATH)/%=%)

include $(BUILD_SHARED_LIBRARY)

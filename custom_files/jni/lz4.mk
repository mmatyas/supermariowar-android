LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := lz4

LOCAL_CPPFLAGS += -O3 -ffast-math

LOCAL_SRC_FILES := \
	lib/lz4.c \
	lib/lz4frame.c \
	lib/lz4hc.c \
	lib/xxhash.c

include $(BUILD_SHARED_LIBRARY)

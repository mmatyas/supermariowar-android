LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := enet

LOCAL_CFLAGS := -DHAS_SOCKLEN_T -O3 -ffast-math

LOCAL_C_INCLUDES := $(LOCAL_PATH)/include

LOCAL_SRC_FILES := \
	callbacks.c \
	compress.c \
	host.c \
	list.c \
	packet.c \
	peer.c \
	protocol.c \
	unix.c

include $(BUILD_SHARED_LIBRARY)

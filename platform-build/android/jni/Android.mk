
LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := libgl2jni
LOCAL_CFLAGS    := -Werror
LOCAL_SRC_FILES := 	gl_code.cpp \
    				esutil.c \
    				tp_opengles.c \
    				tp_opengles_oem.c \
    				
LOCAL_LDLIBS    := -lstdc++ -lc -lm -llog -ldl -lGLESv2  -lEGL  

include $(BUILD_SHARED_LIBRARY)

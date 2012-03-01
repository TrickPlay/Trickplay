
LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := libgl2jni
LOCAL_CFLAGS    := -Werror
LOCAL_SRC_FILES := 	gl_code.cpp \
    				esutil.c \
    				tp_opengles.c \
    				tp_opengles_oem.c \

LOCAL_LDLIBS    := -lstdc++ -lc -lm -llog -ldl \
                    -L ${PREFIX}/lib \
                    -landroid \
                    -latk-1.0 \
                    -lavahi-common \
                    -lavahi-core \
                    -lavahi-glib \
                    -lbz2 \
                    -lcairo \
                    -lcairo-gobject \
                    -lcares \
                    -lclutter-eglnative-1.0 \
                    -lclutteralphamode \
                    -lcogl \
                    -lcogl-pango \
                    -lcrypto \
                    -lcurl \
                    -lEGL \
                    -lexif \
                    -lexpat \
                    -lffi \
                    -lfontconfig \
                    -lfreetype \
                    -lgif \
                    -lgio-2.0 \
                    -lGLESv2 \
                    -lglib-2.0 \
                    -lgmodule-2.0 \
                    -lgobject-2.0 \
                    -lgthread-2.0 \
                    -liconv \
                    -lintl \
                    -lixml \
                    -ljpeg \
                    -ljson-glib-1.0 \
                    -lpango-1.0 \
                    -lpangocairo-1.0 \
                    -lpangoft2-1.0 \
                    -lpixman-1 \
                    -lpng \
                    -lpng15 \
                    -lsndfile \
                    -lsoup-2.4 \
                    -lsqlite3 \
                    -lssl \
                    -lthreadutil \
                    -ltiff \
                    -ltiffxx \
                    -ltpcore \
                    -ltplua \
                    -lupnp \
                    -luriparser \
                    -luuid \
                    -lxml2 \
                    -lz


include $(BUILD_SHARED_LIBRARY)

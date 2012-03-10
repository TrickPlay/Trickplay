ORIG_PATH       :=  $(call my-dir)
LOCAL_PATH      :=  ${TRICKPLAY_PDK_DIR}

include $(CLEAR_VARS)
LOCAL_MODULE    :=  atk-1.0
LOCAL_SRC_FILES :=  lib/libatk-1.0.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	avahi-common
LOCAL_SRC_FILES	:=	lib/libavahi-common.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	avahi-core
LOCAL_SRC_FILES	:=	lib/libavahi-core.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	avahi-glib
LOCAL_SRC_FILES	:=	lib/libavahi-glib.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	bz2
LOCAL_SRC_FILES	:=	lib/libbz2.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	cairo
LOCAL_SRC_FILES	:=	lib/libcairo.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	cairo-gobject
LOCAL_SRC_FILES	:=	lib/libcairo-gobject.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	cares
LOCAL_SRC_FILES	:=	lib/libcares.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	clutter-eglnative-1.0
LOCAL_SRC_FILES	:=	lib/libclutter-eglnative-1.0.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	clutteralphamode
LOCAL_SRC_FILES	:=	lib/libclutteralphamode.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	cogl
LOCAL_SRC_FILES	:=	lib/libcogl.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	cogl-pango
LOCAL_SRC_FILES	:=	lib/libcogl-pango.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	crypto
LOCAL_SRC_FILES	:=	lib/libcrypto.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	curl
LOCAL_SRC_FILES	:=	lib/libcurl.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	exif
LOCAL_SRC_FILES	:=	lib/libexif-tp.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	expat-tp
LOCAL_SRC_FILES	:=	lib/libexpat-tp.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	ffi
LOCAL_SRC_FILES	:=	lib/libffi.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	fontconfig
LOCAL_SRC_FILES	:=	lib/libfontconfig.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	freetype
LOCAL_SRC_FILES	:=	lib/libfreetype.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	gif
LOCAL_SRC_FILES	:=	lib/libgif.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	gio-2.0
LOCAL_SRC_FILES	:=	lib/libgio-2.0.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	glib-2.0
LOCAL_SRC_FILES	:=	lib/libglib-2.0.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	gmodule-2.0
LOCAL_SRC_FILES	:=	lib/libgmodule-2.0.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	gobject-2.0
LOCAL_SRC_FILES	:=	lib/libgobject-2.0.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	gthread-2.0
LOCAL_SRC_FILES	:=	lib/libgthread-2.0.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	iconv
LOCAL_SRC_FILES	:=	lib/libiconv.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	intl
LOCAL_SRC_FILES	:=	lib/libintl.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	ixml
LOCAL_SRC_FILES	:=	lib/libixml.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	jpeg.8
LOCAL_SRC_FILES	:=	lib/libjpeg.8.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	json-glib-1.0
LOCAL_SRC_FILES	:=	lib/libjson-glib-1.0.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	pango-1.0
LOCAL_SRC_FILES	:=	lib/libpango-1.0.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	pangocairo-1.0
LOCAL_SRC_FILES	:=	lib/libpangocairo-1.0.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	pangoft2-1.0
LOCAL_SRC_FILES	:=	lib/libpangoft2-1.0.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	pixman-1
LOCAL_SRC_FILES	:=	lib/libpixman-1.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	png
LOCAL_SRC_FILES	:=	lib/libpng.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	png15
LOCAL_SRC_FILES	:=	lib/libpng15.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	sndfile
LOCAL_SRC_FILES	:=	lib/libsndfile.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	soup-2.4
LOCAL_SRC_FILES	:=	lib/libsoup-2.4.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	sqlite3
LOCAL_SRC_FILES	:=	lib/libsqlite3.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	ssl
LOCAL_SRC_FILES	:=	lib/libssl.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	threadutil
LOCAL_SRC_FILES	:=	lib/libthreadutil.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	tiff
LOCAL_SRC_FILES	:=	lib/libtiff.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	tiffxx
LOCAL_SRC_FILES	:=	lib/libtiffxx.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	tpcore
LOCAL_SRC_FILES	:=	lib/libtpcore.a
LOCAL_EXPORT_C_INCLUDES :=  $(LOCAL_PATH)/include
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	tplua
LOCAL_SRC_FILES	:=	lib/libtplua.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	upnp
LOCAL_SRC_FILES	:=	lib/libupnp.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	uriparser
LOCAL_SRC_FILES	:=	lib/liburiparser.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	uuid
LOCAL_SRC_FILES	:=	lib/libuuid.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	xml2
LOCAL_SRC_FILES	:=	lib/libxml2.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE	:=	zlib
LOCAL_SRC_FILES	:=	lib/libz.a
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_PATH := $(ORIG_PATH)

include $(CLEAR_VARS)
LOCAL_MODULE    := tp-implementation
LOCAL_CFLAGS    := -Werror
LOCAL_SRC_FILES := 	\
    				main.cpp

LOCAL_STATIC_LIBRARIES  :=  \
                            ssl \
                            crypto \
                            libbz2 \
                            zlib \
                            tpcore

LOCAL_SHARED_LIBRARIES  :=  \
                            clutteralphamode \
                            tplua \
                            soup-2.4 \
                            sndfile \
                            uuid \
                            uriparser \
                            upnp \
                            ixml \
                            threadutil \
                            avahi-glib \
                            avahi-core \
                            avahi-common \
                            clutter-eglnative-1.0 \
                            cogl-pango \
                            cogl \
                            atk-1.0 \
                            json-glib-1.0 \
                            gif \
                            tiffxx \
                            tiff \
                            jpeg.8 \
                            pangocairo-1.0 \
                            pangoft2-1.0 \
                            pango-1.0 \
                            cairo-gobject \
                            cairo \
                            png15 \
                            pixman-1 \
                            fontconfig \
                            freetype \
                            curl \
                            cares \
                            sqlite3 \
                            gio-2.0 \
                            gmodule-2.0 \
                            glib-2.0 \
                            gobject-2.0 \
                            gthread-2.0 \
                            exif \
                            ffi \
                            xml2 \
                            expat-tp \
                            intl \
                            iconv \
                            gnustl_shared

LOCAL_CPP_FEATURES := exceptions
LOCAL_LDLIBS    :=  -lstdc++ -lc -lm -llog -ldl -landroid -lEGL -lGLESv2
include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE    := tp-wrapper
LOCAL_SRC_FILES :=  android-glue.cpp unzip.cpp
LOCAL_CPPFLAGS :=  -Wall -Wpointer-arith -Wcast-align
LOCAL_STATIC_LIBRARIES  :=  android_native_app_glue
LOCAL_LDLIBS    :=  -llog -ldl -landroid
include $(BUILD_SHARED_LIBRARY)

$(call import-module,android/native_app_glue)

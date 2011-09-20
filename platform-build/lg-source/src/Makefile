TP_DIR			= ..
#CC				= $(TOOL_BIN)/arm-montavista-linux-gnueabi-gcc

include $(TP_DIR)/config.mk

#=========================================================================
# Directories
#=========================================================================
OBJ_DIR			= $(TP_DIR)/objs
BIN_DIR			= $(TP_DIR)/bin

#=========================================================================
# Targets
#=========================================================================
TARGET			= $(BIN_DIR)/trickplay

#=========================================================================
# Defines
#=========================================================================
THIS_DEFINES	=
THIS_DEFINES	+= _REENTRANT
THIS_DEFINES	+= _GNU_SOURCE
ifeq ($(DEBUG_MODE), YES)
THIS_DEFINES	+= _TP_DEBUG
endif
ifeq ($(USE_DRM_ENCRYPTED_APP), YES)
THIS_DEFINES	+= USE_DRM_ENCRYPTED_APP
endif
ifeq ($(MOUSE_SUPPORTED), YES)
THIS_DEFINES	+= MOUSE_SUPPORTED
endif
ifeq ($(MEDIA_PLAYER_SUPPORTED), YES)
THIS_DEFINES	+= MEDIA_PLAYER_SUPPORTED
endif
ifeq ($(LIBJPEG_SUPPORTS_MEMSRC), YES)
THIS_DEFINES	+= LIBJPEG_SUPPORTS_MEMSRC
endif

#=========================================================================
# Includes and Sources
#=========================================================================
THIS_INCLUDES	=
THIS_INCLUDES	+= $(TP_DIR)/include
THIS_INCLUDES	+= $(TP_DIR)/include/opengles	# for OpenGL ES headers
THIS_INCLUDES	+= $(TP_DIR)/include/addon/
THIS_INCLUDES	+= $(TP_DIR)/include/opensource/zlib
THIS_INCLUDES	+= $(TP_DIR)/include/opensource/libpng
THIS_INCLUDES	+= $(TP_DIR)/include/opensource/libjpeg
THIS_INCLUDES	+= $(TP_DIR)/include/opensource/giflib
THIS_INCLUDES	+= ${TRICKPLAY_INCLUDE}

C_NAMES			=
C_NAMES			+= map
C_NAMES			+= tp_controller
C_NAMES			+= tp_drm
C_NAMES			+= tp_imagedecoder
C_NAMES			+= tp_playclip
C_NAMES			+= tp_playstream
C_NAMES			+= tp_port
C_NAMES			+= tp_mediaplayer
C_NAMES			+= tp_opengles
C_NAMES			+= tp_system
C_NAMES			+= tp_util
C_NAMES			+= main

#=========================================================================
# Libraries and Path
#=========================================================================
INCLUDE_MODULE	=

# TrickPlay core library
INCLUDE_MODULE	+= tpcore

# OpenGL ES
INCLUDE_MODULE	+= EGL
INCLUDE_MODULE	+= GLESv2
INCLUDE_MODULE	+= Mali

# Opensource dependencies
INCLUDE_MODULE	+= atk-1.0
INCLUDE_MODULE	+= avahi-common
INCLUDE_MODULE	+= avahi-core
INCLUDE_MODULE	+= avahi-glib
INCLUDE_MODULE	+= cairo-gobject
INCLUDE_MODULE	+= cairo
INCLUDE_MODULE	+= cares
INCLUDE_MODULE	+= clutter-eglnative-1.0
INCLUDE_MODULE	+= curl
INCLUDE_MODULE	+= exif
INCLUDE_MODULE	+= expat
INCLUDE_MODULE	+= fontconfig
INCLUDE_MODULE	+= freetype
INCLUDE_MODULE	+= gif
INCLUDE_MODULE	+= gio-2.0
INCLUDE_MODULE	+= glib-2.0
INCLUDE_MODULE	+= gmodule-2.0
INCLUDE_MODULE	+= gobject-2.0
INCLUDE_MODULE	+= gthread-2.0
INCLUDE_MODULE	+= ixml
INCLUDE_MODULE	+= jpeg
INCLUDE_MODULE	+= json-glib-1.0
INCLUDE_MODULE	+= pango-1.0
INCLUDE_MODULE	+= pangocairo-1.0
INCLUDE_MODULE	+= pangoft2-1.0
INCLUDE_MODULE	+= pixman-1
INCLUDE_MODULE	+= png12
INCLUDE_MODULE	+= sndfile
INCLUDE_MODULE	+= soup-2.4
INCLUDE_MODULE	+= sqlite3
INCLUDE_MODULE	+= threadutil
INCLUDE_MODULE	+= tiff
INCLUDE_MODULE	+= tiffxx
INCLUDE_MODULE	+= upnp
INCLUDE_MODULE	+= uriparser
INCLUDE_MODULE	+= uuid
INCLUDE_MODULE	+= xml2

# System supported dependencies
INCLUDE_MODULE	+= pthread
INCLUDE_MODULE	+= resolv
INCLUDE_MODULE	+= rt

# LG supported libraries
INCLUDE_MODULE	+= openapi
ifeq ($(USE_DRM_ENCRYPTED_APP), YES)
INCLUDE_MODULE	+= ncg_agent
endif
INCLUDE_MODULE	+= ncg_agent

LIB_PATHS		=
LIB_PATHS		+= $(TP_DIR)/lib/lglib
LIB_PATHS		+= $(TP_DIR)/lib/opengles
LIB_PATHS		+= ${TRICKPLAY_LIB}

#=========================================================================
# Aggregations
#=========================================================================
SRCS			= $(addsuffix .c, $(C_NAMES))
OBJS			= $(foreach src, $(SRCS), $(OBJ_DIR)/$(src:.c=.o))

INCLUDES		= $(addprefix -I, $(THIS_INCLUDES))
DEFINES			= $(addprefix -D, $(THIS_DEFINES))
LIBS			= $(addprefix -l, $(INCLUDE_MODULE))
LDPATHS			= $(addprefix -L, $(LIB_PATHS))

CFLAGS			= $(INCLUDES) $(DEFINES)
CFLAGS			+= -Wall -Wstrict-prototypes -fPIC
ifeq ($(DEBUG_MODE), YES)
CFLAGS			+= -O0 -g
else
CFLAGS			+= -O2
endif
LDFLAGS			= -Wl,--start-group $(LIBS) $(LDPATHS) -Wl,--end-group

#=========================================================================
# Make Rules
#=========================================================================
all: $(TARGET)

$(TARGET): $(OBJS)
	@test -d $(BIN_DIR) || mkdir -p $(BIN_DIR)
	@$(CC) $^ $(LDFLAGS) -o $@

$(OBJ_DIR)/%.i %.i: %.c
	@test -d $(dir $@) || mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -o $@ -E $<

$(OBJ_DIR)/%.o %.o: %.c
	@test -d $(dir $@) || mkdir -p $(dir $@)
	@$(CC) -MMD -MF $@.P $(CFLAGS) -o $@ -c $<
	@echo "$@ $(@:.o=.d) : $< \\" > $(@:.o=.d)
	@rm -f $@.P

clean:
	@rm -f $(OBJS) $(TARGET)

clobber:
	@rm -f $(OBJS) $(OBJS:.o=.d) $(TARGET)

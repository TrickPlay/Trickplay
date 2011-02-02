#=========================================================================
# Tool Chain
#=========================================================================
CROSS_COMPILE	= /opt/toolchains/crosstools_hf-linux-2.6.18.0_gcc-4.2-11ts_uclibc-nptl-0.9.29-20070423_20090508/bin/mipsel-uclibc-
SRC_ROOT		= ..
PLATFORM_NAME	= bcm35230

CC				= $(CROSS_COMPILE)gcc
DEST_OS			= linux
MKBIZ			= $(SRC_ROOT)/utils/mkbiz

#=========================================================================
# Compiler Options
#=========================================================================
CFLAGS			= -g -Wall -Wstrict-prototypes -fPIC

#=========================================================================
# Directory
#=========================================================================
LIB_DIR			= ../lib

ELF_TARGET		= trickplay
SYM_TARGET		= $(ELF_TARGET).sym

C_NAMES			= \
				main \
				tp_system \
				tp_drm \
				tp_controller \
				tp_imagedecoder \
				tp_mediaplayer \
				tp_util

#=========================================================================
# Include Module and Path
#=========================================================================
INCLUDE_MODULE	=

# TrickPlay core library
INCLUDE_MODULE	+= tpcore

# statically linked dependencies
INCLUDE_MODULE  += atk-1.0
INCLUDE_MODULE	+= avahi-common
INCLUDE_MODULE	+= avahi-core
INCLUDE_MODULE	+= avahi-glib
INCLUDE_MODULE	+= cairo
INCLUDE_MODULE	+= cares
INCLUDE_MODULE	+= clutter-eglnative-1.0
INCLUDE_MODULE	+= crypto
INCLUDE_MODULE	+= curl
INCLUDE_MODULE	+= expat
INCLUDE_MODULE	+= fontconfig
INCLUDE_MODULE	+= freetype
INCLUDE_MODULE	+= gif
INCLUDE_MODULE	+= gio-2.0
INCLUDE_MODULE	+= glib-2.0
INCLUDE_MODULE	+= gmodule-2.0
INCLUDE_MODULE	+= gobject-2.0
INCLUDE_MODULE	+= gthread-2.0
INCLUDE_MODULE	+= iconv
INCLUDE_MODULE	+= intl
INCLUDE_MODULE	+= ixml
INCLUDE_MODULE	+= jpeg
INCLUDE_MODULE	+= json-glib-1.0
INCLUDE_MODULE	+= pango-1.0
INCLUDE_MODULE	+= pangocairo-1.0
INCLUDE_MODULE	+= pangoft2-1.0
INCLUDE_MODULE	+= pixman-1
INCLUDE_MODULE	+= png
INCLUDE_MODULE	+= sqlite3
INCLUDE_MODULE	+= ssl
INCLUDE_MODULE	+= threadutil
INCLUDE_MODULE	+= tiff
INCLUDE_MODULE	+= tiffxx
INCLUDE_MODULE	+= upnp
INCLUDE_MODULE  += uprof-0.3
INCLUDE_MODULE	+= uriparser
INCLUDE_MODULE	+= uuid
INCLUDE_MODULE	+= z

# dynamically linked dependencies
INCLUDE_MODULE	+= pthread
INCLUDE_MODULE	+= resolv
INCLUDE_MODULE	+= rt

# LG supported libraries
INCLUDE_MODULE	+= rpc4dtv
INCLUDE_MODULE	+= opengles
INCLUDE_MODULE	+= openapi
INCLUDE_MODULE	+= freespacealg
INCLUDE_MODULE	+= pointer
INCLUDE_MODULE	+= goa
INCLUDE_MODULE	+= ncg_agent
INCLUDE_MODULE	+= lgexc

INCLUDE_LDPATHS	=
INCLUDE_LDPATHS	+= $(LIB_DIR)/lglib
INCLUDE_LDPATHS	+= $(TRICKPLAY_LIB)

THIS_INCLUDES	=
THIS_INCLUDES	+= ../include
THIS_INCLUDES	+= ../include/addon
THIS_INCLUDES	+= ../include/opengles
THIS_INCLUDES	+= $(TRICKPLAY_INCLUDE)

THIS_DEFINES	= \
				_GNU_SOURCE \
				_REENTRANT \
				__LINUX_OS__ \
				_LINUX \
				NEXUS_HAS_GRAPHICS3D \
				NULL_PLATFORM \
				_TP_DEBUG \
				USE_HW_IMAGEDECODER \
				LIBJPEG_MEMSRC_SUPPORT

LDPATHS			= $(addprefix -L, $(INCLUDE_LDPATHS))
LIBS			= $(addprefix -l, $(INCLUDE_MODULE))
LDFLAGS			= $(LDPATHS) $(LIBS)
MKBIZ_OPTS		= -a 0x47

INCLUDES		= $(addprefix -I, $(THIS_INCLUDES))
DEFINES			= $(addprefix -D, $(THIS_DEFINES))
CFLAGS			+= $(INCLUDES) $(DEFINES)
OBJ_FILES		+= $(addsuffix .o, $(C_NAMES))

#=========================================================================
# Make All
#=========================================================================
all: $(ELF_TARGET) $(SYM_TARGET)

$(ELF_TARGET): $(OBJ_FILES)
	@$(CC) -o $@ -Wl,--start-group $^ $(LDFLAGS) -Wl,--end-group

$(SYM_TARGET): $(ELF_TARGET)
	@$(MKBIZ) $(MKBIZ_OPTS) $<

.c.o:
	@$(CC) $< -c -o $@ $(CFLAGS)

clean :
	@rm -f $(ELF_TARGET) $(SYM_TARGET) $(OBJ_FILES)

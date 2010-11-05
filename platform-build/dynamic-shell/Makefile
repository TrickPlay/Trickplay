TARGET			= libtrickplay.so

#=========================================================================
# Tool Chain
#=========================================================================
CROSS_COMPILE	= /opt/toolchains/crosstools_hf-linux-2.6.18.0_gcc-4.2-11ts_uclibc-nptl-0.9.29-20070423_20090508/bin/mipsel-uclibc-

CC				= $(CROSS_COMPILE)gcc
#CC				= gcc
PRODSYNC		= /prod/bin/prodsync

#=========================================================================
# Compiler Options
#=========================================================================
CFLAGS			= -g -Wall -Wstrict-prototypes -fPIC
CXXFLAGS		= -g -Wall -fPIC

#=========================================================================
# Directory
#=========================================================================
OBJ_DIR			= obj
LIB_DIR			= lib
SHARE_DIR		= /share/global_platform/bcm35230/wongi.hong/addon/lib

SRCS			=
SRCS			+= tp_main.c
SRCS			+= tp_controller.c
SRCS			+= tp_imagedecoder.c
SRCS			+= tp_mediaplayer.c

OBJS			= $(foreach src, $(SRCS), $(OBJ_DIR)/$(src:.c=.o))

#=========================================================================
# Include Module and Path
#=========================================================================
INCLUDE_MODULE	=
INCLUDE_MODULE	+= asprintf
INCLUDE_MODULE	+= avahi-common
INCLUDE_MODULE	+= avahi-core
INCLUDE_MODULE	+= avahi-glib
INCLUDE_MODULE	+= bz2
INCLUDE_MODULE	+= cairo
INCLUDE_MODULE	+= cares
INCLUDE_MODULE	+= clutter-eglnative-1.0
INCLUDE_MODULE	+= crypto
INCLUDE_MODULE	+= curl
INCLUDE_MODULE	+= expat
INCLUDE_MODULE	+= fontconfig
INCLUDE_MODULE	+= freetype
INCLUDE_MODULE	+= gettextpo
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
INCLUDE_MODULE	+= uriparser
INCLUDE_MODULE	+= uuid
INCLUDE_MODULE	+= z
INCLUDE_MODULE	+= tpcore

INCLUDE_LDPATHS	= $(LIB_DIR)

THIS_INCLUDES	= include
THIS_DEFINES	= 				\
				_GNU_SOURCE		\
				_REENTRANT		\
				__LINUX_OS__	\
				_LINUX			\
				_TP_DEBUG

LDPATHS			= $(addprefix -L, $(INCLUDE_LDPATHS))
LIBS			= $(addprefix -l, $(INCLUDE_MODULE))

INCLUDES		= $(addprefix -I, $(THIS_INCLUDES))
DEFINES			= $(addprefix -D, $(THIS_DEFINES))
CFLAGS			+= $(DEFINES)

#=========================================================================
# Make All
#=========================================================================
all: $(TARGET)

install: $(TARGET)
	@test -d $(SHARE_DIR) || mkdir -p $(SHARE_DIR)
	@cp -f $^ $(SHARE_DIR) && $(PRODSYNC) $(SHARE_DIR)/$^

$(TARGET): $(OBJS)
	@test -d $(LIB_DIR) || mkdir -p $(LIB_DIR)
	$(CC) -shared -o $@ $^ $(LDPATHS) -Wl,--start-group $(LIBS) -Wl,--end-group -nostartfiles

$(OBJ_DIR)/%.o: %.c
	@test -d $(dir $@) || mkdir -p $(dir $@)
	$(CC) $< -c -o $@ $(CFLAGS) $(INCLUDES)

clean:
	rm -f $(TARGET) $(OBJS)

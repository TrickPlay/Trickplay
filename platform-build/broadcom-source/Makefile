############################################################

ifndef NEXUS_TOP
ifdef COMSPEC
# Any DOS environment
NEXUS_TOP := $(shell cd ../../../../nexus && cd)
else
NEXUS_TOP := $(shell cd ../../../../nexus; pwd)
endif
endif

ifndef PLATFORM
$(error PLATFORM is not defined)
endif

ifndef V3DIP_REV
$(error V3DIP_REV is not defined - 35230A0/B0, export V3DIP_REV=v3d_a1.  35230C0, export V3DIP_REV=v3d_b0/interface)
endif

# include cross-compiler definitions
include $(NEXUS_TOP)/platforms/$(PLATFORM)/build/platform_app.inc

THEAPPS = trickplay

CFLAGS += -lm
CFLAGS += -I$(MAGNUM)/../rockford/middleware/$(V3DIP_REV)/khronos/include/

APPS = $(THEAPPS)

.PHONY: api clean

ifeq ($(APP),)
all: $(APPS)
$(APPS): api
else
all: $(APP)
$(APP): api
endif

# For linux builds, link to the correct libraries
ifneq ($(findstring linux,$(B_REFSW_OS)),)
LDFLAGS := -lnexus -L${NEXUS_BIN_DIR} -lpthread
endif

# This builds the nexus api
api:
	$(MAKE) -C $(NEXUS_TOP)/build

# This cleans nexus and local apps
clean:
	$(MAKE) -C $(NEXUS_TOP)/build clean
	-$(RM) $(APPS) *.d *.o *.out;

# This is the minimum needed to compile and link with Nexus
CFLAGS += $(NEXUS_CFLAGS) $(addprefix -I,$(NEXUS_APP_INCLUDE_PATHS)) $(addprefix -D,$(NEXUS_APP_DEFINES)) -I$(NEXUS_TOP)/../BSEAV/lib/netaccel/include

# Always build with debug
CFLAGS += -g

ifndef TRICKPLAY_INCLUDE
$(error TRICKPLAY_INCLUDE is not defined)
endif

ifndef TRICKPLAY_LIB
$(error TRICKPLAY_LIB is not defined)
endif


CFLAGS += -I$(TRICKPLAY_INCLUDE)

LDFLAGS += -L$(TRICKPLAY_LIB) \
    -Wl,--start-group \
    -ltpcore \
	-ljson-glib-1.0 \
	-latk-1.0 \
	-lclutter-eglnative-1.0 \
	-lavahi-core \
	-lavahi-common \
	-lavahi-glib \
	-lpango-1.0 \
	-lpangocairo-1.0 \
	-lpangoft2-1.0 \
	-lcairo \
	-lpixman-1 \
	-lpng12 \
	-lpng \
	-ltiff \
	-ltiffxx \
	-lgif \
	-ljpeg \
	-lfontconfig \
	-lfreetype \
	-lexpat \
	-lbz2 \
	-lcurl \
	-lcares \
	-lz \
	-lssl \
	-lcrypto \
	-lsqlite3 \
	-lgio-2.0 \
	-lgmodule-2.0 \
	-lgobject-2.0 \
	-lglib-2.0 \
	-lgthread-2.0 \
	-lrt \
	-lresolv \
	-ldl \
	-luuid \
	-luriparser \
	-lupnp \
	-lixml \
	-lthreadutil \
	-lstdc++  \
	-lintl \
	-liconv \
	-lcairo-gobject \
	-luprof-0.3 \
	-lsndfile \
	-Wl,--end-group 


# Implicit rule for building local apps
%$(APPSUFFIX): %.c $(EXTRA_OBJS) $(VXOBJS)
	@echo [Compile... $<]
	$(Q_)$(CC) -o $@ $(filter %.c %.s %.o, $^) $(CFLAGS) $(LDFLAGS)
	cp $@ ${NEXUS_BIN_DIR}

install: all


CLUTTER_LIBS = `pkg-config --libs clutter-1.0`
CLUTTER_INCS = `pkg-config --cflags clutter-1.0`

TOKYO_INCS = -I/opt/local/include
TOKYO_LIBS = -L/opt/local/lib -ltokyocabinet -ltokyotyrant

LUA_LIBS = -I/opt/local/include
LUA_INCS = -L/opt/local/lib -llua

DIRS = UI Storage

TRICKPLAY_INCS = $(foreach dir,$(DIRS),$(dir)/$(dir).h)
TRICKPLAY_LIBS = $(TRICKPLAY_INCS:%.h=%.a)

INCS = $(LUA_INCS) $(CLUTTER_INCS) $(TOKYO_INCS)
LIBS = $(LUA_LIBS) $(CLUTTER_LIBS) $(TOKYO_LIBS) $(TRICKPLAY_LIBS)

SOURCES = \
	trickplay-host.cpp


all: trickplay-host

trickplay-host: $(TRICKPLAY_HEADERS) $(SOURCES) subdirs
	$(CXX) $(INCS) $(LIBS) -O3 -Wall $(CFLAGS) -o $@ $(SOURCES)

subdirs:
	for dir in $(DIRS) ; do ( cd $$dir ; ${MAKE} all ) ; done

clean:
	for dir in $(DIRS); do ( cd $$dir ; ${MAKE} clean ) ; done
	rm -fr *.o trickplay-host

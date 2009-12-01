CLUTTER_LIBS = `pkg-config --libs clutter-1.0`
CLUTTER_INCS = `pkg-config --cflags clutter-1.0`

TOKYO_INCS = -I/opt/local/include
TOKYO_LIBS = -L/opt/local/lib -ltokyocabinet -ltokyotyrant

LUA_LIBS = -I/opt/local/include
LUA_INCS = -L/opt/local/lib -llua

INCS = $(LUA_INCS) $(CLUTTER_INCS) $(TOKYO_INCS)
LIBS = $(LUA_LIBS) $(CLUTTER_LIBS) $(TOKYO_LIBS) UI/UI.a Storage/Storage.a

DIRS = UI Storage

SOURCES = \
	trickplay-host.cpp

HEADERS = \
	UI/UI.h

all: subdirs trickplay-host

trickplay-host: $(HEADERS) $(SOURCES)
	$(CXX) $(INCS) $(LIBS) -O3 -Wall $(CFLAGS) -o $@ $(SOURCES)

subdirs:
	for dir in $(DIRS) ; do ( cd $$dir ; ${MAKE} all ) ; done

clean:
	for dir in $(DIRS); do ( cd $$dir ; ${MAKE} clean ) ; done
	rm -fr *.o trickplay-host

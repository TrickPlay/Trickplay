CLUTTER_LIBS = `pkg-config --libs clutter-1.0`
CLUTTER_INCS = `pkg-config --cflags clutter-1.0`

LUA_LIBS = -I/opt/local/include
LUA_INCS = -L/opt/local/lib -llua

INCS = $(LUA_INCS) $(CLUTTER_INCS)
LIBS = $(LUA_LIBS) $(CLUTTER_LIBS) UI/UI.a

DIRS = UI

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

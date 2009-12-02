CLUTTER_LIBS = `pkg-config --libs clutter-1.0`
CLUTTER_INCS = `pkg-config --cflags clutter-1.0`

TOKYO_INCS = -I/opt/local/include
TOKYO_LIBS = -L/opt/local/lib -ltokyocabinet -ltokyotyrant

CURL_INCS = `curl-config --cflags`
CURL_LIBS = `curl-config --libs`

LUA_LIBS = -I/opt/local/include
LUA_INCS = -L/opt/local/lib -llua

DIRS = UI Storage Network

TRICKPLAY_INCS = $(foreach dir,$(DIRS),$(dir)/$(dir).h)
TRICKPLAY_LIBS = $(TRICKPLAY_INCS:%.h=%.a)

INCS = $(LUA_INCS) $(CLUTTER_INCS) $(TOKYO_INCS) $(CURL_INCS)
LIBS = $(LUA_LIBS) $(CLUTTER_LIBS) $(TOKYO_LIBS) $(CURL_LIBS) $(TRICKPLAY_LIBS)

SOURCES = \
	trickplay-host.cpp


all: trickplay-host

trickplay-host: $(TRICKPLAY_HEADERS) $(SOURCES) $(TRICKPLAY_LIBS)
	$(CXX) $(INCS) $(LIBS) -O3 -Wall $(CFLAGS) -o $@ $(SOURCES)

.PHONY: subdirs $(DIRS)

subdirs: $(DIRS)

$(DIRS):
	$(MAKE) -C $@

$(TRICKPLAY_LIBS): $(DIRS)

.PHONY: clean

clean:
	for dir in $(DIRS); do ( cd $$dir ; ${MAKE} clean ) ; done
	rm -fr *.o trickplay-host

CLUTTER_LIBS=`pkg-config --libs clutter-1.0`
CLUTTER_INCS=`pkg-config --cflags clutter-1.0`

LUA_LIBS=-I/opt/local/include
LUA_INCS=-L/opt/local/lib -llua

INCS=$(LUA_INCS) $(CLUTTER_INCS)
LIBS=$(LUA_LIBS) $(CLUTTER_LIBS)

SOURCES= \
	clutter-host.cpp \
	clutter-timeline.cpp \
	clutter-stage.cpp

HEADERS= \
	clutter-timeline.h \
	clutter-stage.h

all: clutter-host

clutter-host: $(HEADERS) $(SOURCES)
	$(CXX) $(INCS) $(LIBS) -O3 -Wall $(CFLAGS) -o $@ $(SOURCES)

clean:
	rm -fr *.o clutter-host

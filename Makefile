CLUTTER_LIBS=`pkg-config --libs clutter-1.0`
CLUTTER_INCS=`pkg-config --cflags clutter-1.0`

LUA_LIBS=-I/opt/local/include
LUA_INCS=-L/opt/local/lib -llua

INCS=$(LUA_INCS) $(CLUTTER_INCS)
LIBS=$(LUA_LIBS) $(CLUTTER_LIBS)

all: clutter-host

clutter-host: clutter-host.cpp
	$(CXX) $(INCS) $(LIBS) -g -Wall $(CFLAGS) -o $@ $<

clean:
	rm -fr *.o clutter-host

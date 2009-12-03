CLUTTER_INCS = `pkg-config --cflags clutter-1.0`

LUA_INCS = -I/opt/local/include

INCS = $(LUA_INCS) $(CLUTTER_INCS)

SOURCES = \
	UI.cpp \
	UI-stage.cpp \
	UI-timeline.cpp

HEADERS = \
	UI.h \
	UI-stage.h \
	UI-timeline.h

OBJECTS = $(patsubst %.cpp,%.o,$(SOURCES))

%.o: %.cpp %.h
	$(CXX) $(INCS) -g -Wall $(CFLAGS) -c -o $@ $<

all: UI.a

UI.a: $(OBJECTS)
	libtool -static -o $@ $^

clean:
	rm -fr *.o *.a

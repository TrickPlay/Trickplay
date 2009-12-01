LUA_INCS = -I/opt/local/include

INCS = $(LUA_INCS)

SOURCES = \
	Storage.cpp \
	Storage-local.cpp \
	Storage-cloud.cpp \
	Storage-remote.cpp

HEADERS = \
	Storage.h \
	Storage-local.h \
	Storage-cloud.h \
	Storage-remote.h

OBJECTS = $(patsubst %.cpp,%.o,$(SOURCES))

%.o: %.cpp %.h
	$(CXX) $(INCS) -O3 -Wall $(CFLAGS) -c -o $@ $<

all: Storage.a

Storage.a: $(OBJECTS)
	libtool -static -o $@ $^

clean:
	rm -fr *.o *.a

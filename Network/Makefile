CURL_INCS = `curl-config --cflags`

LUA_INCS = -I/opt/local/include

INCS = $(LUA_INCS) $(CURL_INCS)

SOURCES = \
	Network.cpp \
	Network-curl.cpp

HEADERS = \
	Network.h \
	Network-curl.h

OBJECTS = $(patsubst %.cpp,%.o,$(SOURCES))

%.o: %.cpp %.h
	$(CXX) $(INCS) -O3 -Wall $(CFLAGS) -c -o $@ $<

all: Network.a

Network.a: $(OBJECTS)
	libtool -static -o $@ $^

clean:
	rm -fr *.o *.a

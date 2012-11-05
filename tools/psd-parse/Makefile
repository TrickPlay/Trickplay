
CFLAGS+=`pkg-config --cflags glib-2.0`
CFLAGS+=`pkg-config --cflags gio-2.0`
CFLAGS+=`pkg-config --cflags MagickCore`
LDFLAGS+=`pkg-config --libs glib-2.0`
LDFLAGS+=`pkg-config --libs gio-2.0`
LDFLAGS+=`pkg-config --libs MagickCore`

all: psd-parse

psd-parse: psd-parse.cpp
	$(CXX) -Wall -Wextra -g -o psd-parse $(CFLAGS) $(LDFLAGS) psd-parse.cpp

clean:
	rm psd-parse

LIBS=`pkg-config --libs gio-2.0 glib-2.0 json-glib-1.0 MagickCore`
INCS=`pkg-config --cflags gio-2.0 glib-2.0 json-glib-1.0 MagickCore`

.c.o: item.h leaf.h main.h
	$(CC) -g -Wall $(CFLAGS) $(INCS) -c $*.c

all: stitcher

stitcher: main.o item.o leaf.o options.o output.o layout.o
	$(CC) -g -Wall $(CFLAGS) -o $@ $^ -lm $(LIBS)

clean:
	rm -fr *.o stitcher

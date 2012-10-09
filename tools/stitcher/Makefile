LIBS=`pkg-config --libs gio-2.0 MagickCore`
INCS=`pkg-config --cflags gio-2.0 MagickCore`

.c.o:
	$(CC) -g -Wall $(CFLAGS) $(INCS) -c $*.c

all: stitcher

stitcher: main.o
	$(CC) -g -Wall $(CFLAGS) -o $@ $^ -lm $(LIBS)

clean:
	rm -fr *.o stitcher

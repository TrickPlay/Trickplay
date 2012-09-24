LIBS=`pkg-config --libs clutter-1.0`
INCS=`pkg-config --cflags clutter-1.0`

.c.o:
	$(CC) -g -Wall $(CFLAGS) $(INCS) -c $*.c

all: stitcher

stitcher: main.o
	$(CC) -g -Wall $(CFLAGS) -o $@ $^ -lm $(LIBS)

clean:
	rm -fr *.o stitcher

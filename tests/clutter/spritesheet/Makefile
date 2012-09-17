LIBS=`pkg-config --libs clutter-1.0`
INCS=`pkg-config --cflags clutter-1.0`

.c.o: nineslice.h spritesheet.h
	$(CC) -g -Wall $(CFLAGS) $(INCS) -c $*.c

all: spritesheet

spritesheet: main.o nineslice.o spritesheet.o
	$(CC) -g -Wall $(CFLAGS) -o $@ $^ -lm $(LIBS)

clean:
	rm -fr *.o spritesheet

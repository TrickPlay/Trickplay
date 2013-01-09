LIBS=`pkg-config --libs clutter-1.0`
INCS=`pkg-config --cflags clutter-1.0`

%.o : %.c

.cpp.o: nineslice.cpp.h spritesheet.cpp.h
	$(CXX) -g -Wall $(CFLAGS) $(INCS) -c $*.cpp

all: spritesheet

spritesheet: main.o nineslice.o spritesheet.o
	$(CXX) -g -Wall $(CFLAGS) -o $@ $^ -lm $(LIBS)

clean:
	rm -fr *.o spritesheet

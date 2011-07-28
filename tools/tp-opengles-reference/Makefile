
#------------------------------------------------------------------------------
# Set CC to the full path to your C compiler, for example
# CC=/opt/toolchains/some-gcc/bin/gcc
TROOT=/opt/toolchains/arm-2009q3
CC=$(TROOT)/bin/arm-none-linux-gnueabi-gcc

#------------------------------------------------------------------------------
# Set CFLAGS to the include path where EGL and GLES2 directories are located

CFLAGS=-I../../platform-build/lg-source/include/opengles

#------------------------------------------------------------------------------
# Set LDFLAGS to -L<path to libEGL.so and libGLESv2.so> and add any additional
# libraries required.

LDFLAGS=-L../../platform-build/lg-source/lib/opengles -lMali

#------------------------------------------------------------------------------

all:
	$(CC) --sysroot=$(TROOT)/arm-none-linux-gnueabi/libc \
	-g -Wall -o tp_opengles $(CFLAGS) $(LDFLAGS) \
	-lEGL -lGLESv2 -lpthread \
	tp_opengles_oem.c tp_opengles.c esutil.c
	
clean:
	rm -f tp_opengles
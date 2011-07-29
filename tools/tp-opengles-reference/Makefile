
#------------------------------------------------------------------------------
# Set CC to the full path to your C compiler, for example
# CC=/opt/toolchains/some-gcc/bin/gcc

CC=gcc

#------------------------------------------------------------------------------
# Set CFLAGS to the include path where EGL and GLES2 directories are located

CFLAGS=

#------------------------------------------------------------------------------
# Set LDFLAGS to -L<path to libEGL.so and libGLESv2.so> and add any additional
# libraries required.

LDFLAGS=

#------------------------------------------------------------------------------

all:
	$(CC) -g -Wall -o tp_opengles $(CFLAGS) $(LDFLAGS) \
	-lEGL -lGLESv2 -lpthread \
	tp_opengles_oem.c tp_opengles.c esutil.c
	
clean:
	rm -f tp_opengles
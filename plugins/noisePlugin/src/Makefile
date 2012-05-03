#
# Makefile to create a sample TrickPlay C Shared-Library Plug-in
#

# Tool setup
CC=gcc
CFLAGS=-fPIC -c -Wall -I/home/calwas/code/trickplay/engine/public/include

# Default target
NoisePlugin: luaEntry.o perlinNoise.o perlinNoise.h
	$(CC) -shared -Wl,-soname,tp_lua_api-noise.so -o tp_lua_api-noise.so luaEntry.o perlinNoise.o -lc
	cp tp_lua_api-noise.so ../luaTest/plugins/.
	
# Supplementary targets
clean:
	rm -f *.o *.so

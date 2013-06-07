.PHONY: grid

all: grid

grid: grid-layout.c
	clang `pkg-config --cflags --libs clutter-1.0` $< -o $@

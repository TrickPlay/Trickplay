#!/bin/bash

export G_SLICE="always-malloc" 
export G_DEBUG="gc-friendly,resident-modules"

valgrind --tool=memcheck --leak-check=full --leak-resolution=high --num-callers=20 --suppressions="$PWD/trickplay.supp" $@


-------------------------------------------------------------------------------
Compiler
-------------------------------------------------------------------------------

(1) sudo mkdir /opt/toolchains

(2) cd /opt/toolchains

(3) sudo tar xjf crosstools_hf-linux-2.6.18.0_gcc-4.2-11ts_uclibc-nptl-0.9.29-20070423_20090508.tar.bz2

-------------------------------------------------------------------------------
Requirements
-------------------------------------------------------------------------------

(1) sudo apt-get install build-essential automake libtool intltool libglib2.0-dev cmake git-core

-------------------------------------------------------------------------------
Build
-------------------------------------------------------------------------------

(1) Create a new, empty directory, cd to it and run build.sh from there.

    This will:
    
    (a) Fetch and build all of the libraries we depend on.
    
    (b) Build a stub implementation of libGLES2.so

    (c) Build libtpcore.a
    
    (d) Attempt to build a final executable to spot link errors
    
    



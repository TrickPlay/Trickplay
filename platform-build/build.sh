#!/bin/bash

#------------------------------------------------------------------------------
#
# This script fetches and builds all of TrickPlay's dependencies.
#
# 1) With no parameters, it builds everything in order and keeps track of
#    what has been built in a file called "built". This lets it keep going where
#    it left off if there is a problem.
#
# 2) With only the parameter 'clean', it deletes the 'built' file and builds
#    everything in order - calling 'make clean' before each one.
#
# 3) With more paramaters, it builds only what is specified, ignoring what the
#    'built' file says. For example 'build.sh GLIB ZLIB' will only build GLIB
#    and ZLIB.
#
#    If one of the parameters is 'clean', it will do 'make clean' before
#    building each one.
#
# By default, stdout is redirected to /dev/null. To see all output, call the
# script like this: 'VERBOSE=1 ./build.sh <parameters>'
#
#------------------------------------------------------------------------------

set -u
set -e

#------------------------------------------------------------------------------
# This brings in the build environment

THERE=$(cd ${0%/*} && echo $PWD/${0##*/})
THERE=`dirname ${THERE}`

source "${THERE}/env"

#------------------------------------------------------------------------------
# glib

GLIB_MV="2.22"
GLIB_V="${GLIB_MV}.4"
GLIB_URL="http://ftp.acc.umu.se/pub/GNOME/sources/glib/${GLIB_MV}/glib-${GLIB_V}.tar.gz"
GLIB_DIST="glib-${GLIB_V}.tar.gz"
GLIB_SOURCE="glib-${GLIB_V}"
GLIB_COMMANDS="glib_cv_stack_grows=no glib_cv_uscore=no ac_cv_func_posix_getpwuid_r=yes ac_cv_func_posix_getgrgid_r=yes ./configure --prefix=$PREFIX --host=$HOST --build=$BUILD --disable-shared ${GLIB_ICONV} --with-pic && make install"

#------------------------------------------------------------------------------
# sqlite

SQLITE_V="3.6.22"
SQLITE_DIST="sqlite-amalgamation-${SQLITE_V}.tar.gz"
SQLITE_SOURCE="sqlite-${SQLITE_V}"
SQLITE_COMMANDS="./configure --prefix=$PREFIX --host=$HOST  --build=$BUILD --with-pic --disable-shared && make install"

#------------------------------------------------------------------------------
# openssl

OPENSSL_V="0.9.8l"
OPENSSL_URL="http://www.openssl.org/source/openssl-${OPENSSL_V}.tar.gz"
OPENSSL_DIST="openssl-${OPENSSL_V}.tar.gz"
OPENSSL_SOURCE="openssl-${OPENSSL_V}"
OPENSSL_COMMANDS="./Configure dist threads --prefix=$PREFIX -fPIC -D_REENTRANT && make CC=$CC RANLIB=$RANLIB AR=\"$AR r\" CXX=$CXX install"

#------------------------------------------------------------------------------
# zlib

ZLIB_V="1.2.3"
ZLIB_URL="http://www.zlib.net/zlib-${ZLIB_V}.tar.gz"
ZLIB_DIST="zlib-${ZLIB_V}.tar.gz"
ZLIB_SOURCE="zlib-${ZLIB_V}"
ZLIB_COMMANDS="make prefix=$PREFIX CC=\"$CC\" AR=\"$AR r\" CFLAGS=\"-fPIC\" install"

#------------------------------------------------------------------------------
# cares

CARES_V="1.7.0"
CARES_URL="http://c-ares.haxx.se/c-ares-${CARES_V}.tar.gz"
CARES_DIST="c-ares-${CARES_V}.tar.gz"
CARES_SOURCE="c-ares-${CARES_V}"
CARES_COMMANDS="./configure --prefix=$PREFIX --host=$HOST --build=$BUILD --disable-shared --with-pic && make install"

#------------------------------------------------------------------------------
# curl

CURL_V="7.20.0"
CURL_URL="http://curl.haxx.se/download/curl-${CURL_V}.tar.gz"
CURL_DIST="curl-${CURL_V}.tar.gz"
CURL_SOURCE="curl-${CURL_V}"
CURL_COMMANDS="./configure --prefix=$PREFIX --host=$HOST --build=$BUILD --disable-shared --with-pic --enable-ares --with-ssl --with-zlib --without-random --disable-file --disable-ldap --disable-ldaps --disable-rtsp --disable-telnet --disable-tftp --disable-pop3 --disable-imap --disable-smtp --disable-manual --disable-dict && make install"
CURL_DEPENDS="CARES ZLIB OPENSSL"
#------------------------------------------------------------------------------
# bzip

BZIP_V="1.0.5"
BZIP_URL="http://www.bzip.org/${BZIP_V}/bzip2-${BZIP_V}.tar.gz"
BZIP_DIST="bzip2-${BZIP_V}.tar.gz"
BZIP_SOURCE="bzip2-${BZIP_V}"
BZIP_COMMANDS="make CC=\"$CC\" AR=\"$AR\" RANLIB=\"$RANLIB\" LDFLAGS=\"$LDFLAGS\" CFLAGS=\"-fPIC $CFLAGS\" PREFIX=\"$PREFIX\" install"

#------------------------------------------------------------------------------
# tokyo (DEPRECATED IN 0.0.8)

#TOKYO_V="1.4.42"
#TOKYO_DIST="tokyocabinet-${TOKYO_V}.tar.gz"
#TOKYO_SOURCE="tokyocabinet-${TOKYO_V}"
#TOKYO_COMMANDS="CFLAGS=\"${CFLAGS} -D_SYS_OPENBSD_=1\" ./configure --prefix=$PREFIX --host=$HOST --build=$BUILD --disable-shared --with-pic && make && make install"
#TOKYO_DEPENDS="BZIP"

#------------------------------------------------------------------------------
# expat

EXPAT_V="2.0.1"
EXPAT_URL="http://sourceforge.net/projects/expat/files/expat/${EXPAT_V}/expat-${EXPAT_V}.tar.gz/download"
EXPAT_DIST="expat-${EXPAT_V}.tar.gz"
EXPAT_SOURCE="expat-${EXPAT_V}"
EXPAT_COMMANDS="./configure --prefix=$PREFIX --host=$HOST --build=$BUILD --disable-shared --with-pic && make install"

#------------------------------------------------------------------------------
# freetype

FREETYPE_V="2.3.12"
FREETYPE_URL="http://download.savannah.gnu.org/releases/freetype/freetype-${FREETYPE_V}.tar.gz"
FREETYPE_DIST="freetype-${FREETYPE_V}.tar.gz"
FREETYPE_SOURCE="freetype-${FREETYPE_V}"
FREETYPE_COMMANDS="./configure --prefix=$PREFIX --host=$HOST --build=$BUILD --disable-shared --with-pic && make install"

#------------------------------------------------------------------------------
# fontconfig

FONTCONFIG_V="2.8.0"
FONTCONFIG_URL="http://fontconfig.org/release/fontconfig-${FONTCONFIG_V}.tar.gz"
FONTCONFIG_DIST="fontconfig-${FONTCONFIG_V}.tar.gz"
FONTCONFIG_SOURCE="fontconfig-${FONTCONFIG_V}"
FONTCONFIG_COMMANDS="./autogen.sh --prefix=$PREFIX --host=$HOST --build=$BUILD --with-arch=$ARCH --disable-shared --with-pic --with-freetype-config=\"$PREFIX/bin/freetype-config\" && make install"

#------------------------------------------------------------------------------
# pixman

PIXMAN_V="0.17.6"
PIXMAN_URL="http://cgit.freedesktop.org/pixman/snapshot/pixman-${PIXMAN_V}.tar.gz"
PIXMAN_DIST="pixman-${PIXMAN_V}.tar.gz"
PIXMAN_SOURCE="pixman-${PIXMAN_V}"
PIXMAN_COMMANDS="./configure --prefix=$PREFIX --host=$HOST --build=$BUILD --disable-shared --with-pic --disable-gtk && make install"

#------------------------------------------------------------------------------
# png

PNG_V="1.2.42"
PNG_URL="http://sourceforge.net/projects/libpng/files/00-libpng-stable/${PNG_V}/libpng-${PNG_V}.tar.gz/download"
PNG_DIST="libpng-${PNG_V}.tar.gz"
PNG_SOURCE="libpng-${PNG_V}"
PNG_COMMANDS="./configure --prefix=$PREFIX --host=$HOST --build=$BUILD --disable-shared --with-pic && make install"

#------------------------------------------------------------------------------
# cairo

CAIRO_V="1.8.10"
CAIRO_URL="http://cairographics.org/releases/cairo-${CAIRO_V}.tar.gz"
CAIRO_DIST="cairo-${CAIRO_V}.tar.gz"
CAIRO_SOURCE="cairo-${CAIRO_V}"
CAIRO_COMMANDS="CFLAGS=\"${CFLAGS} -DPNG_SKIP_SETJMP_CHECK=1\" ./configure --prefix=$PREFIX --host=$HOST --build=$BUILD --disable-shared --with-pic --disable-xlib --disable-ps --disable-pdf --disable-svg && make install"
CAIRO_DEPENDS="PIXMAN PNG"

#------------------------------------------------------------------------------
# pango

PANGO_MV="1.26"
PANGO_V="${PANGO_MV}.2"
PANGO_URL="http://ftp.gnome.org/pub/GNOME/sources/pango/${PANGO_MV}/pango-${PANGO_V}.tar.gz"
PANGO_DIST="pango-${PANGO_V}.tar.gz"
PANGO_SOURCE="pango-${PANGO_V}"
PANGO_COMMANDS="./configure --prefix=$PREFIX --host=$HOST --build=$BUILD --without-x --disable-shared --with-pic --with-included-modules=yes && make install"
PANGO_DEPENDS="CAIRO FREETYPE FONTCONFIG"
#------------------------------------------------------------------------------
# jpeg

JPEG_V="8b"
JPEG_URL="http://www.ijg.org/files/jpegsrc.v${JPEG_V}.tar.gz"
JPEG_DIST="jpegsrc.v${JPEG_V}.tar.gz"
JPEG_SOURCE="jpeg-${JPEG_V}"
JPEG_COMMANDS="./configure --prefix=$PREFIX --host=$HOST --build=$BUILD --disable-shared --with-pic && make install"

#------------------------------------------------------------------------------
# tiff

TIFF_V="3.9.4"
TIFF_URL="ftp://ftp.remotesensing.org/pub/libtiff/tiff-${TIFF_V}.tar.gz"
TIFF_DIST="tiff-${TIFF_V}.tar.gz"
TIFF_SOURCE="tiff-${TIFF_V}"
TIFF_COMMANDS="./configure --prefix=$PREFIX --host=$HOST --build=$BUILD --disable-shared --with-pic && make install"

#------------------------------------------------------------------------------
# gif

GIF_V="4.1.6"
GIF_URL="http://sourceforge.net/projects/giflib/files/giflib%204.x/giflib-${GIF_V}/giflib-${GIF_V}.tar.gz/download"
GIF_DIST="giflib-${GIF_V}.tar.gz"
GIF_SOURCE="giflib-${GIF_V}"
GIF_COMMANDS="./configure --prefix=$PREFIX --host=$HOST --build=$BUILD --disable-shared --with-pic && make install"

#------------------------------------------------------------------------------
# json

JSON_MV="0.10"
JSON_V="${JSON_MV}.4"
JSON_URL="http://ftp.gnome.org/pub/GNOME/sources/json-glib/${JSON_MV}/json-glib-${JSON_V}.tar.gz"
JSON_DIST="json-glib-${JSON_V}.tar.gz"
JSON_SOURCE="json-glib-${JSON_V}"
JSON_COMMANDS="./configure --prefix=$PREFIX --host=$HOST --build=$BUILD --disable-shared --with-pic --disable-glibtest && make install"
JSON_DEPENDS="GLIB"

#------------------------------------------------------------------------------
# clutter

CLUTTER_MV="1.0"
CLUTTER_V="${CLUTTER_MV}.8"
CLUTTER_URL="http://source.clutter-project.org/sources/clutter/${CLUTTER_MV}/clutter-${CLUTTER_V}.tar.gz"
CLUTTER_DIST="clutter-${CLUTTER_V}.tar.gz"
CLUTTER_SOURCE="clutter-${CLUTTER_V}"
CLUTTER_COMMANDS="ac_cv_lib_GLES_CM_eglInitialize=yes ac_cv_func_malloc_0_nonnull=yes ./configure --prefix=$PREFIX --host=$HOST --build=$BUILD --disable-shared --with-pic --with-flavour=eglnative --with-gles=${GLES} --with-imagebackend=internal && make install" 
CLUTTER_DEPENDS="GLIB PANGO FREETYPE CAIRO FONTCONFIG"

#------------------------------------------------------------------------------
# avahi

AVAHI_V="0.6.25"
AVAHI_URL="http://avahi.org/download/avahi-${AVAHI_V}.tar.gz"
AVAHI_DIST="avahi-${AVAHI_V}.tar.gz"
AVAHI_SOURCE="avahi-${AVAHI_V}"
AVAHI_COMMANDS="./configure --host=$HOST --prefix=$PREFIX --build=$BUILD --disable-shared --with-pic --disable-qt3 --disable-qt4 --disable-gtk --disable-dbus --disable-gdbm --disable-libdaemon --disable-python --disable-pygtk --disable-python-dbus --disable-mono --disable-monodoc --disable-autoipd --disable-doxygen-doc --disable-doxygen-dot --disable-doxygen-xml --with-distro=none --disable-nls --disable-shared && make install"
AVAHI_DEPENDS="GLIB"

#------------------------------------------------------------------------------
# upnp

UPNP_V="1.6.6"
UPNP_DIST="libupnp-${UPNP_V}.tar.bz2"
UPNP_SOURCE="libupnp-${UPNP_V}"
UPNP_COMMANDS="./configure --host=$HOST --prefix=$PREFIX --build=$BUILD --disable-shared --with-pic && make && make install"

#------------------------------------------------------------------------------
# uriparser

URI_V="0.7.5"
URI_DIST="uriparser-${URI_V}.tar.gz"
URI_SOURCE="uriparser-${URI_V}"
URI_COMMANDS="./configure --host=$HOST --prefix=$PREFIX --build=$BUILD --disable-shared --with-pic --disable-test --disable-doc && make && make install"

#------------------------------------------------------------------------------
# uuid

UUID_V="1.6.2"
UUID_DIST="uuid-${UUID_V}.tar.gz"
UUID_SOURCE="uuid-${UUID_V}"
UUID_COMMANDS="sed -i \"s/-c -s -m/-c -m/\" Makefile.in && ac_cv_va_copy=no ./configure --host=$HOST --prefix=$PREFIX --build=$BUILD --includedir=$PREFIX/include/ossp --disable-shared --with-pic && make && make install"

#------------------------------------------------------------------------------

ALL="GLIB SQLITE OPENSSL ZLIB CARES CURL BZIP EXPAT FREETYPE FONTCONFIG PIXMAN PNG CAIRO PANGO JPEG TIFF GIF JSON CLUTTER AVAHI UPNP URI UUID"

#-----------------------------------------------------------------------------

HERE=${PWD}

SOURCE=${HERE}/source


#-----------------------------------------------------------------------------
# If the output directory does not exist, create it and copy the baseline
# files to it.

if [[ ! -d "${PREFIX}" ]]
then

    mkdir "${PREFIX}"
    
    if [[ -d ${THERE}/base ]]
    then
        cp -r ${THERE}/base/* ${PREFIX}/
    fi

fi

#-----------------------------------------------------------------------------

if [[ ! -d "${SOURCE}" ]]
then
    mkdir "${SOURCE}"
fi   

#-----------------------------------------------------------------------------
# Get the list of things that have already been built - this lets you keep
# going where you left off if something fails.

touch ${HERE}/built

BUILT=`cat ${HERE}/built`

#-----------------------------------------------------------------------------
# If there are parameters, we build those regardless of whether they
# have been built or not

CLEAN=0

STATE=1

if [[ $# > 0 ]]
then
    if [[ $# == 1 && $1 == "clean" ]]
    then
        rm ${HERE}/built
        BUILT=""
        CLEAN=1
    else
        ALL="$@"
        BUILT=""
        STATE=0
        if [[ ${ALL} == *clean* ]]
        then
            CLEAN=1
        fi    
    fi
fi

VERBOSE=${VERBOSE:-0}

if [[ ${VERBOSE} == 1 ]]
then
    OUT=/dev/stdout
else
    OUT=/dev/null
fi

#-----------------------------------------------------------------------------

for THIS in ${ALL}; do

    if [[ ${THIS} == "clean" ]]
    then
        continue
    fi

    if [[ ! ${BUILT} == *${THIS}* ]]
    then
    
        THIS_V=${THIS}_V
        THIS_URL=${THIS}_URL
        THIS_DIST=${THIS}_DIST
        THIS_SOURCE=${THIS}_SOURCE
        THIS_COMMANDS=${THIS}_COMMANDS
        
        echo "================================================================="
        echo "== Building ${!THIS_SOURCE}..."
        echo "================================================================="

        # If the source directory does not exist, unpack the dist
        

        if [[ ! -d "${SOURCE}/${!THIS_SOURCE}" ]]
        then
        
            cd ${SOURCE}
            
            # If the dist does not exist, download it
            
            if [[ ! -f "${!THIS_DIST}" ]]
            then
                wget "http://developer.trickplay.com/sources/${!THIS_DIST}"
            fi
            
            if [[ "${!THIS_DIST:0-3}" == "bz2" ]]
            then
                tar jxf "${!THIS_DIST}" 
            else
                tar zxf "${!THIS_DIST}" 
            fi

	        # Patches

            if [[ -d "${THERE}/patches/${!THIS_SOURCE}" ]]
	        then
			cd "${SOURCE}/${!THIS_SOURCE}"
			QUILT_PATCHES="${THERE}/patches/${!THIS_SOURCE}" quilt push -a
	        fi
        fi
        
        
        # cd into the source directory for this one
        
        cd ${SOURCE}/${!THIS_SOURCE}
        
        # clean
        
        if [[ ${CLEAN} == 1 ]]
        then
            make clean > ${OUT}
        fi
        
        # configure and build
        
        eval ${!THIS_COMMANDS} > ${OUT}
        
        # Save it to the built file
        
        if [[ ${STATE} == 1 ]]
        then
        
            echo "${THIS}" >> ${HERE}/built
            
        fi
        
        # cd back here
        
        cd ${HERE}
    
    fi
    
done

#------------------------------------------------------------------------------
# OpenGL stub

if [[ ! -f ${PREFIX}/lib/libGLES2.so ]]
then
    echo "================================================================="
    echo "== Building GLES2 stub..."
    echo "================================================================="


    ${CC} -I ${PREFIX}/include -shared ${THERE}/gl-stub/gl-stub.c -o ${PREFIX}/lib/libGLES2.so
fi

#------------------------------------------------------------------------------
# Trickplay

if [[ ! -d ${HERE}/tp-build ]]
then
    mkdir ${HERE}/tp-build
    cd ${HERE}/tp-build 
    
    cmake   -DCMAKE_TOOLCHAIN_FILE=${THERE}/toolchain.cmake \
            -DCMAKE_BUILD_TYPE=Debug \
            -DTP_CLUTTER_BACKEND_EGL=1 \
            "${THERE}/../"   
fi

echo "================================================================="
echo "== Building libtpcore..."
echo "================================================================="

make -C ${HERE}/tp-build --no-print-directory
   
if [[ ! -f "${PREFIX}/lib/libtpcore.a" ]]
then
    ln -s ${HERE}/tp-build/engine/libtpcore.a "${PREFIX}/lib/libtpcore.a"
fi
   
#------------------------------------------------------------------------------
# Build a test exe

echo "================================================================="
echo "== Link test..."
echo "================================================================="

${CXX} -o ${HERE}/test \
    -g -Wall -fPIC \
    -L ${PREFIX}/lib \
    -L ${HERE}/tp-build/engine \
    -I ${THERE}/../engine/public/include \
    -I ${PREFIX}/include \
    -Wl,--start-group \
    -ltpcore \
	-ljson-glib-1.0 \
	-lclutter-eglnative-1.0 \
	-lavahi-core \
	-lavahi-common \
	-lavahi-glib \
	-lpango-1.0 \
	-lpangocairo-1.0 \
	-lpangoft2-1.0 \
	-lcairo \
	-lpixman-1 \
	-lpng12 \
	-lpng \
	-ltiff \
	-ltiffxx \
	-lgif \
	-ljpeg \
	-lfontconfig \
	-lfreetype \
	-lexpat \
	-lbz2 \
	-lcurl \
	-lcares \
	-lz \
	-lssl \
	-lcrypto \
	-lsqlite3 \
	-lgio-2.0 \
	-lgmodule-2.0 \
	-lgobject-2.0 \
	-lglib-2.0 \
	-lgthread-2.0 \
	-liconv \
	-lintl \
	-lrt \
	-lresolv \
	-ldl \
	-luuid \
	-luriparser \
	-lupnp \
	-lixml \
	-lthreadutil \
	-lGLES2 \
	${THERE}/test/main.cpp \
	-Wl,--end-group 
	
rm -rf ${HERE}/test	

#------------------------------------------------------------------------------
# Build the LG dynamic shell

echo "================================================================="
echo "== Building dynamic shell..."
echo "================================================================="

if [[ ! -d ${HERE}/dynamic-shell ]] 
then
    cp -r ${THERE}/dynamic-shell ${HERE}/
    ln -s ${THERE}/../engine/public/include/trickplay ${HERE}/dynamic-shell/include/trickplay
    ln -s ${PREFIX}/lib ${HERE}/dynamic-shell/lib
fi

make -C ${HERE}/dynamic-shell --no-print-directory




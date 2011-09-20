/*	
 *	mfMacros - Misc utility macros
 *	Copyright (C) 1996-2010 Muscle Fish LLC
 *	All Rights Reserved
 */

#ifndef _MFMACROS_H
#define _MFMACROS_H 

#include <stdlib.h>

#ifdef __MACH__
#define unix
#include "/usr/include/stdint.h"
#endif

#ifdef __APPLE__
#define unix
#include "TargetConditionals.h"
#if TARGET_OS_IPHONE
#define MF_ANALYZE_MONO_SHORTS_ONLY
#endif
#endif

#if defined(unix)
#include <sys/param.h>
#include <sys/types.h>
#endif
#ifdef WIN32
#include <sys/types.h>
#endif
#include "mfAlloc.h"

#ifndef YES
#define YES	1
#endif
#ifndef NO
#define NO	0
#endif /* YES_NO */

#ifdef USE_STANDARD_MALLOC
    #define Malloc  malloc
    #define Realloc realloc
    #define Calloc  calloc
    #if (defined(WIN32) || defined(macintosh))
	#define Strdup  _strdup
    #else
	#define Strdup  strdup
    #endif
    #define Free    free
#else
    #define Malloc(x)  MFMalloc(x, __FILE__, __LINE__)
    #define Realloc(x,y) MFRealloc(x, y, __FILE__, __LINE__)
    #define Calloc(x,y)  MFCalloc(x, y, __FILE__, __LINE__)
    #define Strdup(x)  MFStrdup(x, __FILE__, __LINE__)
    #define Free(x)    MFFree(x, __FILE__, __LINE__)
#endif

#ifndef MIN
#define MIN(a,b)		    (((a) < (b)) ? (a) : (b))
#endif
#ifndef MAX
#define MAX(a,b)		    (((a) > (b)) ? (a) : (b))
#endif
#define CONSTRAIN(x, a, b)	    MIN(MAX(x, a), b)
#ifndef ABS
#define ABS(x)			    ((x) >= 0) ? (x) : (-(x))
#endif
#define SIGN(x)			    (((x) >= 0) ? 1 : -1)

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif
#ifndef M_TWOPI
#define M_TWOPI	6.28318530717958647692
#endif
#ifndef MF_TWOGB
#define MF_TWOGB    2147483647	/* 2^31 - 1 */
#endif

#ifdef WIN32
#define strcasecmp _stricmp
#define strncasecmp _strnicmp
#define snprintf _snprintf
#define vsnprintf _vsnprintf
#endif

#ifndef unix
#ifndef rint
#define rint(x) ((x) >= 0 ? ((int) ((x)+0.5)) : ((int) ((x)-0.5)))
#endif
#endif

#ifdef WIN32
#define MF_DIRECTORY_SEPARATOR "\\"
#define MF_DIRECTORY_SEPARATOR_CHAR '\\'
#endif
#ifdef macintosh
#define MF_DIRECTORY_SEPARATOR ":"
#define MF_DIRECTORY_SEPARATOR_CHAR ':'
#endif
#ifdef unix
#define MF_DIRECTORY_SEPARATOR "/"
#define MF_DIRECTORY_SEPARATOR_CHAR '/'
#endif

#ifdef WIN32
#define MF_NULL_DEVICE "NUL"
#else
#define MF_NULL_DEVICE "/dev/null"
#endif

#ifndef MAXPATHLEN 
#define MAXPATHLEN 1024
#endif

#if (!(defined(__FreeBSD__) || defined(__MACH__)))
#include "mfStrlcat.h"
#include "mfStrlcpy.h"
#endif
#if WIN32
#include "mfStrtoll.h"
#endif

#endif /* _MFMACROS_H */

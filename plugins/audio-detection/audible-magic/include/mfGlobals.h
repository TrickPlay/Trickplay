/*
 *----------------------------------------------------------------------------
 * Copyright notice:
 * (c) Copyright 1996-2010 Muscle Fish LLC
 * All rights reserved.
 *
 * This program is protected as an unpublished work under the U.S. copyright
 * laws. The above copyright notice is not intended to effect a publication of
 * this work.
 *
 * This program is the confidential and proprietary information of Muscle
 * Fish.  Neither the binaries nor the source code may be redistributed 
 * without prior written permission from Muscle Fish. 
 *----------------------------------------------------------------------------
 *
 * File: mfGlobals.h
 */

#ifndef _mfGlobals_h
#define _mfGlobals_h

#ifdef __MACH__
#define unix
#endif

#include <string.h>
#ifdef macintosh
#include <MacTypes.h>
#endif

#ifdef AMP2P_MANGLED
#include "mfDemangle.h"
#include "cobfusc.h"
#endif

#ifndef FALSE
#define FALSE 0
#endif
#ifndef TRUE
#define TRUE  1
#endif
#define MFTERNARY_UNKNOWN -1

#ifndef MAXPATHLEN 
#define MAXPATHLEN 1024
#endif

typedef int	MFBoolean;
typedef int	MFTernary;
typedef char*	MFString;
typedef char    MFFileName[MAXPATHLEN];

#ifdef STDCALL
#define MF_CALLCONV __stdcall
#else
#define MF_CALLCONV
#endif

#if (__GNUC__)
#define MF_DEPRECATED  __attribute__((__deprecated__))
#else
#define MF_DEPRECATED
#endif

#ifndef _MSC_VER
typedef long long MFLongLong;
typedef unsigned long long MFULongLong;
#define MFLLFormat "ll"
#define MFLL LL
#define MFULL ULL
#else
typedef __int64 MFLongLong;
typedef unsigned __int64 MFULongLong;
#define MFLLFormat "I64"
#define MFLL i64
#define MFULL ui64
#endif

/* is this a 64 bit machine? */
#if defined(_LP64) || defined(__LP64__) || defined(__amd64) || defined(__amd64__)
#define MF_64BIT 1
#define MF_NUMBER_OF_BITS_PER_WORD 64
#else
#define MF_NUMBER_OF_BITS_PER_WORD 32
#endif

#endif /* _mfGlobals_h */

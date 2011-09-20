/*
 *----------------------------------------------------------------------------
 * Copyright notice:
 * (c) Copyright 2000-2010 Audible Magic
 * All rights reserved.
 *
 * This program is protected as an unpublished work under the U.S. copyright
 * laws. The above copyright notice is not intended to effect a publication of
 * this work.
 *
 * This program is the confidential and proprietary information of Audible
 * Magic.  Neither the binaries nor the source code may be redistributed 
 * without prior written permission from Audible Magic. 
 *----------------------------------------------------------------------------
 *
 * File: mfAlloc.h
 */

#ifndef _MFMALLOC_H
#define _MFMALLOC_H

#include "mfGlobals.h"

#ifdef __cplusplus
extern "C" {
#endif

extern void* MF_CALLCONV MFMalloc(size_t size, const char* file, int line);
extern void* MF_CALLCONV MFCalloc(size_t nElems, size_t elemSize, const char* file, int line);
extern void* MFRealloc(void *ptr, size_t size, const char* file, int line);
extern void  MF_CALLCONV MFFree(void* ptr, const char* file, int line);
extern char* MFStrdup(const char* s, const char* file, int line);
extern char* MFStrFreeAndDup( char** destStr, char* srcStr );

#ifdef __cplusplus
}
#endif

#endif /* _MFMALLOC_H */

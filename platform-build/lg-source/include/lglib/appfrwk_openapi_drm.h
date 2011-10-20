/******************************************************************************
 *   LCD TV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2011 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/


/** @file appfrwk_openapi_drm.h
 *
 *  NCG DRM openapi header
 *
 *  @author    Sang-gi Lee (sanggi0.lee@lge.com)
 *  @version   1.0
 *  @date      2011.09.29
 *  @note
 *  @see
 */
#ifndef _APPFRWK_OPENAPI_DRM_H_
#define _APPFRWK_OPENAPI_DRM_H_

#include <dbus/dbus.h>
#include "appfrwk_common.h"
#include "appfrwk_openapi_types.h"

#ifdef __cplusplus
extern "C" {
#endif


/* appfrwk_openapi_game_drm.c */
int					HOA_NCG_POSIX_open( const char *filename, int oflag, int pmode );
int					HOA_NCG_POSIX_read( int handle, void *buffer, unsigned int count );
long				HOA_NCG_POSIX_lseek( int handle, long offset, int origin );
long				HOA_NCG_POSIX_write( int handle, const unsigned char * buf, int size );
long				HOA_NCG_POSIX_fstat( int handle, struct stat *statBuf );
void				HOA_NCG_POSIX_close( int handle );

#ifdef __cplusplus
}
#endif
#endif /* _APPFRWK_OPENAPI_DRM_H_ */

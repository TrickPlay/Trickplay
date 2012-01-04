/******************************************************************************
 *   LCD TV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2011 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/


/** @file drm_openapi.h
 *
 *  NCG DRM openapi header
 *
 *  @author    Sang-gi Lee (sanggi0.lee@lge.com)
 *  @version   1.0
 *  @date      2011.09.29
 *  @note
 *  @see
 */
#ifndef _DRM_OPENAPI_H_
#define _DRM_OPENAPI_H_

#include <dbus/dbus.h>
#include "appfrwk_common.h"
#include "appfrwk_openapi_types.h"

#ifdef __cplusplus
extern "C" {
#endif


/* drm_openapi.c */

/**
 * open NCG_DRM encrypted file and return its handle
 * @param 	filename [in] file name
 * @param 	oflag [in] opening mode, ex) O_RDONLY, ...
 * @param 	pmode [in] opening mode, ex) S_IRUSR, ...
 * @param 	handle [out] file handle
 * @return 	HOA_OK if opening file is success. In any other cases, HOA_ERROR
 * @author 	Sang-gi Lee(sanggi0.lee@lge.com)
 */
HOA_STATUS_T		HOA_NCG_POSIX_open( const char *filename, int oflag, int pmode, int *handle );

/**
 * read data from the given file
 * @param 	handle [in]
 * @param 	buffer [out] pointer of buffer to store data
 * @param 	count [in] size to read in bytes. It must not be over the size of the buffer.
 * @param 	n_read [out] the number of bytes actually read
 * @return 	HOA_OK if reading is success. In any other cases, HOA_ERROR
 * @author 	Sang-gi Lee(sanggi0.lee@lge.com)
 */
HOA_STATUS_T		HOA_NCG_POSIX_read( int handle, void *buffer, size_t count, size_t *n_read );

/**
 * set the file offset
 * @param 	handle [in] handle of file
 * @param 	offset [in] relative offset in bytes from 'origin'
 * @param 	origin [in] one of {SEEK_SET, SEEK_CUR, SEEK_END}
 * @param 	offset_res [out] offset of the new position in bytes from the beginning of the file
 * @return 	HOA_OK if operation is success. In any other cases, HOA_ERROR
 * @author 	Sang-gi Lee(sanggi0.lee@lge.com)
 */
 HOA_STATUS_T		HOA_NCG_POSIX_lseek( int handle, off_t offset, int origin, off_t *offset_res );

/**
 * write data into the given file
 * @param 	handle [in] handle of file
 * @param 	buf [in] pointer of data buffer to write
 * @param 	size [in] size of data to write
 * @param 	n_write [out] the number of bytes actually written to the file
 * @return 	HOA_OK if writing is success. In any other cases, HOA_ERROR
 * @author 	Sang-gi Lee(sanggi0.lee@lge.com)
 */
 HOA_STATUS_T		HOA_NCG_POSIX_write( int handle, const void *buf, size_t size, ssize_t *n_write );

/**
 * obtain information of the given file
 * @param 	handle [in] handle of file
 * @param 	statBuf [out] file information will be updated to the stat instance. pointer of 'struct stat' instance must be provided.
 * @return 	HOA_OK if operation is success. In any other cases, HOA_ERROR
 * @author 	Sang-gi Lee(sanggi0.lee@lge.com)
 */
HOA_STATUS_T		HOA_NCG_POSIX_fstat( int handle, struct stat *statBuf );

/**
 * close file
 * @param 	handle [in] handle of file
 * @return 	HOA_OK if closing file is success. In any other cases, HOA_ERROR
 * @author 	Sang-gi Lee(sanggi0.lee@lge.com)
 */
HOA_STATUS_T		HOA_NCG_POSIX_close( int handle );

/**
 * check if the given file is encrypted
 * @param 	filename [in] file name
 * @param 	is_encrypted [out] 1 if the given file is encrypted. In any other cases, 0
 * @return 	HOA_OK if operation is success. In any other cases, HOA_ERROR
 * @author 	Sang-gi Lee(sanggi0.lee@lge.com)
 */
HOA_STATUS_T		HOA_NCG_POSIX_CheckEncrypted( const char *filename, int *is_encrypted );

#ifdef __cplusplus
}
#endif
#endif /* _DRM_OPENAPI_H_ */


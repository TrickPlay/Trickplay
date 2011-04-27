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
 * File: mfErrors_oem.h
 */

#ifndef _MFERRORS_OEM_H_
#define _MFERRORS_OEM_H_

/*
 * Error codes.  
 */
typedef int MFError;

/* Gaps in the numerical sequence contain error codes that don't apply to the OEM DLL. */

#define MF_SUCCESS 				(0)
#define MF_FAILURE 				(1)
#define MF_OUT_OF_MEMORY 			(2)
#define MF_INCORRECT_COMMAND_LINE 		(3)
#define MF_CALLING_PROGRAM_ERROR		(4)
#define MF_INTERNAL_PROGRAM_ERROR		(5)
#define MF_FILE_IO_ERROR			(6)
#define MF_MALFORMED_INPUT_DATA			(7)
#define MF_NOT_IMPLEMENTED_YET			(8)
#define MF_UNSUPPORTED_SOUNDFILE_FORMAT		(9)
#define MF_NO_SOUND_DATA_IN_FILE		(10)
#define MF_HARDWARE_ERROR			(11)
#define MF_END_OF_FILE				(12)
#define MF_DROPPED_SAMPLES_ERROR		(13)
#define MF_NULL_POINTER				(14)
#define MF_PARAMETER_OUT_OF_RANGE		(15)
#define MF_COULDNT_CREATE_FILE		 	(16)
#define MF_BAD_HEADER				(17)
#define MF_COULDNT_OPEN_URL			(18)
#define MF_WRONG_CODEC_VERSION			(23)
#define MF_CODEC_OPEN_ERROR			(24)
#define MF_CODEC_READ_ERROR			(25)
#define MF_STRING_TOO_SHORT			(27)
#define MF_THREAD_ERROR				(28)
#define MF_MUTEX_ERROR				(29)
#define MF_TIMEOUT				(30)
#define MF_KEY_ALREADY_EXISTS			(31)
#define MF_NO_SUCH_KEY				(32)
#define MF_COULDNT_EXPAND_ARCHIVE               (33)
#define MF_COULDNT_DELETE_FILE                  (34)
#define MF_COULDNT_CREATE_DIRECTORY             (35)
#define MF_COULDNT_DELETE_DIRECTORY             (36)
#define MF_STRING_TOO_LONG			(39)
#define MF_FILE_ALREADY_EXISTS			(40)
#define MF_NO_VIDEO_AVAILABLE                   (42)
#define MF_DISALLOWED_FORMAT                    (43)
#define MF_OPERATION_DISABLED                   (44)
#define MF_FILE_TOO_BIG                         (45)
#define MF_NO_STREAMS_FOUND			(46)
#define MF_FILE_IS_PROTECTED_BY_DRM		(47)
#define MF_COULDNT_OPEN_FFMPEG_EXECUTABLE	(48)
#define MF_FILE_NOT_FOUND			(49)
#define MF_NEEDS_ENTIRE_FILE			(54)
#define MF_MS_RUNTIME_LIB_FOR_VSS1_NOT_FOUND	(60)
#define MF_MS_RUNTIME_LIB_MISSING_S_BY_S_FOLDER	(62)
#define MF_MS_RUNTIME_LIB_WRONG_S_BY_S_FOLDER	(63)
#define MF_SQL_UNABLE_TO_OPEN                   (64)
#define MF_SQL_COMMAND_FAILED                   (65)
#define MF_SQL_PREPARE_FAILED                   (66)
#define MF_SQL_ESCAPE_STRING_FAILED             (67)
#define MF_DIRECTORY_NOT_FOUND			(68)
#define MF_SPECIFIED_METADATA_FILE_NOT_FOUND	(69)
#define MF_INVALID_CLIENT_SUFFIX		(70)
#define MF_NOT_A_MEDIA_FILE			(71)
#define MF_UNEXPECTED_SERVER_RESPONSE		(72)
#define MF_CURL_INIT_ERROR			(73)

#define MF_INVALID_OPTIONS		(20003)
#define MF_INVALID_OBJECT		(20011)
#define MF_BUFFER_TOO_SMALL		(20014)
#define	MF_OUT_OF_DISK_SPACE		(20017)
#define MF_UNKNOWN_XML_CUSTOMER	        (20021)
#define MF_MUTEX_FAILURE	        (20022)
#define MF_MALFORMED_XML		(20025)
#define MF_INVALID_CHECKSUM		(20026)
#define MF_INVALID_VERSION		(20027)
#define MF_INVALID_USERGUID		(20028)
#define MF_INSUFFICIENT_DATA   	     	(20050)
#define MF_VIDEO_SIGNATURE_FEATURE_SET_LIBRARY_NOT_FOUND	(20067)
#define MF_VIDEO_SIGNATURE_FEATURE_SET_FUNCTION_NOT_FOUND	(20068)
#define MF_VIDEO_SIGNATURE_STRIPPED			(20069)
#define MF_INCONSISTENT_SIGNATURE_NORMALIZATION		(20070)
#define MF_NORMALIZED_SEARCH_NOT_SPECIFIED 		(20071)
#define MF_UNSUPPORTED_MEDIA_FILE	 		(20072)
#define MF_CONFIGURATION_ERROR  	 		(20073)
#define MF_VIDEO_SIGNATURE_FEATURE_SET_UNKNOWN		(20074)
#define MF_UNDESIRED_FILE_FORMAT			(20075)
#define MF_VIDEO_SIGNATURE_BAD_FRAME_TIMES		(20076)
#define MF_VIDEO_SIGNATURE_FEATURE_SET_SIG_GEN_FAILED	(20077)


#ifdef __cplusplus
extern "C" {
#endif

#ifdef __cplusplus
}
#endif

#endif /* _MFERRORS_OEM_H_ */

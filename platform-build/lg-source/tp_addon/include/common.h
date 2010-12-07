/******************************************************************************
 *	 DTV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *	 Copyright(c) 1999 by LG Electronics Inc.
 *
 *	 All rights reserved. No part of this work may be reproduced, stored in a
 *	 retrieval system, or transmitted by any means without prior written
 *	 permission of LG Electronics Inc.
 *****************************************************************************/

/** @file common.h
 *
 *	Common Used Type Definitions.
 *
 *	@author 	cskim
 *	@version	1.0
 *	@date		2005. 6. 1
 *	@note
 *	@see
 */

/******************************************************************************
	Header File Guarder
******************************************************************************/

#ifndef _COMMON_H_
#define _COMMON_H_

#ifdef __cplusplus
extern "C" {
#endif

// DOM-IGNORE-BEGIN
// Common type definitions
// DOM-IGNORE-END
#ifndef UINT8
typedef	unsigned char			__UINT8;
#define UINT8 __UINT8
#endif

#ifndef UINT08
typedef	unsigned char			__UINT08;
#define UINT08 __UINT08
#endif

#ifndef SINT8
typedef	signed char				__SINT8;
#define SINT8 __SINT8
#endif

#ifndef SINT08
typedef	signed char				__SINT08;
#define SINT08 __SINT08
#endif

#ifndef CHAR
typedef	char					__CHAR;
#define CHAR __CHAR
#endif

#ifndef UINT16
typedef	unsigned short			__UINT16;
#define UINT16 __UINT16
#endif

#ifndef SINT16
typedef	signed short			__SINT16;
#define SINT16 __SINT16
#endif

#ifndef UINT32
typedef	unsigned int			__UINT32;
#define UINT32 __UINT32
#endif

#ifndef SINT32
typedef signed int				__SINT32;
#define SINT32 __SINT32
#endif

#ifndef BOOLEAN
#ifndef _EMUL_WIN
typedef	unsigned int			__BOOLEAN;
#define BOOLEAN __BOOLEAN
#else
typedef	unsigned char		__BOOLEAN;
#define BOOLEAN __BOOLEAN
#endif
#endif

#ifndef ULONG
typedef unsigned long			__ULONG;
#define ULONG __ULONG
#endif

#ifndef SLONG
typedef signed long				__SLONG;
#define SLONG __SLONG
#endif

#ifndef UINT64
#ifndef _EMUL_WIN
typedef	unsigned long long		__UINT64;
#else
typedef	unsigned _int64			__UINT64;
#endif
#define UINT64 __UINT64
#endif

#ifndef SINT64
#ifndef _EMUL_WIN
typedef	signed long long		__SINT64;
#else
typedef	signed _int64			__SINT64;
#endif
#define SINT64 __SINT64
#endif

// Common constant definitions
#ifndef TRUE
#define TRUE					(1)
#endif

#ifndef FALSE
#define FALSE					(0)
#endif

#ifndef ON_STATE
#define ON_STATE				(1)
#endif

#ifndef OFF_STATE
#define OFF_STATE				(0)
#endif

#ifndef ON
#define ON						(1)
#endif

#ifndef OFF
#define OFF						(0)
#endif

#ifndef NULL
#define NULL					((void *)0)
#endif

#ifndef OFFSET
#define OFFSET(structure, member)		/* byte offset of member in structure*/\
		((int) &(((structure *) 0) -> member))
#endif

#ifndef MEMBER_SIZE
#define MEMBER_SIZE(structure, member)	/* size of a member of a structure */\
		(sizeof (((structure *) 0) -> member))
#endif

#ifndef NELEMENTS
#define NELEMENTS(array)				/* number of elements in an array */ \
		(sizeof (array) / sizeof ((array) [0]))
#endif

/**
 *	API return type definitions
 *
 *  \- API_OK				: success (no error) <P>
 *	\- API_ERROR			: generic error <P>
 *	\- API_INVALID_PARAMS	: input parameter error <P>
 *	\- API_NOT_SUPPORTED	: not supported <P>
 *	\- API_NOT_PERMITTED	: no permission <P>
 *	\- API_TIMEOUT			: time-out <P>
 */
typedef enum
{
	API_OK   					=	0,
	OK							=	0,
	API_ERROR     				=	-1,
	API_NOT_OK					= 	-1,
	NOT_OK						=	-1,
	PARAMETER_ERROR				=   -2,
	API_INVALID_PARAMS			=	-2,
	INVALID_PARAMS				=	-2,
	API_NOT_ENOUGH_RESOURCE		=	-3,
	NOT_ENOUGH_RESOURCE			=	-3,
	API_NOT_SUPPORTED			=	-4,
	NOT_SUPPORTED				=	-4,
	API_NOT_PERMITTED			=	-5,
	NOT_PERMITTED				=	-5,
	API_TIMEOUT					=	-6,
	TIMEOUT						=	-6,
	NO_DATA_RECEIVED			=	-7,
	DN_BUF_OVERFLOW				=	-8,
	DLNA_NOT_CONNECTED			=	-9,  		/**< DLNA 접속 에러 발생시*/
	IPM_OK              		=	API_OK,		/**< 네트워크 설정을 완료했습니다. */
	IPM_FAIL          			=	API_NOT_OK,	/**< 네트워크 설정 오류(에러코드:102) */
	IPM_ERR_ARG					=	-1,			/**< 네트워크 설정 오류(에러코드:103) */
	IPM_ERR_INTERFACE_DOWN		=	-2,			/**< 네트워크 설정 오류(에러코드:104) */
	IPM_ERR_INVALID_GATEWAY		=	-3,			/**< 네트워크 설정 오류(에러코드:105) */
	IPM_ERR_EXISTENT_IP			=	-4,			/**< 현재 설정한 IP는 사용중입니다. */
	IPM_ERR_NO_DHCP_RESPONSE	=	-5			/**< No response from DHCP server */
}	API_STATE_T;

typedef API_STATE_T		DTV_STATUS;
typedef API_STATE_T		DTV_STATUS_T;

/**
 *	Time structure type definitions
 *
 *	\- year		: 1970 ~ 65535 <P>
 *	\- month	: 1 ~ 12 <P>
 *	\- day		: 1 ~ 31 <P>
 *	\- hour		: 0 ~ 23 <P>
 *	\- minute	: 0 ~ 59 <P>
 *	\- second	: 0 ~ 59 <P>
 */
typedef	struct
{
	UINT16		year;
	UINT8		month;
	UINT8 		day;
	UINT8 		hour;
	UINT8 		minute;
	UINT8 		second;
}	TIME_T;

#define	DTV_MAIN_TIME		0x0
#define	PSIP_TIME_PORT_0	0x1
#define	PSIP_TIME_PORT_1	0x2
#define	SI_TIME_PORT_0		0x3
#define	SI_TIME_PORT_1		0x4

/**
 *	Common message type definitions <P>
 *	This message type is used between DTV modules
 *
 *	\- msgID : message ID <P>
 *	\- data  : data payload <P>
 */
typedef struct
{
	UINT32			msgID;
	UINT32			data[3];

}	MSG_TYPE_T;

#ifdef __cplusplus
}
#endif

#endif  /* _COMMON_H_ */

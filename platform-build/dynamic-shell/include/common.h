#ifndef __COMMON_H__
#define __COMMON_H__


// Common type definitions

#ifndef UINT8
typedef unsigned char		__UINT8;
#define UINT8	__UINT8
#endif

#ifndef SINT8
typedef signed char			__SINT8;
#define SINT8	__SINT8
#endif

#ifndef CHAR
typedef	char				__CHAR;
#define CHAR	__CHAR
#endif

#ifndef UINT16
typedef unsigned short		__UINT16;
#define UINT16	__UINT16
#endif

#ifndef SINT16
typedef signed short		__SINT16;
#define SINT16	__SINT16
#endif

#ifndef UINT32
typedef unsigned int		__UINT32;
#define UINT32	__UINT32
#endif

#ifndef SINT32
typedef signed int			__SINT32;
#define SINT32	__SINT32
#endif

#ifndef BOOLEAN
typedef unsigned int		__BOOLEAN;
#define BOOLEAN	__BOOLEAN
#endif

#ifndef ULONG
typedef unsigned long		__ULONG;
#define ULONG	__ULONG
#endif

#ifndef SLONG
typedef signed long			__SLONG;
#define SLONG	__SLONG
#endif

#ifndef UINT64
typedef unsigned long long	__UINT64;
#define UINT64	__UINT64
#endif

#ifndef SINT64
typedef signed long long	__SINT64;
#define SINT64	__SINT64
#endif


// Common constant definitions

#ifndef TRUE
#define TRUE				(1)
#endif

#ifndef FALSE
#define FALSE				(0)
#endif

#ifndef	NULL
#define NULL				((void *)0)
#endif

// API return type definition
typedef enum
{
	API_OK					= 0,
	OK						= 0,
	API_ERROR				= -1,
	API_NOT_OK				= -1,
	NOT_OK					= -1,
	PARAMETER_ERROR			= -2,
	API_INVALID_PARAMS		= -2,
	INVALID_PARAMS			= -2,
	API_NOT_ENOUGH_RESOURCE	= -3,
	NOT_ENOUGH_RESOURCE		= -3,
	API_NOT_SUPPORTED		= -4,
	NOT_SUPPORTED			= -4,
	API_NOT_PERMITTED		= -5,
	NOT_PERMITTED			= -5,
	API_TIMEOUT				= -6,
	TIMEOUT					= -6,
	NO_DATA_RECEIVED		= -7,
	DN_BUF_OVERFLOW			= -8,
} API_STATE_T;

#endif


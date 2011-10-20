/******************************************************************************
 *   LCD TV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2011 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/

/** @file scf.h
 *
 *  Service communication framework dbus primitives
 *
 *  @author    dhjung (donghwan.jung@lge.com)
 *  @version   1.0
 *  @date       2011.06.07
 *  @note
 *  @see
 */

#ifndef	_SCF_H_
#define _SCF_H_

#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <time.h>
#include <sys/time.h>
#include <dbus/dbus.h>
#include <stdbool.h>
#include <stdlib.h>

#include "appfrwk_common.h"

#ifdef __cplusplus
extern "C" {
#endif

#define SCF_DEBUG_ERROR(fmt, args...)		AF_DEBUG_ERRTR(fmt, ##args)

#define DATA_TYPE_INVALID					((int) '\0')
#define DATA_TYPE_BYTE   					((int) 'y')
#define DATA_TYPE_BOOLEAN					((int) 'b')
#define DATA_TYPE_INT16  					((int) 'n')
#define DATA_TYPE_UINT16 					((int) 'q')
#define DATA_TYPE_INT32  					((int) 'i')
#define DATA_TYPE_UINT32 					((int) 'u')
#define DATA_TYPE_INT64  					((int) 'x')
#define DATA_TYPE_UINT64 					((int) 't')
#define DATA_TYPE_DOUBLE 					((int) 'd')
#define DATA_TYPE_STRING 					((int) 's')
#define DATA_TYPE_ARRAY  					((int) 'a')

#define DATA_SIZE_CREATEPAYLOAD(type, num)  sizeof(type)*num*2+1
#define DATA_SIZE_GETPAYLOAD(size) 			(size-1)/2

#define CHECK_DBUS_AVAILABLE(x)											\
do {																	\
	if (HOA_UTIL_GetAlive() == FALSE)									\
	return (x);															\
} while(0)

#define _DEL_PRE							"<#*/"
#define _DEL_PST							"/*#>"
#define _DELIMETER							_DEL_PRE"%c"_DEL_PST
#define _DEL_LEN							9

#define _CR_FMT_ARRY						"%s"_DELIMETER
#define _CR_FMT_BOOL						"%s"_DELIMETER"%x"
#define _CR_FMT_UI16						"%s"_DELIMETER"%x"
#define _CR_FMT_UI32						"%s"_DELIMETER"%x"
#define _CR_FMT_UI64						"%s"_DELIMETER"%llx"
#define _CR_FMT__I16						"%s"_DELIMETER"%x"
#define _CR_FMT__I32						"%s"_DELIMETER"%x"
#define _CR_FMT_BYTE						"%s"_DELIMETER"%x"
#define _CR_FMT_DBLE						"%s"_DELIMETER"%f"
#define _CR_FMT__STR						"%s"_DELIMETER"%s"

#define _FIND_NEXT_PTR(ptr, next)										\
do {																	\
	if (strstr(ptr, _DEL_PRE) != NULL && strstr(ptr, _DEL_PST) != NULL)	\
		next = strstr(ptr, _DEL_PRE);									\
	else																\
		next = NULL;													\
} while(0)

/**
 *	Type of SCF State
 */
typedef enum
{
	SCF_OK						=	 0,
	SCF_ERROR     				=	-1,		/* from ERROR				*/
	SCF_INVALID_PARAM			=	-2,		/* from PARAMETER ERROR		*/
	SCF_NOT_AVAILABLE			=	-3,		/* from NOT_ENOUGH_RESOURCE	*/
	SCF_NOT_CALLABLE			=	-4,		/* from NOT_SUPPORTED		*/
	SCF_ERR_LENGTH				=	-5,		/* from NOT_PERMITTED		*/
	SCF_ERR_TIMEOUT				=	-6,		/* from TIMEOUT				*/

	SCF_ERR_OBJ_DELETED			=	-101

} SCF_STATE_T;

/* scf_bus.c */
void			SCF_BUS_Error_Init(DBusError *error);
void			SCF_BUS_Error_Free(DBusError *error);
dbus_bool_t 	SCF_BUS_Error_Check(DBusError *error);
dbus_bool_t 	SCF_BUS_Threads_Init(void);
DBusConnection 	*SCF_BUS_Connection_Request(DBusBusType bustype, const char *service);
dbus_bool_t		SCF_BUS_Connection_Release(DBusConnection *connection, const char *service);
void 			SCF_BUS_Connection_Flush(DBusConnection *connection);
dbus_bool_t		SCF_BUS_Connection_Add_Filter(DBusConnection *connection, DBusHandleMessageFunction function, void *user_data, DBusFreeFunction free_data_function);
dbus_bool_t		SCF_BUS_Connection_RW_Dispatch(DBusConnection *connection, int timeout_milliseconds);
dbus_bool_t 	SCF_BUS_Connection_Read_Write(DBusConnection *connection, int timeout_milliseconds);
void			SCF_BUS_Connection_Set_Exit_On_Disconnection(DBusConnection *connection, dbus_bool_t exit_on_disconnect);
dbus_bool_t		SCF_BUS_Message_Is_Signal(DBusMessage *message, const char *interface, const char *name);
dbus_bool_t		SCF_BUS_Message_Is_Method(DBusMessage *message, const char *interface, const char *name);
DBusMessage		*SCF_BUS_Message_Receive(DBusConnection *connection, int timeout_milliseconds);
DBusMessage		*SCF_BUS_Message_Create_Signal(const char *path, const char *interface, const char *name, int first_arg_type, ...);
DBusMessage		*SCF_BUS_Message_Create_Method(const char *destination, const char *path, const char *interface, const char *name, int first_arg_type, ...);
DBusMessage		*SCF_BUS_Message_Create_Method_Return(DBusMessage *message, int first_arg_type, ...);
dbus_bool_t		SCF_BUS_Message_Send(DBusConnection *connection, DBusMessage *message);
DBusMessage		*SCF_BUS_Message_Send_And_Wait_Reply(DBusConnection *connection, DBusMessage *message, int timeout_milliseconds);
dbus_bool_t		SCF_BUS_Message_Get_Any(DBusMessage *message, int first_arg_type, ...);
dbus_bool_t		SCF_BUS_Message_Get_Signal(DBusMessage *message, const char *interface, const char *name, int first_arg_type, ...);
dbus_bool_t		SCF_BUS_Message_Get_Method(DBusMessage *message, const char *interface, const char *name, int first_arg_type, ...);
int 			SCF_BUS_Message_Get_Type(DBusMessage *message);
dbus_uint32_t 	SCF_BUS_Message_Get_Serial(DBusMessage *message);
char			*SCF_BUS_Message_Get_Path(DBusMessage *message);
char			*SCF_BUS_Message_Get_Interface(DBusMessage *message);
char			*SCF_BUS_Message_Get_Member(DBusMessage *message);
char			*SCF_BUS_Message_Get_Sender(DBusMessage *message);
dbus_bool_t		SCF_BUS_Message_Unreference(DBusMessage *message);
dbus_bool_t		SCF_BUS_Message_Set_Destination(DBusMessage *message, const char *destservice);
dbus_bool_t		SCF_BUS_Add_Match_Rule(DBusConnection *connection, const char *rule);
dbus_bool_t		SCF_BUS_Remove_Match_Rule(DBusConnection *connection, const char *rule);

/* scf_util.c */
SCF_STATE_T		SCF_UTIL_Create_DataArgs(char *string, int first_type, ...);
SCF_STATE_T		SCF_UTIL_Get_DataArgs(char *data, int first_type, ...);
SCF_STATE_T 	SCF_UTIL_Create_StructPayload(char *string, void *ptr, unsigned int size);
SCF_STATE_T 	SCF_UTIL_Get_StructPayload(char *string, void *ptr, unsigned int size);

/* scf_shm.c */
SCF_STATE_T		SCF_SHM_GetMemory(key_t keyval, int size, char **ppBuffer, int *shmid);
SCF_STATE_T		SCF_SHM_DetachMemory(char *pBuffer);
SCF_STATE_T		SCF_SHM_RemoveMemory(int shmid);
void 			SCF_BUS_ShutDown(void);

#ifdef __cplusplus
}
#endif
#endif

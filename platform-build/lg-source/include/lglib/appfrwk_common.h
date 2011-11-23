/******************************************************************************
 *   LCD TV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2011 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/

/** @file appfrwk_common.h
 *
 *  Common header(PM/AC/UC/Openapi common)
 *
 *  @author    dhjung (donghwan.jung@lge.com)
 *  @version   1.0
 *  @date       2011.05.18
 *  @note
 *  @see
 */
#ifndef _APPFRWK_COMMON_H_
#define _APPFRWK_COMMON_H_

#include <pthread.h>
#include <semaphore.h>
#include <dbus/dbus.h>
#include "appfrwk_common_pm.h"
#include "appfrwk_common_ac.h"
#include "appfrwk_common_uc.h"
#include "appfrwk_common_names.h"
#include "appfrwk_common_pm_events.h"
#include "appfrwk_common_appid.h"
#include "appfrwk_common_key.h"
#include "appfrwk_common_dbgfrwk.h"

#ifdef __cplusplus
extern "C" {
#endif

#define AF_DEBUG_ERRTR(fmt, args...)		do { 																		\
												xlibc_warning_msg(__FILE__, __FUNCTION__, __LINE__, fmt, ##args);		\
												xlibc_sym_backtrace();													\
											} while(0)

#define AF_DEBUG_ERROR(fmt, args...)		do { 																		\
												xlibc_warning_msg(__FILE__, __FUNCTION__, __LINE__, fmt, ##args);		\
											} while(0)

#define MSG_HANDLER							gprocInfo.callbacks.pfnMsgHandler
#define KEY_HANDLER 						gprocInfo.callbacks.pfnKeyEventCallback
#define MOUSE_HANDLER 						gprocInfo.callbacks.pfnMouseEventCallback
#define MSG_HANDLE(msg, submsg, data, size)	do {																		\
												if (MSG_HANDLER != NULL) 												\
													MSG_HANDLER(msg, submsg, data, size);								\
											} while(0)


#ifdef AF_USE_DBGFRWK
#include "xosa_api.h"
/**
* Appfrwk State
*/
typedef enum
{
	AF_OK						=	0,
	AF_ERROR     				=	OSA_ERROR,				/* from ERROR				*/
	AF_INVALID_PARAM			=	OSA_INVALID_PARAM,		/* from PARAMETER ERROR		*/
	AF_NOT_AVAILABLE			=	OSA_NOT_AVAILABLE,		/* from NOT_ENOUGH_RESOURCE	*/
	AF_NOT_CALLABLE				=	OSA_NOT_CALLABLE,		/* from NOT_SUPPORTED		*/
	AF_ERR_LENGTH				=	OSA_ERR_LENGTH,			/* from NOT_PERMITTED		*/
	AF_ERR_TIMEOUT				=	OSA_ERR_TIMEOUT,		/* from TIMEOUT				*/
	AF_ERR_OBJ_DELETED			=	OSA_ERR_OBJ_DELETED

} AF_STATE_T;
#else
/**
* Appfrwk State
*/
typedef enum
{
	AF_OK						=	 0,
	AF_ERROR     				=	-1,		/* from ERROR				*/
	AF_INVALID_PARAM			=	-2,		/* from PARAMETER ERROR		*/
	AF_NOT_AVAILABLE			=	-3,		/* from NOT_ENOUGH_RESOURCE	*/
	AF_NOT_CALLABLE				=	-4,		/* from NOT_SUPPORTED		*/
	AF_ERR_LENGTH				=	-5,		/* from NOT_PERMITTED		*/
	AF_ERR_TIMEOUT				=	-6,		/* from TIMEOUT				*/

	AF_ERR_OBJ_DELETED			=	-101

} AF_STATE_T;
#endif

/**
* Appfrwk Message Type
*/
typedef enum
{
	AF_MESSAGE_TYPE_METHOD,
	AF_MESSAGE_TYPE_EVENT,
	AF_MESSAGE_TYPE_CALLBACK,

} AF_MSG_TYPE_T;

/**
* Task Configuration
*/
typedef struct
{
	char 		*	name;
	void  		*	(*entry_point)(void *);
	int   			priority;
	size_t			stack_size;
	int				sched_policy;
	int				create_flag;	/* no use */
	unsigned long	affnty;
	pthread_t		thid;

} _AF_TASK_CONF_T;

/**
* Task GConfigure
*/
typedef struct
{
	char 		name[AF_MAX_NAME_LEN];
	void  		*(*entry_point)(void *);
	int   		priority;
	size_t		stack_size;
	pthread_t	thid;

} _AF_TASK_GCONF_T;

/**
* Buffer Handler
*/
typedef struct
{
	UINT32		key;
	int			shmid;
	UINT32		size;
	char		*pBuffer;
	char		*pAllocbuffer;
	char		*pProtect;
	UINT32		protsize;

} AF_BUFFER_HNDL_T;

/**
 * Application process가 Agent에 등록해야 하는 Callback들 .
 */
typedef struct
{
	HOA_STATUS_T 	(*pfnMsgHandler)(HOA_MSG_TYPE_T msg, UINT32 submsg, UINT8 *pData, UINT16 dataSize);
	BOOLEAN 		(*pfnKeyEventCallback)(UINT32 key, PM_KEY_COND_T keyCond,PM_ADDITIONAL_INPUT_INFO_T event);
	//BOOLEAN 		(*pfnMouseEventCallback)(SINT32 posX, SINT32 posY, UINT32 keyCode, PM_KEY_COND_T keyCond);
	BOOLEAN 		(*pfnMouseEventCallback)(SINT32 posX, SINT32 posY, UINT32 keyCode, PM_KEY_COND_T keyCond, PM_ADDITIONAL_INPUT_INFO_T event);

} HOA_PROC_CALLBACKS_T;

/**
 * Application process가 PID와 Status.
 * (HOA_MSG_OTHERAPPSTATUSCHANGED의 pData)
 */
typedef struct AF_PROC_PID_STATUS
{
	SINT32			pid;					/**< Process ID of Executed Application */
	PM_PROC_STATE_T status;					/**< Status of Executed Application */

} HOA_PROC_PID_STATUS_T;

typedef enum
{
	PID,
	SNAME,
	RCVCONN,
	SNDCONN,
	KEYCONN,
	EVTCONN,
	CBCONN,
	CBFUNCS

} HOA_PROC_INFO_E;

/**
 * Application information
 */
typedef struct
{
	SINT32					pid;			/**< Process PID */
	char					serviceName[AF_MAX_SERNAME_LEN];
	DBusConnection			*connrcv;		/**< msg receive / reply sender 용 connection --> default connection */
	DBusConnection			*connsend;		/**< msg send    / reply receive용 connection */
	DBusConnection			*connkey;		/**< key receive 용 connection */
	DBusConnection			*connevt;		/**< evt receive 용 connection */
	DBusConnection			*conncb;		/**< callback receive 용 connection */
	HOA_PROC_CALLBACKS_T	callbacks;		/**< 초기화시에 등록한 callback */

} HOA_PROC_INFO_T;

#ifdef AF_USE_DBGFRWK

typedef osa_thread_t	 	AF_TID_TYPE;
typedef osa_thread_attr_t	AF_TASK_CONF_T;
typedef osa_thread_attr_t	AF_TASK_GCONF_T;
typedef	osa_lock_t			AF_MUTEX_T;
typedef	osa_lock_t			AF_SEMA_T;

#define RES_END_POINT   	{ "",   NULL,0,0,0,0,0}
#define CHK_RES_END(p_conf)	((p_conf)->entry_point == NULL)
#else

typedef pthread_t	 		AF_TID_TYPE;
typedef _AF_TASK_CONF_T		AF_TASK_CONF_T;
typedef _AF_TASK_GCONF_T	AF_TASK_GCONF_T;
typedef	sem_t *				AF_SEMA_T;

#define RES_END_POINT  		{NULL, NULL, 0, 0, 0}
#define CHK_RES_END(p_conf)	((p_conf)->name == NULL)

#endif


/* appfrwk_common_debug.c */
void			AF_DEBUG_Print(const char *function_name, const char * format, ...);
void 			AF_DEBUG_Init(void);

/* appfrwk_common_osa.c */
AF_STATE_T		AF_InitTaskRes(void);

AF_TID_TYPE		AF_CreateTask(AF_TASK_CONF_T *taskconf, void *pArgs);

AF_TID_TYPE 	AF_CreateTaskEx(
						   char		*name,
						   void	*	(*entry_point)(void *),
						   void		*arg,
						   void		*rsv,
						   size_t	stack_size,
						   int		prio,
						   unsigned long	cpunum);

AF_SEMA_T 		AF_CreateBinSem(char *name, int sFlag, int iCount);
AF_SEMA_T 		AF_CreateSerSem(char *name, int sFlag, int iCount);
int 			AF_DeleteSem (AF_SEMA_T sema);
int 			AF_WaitSem( AF_SEMA_T sema, int wait_ms );
int 			AF_PostSem( AF_SEMA_T sema );
void 			AF_PrintStack(void);

/* appfrwk_common_util.c */
AF_STATE_T 		AF_UTIL_GetServiceName(char *args, char *service);
int 			AF_UTIL_GetUinputFDForReturn(BOOLEAN bIsKeyReturnPath);
HOA_STATUS_T	HOA_UTIL_SetProcInfo(HOA_PROC_INFO_E info, void *pData);
HOA_STATUS_T	HOA_UTIL_GetProcInfo(HOA_PROC_INFO_T *procInfo);
SINT32 			HOA_UTIL_GetProcPID(void);
char 			*HOA_UTIL_GetProcServiceName(void);
DBusConnection 	*HOA_UTIL_GetProcRcvConnection(void);
DBusConnection 	*HOA_UTIL_GetProcSendConnection(void);
#ifdef USE_POLLING
void 			*HOA_UTIL_Task_MsgSender(void *data);
#endif
HOA_STATUS_T	 HOA_UTIL_CheckProcessExistFromProcFs(const char *pProcName, const char *pServiceName, BOOLEAN *bExist, pid_t *pProcPID);
void 			HOA_UTIL_QuitTask(void);
UINT32 			HOA_UTIL_GetAlive(void);

/* appfrwk_common_shm.c */
AF_STATE_T		AF_SHM_CreateSharedMemory(AF_BUFFER_HNDL_T *pHndl, int size);
AF_STATE_T		AF_SHM_GetSharedMemory(AF_BUFFER_HNDL_T *pHndl, char **ppBuffer);
AF_STATE_T		AF_SHM_DetachSharedMemory(AF_BUFFER_HNDL_T *pHndl);
AF_STATE_T		AF_SHM_RemoveSharedMemory(AF_BUFFER_HNDL_T *pHndl);

/* appfrwk_common_fileio.c */
AF_STATE_T		AF_FILEIO_CopyFileToBuffer(char* fileName, char *pFileData);
AF_STATE_T		AF_FILEIO_MakeFileFromBuffer(char* fileName, char *pFileData, int buffSize);
AF_STATE_T		AF_FILEIO_GetFileSize(char* fileName, UINT32 *nFileSize);
AF_STATE_T		AF_FILEIO_GetDataFromFile(char *fileName , char **ppFileData, int *pBuffSize);
AF_STATE_T		AF_FILEIO_CopyFile(char *pszSrcFilePath, char *pszDestPath);
AF_STATE_T		AF_FILEIO_MoveFile(char *pszPathSrc, char *pszPathDest);
AF_STATE_T		AF_FILEIO_DeleteFile(char *pszPath, BOOLEAN bRecursive);

#ifdef __cplusplus
}
#endif
#endif

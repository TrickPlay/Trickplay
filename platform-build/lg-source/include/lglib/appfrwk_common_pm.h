/******************************************************************************
 *   LCD TV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2011 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/

/** @file appfrwk_common_pm.h
 *
 *  PM <-> Openapi common header
 *
 *  @author    dhjung (donghwan.jung@lge.com)
 *  @version    1.0
 *  @date       2011.06.20
 *  @note
 *  @see
 */

#ifndef _APPFRWK_COMMON_PM_H_
#define _APPFRWK_COMMON_PM_H_

#include "appfrwk_common_types.h"

#ifdef __cplusplus
extern "C" {
#endif

#define	PM_CURSOR_MAX_FPS		70			/**< maximum cursor fps is 50 */

/**
* PM_PROC_STATE_T
*
* Process의 상태를 나타내는 데 사용하는 enumeration
*/
typedef enum
{
	PM_PROC_STATE_INIT,						/**< Process가 생성은 되었지만 register는 되지 않은 상태 : dbus 송수신 불가 */
	PM_PROC_STATE_LOAD,						/**< Process가 register까지만 된 상태 : 이상태에서도 dbus는 connection이 맺어져 evt를 받을 수는 있음 */
	PM_PROC_STATE_RUN,						/**< 실행 중인 상태로 보통 이 상태 이후 부터 process들이 evt를 받음 */
	PM_PROC_STATE_TERM,						/**< Terminate중인 상태 : 이 상태 이후에 deregister를 한 다음 NONE 상태로 간다 */
	PM_PROC_STATE_NONE,						/**< Process가 deregister 되었을 때의 상태 : 이 상태 이후로 process는 exit된다. */
	PM_PROC_STATE_LAST

} PM_PROC_STATE_T;

typedef enum
{
	CREATE_NONE, 							/**< do not have plan to create background process */
	CREATE_NOTYET,							/**< have plan to create bg process but not created */
	CREATE_WAITING,							/**< bg process create waiting in register handler */
	CREATE_COMPLETE,						/**< bg process create done */
	CREATE_TERM,							/**< bg process is terminated forcibly */

} PM_PROC_BG_STATUS_T;

typedef enum
{
	TERM_UPDATE, 							/**< process terminate when s/w update */
	TERM_POWEROFF, 							/**< process terminate when power off */
	TERM_NOMEM, 							/**< process terminate when memory is insufficient */

} PM_PROC_TERM_CASE_T;

/**
 * This enumeration describes the remote control key condition.
 */
typedef enum
{
	PM_KEY_PRESS, 							/**< for Pressed key */
	PM_KEY_RELEASE, 						/**< for Released key */
	PM_KEY_REPEAT, 							/**< for Repeated key */
	PM_KEY_DRAG, 							/**< for Motion Remote Drag */
	PM_KEY_POWER, 							/**< for Motion Remote Swing power */
	PM_KEY_GESTURE, 						/**< for Motion Remote Gesture recognition */
	PM_KEY_COND_LAST

} PM_KEY_COND_T;

typedef struct
{
	char	*pServiceName;					/**< Process servicename */
	UINT64	nAUID;							/**< The current auid of process */

} PM_PROC_SUBINFO_T;

#ifdef __cplusplus
}
#endif
#endif

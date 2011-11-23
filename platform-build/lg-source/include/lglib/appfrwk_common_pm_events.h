/******************************************************************************
 *   LCD TV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2011 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/
/** @file appfrwk_common_pm_events.h
*
*	Events header file.
*
*	@author 	Kun-IL Lee(dreamer@lge.com)
*	@version	0.9
*	@date   	2011.05.11
*	@note
*/

/*---------------------------------------------------------
    (Header File Guarder )
---------------------------------------------------------*/
#ifndef _APPFRWK_COMMON_PM_EVENTS_H_
#define _APPFRWK_COMMON_PM_EVENTS_H_

/*---------------------------------------------------------
    Control 상수 정의
    (Control Constants)
---------------------------------------------------------*/

/*---------------------------------------------------------
    #include 파일들
    (File Inclusions)
---------------------------------------------------------*/
#include "appfrwk_common_types.h"

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <errno.h>
#include <limits.h>
#include <linux/input.h>
#include <linux/uinput.h>
#include <time.h>
#include <sys/time.h>

#ifdef __cplusplus
extern "C" {
#endif

/*---------------------------------------------------------
    상수 정의
    (Constant Definitions)
---------------------------------------------------------*/
#define	DEV_FILE_UINPUT					"/dev/uinput"

/*	LGE's event device names */
#define	DEV_NAME_INPUT_LGE_KEY_RETURNPATH 		"LGE KEY RETURNPATH" 		/*Return Path of IR, Keyboard */
#define	DEV_NAME_INPUT_LGE_CURSOR_RETURNPATH 	"LGE CURSOR RETURNPATH" 	/*Return Path of MRCU, mouse*/
#define	DEV_NAME_INPUT_LGE_RCU  					"LGE RCU"					/*IR*/
#define	DEV_NAME_INPUT_LGE_M_RCU					"LGE M-RCU - Builtin"	    /*MRCU*/

/*	Max number of inputs(event devices) */
#define MAX_LINUX_INPUT_DEVICES 		16

/*
 * Event types
 */
#ifdef	_DEFINED_IN_INPUT_H		/* just references(copy from <linux/input.h>) */
#define EV_SYN							0x00
#define EV_KEY							0x01
#define EV_REL							0x02
#define EV_ABS							0x03
#define EV_MSC							0x04
#define EV_SW							0x05
#define EV_LED							0x11
#define EV_SND							0x12
#define EV_REP							0x14
#define EV_FF							0x15
#define EV_PWR							0x16
#define EV_FF_STATUS					0x17
#define EV_MAX							0x1f
#define EV_CNT							(EV_MAX+1)
#endif

/*	definitions of special keys for LGE	*/
// moved appfrwk_common_key.h //
/*
#define KEY_LGE_MRCU_PAIR_START			0x4EA
#define KEY_LGE_MRCU_PAIR_STOP			0x4EB
#define KEY_LGE_MRCU_PAIR_OK   			0x4EC
#define KEY_LGE_MRCU_PAIR_NG			    0x4ED
#define KEY_LGE_MRCU_CURSOR_ON			0x4EE
#define KEY_LGE_MRCU_CURSOR_OFF			0x4EF

#define KEY_LGE_MRCU_GESTURE_CHECK			0x4F0
#define KEY_LGE_MRCU_GESTURE_RIGHT				0x4F1
#define KEY_LGE_MRCU_GESTURE_CIRCLE			0x4F2
#define KEY_LGE_MRCU_GESTURE_CIRCLE_INVERSE	0x4F3
#define KEY_LGE_MRCU_GESTURE_INVALID			0x4F4
#define KEY_LGE_MRCU_GESTURE_FAIL				0x4F5
#define KEY_LGE_MRCU_GESTURE_END				0x4F6

#define KEY_LGE_INPUT_FIRST				0x4F7	// Print input's list 
#define KEY_LGE_INPUT_PRINT				(KEY_LGE_INPUT_FIRST + 1)	// Print input's list 
#define KEY_LGE_INPUT_CHECK				(KEY_LGE_INPUT_PRINT + 1)
#define KEY_LGE_INPUT_LAST				(KEY_LGE_INPUT_CHECK + 1)
*/

/*	definitions of key.value	*/
#define	KEY_VALUE_RELEASE				0
#define	KEY_VALUE_PRESS				1
#define	KEY_VALUE_REPEAT				2
#define KEY_VALUE_DRAG					3

/*
 * Type of input device for basic classification.
 * Values may be or'ed together.
 */
typedef enum {

	PEID_TYPE_NONE         				= 0x00000000,  /* Unclassified, no specific type. */

	PEID_TYPE_KEYBOARD     				= 0x00000001,  /* Can act as a keyboard. */
	PEID_TYPE_MOUSE        				= 0x00000002,  /* Can be used as a mouse. */
	PEID_TYPE_JOYSTICK     				= 0x00000004,  /* Can be used as a joystick. */
	PEID_TYPE_REMOTE       				= 0x00000008,  /* Is a remote control. */
	PEID_TYPE_VIRTUAL      				= 0x00000010,  /* Is a virtual input device. */

	PEID_TYPE_KEY_RETURN      			= 0x00000020,  /* Is a key(IR,keyboard)return input device. */
	PEID_TYPE_CURSOR_RETURN				= 0x00000040,  /* Is a Cursor(MRCU,Mouse)return input device. */
	PEID_TYPE_LGE          				= 0x00000080,  /* Is a LGE's input device. */

	PEID_TYPE_ALL          				= 0x0000009F   /* All type flags set. */

} PM_EVENT_INPUT_DEV_TYPE_T;

/*
 * Basic input device features.
 */
typedef enum {

	PEID_CAP_KEYS          				= 0x00000001,  /* device supports key events */
	PEID_CAP_AXES          				= 0x00000002,  /* device supports axis events */
	PEID_CAP_BUTTONS       				= 0x00000004,  /* device supports button events */
	PEID_CAP_GESTURE       				= 0x00000008,  /* device supports gesture events */

	PEID_CAP_ALL           				= 0x0000000F   /* all capabilities */

} PM_EVENT_INPUT_DEV_CAP_T;

/*
	CURSOR's bitmap types
*/
typedef enum {
	PM_CURSOR_TYPE_NORMAL,
	PM_CURSOR_TYPE_PROGRESS,	/** progress look */
} PM_CURSOR_LOOK_TYPE_T;


/*---------------------------------------------------------
    Type 정의
    (Type Definitions)
---------------------------------------------------------*/

/*
 * Description of the input device capabilities.
 */
typedef struct {

	PM_EVENT_INPUT_DEV_TYPE_T			type;	/* classification of input device */
	PM_EVENT_INPUT_DEV_CAP_T			caps;	/* capabilities, validates the following fields */
	char 								name[256]; /* device name */
} PM_EVENT_INPUT_DEV_DESC_T;

/*
 * Description of the input device id & fd.
 */
typedef	struct	{
	SINT32	fd;
	SINT32	index;
} PM_EVENT_INPUT_FD_T;

/*
 *  the input device info.
 */
typedef	struct	{
	PM_EVENT_INPUT_FD_T			info;
	PM_EVENT_INPUT_DEV_DESC_T	desc;
} PM_EVENT_INPUT_T;

/**
 * PM_ADDITIONAL_INPUT_INFO_T.
 */

typedef struct
{
	struct input_event event;
	SINT32 deviceID;
} PM_ADDITIONAL_INPUT_INFO_T;

#ifdef __cplusplus
}
#endif
#endif /* #ifndef _PM_EVENT_H_ */

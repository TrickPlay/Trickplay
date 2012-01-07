/******************************************************************************
 *   Software Platform Lab., LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2008 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/

/** @file appfrwk_common_types.h
 *
 *  Appframework common types header
 *
 *  @author     Meekyung Lim (meekyung.lim@lge.com)
 *  @version    1.0
 *  @date       2011.07.19
 *  @note
 *  @see
 */
#ifndef _APPFRWK_COMMON_TYPES_H_
#define _APPFRWK_COMMON_TYPES_H_

#ifdef __cplusplus
extern "C" {
#endif

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
typedef	unsigned int			__BOOLEAN;
#define BOOLEAN __BOOLEAN
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
typedef	unsigned long long		__UINT64;
#define UINT64 __UINT64
#endif

#ifndef SINT64
typedef	signed long long		__SINT64;
#define SINT64 __SINT64
#endif

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

#ifndef UNUSED
#define UNUSED(x)				((void)(x))
#endif

#ifndef CONST_FUNC
#define CONST_FUNC				__attribute__ ((constructor))
#endif

#ifndef DEST_FUNC
#define DEST_FUNC				__attribute__ ((destructor))
#endif

#define AF_MAX_PATH_LEN				256
#define AF_MAX_ARGS_LEN				3072+640
#define AF_MAX_ARG_NUM				128
#define AF_MAX_ENV_VAR_LEN			64
#define AF_MAX_LINE_LEN				512

#define AF_MAX_VER_LEN	 			16
#define AF_MAX_NAME_LEN 			64
#define AF_MAX_SERNAME_LEN			256
#define AF_MAX_RULE_LEN				256
#define AF_MAX_TASK_NUM				16
#define AF_MAX_HNDL_NUM				1024
#define AF_MAX_PROC_NUM				30

#ifdef USE_POLLING
#define AF_MAX_TIMEOUT				50 					/* msec */
#define AF_MAX_SEND_TIMEOUT			1 					/* msec */
#define AF_MAX_WAIT					10					/* usec */
#else
#define AF_MAX_TIMEOUT				-1 					/* msec */
#endif

#define _MEMBER(a)					#a

#define ENTER_FUNC()				PM_SEND_PRINT("[ENTER] %s\n", __FUNCTION__)
#define LEAVE_FUNC()				PM_SEND_PRINT("[LEAVE] %s\n", __FUNCTION__)

#ifdef AF_USE_DBGFRWK
#include "xosa_api.h"

#define AF_SCHED_OTHER				OSA_SCHED_OTHER
#define AF_SCHED_RR					OSA_SCHED_RR
#define AF_SCHED_FIFO				OSA_SCHED_FIFO

#define AF_SMF_NONE					SMF_NONE
#define AF_SMF_RECURSIVE			SMF_RECURSIVE
#define AF_OSA_INF_WAIT	       	 	OSA_INF_WAIT 		/* Wait for ever			*/
#define AF_OSA_NO_WAIT         	 	OSA_NO_WAIT			/* No wait					*/
#define AF_OSA_WAIT_FOREVER	 	   	OSA_INF_WAIT

#define AF_FLAG_CPU_0				FLAG_CPU_0
#define AF_FLAG_CPU_1				FLAG_CPU_1
#define AF_FLAG_CPU_ALL				FLAG_CPU_ALL
#define	AF_THREAD_STACK_DEF			OSA_THREAD_STACK_DEF

#else
#define AF_SCHED_OTHER				SCHED_OTHER
#define AF_SCHED_RR					SCHED_RR
#define AF_SCHED_FIFO				SCHED_FIFO

#define AF_SMF_NONE					0
#define AF_SMF_RECURSIVE			1
#define AF_OSA_INF_WAIT	       	 	-1		/* Wait for ever			*/
#define AF_OSA_NO_WAIT         	 	0		/* No wait					*/
#define AF_OSA_WAIT_FOREVER	 	   	AF_OSA_INF_WAIT

#define AF_FLAG_CPU_0				0
#define AF_FLAG_CPU_1				1
#define AF_FLAG_CPU_ALL				0xffffffff
#define	AF_THREAD_STACK_DEF			(128 * 1024)

#endif

/**
 * HOA API의 Return type.
 *
 */
typedef enum {
	HOA_OK					= 0,	/**< HOA 함수가 성공적으로 수행 */
	HOA_HANDLED				= 0,	/**< 주어진 요청사항에 대한 처리를 완료함 */
	HOA_ERROR				= -1,	/**< 함수 수행 중 에러 발생 */
	HOA_NOT_HANDLED			= -1,	/**< 주어진 요청사항에 대한 처리를 하지 않음 */
	HOA_BLOCKED				= -2,	/**< 다른 App.가 HOA를 독점적으로 사용하고 있어 수행되지 않음 */
	HOA_INVALID_PARAMS		= -3,	/**< 함수 인자에 잘못된 값이 들어있음 */
	HOA_NOT_ENOUGH_MEMORY	= -4,	/**< 메모리가 함수를 수행할 수 있을 만큼 충분하지 않음 */
	HOA_TIMEOUT				= -5,	/**< 함수 수행 요청 후 일정 시간 내에 답이 오지 않음 */
	HOA_NOT_SUPPORTED		= -6,	/**< 버전 차이 등으로 인해 지원되지 않는 함수임 */
	HOA_BUFFER_FULL			= -7,	/**< 버퍼에 데이터가 가득 차있어 함수가 수행되지 않음  */
	HOA_HOST_NOT_CONNECTED	= -8,	/**< Host가 연결되어 있지 않아 함수가 수행되지 않음  */
	HOA_VERSION_MISMATCH	= -9,	/**< App.와 library간에 버전이 맞지 않아 수행되지 않음 */
	HOA_ALREADY_REGISTERED	= -10,	/**< App.가 이미 Manager에 등록되어 있음 */
	HOA_LAST

} HOA_STATUS_T;

/**
 * Message의 종류
 */
typedef enum MSG_TYPE
{
	HOA_MSG_NONE,					/**< 메세지 없음 */
	HOA_MSG_FOCUS_IN,				/**< Focus in.\n
											submsg : 0,\n
											pData : NULL,\n
											dataSize : 0.
									*/
	HOA_MSG_FOCUS_OUT,				/**< Focus out.\n
											submsg : 0,\n
											pData : NULL,\n
											dataSize : 0.
									*/
	HOA_MSG_EXECUTE,				/**< 이미 실행중인 프로그램에 대해 다시 한번 실행 요청이 올 경우 실행 파라메터를 전달해 준다.\n
											submsg : 0,\n
											pData : 실행 argument. NULL로 끝나도록 처리되어 있음,\n
											dataSize : string length of argument.
									*/
	HOA_MSG_TERMINATE,				/**< Application 종료 요청.\n
											submsg : 0,\n
											pData : NULL,\n
											dataSize : 0.
									*/
	HOA_MSG_THE_END,				/**< Application 이 Appctrl에 의해서 dereg 됐음을 알림 .\n
											submsg : 0,\n
											pData : NULL,\n
											dataSize : 0.
									*/
	HOA_MSG_HOST_EVENT,				/**< Host에서 보낸 Event 알림.\n
											submsg : ADDON_HOST_EVENT_T,\n
											pData : UINT32 size의 data,\n
											dataSize : sizeof(UINT32).
									*/
	HOA_MSG_USER,					/**< Host에서 특정 Add-on App.로 보내는 custom message.\n
											submsg : customized message ID,\n
											pData : customized Data,\n
											dataSize : size of customized Data.
									*/
	HOA_MSG_OTHERAPPSTATUSCHANGED,	/**< 프로그램이 실행을 요청한 다른 프로그램의 상태가 변경될 경우 알림.\n
											submsg : 0, \n
											pData : pointer of HOA_APP_PID_STATUS_T,\n
											dataSize : size of (HOA_APP_PID_STATUS_T)
									*/
	HOA_MSG_STOPLOADING,			/**< 프로그램이 로딩중일 때, 로딩을 멈추도록 함.\n
											submsg : 0,\n
											pData : NULL,\n
											dataSize : 0.
									*/
	HOA_MSG_UC_EVENT,				/**< Update Contoller에서 보낸 Event 및 Progress Rate 알림.\n
											submsg : 0, \n
											pData : pointer of HOA_UC_EVENT_T,\n
											dataSize : size of (HOA_UC_EVENT_T)
									*/
	HOA_MSG_AC_EVENT,				/**< Application Contoller에서 보낸 Event \n
											submsg : HOA_AC_SUBMSG_TYPE_T, \n
											pData : pointer of AUID (UINT64),\n
											dataSize : size of AUID.
									*/
	HOA_MSG_PM_EVENT,				/**< Process Manager에서 보낸 Event \n
											submsg : HOA_PM_SUBMSG_TYPE_T, \n
											pData : pServiceName,\n
											dataSize : strlen(pServiceName).
									*/
	HOA_MSG_APP_EXITCODE,			/**< App.이 ExitCode를 주고 종료시, App.의 수행을 요청한 App.에게 ExitCode를 전달 \n
											submsg : 0, \n
											pData : pointer of ADDON_EXITCODE_T,\n
											dataSize : size of (ADDON_EXITCODE_T)
									*/
	HOA_MSG_LAST

} HOA_MSG_TYPE_T;

/**
 * 일정 시간마다 자신의 상태를 알리는 데 사용하는 enumeration
 */
typedef enum
{
	HOST_EVT_CH_CHANGED,						/**< Channel is changed */

	/* USB evnet */
	HOST_EVT_USB_CONNECTED,						/**< USB device is connected */
	HOST_EVT_USB_DISCONNECTED,					/**< USB device is disconnected */
	HOST_EVT_USB_ATTATCHED,						/**< USB device is attatched (mount) */
	HOST_EVT_USB_DETACHED,						/**< USB device is detached (umount) */

	HOST_EVT_BTUSB_CONNECTED, 					/**< BT USB device is connected */
	HOST_EVT_BTUSB_DISCONNECTED,				/**< BT USB device is disconnected */

	HOST_EVT_POWER_OFF,							/**< Power off */
	HOST_EVT_POWER_ON,							/**< Power on */
	HOST_EVT_ASPECTRATIO_CHANGED, 				/**< Aspect ratio is changed */
	HOST_EVT_LANGUAGE_CHANGED,					/**< A language is changed */
	HOST_EVT_COUNTRY_CHANGED,					/**< B country is changed */
	HOST_EVT_SCREENSAVER_CHANGED,				/**< C screensaver(black out status) is changed */
	HOST_EVT_REPEAT_CH_CHANGE,					/**< D Change channel using repeat key */
	HOST_EVT_INPUT_CHANGED, 					/**< E Input source is changed */

	/* BSI On/Off */
	HOST_EVT_BSI_ON,							/**< F BSI on */
	HOST_EVT_BSI_OFF,							/**< 10 BSI off */

	HOST_EVT_CLOSE_ALL_WINDOW,					/**< Close all window */

	HOST_EVT_SIMPLINK,							/**< Simplink event */

	HOST_EVT_POPUP_ON,							/**< Host popup is on */
	HOST_EVT_POPUP_OFF,							/**< Host popup is off */

	HOST_EVT_MOTIONREMOCON_ON,					/**< Motion remocon is on */
	HOST_EVT_MOTIONREMOCON_OFF,					/**< Motion remocon is off */
	HOST_EVT_MOTIONREMOCON_ON_PROC_NO,			/**< Motion remocon is on, but proc isn't exist */
	HOST_EVT_MOTIONREMOCON_OFF_PROC_NO,			/**< Motion remocon is off, but proc isn't exist */

	/* Tuner Event */
	HOST_EVT_TUNER_INITIALIZED = 0xf000,		/**< Tuner is initialized */
	HOST_EVT_TUNER_TUNED,						/**< Tuner is tuned */
	HOST_EVT_TUNER_UNLOCKED,					/**< Tuner is unlocked */
	HOST_EVT_TUNER_LOCKED,						/**< Tuner is locked */
	HOST_EVT_TUNER_TSLIST_CHANGED,				/**< TS list is changed */

	/* IPTV Event\n */
	HOST_EVT_IPTV_NEWFIRMWARE = 0xf010,			/**< New IPTV Firmware detected */

	/* Network Event
	----------------------------------------------------------
	This message means that your physical link is connected.
	==>> HOST_EVT_NETWORK_CONNECTED
	So, if you don't received above the message, check your cable plug, and check your wireless physical connection.

	If you receive messages like this sequence,
		1. HOST_EVT_NETWORK_CONNECTED
		2. HOST_EVT_NETWORK_INET_DISABLED
	==> The physical link is connected. Check your server setting like DNS, Gateway, Subnetmask.

	If you receive messages like this sequence,
		1. HOST_EVT_NETWORK_CONNECTED
		2. HOST_EVT_NETWORK_INET_ENABLED
	==> you can reach internet.
	*/
	HOST_EVT_NETWORK_CONNECTED,					/**< Network is connected: This means that the physical link is connected */
	HOST_EVT_NETWORK_DISCONNECTED,				/**< Network is disconnected: This means that the physical link is disconnected */
	HOST_EVT_NETWORK_SETTINGCHANGED,			/**< Network setting is changed */
	HOST_EVT_NETWORK_INET_ENABLED ,				/**< Internet is enabled : This means that you can use internet */
	HOST_EVT_NETWORK_INET_DISABLED, 			/**< Internet is disabled : This means that you can't use internet */

	/* Bluetooth Event\n */
	HOST_EVT_BLUETOOTH_CONNECTED,				/**< Bluetooth is connected */
	HOST_EVT_BLUETOOTH_DISCONNECTED,			/**< Bluetooth is disconnected */

	HOST_EVT_WEBCAM_ON,							/**< Webcam on */
	HOST_EVT_WEBCAM_OFF,						/**< Webcam off */
	HOST_EVT_SDP_FORCE_UPDATE,					/**< A SDP Force update*/
	HOST_EVT_SDP_DNLD_DONE,						/**< SDP Download done*/
	HOST_EVT_SDP_PATH_UPDATE,					/**< SDP Path update*/

	HOST_EVT_UPDATE_ALL,						/**< 'update all screen' is needed */
	HOST_EVT_OUT_OF_MEMORY,						/**< out of device memory */
	HOST_EVT_USB_FORMAT_COMPLETED,				/**< LG formatted USB format completed  */
	HOST_EVT_FLASH_FORMAT_COMPLETED,			/**< 10 MY Apps Internal flash format completed  */

	HOST_EVT_SDPIF_COUNTRY_CHANGED,				/**< SDPIF country information is changed */
	HOST_EVT_SDPIF_UPDATE_OPT,					/**< SDP server data is updated */
	HOST_EVT_SDPIF_SIGN_IN,						/**< sign in */
	HOST_EVT_SDPIF_SIGN_OUT,					/**< sign out */
	HOST_EVT_SDPIF_UPDATE_DONE,					/**< premium pkg is updated */
	HOST_EVT_SDPIF_UPDATE_ERR,					/**< cannot update premium pkgs */
	HOST_EVT_SDPIF_LANG_CHANGED,				/**< lang is changed */

	HOST_EVT_COUNTRY_OTHERS_AUTO,				/**< country is others(auto) */

	HOST_EVT_VCS_UI_PRINT,						/**< skype flash ui print on/off */

	HOST_EVT_HBBTV_OFF,							/**< 1A hbbtv */
	HOST_EVT_HBBTV_ON,

	HOST_EVT_USB_FORMAT_INITIALIZE_COMPLETED,	/**< MY Apps USB Init/format completed  */
	HOST_EVT_USB_FORMAT_INITIALIZE_FAILED,		/**< MY Apps USB Init/format failed  */
	HOST_EVT_USB_INITIALIZE_COMPLETED,			/**< MY Apps USB Init Completed */
	HOST_EVT_USB_INITIALIZE_FAILED,				/**< 1F MY Apps USB Init failed */

	HOST_EVT_FLASH_MOUNT_COMPLETED,    			/**< 20 MY Apps Internal flash Mount  completed  */
	HOST_EVT_FLASH_MOUNT_FAILED,       			/**< MY Apps Internal flash Mount  failed  */
	HOST_EVT_FLASH_FORMAT_INITIALIZE_COMPLETED, /**< MY Apps Internal flash Init/format  completed  */
	HOST_EVT_FLASH_FORMAT_INITIALIZE_FAILED,	/**< MY Apps Internal flash Init/format  failed  */

	HOST_EVT_3D_STATUS_CHANGE,					/**< 3D status change message. */

	HOST_EVT_FXUI_FOCUS_ON, 					/**< fxui > */
	HOST_EVT_FXUI_FOCUS_OFF,

	HOST_EVT_LAST = 0xffff

} HOA_HOST_EVENT_T;

/**
* Candiate Country Event
*/
typedef enum
{
	SDPIF_CANDIDATE_COUNTRY_AVAILABLE 	= 0x30,	/**< Candidate country code exist */
	SDPIF_CANDIDATE_COUNTRY_NONE,				/**< Candidate country code none */
	SDPIF_CANDIDATE_COUNTRY_EVENT_LAST

} HOA_SDPIF_COUNTRY_EVENT_T;

/**
* Force Update Message Event
*/
typedef enum
{
	SDPIF_UPDATE_PKG 	= 0x40,					/**< Force update message event */
	SDPIF_UPDATE_EVENT_LAST

}HOA_SDPIF_UPDATE_PKG_EVENT_T;

#ifdef ENABLE_AJJA_GROUP
/**
 * Group Type
 */
typedef enum HOA_LOCALE_GROUP
{
	HOA_GROUP_KR = 0x01,	/**< Korea */
	HOA_GROUP_US,			/**< United States */
	HOA_GROUP_BR,			/**< Brazil */
	HOA_GROUP_EU,			/**< EU */
	HOA_GROUP_CN,			/**< China (Mainland) */
	HOA_GROUP_TW,			/**< Taiwan */
	HOA_GROUP_XA,			/**< 중남미 아날로그 국가, NTSC */
	HOA_GROUP_IL,			/**< 이스라엘 */
	HOA_GROUP_HK,			/**< China (Hongkong) */
	HOA_GROUP_JP,			/**< Japan */
	HOA_GROUP_AJ,			/**< ASIA */
	HOA_GROUP_JA,			/**< MEA */
	HOA_GROUP_ZZ			/**< not defined */
} HOA_LOCALE_GROUP_T;
#else

/**
 * Group Type
 */
typedef enum HOA_LOCALE_GROUP
{
	HOA_GROUP_KR = 0x01,	/**< Korea */
	HOA_GROUP_US,			/**< United States */
	HOA_GROUP_BR,			/**< Brazil */
	HOA_GROUP_EU,			/**< EU */
	HOA_GROUP_CN,			/**< China (Mainland) */
	HOA_GROUP_AU,			/**< Australia */
	HOA_GROUP_SG,			/**< Singapore */
	HOA_GROUP_ZA,			/**< South Africa */
	HOA_GROUP_VN,			/**< Vietnam */
	HOA_GROUP_TW,			/**< Taiwan */
	HOA_GROUP_XA,			/**< 중남미 아날로그 국가, NTSC */
	HOA_GROUP_XB,			/**< 중아, 아주 아날로그 국가, PAL */
	HOA_GROUP_IL,			/**< 이스라엘 */
	HOA_GROUP_ID,			/**< 인도네시아 */
	HOA_GROUP_MY,			/**< 말레이시아 */
	HOA_GROUP_IR,			/**< 이란 */
	HOA_GROUP_HK,			/**< China (Hongkong) */
	HOA_GROUP_JP,			/**< Japan */
	HOA_GROUP_AJ,			/**< ASIA */
	HOA_GROUP_JA,			/**< MEA */
	HOA_GROUP_ZZ			/**< not defined */
} HOA_LOCALE_GROUP_T;
#endif

// 임시로 사용하는 locale group
typedef enum HOA_OLD_LOCALE_GROUP
{
	HOA_OLD_GROUP_KR = 0x01,	/**< Korea */
	HOA_OLD_GROUP_US,			/**< United States */
	HOA_OLD_GROUP_BR,			/**< Brazil */
	HOA_OLD_GROUP_EU,			/**< EU */
	HOA_OLD_GROUP_CN,			/**< China (Mainland) */
	HOA_OLD_GROUP_AU,			/**< Australia */
	HOA_OLD_GROUP_SG,			/**< Singapore */
	HOA_OLD_GROUP_ZA,			/**< South Africa */
	HOA_OLD_GROUP_VN,			/**< Vietnam */
	HOA_OLD_GROUP_TW,			/**< Taiwan */
	HOA_OLD_GROUP_XA,			/**< 중남미 아날로그 국가, NTSC */
	HOA_OLD_GROUP_XB,			/**< 중아, 아주 아날로그 국가, PAL */
	HOA_OLD_GROUP_IL,			/**< 이스라엘 */
	HOA_OLD_GROUP_ID,			/**< 인도네시아 */
	HOA_OLD_GROUP_MY,			/**< 말레이시아 */
	HOA_OLD_GROUP_IR,			/**< 이란 */
	HOA_OLD_GROUP_HK,			/**< China (Hongkong) */
	HOA_OLD_GROUP_JP,			/**< Japan */
	HOA_OLD_GROUP_AJ,			/**< ASIA */
	HOA_OLD_GROUP_JA,			/**< MEA */
	HOA_OLD_GROUP_ZZ			/**< not defined */
} HOA_OLD_LOCALE_GROUP_T;

/**
 * Device Feature Info.
 */
typedef struct HOA_DEVICE_FEATURE_INFO
{
	char modelName[14];
	char flashMemorySize[5];
	char dramSize[5];
	char support3D[5];
	char localeInfoGroup[3];
	char localeInfoCountry[4];
	char videoResolution[5];
	char osdResolution[10];
	char wifiReady[4];
	char gpuSpec[9];
	char openGLVersion[4];
	char flashEngineVersion[15];
	char browserVersion[15];
	char lgSDKVersion[10];
	char tvFirmwareVersion[9];
	char netcastPlatformVersion[15];
	char otaID[33];

} HOA_DEVICE_FEATURE_INFO_T;

/**
 * TV General Info.
 */
typedef struct HOA_CTRL_INFO
{
	char projectName[32];	/**< Project Name, OSA_MD_GetProjectName() */
	char modelName[32];		/**< Model Name, OSA_MD_GetModelName() */
	char hwVer[32];			/**< Hardware Version, OSA_MD_GetEventBoardType(), tv_system.c 참조 */
	char swVer[32];			/**< Software Version, G_FIRMWARE_VERSION */
	char ESN[32];			/**< ESN, API_NSU_GetESN() */
	char toolTypeName[32];	/**< Tool type name, OSA_MD_GetToolType(), toolitem.h */
	char serialNumber[32];
	char modelInch[8];		/** model inch from UI_SUMODE_GetInchTypeString() */
	char countryGroup[8];	/** countryGroup from UI_SUMODE_GetCountryGroupString*/
} HOA_CTRL_INFO_T;

/**
* TV Group Type - DVB, ATSC
*/
typedef enum
{
	HOA_GROUP_DVB       =0,
	HOA_GROUP_ATSC
} HOA_TV_GROUP_TYPE_T;

/**
* Development mode
*/
typedef enum
{
	HOA_DEVELOPMENT_MODE		= 0,
	HOA_CP_DEVELOPMENT_MODE
} HOA_CTRL_DEVELOPMENT_MODE_T;

/**
 * InStart System Information.
 */
typedef struct HOA_INSTART_SYSTEM_INFO
{
	UINT8	modelName[32];
	UINT8	serialnumber[32];
	UINT32	swversion;
	UINT8 	hwversion;
	UINT32 	motionremocononoff;
	UINT8 	macaddress[6];
	HOA_TV_GROUP_TYPE_T	batsc_dvb;
	HOA_CTRL_DEVELOPMENT_MODE_T	cpDevelopmentMode;
} HOA_INSTART_SYSTEM_INFO_T;

/**
 * rect struct
 */
typedef struct HOA_RECT_4PIP
{
	UINT16 x;						/**< x cordinate of its top-letf point */
	UINT16 y;						/**< y cordinate of its top-left point */
	UINT16 w;						/**< width of it */
	UINT16 h;						/**< height of it */
} HOA_RECT_4PIP_T;

/**
* HOA AV Block ctrl type
*/
typedef struct HOA_AV_BLOCKCTRL
{
	BOOLEAN 	bBackToTVInput;		/* TV 입력으로 빠져나가는 상황이면 True (기존의 DISPLAY_NONE, UIWITHTV, WIDGET_MODE 로 변경할 때 )*/
	UINT32		backToTVBlockDelay;	/* TV 입력으로 빠져나갈 때 몇 ms 이후에 block control 함수를 호출할 지 setting 하는 변수 ( ms 단위, 1초면 1000 ) , bBackToDTV 가  True일 경우에만 의미가 있음*/
	BOOLEAN 	bAddonBlock;		/* Addon Block 을 걸지, 말지 여부 (Addon block 을 걸려면 : TRUE,  풀려면: False), bBackToTVInput 이 TRUE 일 때는 AddonBlock 을 무조건 풀어줌 */
} HOA_AV_BLOCK_CTRL_T;

/**
* HOA path control type
* 아래 Attribute 를 Setting 하면 TV_Action_InDetail () 함수에서 현재의 MRE Path와 attribute 를 읽어 path 를 변경해준다.
*/
typedef enum HOA_AV_PATH_CTRL
{
	HOA_PATH_ATTR_TV = 0,			/* TV 입력으로 빠져나가는 경우에 사용 (기존의 DISPLAY_NONE, UIWITHTV, WIDGET_MODE 로 변경할 때 )*/
	HOA_PATH_ATTR_PHOTO_MUSIC,		/* Photo 혹은  Music play 시 사용 (기존 HOA_DISP_FULLIMAGE)*/
	HOA_PATH_ATTR_MOVIE,			/* Movie play  시 사용 (기존 HOA_DISP_FULLVIDEO, HOA_DISP_FULLVIDEONVS)*/
	HOA_PATH_ATTR_NONE,				/* path 를 변경할 필요가 없을 때*/
}HOA_AV_PATH_CTRL_T;

/**
 * detail dtv action specification.
 */
typedef struct HOA_DTV_DETAIL_ACTION_SPEC
{
	/*******************************
	* App,CP 진입 후 즉시 수행 가능한 부분
	********************************/
#if 0
	HOA_AV_BLOCK_CTRL_T	av_block;				/* HOA_AV_BLOCK_CTRL_T 구조체 참조 */
	HOA_AV_PATH_CTRL_T	pathAttr;				/* HOA_AV_PATH_CTRL_T enum 참조 */

	UINT8				pvr_play;				/* on:1, off:0, none:0xff */
	UINT8				Dimming;				/* */
	UINT8				caption;				/* on:1, off:0, none:0xff */
	UINT8				subtitle;				/* */
	UINT8				mhp;					/* */
	UINT8				mheg;					/* */
	UINT8				auto_volume;			/* */
	UINT8				auto_av;				/* on:1, off:0, none:0xff */
	UINT8				analog_ttx;				/* */
	UINT8				cecp;					/* on:1, off:0, none:0xff */
	UINT8				cursor_shape;			/* */
	HOA_RECT_4PIP_T		display_area;			/* video rect area 		*/
#endif
	/*******************************
	* 진입 이후 사용하게 될 status setting
	********************************/
	UINT8				quick_menu_type;		/* q menu type number */
	UINT8				aspect_ratio_menu;		/* aspect ration menu */
	UINT8				network_setting_menu; 	/* */
	UINT8				emf_subtitle_menu;		/* */
	UINT8				camera_popup;			/* */
	UINT8				evergy_saving_menu;		/* key return path  대치 가능 */
//	UINT8				ratio_menu;				/* key return path  대치 가능 */
//	UINT8				av_mode_menu;			/* key return path  대치 가능 */
} HOA_DTV_DETAIL_ACTION_SPEC_T;

/**
 *  Addon  Storage Device Type for TV Apps.
 * (This enum should be synchronized with UC_STORAGE_TYPE_T)
 */
typedef enum HOA_TVAPPS_STORAGE_TYPE
{
	HOA_TVAPPS_FLASH_DEV				= 0x01,		/**<TV Apps Flash Storage */
	HOA_TVAPPS_USB_DEV					= 0x02,		/**<TV Apps USB Storage */
	HOA_TVAPPS_USB_TEST_DEV				= 0x03, 	/**<TV Apps USB Test Storage */
	HOA_TVAPPS_TYPE_INVALID				= 0x80,		/** Unknown or Invalid Type*/

} HOA_TVAPPS_STORAGE_TYPE_T;

/**
 *  Addon  App List Type  for TV Apps.
 * (This enum should be synchronized with UC_STORAGE_TYPE_T)
 */
typedef enum HOA_TVAPPS_APPLIST_TYPE
{
	HOA_TVAPPS_APPLIST_SYSTEM			= 0x01,		/**<Apps List - System */
	HOA_TVAPPS_APPLIST_LAUNCHER			= 0x02,		/**<Apps List - LauncherBar */
	HOA_TVAPPS_APPLIST_FLASH			= 0x03,		/**<Apps List - Flash */
	HOA_TVAPPS_APPLIST_USB				= 0x04,		/**<Apps List - USB  */
	HOA_TVAPPS_APPLIST_INVALID			= 0x80,		/**<Apps List - Invalid */

} HOA_TVAPPS_APPLIST_TYPE_T;

/**
 * SubMessage의 종류
 */
typedef enum
{
	HOA_SUBMSG_APPSTORE_EXECUTE			= 0x0100,	/**< StoreMaster 실행 */
	HOA_SUBMSG_SERVER_STATUS			= 0x0101,	/**< SDP Server Status Noti. */
	HOA_SUBMSG_SMARTTEXT_COMPOSITION	= 0x0102,	/**< SmartText Composition */
	HOA_SUBMSG_LAUNCHER_CHANGED			= 0x0103,	/**< Launcher Bar changed noti */
	HOA_SUBMSG_ENTER_FULL_BROWSER		= 0x0104,	/**< Enter Full Browser noti */
	HOA_SUBMSG_EXIT_FULL_BROWSER		= 0x0105,	/**< Exit Full Browser noti */
	HOA_SUBMSG_APPSTORE_MOUNT_COMPLETE	= 0x0106,	/**< Appstore mount complete noti */
	HOA_SUBMSG_MASTER_LOAD_COMPLETE		= 0x0107,	/**< FXUI Master load comlete in BootTime */
	HOA_SUBMSG_USB_FORMAT_COMPLETED		= 0x0108,	/**< LG formatted USB format completed */
	HOA_SUBMSG_USB_INIT_DONE			= 0x0109,	/**< LG formatted USB initialization completed */
	HOA_SUBMSG_LAST						= 0x1000

} HOA_SUBMSG_TYPE_T;

/**
 * AC SubMessage의 종류
 */
typedef enum
{
	HOA_AC_SUBMSG_APPLIST_CHANGED					= 0x01,		/**< MyApps list change event.  pData is AM_APPLIST_EVENT_T * */
	HOA_AC_SUBMSG_APPLIST_ADDED						= 0x02,		/**< MyApps list add event. pData is AM_APPLIST_EVENT_T * */
	HOA_AC_SUBMSG_APPLIST_DELETED 					= 0x03, 	/**< MyApps list delete event. pData is AM_APPLIST_EVENT_T * */
	HOA_AC_SUBMSG_LOADING_START						= 0x04, 	/**< Loading starts. (Send to AF_SERVICE_ADPREMIUM). pData is  AM_APPLOADING_EVENT_T * */
	HOA_AC_SUBMSG_LOADING_END	 					= 0x05, 	/**< Loading ends. (Send to AF_SERVICE_ADPREMIUM). pData is  AM_APPLOADING_EVENT_T * */
	HOA_AC_SUBMSG_RUNNINGAPP_EXIST 					= 0x06, 	/**< Running App Exist. (Send to AF_SERVICE_BROADCAST). pData is  NULL */
	HOA_AC_SUBMSG_RUNNINGAPP_NOT_EXIST				= 0x07, 	/**< Running App Not Exist. (Send to AF_SERVICE_BROADCAST). pData is  NULL */
	HOA_AC_SUBMSG_RUNNINGAPP_EXCEPTDTV_EXIST		= 0x08, 	/**< Running App (not including DTV App) Exist. (Send to AF_SERVICE_BROADCAST). pData is  NULL */
	HOA_AC_SUBMSG_RUNNINGAPP_EXCEPTDTV_NOT_EXIST	= 0x09, 	/**< Running App (not including DTV App) Not Exist. (Send to AF_SERVICE_BROADCAST). pData is  NULL */
	HOA_AC_SUBMSG_APPLIST_CHANGED_BY_SERVER			= 0x0A, 	/**< MyApps list change event.  pData is AM_APPLIST_EVENT_T * */
	HOA_AC_SUBMSG_LAST								= 0xff

} HOA_AC_SUBMSG_TYPE_T;

/**
 * UC SubMessage의 종류
 */
typedef enum
{
	HOA_UC_SUBMSG_UNKNOWN					= 0x00,		/**< Unknown message */
	HOA_UC_SUBMSG_INSTALL_APP				= 0x01,		/**< Install app */
	HOA_UC_SUBMSG_INSTALL_APP_IN_LOCAL		= 0x02,		/**< Install app in local */
	HOA_UC_SUBMSG_CANCEL_INSTALL_APP		= 0x03,		/**< Cancel install app */
	HOA_UC_SUBMSG_UNINSTALL_APP				= 0x04,		/**< Uninstall app */
	HOA_UC_SUBMSG_UPDATE_APP				= 0x05,		/**< Update app */
	HOA_UC_SUBMSG_CHECK_APP_UPDATE			= 0x06,		/**< Check app update */
	HOA_UC_SUBMSG_LAST						= 0xff

} HOA_UC_SUBMSG_TYPE_T;

/**
 * PM SubMessage의 종류
 */
typedef enum
{
	HOA_PM_SUBMSG_PROC_INIT,
	HOA_PM_SUBMSG_PROC_LOAD,
	HOA_PM_SUBMSG_PROC_RUN,
	HOA_PM_SUBMSG_PROC_TERM,
	HOA_PM_SUBMSG_PROC_NONE,
	HOA_PM_SUBMSG_PROC_LAST

} HOA_PM_SUBMSG_TYPE_T;

/**
 * HOA_CURSOR_TYPE_T.
*/
typedef enum {
	HOA_CURSOR_TYPE_A = 0,
	HOA_CURSOR_TYPE_B,
	HOA_CURSOR_TYPE_C,
	HOA_CURSOR_TYPE_D,
	HOA_CURSOR_TYPE_DRAG, 			/** hand type(for drag) */
	HOA_CURSOR_TYPE_POINT,
	HOA_CURSOR_TYPE_HOLD,
	HOA_CURSOR_TYPE_GESTURE_POINT,
	HOA_CURSOR_TYPE_DISABLE,
	HOA_CURSOR_TYPE_CUSTOM_A, 		/** < user defined cursor type A */
	HOA_CURSOR_TYPE_CUSTOM_B,		/** < user defined cursor type B */
	HOA_CURSOR_TYPE_CUSTOM_C,		/** < user defined cursor type C */
	HOA_CURSOR_TYPE_CUSTOM_D,		/** < user defined cursor type D */
	HOA_CURSOR_TYPE_CUSTOM_E,		/** < user defined cursor type E */
	HOA_CURSOR_TYPE_LASTEST, 		/** < Lastest cursor type */
	HOA_CURSOR_TYPE_LAST,
} HOA_CURSOR_TYPE_T;

/**
 * HOA_CURSOR_SIZE_T.
*/
typedef enum {
	HOA_CURSOR_SIZE_L = 0,
	HOA_CURSOR_SIZE_M,
	HOA_CURSOR_SIZE_S,
	HOA_CURSOR_SIZE_LASTEST,
	HOA_CURSOR_SIZE_LAST
} HOA_CURSOR_SIZE_T;

/**
 * HOA_CURSOR_STATE_T.
*/
typedef enum
{
	HOA_CURSOR_STATE_NORMAL = 0,
	HOA_CURSOR_STATE_PRESS,
	HOA_CURSOR_STATE_LASTEST,
	HOA_CURSOR_STATE_LAST
} HOA_CURSOR_STATE_T;

/**
 * HOA_CURSOR_SPEED_FOR_EXT_DEV.
 * usb mouse, usb joystick, ... except MRCU
*/
typedef enum
{
	HOA_CURSOR_SPEED_SLOW = 0,
	HOA_CURSOR_SPEED_NORMAL,
	HOA_CURSOR_SPEED_FAST,
	HOA_CURSOR_SPEED_LAST
} HOA_CURSOR_SPEED_T;

/**
 * HOA_CURSOR_HOTSPOT_T.
*/
typedef enum
{
	HOA_CURSOR_HOTSPOT_LEFTTOP = 0,
	HOA_CURSOR_HOTSPOT_USERSETTING,
	HOA_CURSOR_HOTSPOT_LAST
} HOA_CURSOR_HOTSPOT_T;

/**
 * HOA_CUSTOM_CURSOR_T.
*/
typedef struct HOA_CUSTOM_CURSOR
{
	char	fileInfo[256];					/** cursor file  info.(path+filename) ex. /mnt/lg/res/customA.png */
	HOA_CURSOR_TYPE_T cursorType;           /** cursor type */
	HOA_CURSOR_SIZE_T cursorSize;			/** cursor size */
	HOA_CURSOR_STATE_T cursorState;			/** cursor state */
	HOA_CURSOR_HOTSPOT_T cursorHotSpot;		/** cursor hotspot info. */
	UINT16  gapX;                   		/** cursor hotspot gap X info. */
    UINT16  gapY;                   		/** cursor hotspot gap Y info. */
} HOA_CUSTOM_CURSOR_T;

/**
 * HOA_INPUTDEV_INFO_T.
*/
typedef struct HOA_INPUTDEV_INFO
{
	SINT32 devID;							/** input device ID. */
	char devName[256];						/** input device Name. */
}HOA_INPUTDEV_INFO_T;

/**
 * HOA_3D_MODE_T.
 */
typedef enum {
	HOA_3D_MODE_OFF	=	0,
	HOA_3D_MODE_ON	=	1,
	HOA_3D_MODE_LAST
} HOA_3D_MODE_T;

/**
 * HOA_3D_TYPE_T.
 */
typedef enum {
	HOA_3D_TYPE_TOP_BOTTOM		=	0,
	HOA_3D_TYPE_SIDE_BY_SIDE	=	1,
	HOA_3D_TYPE_CHECKER_BOX		=	2,
	HOA_3D_TYPE_FULL_HD_3D		=	3,
//	HOA_3D_TYPE_MODE_EXIT		=	4,
	HOA_3D_TYPE_OFF_2D_3D		=	5,
	HOA_3D_TYPE_2D_3D			=	6,
	HOA_3D_1080P_FRAME_PACKED 	=	7,
	HOA_3D_720P_FRAME_PACKED 	=	8,
	HOA_3D_LAST
} HOA_3D_TYPE_T;

/**
 * HOA_ENERGY_SAVING_TYPE_T.
 */
typedef enum {
	HOA_ENERGY_SAVING_TYPE_NONE	=	0, /** < NONE */
	HOA_ENERGY_SAVING_TYPE_OFF	=	1, /** < Two Type - Off / Screen Off */
	HOA_ENERGY_SAVING_TYPE_FULL	=	2, /** < Full Type - Auto / Off / Minimum / Medium / Maximum / Screen Off */
} HOA_ENERGY_SAVING_TYPE_T;

/**
 * HOA_ASPECT_RATIO_TYPE_T.
 */
typedef enum {
	HOA_ASPECT_RATIO_TYPE_NONE	=	0, /** < NONE */
	HOA_ASPECT_RATIO_TYPE_FULL	=	1, /** < FULL VIDEO */
} HOA_ASPECT_RATIO_TYPE_T;

typedef enum
{
	GAME_DATA_MODE_CURSOR		= 0x01,
	GAME_DATA_MODE_BUTTON		= 0x02,
	GAME_DATA_MODE_GYRO			= 0x04,
	GAME_DATA_MODE_ACCEL		= 0x08,
	GAME_DATA_MODE_QUATERNION	= 0x10,
} HOA_GAME_DATA_MODE_T;

typedef enum {
	HOA_INPUT_DISPATCH_NONE		=	0,  /** <  모든 event(cursor,key)를 전달 하지 않는다. */
	HOA_INPUT_DISPATCH_CURSOR, 			/** < cursor moving event(MRCU/Mouse)만을 전달 한다.*/
	HOA_INPUT_DISPATCH_KEY,				/** < cursor hide이후, key event(IR/Keyboard/MRCU/Mouse의 key)만을 전달 한다.*/
	HOA_INPUT_DISPATCH_ALL,				/** < 모든 event(cursor,key)를 전달 한다.*/
	HOA_INPUT_DISPATCH_HOOKING,			/** < cursor hide이후, 모든 event를 PM에서 가공없이 App.으로 바로 전달하여 App.이 원하는 처리를 가능하게 한다. */
	HOA_INPUT_DISPATCH_LAST
} HOA_INPUT_DISPATCH_TYPE_T;

#ifdef __cplusplus
}
#endif
#endif //_APPFRWK_COMMON_TYPES_H_

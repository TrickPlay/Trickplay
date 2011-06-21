/******************************************************************************
 *	 DTV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *	 Copyright(c) 1999 by LG Electronics Inc.
 *
 *	 All rights reserved. No part of this work may be reproduced, stored in a
 *	 retrieval system, or transmitted by any means without prior written
 *	 permission of LG Electronics Inc.
 *****************************************************************************/

/** @file addon_types.h
 *
 *	Commonly Used Type Definitions for Add-on architecture
 *
 *  @author     Meekyung Lim(mimir@lge.com)
 *	@version	1.0
 *	@date		2008. 12. 1
 *	@note
 *	@see
 */

/******************************************************************************
	Header File Guarder
******************************************************************************/

#ifndef _ADDON_TYPES_H_
// DOM-IGNORE-BEGIN
#define _ADDON_TYPES_H_
// DOM-IGNORE-END

#ifdef __cplusplus
extern "C" {
#endif

#ifndef INCLUDE_ADDON_HOST
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

// DOM-IGNORE-BEGIN
// Common constant definitions
// DOM-IGNORE-END
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
#endif //INCLUDE_ADDON_HOST

#define ADDON_MAX_PROC_NUM			20


//sophia
/**
 * Update Controller Installed App List Item Info
 */
#define ADDON_APP_TITLE_MAX				20
#define ADDON_APPIMG_PATH_MAX			60
#define ADDON_APPIMG_FILENAME_MAX		30
#define ADDON_APP_FILENAME_MAX			256


//may.yoon
/**
 * Update Controller Server(SDPIF) URL Size
 */
#define ADDON_SERVER_URL_SIZE				64
#define ADDON_SERVER_COUNTRY_CODE_SIZE	10

/**
 * ADDON_APP_TYPE_T\n
 *
 * Application의 종류 나타냄.
 */
typedef enum
{
	ADDONTYPE_MGR		=	0x01,		/**< Add-on Manager */
	ADDONTYPE_BROWSER	=	0x02,		/**< Add-on Browser */
	ADDONTYPE_DTV		=	0x04,		/**< DTV S/W */
	ADDONTYPE_ADDON		=	0x08,		/**< Add-on S/W */
	ADDONTYPE_UC		=	0x10,		/**< Add-on Update Controller */
	ADDONTYPE_ALL		=	0xFF		/**< 모든 S/W */
} ADDON_APP_TYPE_T;



/**
 * Exit Code
 */
typedef enum ADDON_EXITCODE
{
	EXITCODE_BAD_CRASH	= -1,			/**< 기본 종료. */
	EXITCODE_NORMAL		= 0,			/**< 기본 종료. */
	EXITCODE_BACK_TO_BROWSER,			/**< 종료하고 나면 Application Browser로 돌아간다. */
	EXITCODE_NEED_NETCONFIG,			/**< 종료하고 나면 Network Setting을 시작한다. */
	EXITCODE_NEED_SW_UPDATE,			/**< 종료하고 나면 S/W update를 시작한다. */
	EXITCODE_BACK_TO_GAMEMENU,			/**< 종료하고 나면 Game Menu로 돌아간다. */
	EXITCODE_RETURN,					/**< 종료하고 나면 실행되기 이전 상태로 돌아간다. Browser로부터 실행되었으면 Browser로, TV상태에서 실행되었으면 다시 TV 상태로.*/
	EXITCODE_EXEC_OTHERAPP,				/**< 다른 application을 실행시키고 종료함.*/
	//sophia
	EXITCODE_BACK_TO_DASHBOARD,			/**< 종료하고 나면 DashBoard로 돌아간다.*/
	EXITCODE_BACK_TO_MYAPP, 			/**< 종료하고 나면 MyApp으로 돌아간다.*/
	
	EXITCODE_BACK_TO_SEARCHRESULT,		/**< 종료하고 나면 SearchResult로 돌아간다.*/

	EXITCODE_NEED_NETCONFIG_NETCAST,			/**< 종료하고 나면 Network Setting을 시작한다. Dash board의 netcast로 CP 진입한 경우)*/
	EXITCODE_BACK_TO_NETWORKSETTING,		/**< 종료하고 나면 network setting으로 돌아간다. */

	EXITCODE_LAST	= 0xff
} ADDON_EXITCODE_T;

/**
 * Resource의 종류
 */
typedef enum ADDON_RESOURCE_TYPE
{
	ADDON_RESOURCE_OPENAPI_HOST	= 1,		/**< Open API를 실행하는 Host */
	ADDON_RESOURCE_DISP_TV 		= (1<<1),	/**< TV나 동영상 등을 display하는 plane */
	ADDON_RESOURCE_DISP_UI		= (1<<2),	/**< UI를 display하는 plane */
	ADDON_RESOURCE_AUDIOPLAY	= (1<<3),	/**< Audio play */
	ADDON_RESOURCE_VIDEOPLAY	= (1<<4),	/**< Video play */
	ADDON_RESOURCE_LAST			= (1<<5),
} ADDON_RESOURCE_TYPE_T;



/**
 *  Addon  Storage Device Type for TV Apps. 
 * (This enum should be synchronized with HOA_TVAPPS_STORAGE_TYPE_T)
 */
typedef enum ADDON_STORAGE_TYPE
{
	ADDON_STORAGE_FLASH_DEV			= 0x01,				/**<Addon Flash Storage */
	ADDON_STORAGE_USB_DEV			= 0x02,				/**<Addon USB Storage */
	ADDON_STORAGE_INVALID_DEV		= 0x80,				/** Unknown or Invalid Type*/		
} ADDON_STORAGE_TYPE_T;



/**
 *  Addon  AppList Type for TV Apps. 
 * (This enum should be synchronized with HOA_TVAPPS_APPLIST_TYPE_T)
 */
typedef enum ADDON_APPLIST_TYPE
{
	ADDON_APPLIST_SYSTEM				= 0x01,				/**<Apps List - System */
	ADDON_APPLIST_LAUNCHER			= 0x02,				/**<Apps List - LauncerBar*/
	ADDON_APPLIST_FLASH				= 0x03,				/**<Apps List - Flash Main */
	ADDON_APPLIST_USB				= 0x04,				/**<Apps List - USB Main */
	ADDON_APPLIST_INVALID			= 0x80,				/**<Apps List - Invalid */	
} ADDON_APPLIST_TYPE_T;


/**
 * ADDON_HOST_EVENT_T\n
 *
 * 일정 시간마다 자신의 상태를 알리는 데 사용하는 enumeration
 */
typedef enum
{
	HOST_EVT_CH_CHANGED,					/**< Channel is changed */
	HOST_EVT_USB_CONNECTED,					/**< USB device is connected */
	HOST_EVT_USB_DISCONNECTED,				/**< USB device is disconnected */
	HOST_EVT_POWER_OFF,						/**< Power off */
	HOST_EVT_POWER_ON,						/**< Power on */
	HOST_EVT_ASPECTRATIO_CHANGED, 			/**< Aspect ratio is changed */
	HOST_EVT_LANGUAGE_CHANGED,				/**< language is changed */
	HOST_EVT_COUNTRY_CHANGED,				/**< country is changed */
	HOST_EVT_SCREENSAVER_CHANGED,				/**< screensaver(black out status) is changed */

	/* BSI On/Off */
	HOST_EVT_BSI_ON,						/**< BSI on */
	HOST_EVT_BSI_OFF,						/**< BSI off */

	HOST_EVT_CLOSE_ALL_WINDOW,				/**< Close all window */

	HOST_EVT_SIMPLINK,						/**< Simplink event */

	HOST_EVT_POPUP_ON,						/**< Host popup is on */
	HOST_EVT_POPUP_OFF,						/**< Host popup is off */

	HOST_EVT_MOTIONREMOCON_ON,				/**< Motion remocon is on */
	HOST_EVT_MOTIONREMOCON_OFF,				/**< Motion remocon is off */
	HOST_EVT_MOTIONREMOCON_ON_ADDON_APP_NO,	/**< Motion remocon is on, but addon app isn't exist */
	HOST_EVT_MOTIONREMOCON_OFF_ADDON_APP_NO, /**< Motion remocon is off, but addon app isn't exist */

	/* Tuner Event\n */
	HOST_EVT_TUNER_INITIALIZED = 0xf000,	/**< Tuner is initialized */
	HOST_EVT_TUNER_TUNED,					/**< Tuner is tuned */
	HOST_EVT_TUNER_UNLOCKED,				/**< Tuner is unlocked */
	HOST_EVT_TUNER_LOCKED,					/**< Tuner is locked */
	HOST_EVT_TUNER_TSLIST_CHANGED,			/**< TS list is changed */

	/* IPTV Event\n */
	HOST_EVT_IPTV_NEWFIRMWARE = 0xf010,		/**< New IPTV Firmware detected */

	/* Network Event\n
	----------------------------------------------------------\n
	This message means that your physical link is connected.
	==>> HOST_EVT_NETWORK_CONNECTED\n
	So, if you don't received above the message, check your cable plug, and check your wireless physical connection.\n

	If you receive messages like this sequence,\n
		1. HOST_EVT_NETWORK_CONNECTED\n
		2. HOST_EVT_NETWORK_INET_DISABLED\n
	==> The physical link is connected. Check your server setting like DNS, Gateway, Subnetmask.\n

	If you receive messages like this sequence,\n
		1. HOST_EVT_NETWORK_CONNECTED\n
		2. HOST_EVT_NETWORK_INET_ENABLED\n
	==> you can reach internet. ;-)\n
	*/
	HOST_EVT_NETWORK_CONNECTED,		/**< Network is connected: This means that the physical link is connected */
	HOST_EVT_NETWORK_DISCONNECTED,	/**< Network is disconnected: This means that the physical link is disconnected */
	HOST_EVT_NETWORK_SETTINGCHANGED,	/**< Network setting is changed */
	HOST_EVT_NETWORK_INET_ENABLED ,	/**< Internet is enabled : This means that you can use internet */
	HOST_EVT_NETWORK_INET_DISABLED, 	/**< Internet is disabled : This means that you can't use internet */

	/* Bluetooth Event\n */
	HOST_EVT_BLUETOOTH_CONNECTED,				/**< Bluetooth is connected */
	HOST_EVT_BLUETOOTH_DISCONNECTED,			/**< Bluetooth is disconnected */

	HOST_EVT_WEBCAM_ON,						/**< Webcam on */
	HOST_EVT_WEBCAM_OFF,						/**< Webcam off */
	HOST_EVT_SDP_FORCE_UPDATE,			/**< SDP Force update*/	
	HOST_EVT_SDP_DNLD_DONE,				/**< SDP Download done*/	
	HOST_EVT_SDP_PATH_UPDATE,				/**< SDP Path update*/		
	
	HOST_EVT_UPDATE_ALL,					/**< 'update all screen' is needed */
	HOST_EVT_OUT_OF_MEMORY,					/**< out of device memory */
	HOST_EVT_USB_FORMAT_COMPLETED,			/**< MY Apps USB format completed  */
	HOST_EVT_FLASH_FORMAT_COMPLETED,		/**< MY Apps Internal flash format completed  */
	
	HOST_EVT_SDPIF_COUNTRY_CHANGED,				/**< SDPIF country information is changed */
	HOST_EVT_SDPIF_UPDATE_OPT,				/**< SDP server data is updated */

	HOST_EVT_COUNTRY_OTHERS_AUTO,			/**< country is others(auto) */

#ifdef INCLUDE_VCS
	HOST_EVT_VCS_UI_PRINT,					/**< skype flash ui print on/off */
#endif

	HOST_EVT_LAST = 0xffff
} ADDON_HOST_EVENT_T;

/**
 * ADDON_HOST_EVENT_T\n
 *
 * Remocon Type Information
 */
typedef enum
{
	HOST_REMOCON_MOTION,			/**< Motion Remocon */
	HOST_REMOCON_QUARTER_DIR,		/**< 4-direction Remocon */

	HOST_REMOCON_LAST = 0x10
} ADDON_REMOCON_TYPE_T;
	
/**
 * ADDON_HOST_USER_SMART_MSG_T\n
 *
 * Smart Text(String/Position) 전달을 위해 host에서 addon app.으로 보내는 sub-message enum
 */
typedef enum
{
	HOST_USER_SMART_MSG_NOTI		= 0x00000001,	/**< Smart Text string & position noti msg */
	HOST_USER_SMART_MSG_SHOW		= 0x00000010,	/**< Smart Text string & position msg show */
	HOST_USER_SMART_MSG_HIDE		= 0x00000100,	/**< Smart Text string & position msg hide */
	HOST_USER_SMART_MSG_LAST		= 0x40000000	/**< Smart Text string & position msg none */
} ADDON_HOST_USER_SMART_MSG_T;

/**
 * ADDON_SMART_TEXT_T\n
 *
 * Smart Text(Position/String) structure
 */
typedef struct ADDON_SMART_TEXT
{
	UINT16 positionX;			/**< Smart Text position x */
	UINT16 positionY;			/**< Smart Text position y */
	CHAR textString[512];		/**< Smart Text string */
} ADDON_SMART_TEXT_T;

#ifdef INCLUDE_VCS
/**
* SKYPE_DEBUG_STATE_T
*
* SKYPE Debug Print On/Off
*/
typedef enum
{
	SKYPE_DEBUG_PRINT1_ON,
	SKYPE_DEBUG_PRINT1_OFF,
	SKYPE_DEBUG_PRINT2_ON,
	SKYPE_DEBUG_PRINT2_OFF,	
} SKYPE_DEBUG_STATE_T;
#endif

/**
* ADDON_APP_STATE_T\n
*
* Add-on App.의 상태를 나타내는 데 사용하는 enumeration
*/
typedef enum{
	APP_STATE_NONE,					/**< Process가 생성은 되었지만 Register는 되지 않은 상태 */
	APP_STATE_LOAD,					/**< Loading중인 상태로, 아직 Event, Key등을 받아서 처리할 여건이 되지 못함 */
	APP_STATE_RUN,					/**< 실행 중인 상태 */
	APP_STATE_TERM,					/**< Terminate중인 상태 */
	APP_STATE_LAST
} ADDON_APP_STATE_T;

/**
 * Display Mode
 */
typedef enum ADDON_DISPLAYMODE
{
	ADDON_DISP_NONE,			/**< UI가 없을 경우 */
	ADDON_DISP_UIWITHTV,		/**< 기존 TV화면 위에 UI가 겹쳐서 보일 경우 */
	ADDON_DISP_FULLUI,			/**< 전체 화면으로 UI가 보이고, 기존 TV가 보이지 않아야 할 경우 (UI전환이 느린 대신 Media 재생시 빨리 시작됨) */
	ADDON_DISP_FULLVIDEO,		/**< 전체 화면으로 Video가 재생되는 경우 */
	ADDON_DISP_FULLIMAGE,		/**< 전체 화면으로 Image가 재생되는 경우 */
	ADDON_DISP_FULLUIFAST,		/**< 전체 화면으로 UI가 보이고, 기존 TV가 보이지 않아야 할 경우 (UI전환이 빠른 대신 Media 재생시 느리게 시작됨) */
	ADDON_DISP_FULLUIKEEP,		/**< Dimming On/Off하지 않고 기존 UI 그대로 유지 (Netflix 2.1 trick/pause mode시 사용) */

	ADDON_DISP_UIWITHTV_VCS,		/**< 기존 TV화면 위에 VCS UI가 겹쳐서 보일 경우 */
	ADDON_DISP_UIWITHTV_VCSAUDIO,	/**< 기존 TV화면 위에 UI가 겹쳐서 보이고 소리는 VCS Audio*/
	ADDON_DISP_FULLUI_VCSAUDIO,		/**< 전체 UI에 소리는 VCS Audio (Video는 TV source) */
	ADDON_DISP_FULLVCSAV,			/**< VCS Audio + Video */
	
	ADDON_DISP_FULLVIDEOWITH3D,		/**< 전체 화면 Video(3D)가 재생되는 경우 */
	ADDON_DISP_FULLUIWITHTV,		/**< 전체 화면에 UI가 나오고 작은 TV 화면이 나오는 경우 */

	ADDON_DISP_NUM
} ADDON_DISPLAYMODE_T;

/**
 * This enumeration describes the media channel.
 *
 */
typedef enum MEDIA_CHANNEL {
		MEDIA_CH_UNKNOWN = -1,	/**< Unknown channel. Host에서만 사용. */
		MEDIA_CH_A = 0,		/**< Channel A */
		MEDIA_CH_B,			/**< Channel B */
		MEDIA_CH_C,			/**< Channel C */
		MEDIA_CH_NUM		/**< Maximum channel number */
} MEDIA_CHANNEL_T;

/**
 * Callback Message of Media play
 */
typedef enum MEDIA_CB_MSG
{
	MEDIA_CB_MSG_NONE			= 0x00,				/**< message 없는 상태 */
	MEDIA_CB_MSG_PLAYEND,							/**< media data의 끝이어서 재생이 종료됨 */
	MEDIA_CB_MSG_PLAYSTART,							/**< media가 실제로 재생 시작됨 */
	MEDIA_CB_MSG_ERR_PLAYING	= 0xf000,			/**< 재생중 error 발생 */
	MEDIA_CB_MSG_ERR_BUFFERFULL,					/**< 재생중 buffer full 발생 */
	MEDIA_CB_MSG_ERR_BUFFERLOW,						/**< 재생중 buffer low 발생 */
	MEDIA_CB_MSG_ERR_NOT_FOUND,						/**< 재생하려는 path혹은 url에서 파일 발견되지 않음 */
	MEDIA_CB_MSG_ERR_NET_DISCONNECTED	= 0xff00,	/**< network이 끊김 */
	MEDIA_CB_MSG_ERR_NET_BUSY,						/**< network이 사용중 */
	MEDIA_CB_MSG_ERR_NET_CANNOT_PROCESS,			/**< 기타 이유로 network이 사용 불가함 */
	MEDIA_CB_MSG_ERR_WMDRM_CANNOT_PROCESS	= 0xff10,	/**< WMDRM license error. */
	MEDIA_CB_MSG_ERR_WMDRM_LIC_FAILLOCAL,				/**< WMDRM license error. 저장된 license가 없음. */
	MEDIA_CB_MSG_ERR_WMDRM_LIC_FAILTRANSFER,			/**< WMDRM license error. license 전송중 error & 전송된 license error. */
	MEDIA_CB_MSG_ERR_WMDRM_LIC_EXPIRED,					/**< WMDRM license error. 저장된 License가 만료됨. */
	MEDIA_CB_MSG_REQ_ONLY_PLAY_AGAIN,					/**< Live streaming 중, network 연결 상태 오류로 media play재시도가 요청됨.  */
#ifdef INCLUDE_VCS
	MEDIA_CB_MSG_ERR_BUFFER_20MS,					/**< 재생중 buffer data 20 msec 남음 */
	MEDIA_CB_MSG_ERR_BUFFER_40MS,					/**< 재생중 buffer data 40 msec 남음 */
	MEDIA_CB_MSG_ERR_BUFFER_60MS,					/**< 재생중 buffer data 60 msec 남음 */
	MEDIA_CB_MSG_ERR_BUFFER_80MS,					/**< 재생중 buffer data 80 msec 남음 */
	MEDIA_CB_MSG_ERR_BUFFER_100MS,					/**< 재생중 buffer data 100 msec 남음 */
	MEDIA_CB_MSG_ERR_BUFFER_120MS,					/**< 재생중 buffer data 120 msec 남음 */
	MEDIA_CB_MSG_ERR_BUFFER_140MS,					/**< 재생중 buffer data 140 msec 남음 */
	MEDIA_CB_MSG_ERR_BUFFER_160MS,					/**< 재생중 buffer data 160 msec 남음 */
	MEDIA_CB_MSG_ERR_BUFFER_180MS,					/**< 재생중 buffer data 180 msec 남음 */
	MEDIA_CB_MSG_ERR_BUFFER_200MS,					/**< 재생중 buffer data 200 msec 남음 */
#endif		
	MEDIA_CB_MSG_LAST
} MEDIA_CB_MSG_T;

/**
 * This enumeration describes the remote control key condition.
 */
typedef enum
{
	ADDON_KEY_PRESS, 					/**< for Pressed key */
	ADDON_KEY_RELEASE, 					/**< for Released key */
	ADDON_KEY_REPEAT, 					/**< for Repeated key */
	ADDON_KEY_DRAG, 					/**< for Motion Remote Drag */
	ADDON_KEY_POWER, 					/**< for Motion Remote Swing power */
	ADDON_KEY_GESTURE, 					/**< for Motion Remote Gesture recognition */
	ADDON_KEY_COND_LAST
} ADDON_KEY_COND_T;

/**
 * This enumeration describes the motion remocon support setting.
 */
typedef enum
{
	ADDON_MOTION_SUPPORT_FALSE			= 0, 		/**< Motion Remocon Not Support */
	ADDON_MOTION_SUPPORT_TRUE, 							/**< Motion Remocon Support */
	ADDON_MOTION_SUPPORT_TRANSIENT, 				/**< Motion Remocon Temporary Support */

	ADDON_MOTION_SUPPORT_LAST
} ADDON_MOTION_SUPPORT_T;

/**
 * ADDON_SUBMSG_TYPE_T\n
 *
 * SubMessage의 종류
 */
typedef enum
{
	ADDON_SUBMSG_APPSTORE_EXECUTE		= 0x0100,	/**< StoreMaster 실행 */
	ADDON_SUBMSG_SERVER_STATUS			= 0x0101,	/**< SDP Server Status Noti. */
	ADDON_SUBMSG_SMARTTEXT_COMPOSITION	= 0x0102,	/**< SmartText Composition */
	ADDON_SUBMSG_LAUNCHER_CHANGED		= 0x0103,	/**< Launcher Bar changed noti */
	ADDON_SUBMSG_ENTER_FULL_BROWSER		= 0x0104,	/**< Enter Full Browser noti */
	ADDON_SUBMSG_EXIT_FULL_BROWSER		= 0x0105,	/**< Exit Full Browser noti */
	ADDON_SUBMSG_LAST					= 0x1000
} ADDON_SUBMSG_TYPE_T;



//sophia
/**
 * Update Controller Installed App List Item Info
 */
typedef struct ADDON_UC_APPLIST_ITEM
{
	UINT32 appID;							// Unique App ID
	char appTitle[ADDON_APP_TITLE_MAX];		// 타이틀 - default : English (한글 가능성도 있음)
	char imagePath[ADDON_APPIMG_PATH_MAX];
	char imageFileName[ADDON_APP_FILENAME_MAX]; //ADDON_APPIMG_FILENAME_MAX -> ADDON_APP_FILENAME_MAX
//	char appArgs[ADDON_APP_FILENAME_MAX];	// path + execution arguments
} ADDON_UC_APPLIST_ITEM_T;


/**
 * This enumeration describes file format(container type) of media.
 *
 */
typedef enum MEDIA_FORMAT
{
	MEDIA_FORMAT_RAW	= 0x00,			/**< File Format이 따로 없고, Audio 또는 Video codec으로 encoding 된 raw data */
	MEDIA_FORMAT_WAV	= 0x01,			/**< wave file format (Audio). */
	MEDIA_FORMAT_MP3	= 0x02,			/**< mp3 file format (Audio). */
	MEDIA_FORMAT_AAC	= 0x03,			/**< aac file format (Audio). */
	MEDIA_FORMAT_AVI	= (0x01<<8),	/**< avi file format (Video). */
	MEDIA_FORMAT_MP4	= (0x02<<8),	/**< mpeg4 file format (Video). */
	MEDIA_FORMAT_MPEG1	= (0x03<<8),	/**< mpeg1 file format (Video). */
	MEDIA_FORMAT_MPEG2	= (0x04<<8),	/**< mpeg2 file format (Video). */
	MEDIA_FORMAT_ASF	= (0x05<<8),	/**< asf file format (Video). */
	MEDIA_FORMAT_MKV	= (0x06<<8),	/**< mkv file format (Video). */
	MEDIA_FORMAT_JPG	= (0x08<<16),	/**< jpeg file format (Image). */
	MEDIA_FORMAT_PNG	= (0x09<<16),	/**< png file format (Image). */
	MEDIA_FORMAT_CIF	= (0x0A<<16),	/**< cif file format (Image). */

	MEDIA_FORMAT_AUDIO_MASK	= 0xFF,			/**< Audio file format mask */
	MEDIA_FORMAT_VIDEO_MASK	= (0xFF<<8),	/**< Video file format mask */
	MEDIA_FORMAT_IMAGE_MASK	= (0xFF<<16)	/**< Image file format mask */
} MEDIA_FORMAT_T;


/**
 * This structure contains the media buffer handle informations.
 *
 */
typedef struct MEDIA_BUFFER_HANDLE {
		UINT32 key;				/**< Key of shared memoy */
		int shmid;				/**< Shmid of shared memory */
		UINT32 nBuffSize;		/**< Buffer size*/
		char *pBuffer;			/**< Buffer address*/
} MEDIA_BUFFER_HANDLE_T;

/**
 * This structure contains the SDPIF buffer handle informations.
 *
 */
typedef struct SDPIF_BUFFER_HANDLE {
		UINT32 key;				/**< Key of shared memoy */
		int shmid;				/**< Shmid of shared memory */
		UINT32 nBuffSize;		/**< Buffer size*/
		char *pBuffer;			/**< Buffer address*/
} SDPIF_BUFFER_HANDLE_T;

/**
 * This structure contains the SDPIF buffer handle informations.
 *
 */
typedef struct WMDRM_BUFFER_HANDLE {
		UINT32 key;				/**< Key of shared memoy */
		int shmid;				/**< Shmid of shared memory */
		UINT32 nBuffSize;		/**< Buffer size*/
		char *pBuffer;			/**< Buffer address*/
} WMDRM_BUFFER_HANDLE_T;

/**
 * DEBUG_LEVEL_T\n
 *
 * DEBUG LOG LEVEL로 사용되는 코드.
 */
typedef enum
{
	DEBUG_LEVEL_0 = 0,		/**< DEBUG LEVEL 0 */
	DEBUG_LEVEL_1 ,			/**< DEBUG LEVEL 1 */
	DEBUG_LEVEL_2 ,			/**< DEBUG LEVEL 2 */
	DEBUG_LEVEL_3 ,			/**< DEBUG LEVEL 3 (DEBUG_FULL_LEVEL) */
	DEBUG_LEVEL_LAST
} DEBUG_LEVEL_T;


//sophia
/**
 * Update Controller Event Type
 */
typedef enum ADDON_UC_EVENT_TYPE
{
	UC_EVT_ERROR			= -1,		/**< 에러. */
	UC_EVT_INIT				= 0,		/**< 초기 상태*/
	UC_EVT_DOWNLOADING,				/**< 다운로드 중*/
	UC_EVT_DOWNLOADED,				/**< 다운로드 완료 */
	UC_EVT_INSTALLING,					/**< 인스톨 중 */
	UC_EVT_INSTALLED,					/**< 인스톨 완료 */
	UC_EVT_CANCELED,					/**< 취소 */
	UC_EVT_UNINSTALLING,				/**< 삭제 중 */
	UC_EVT_UNINSTALLED,				/**< 삭제 완료 */
	UC_EVT_NEEDTOUPDATE, 				/**< 업데이트 필요 */
	UC_EVT_REQDRM,					/**< DRM 요청 */
	UC_EVT_RESDRM,					/**< DRM 결과 */		
	UC_EVT_SYNCINSTALLEDAPP_END,	/**< Cleanup Unregistered App 완료. */
	UC_EVT_LAST
} ADDON_UC_EVENT_TYPE_T;


//sophia
/**
 * Update Controller Event Structure
 *
 */
typedef struct ADDON_UC_EVENT {
	UINT32 appID;						/**< App ID */
	ADDON_UC_EVENT_TYPE_T eventType;	/**< EventType */
	UINT16 eventData;					/**< Event Data: Progress Rate, and so on */
} ADDON_UC_EVENT_T;

/**
 * Send Host System Info to Managers
 */
typedef struct ADDON_HOST_INFO
{
	UINT8	macAddress[6];
	char	productType[8];	// { DTV | BDP }
//	char	platformName[32];
	char	modelName[32];
//	char	city[32];
	UINT32	countryCode;
	char	countryGroup[3];	// {'Z', 'Z', '\0');
	UINT32	languageCode;
//	UINT32	resolution[2];
//	char	firmwareVer[32];
//	char	displayType[32];
	UINT32	mtdIdxApps;
//	char netcastPlatformVersion[32];
//	char publishFlag[3];	
	//////////// Device Feature Info Set
//	char	modelName[14];		//modelName = deviceFeatureModelName
	UINT16	flashMemorySize;
	UINT16	dramSize;
	char	support3D[5];
//	char	countryGroup[3];	//countryGroup = deviceFeatureLocaleInfoGroup ex) {'Z', 'Z', '\0'}
//	char	localeInfoCountry[4]; //countryCode = deviceFeatureLocaleInfoCountry
	char	videoResolution[5];
	char	osdResolution[10];	//resolution = deviceFeatureOsdResolution
	char	wifiReady[4];
	char	gpuSpec[9];
	char	openGLVersion[4];
	char	flashEngineVersion[15];
	char	browserVersion[15];
	char	lgSDKVersion[10];
	char	firmwareVersion[9];	//firmwareVer = deviceFeatureTvFirmwareVersion
	char	netcastPlatformVersion[15];	//netcastPlatformVersion = deviceFeatureNetcastPlatformVersion
	char	otaID[33];
} ADDON_HOST_INFO_T;


/**
 * SDP I/F(App. Store client) Data Type Definition
 * App. Store User information
 */
 #if 0 // deleted by may.yoon 20101014
typedef enum	
{	
	SDPIF_NOT_EXIST_ID	= 0x0,		/**< Not exist user ID */
	SDPIF_NOT_MATCH_PWD,			/**< Do not match Password */
	SDPIF_NOT_AVAILABLE_SERVER,		/**< Don't available sdp server connection */
	SDPIF_LOGIN_SUCCEED,			/**< Log in success */
	SDPIF_NOT_MATCH_COUNTRY_USER,	/**< Country and User mis-match */
	SDPIF_LOG_EVENT_LAST
} ADDON_SDPIF_LOGIN_EVENT_T;


typedef enum
{
	SDPIF_ID_DUPLICATE	= 0x10,	/**< ID duplicate */
	SDPIF_ID_AVAILABLE,					/**< ID available */
	SDPIF_REGISTER_SUCCEED,			/**< User ID register success */
	SDPIF_REGISTER_FAILED,			/**< User ID register failed */
	SDPIF_REGISTER_EVENT_LAST
} ADDON_SDPIF_REGISTER_EVENT_T;

typedef enum
{
	SDPIF_USER_LIST 	= 0x20,		/**< User List */
	SDPIF_USER_DEACTIVATE_SUCCESS,		/**< User deactiviate */
	SDPIF_USER_DEACTIVATE_FAILED,		/**< User deactiviate */
	SDPIF_ACOUNT_EVENT_LAST
} ADDON_SDPIF_ACCOUNT_EVENT_T;
#else
// added by may.yoon 20101014
typedef enum
{	
	SDPIF_CMNCODE_SUCCESS= 0x00,		/**< Get Server Status  */	
	SDPIF_CMNCODE_FAIL,	
	SDPIF_CMNCODE_LAST
} ADDON_SDPIF_SERVER_STATUS_T;
#endif

typedef enum
{
	SDPIF_CANDIDATE_COUNTRY_AVAILABLE 	= 0x30,	/**< Candidate country code exist */
	SDPIF_CANDIDATE_COUNTRY_NONE,								/**< Candidate country code none */
	SDPIF_CANDIDATE_COUNTRY_EVENT_LAST
} ADDON_SDPIF_COUNTRY_EVENT_T;

typedef enum
{
	SDPIF_UPDATE_PKG 	= 0x40,		/**< Force update message event */
	SDPIF_UPDATE_EVENT_LAST
} ADDON_SDPIF_UPDATE_PKG_EVENT_T;

/**
 * This structure contains the media server informations.
 *
 */
typedef struct MEDIA_SERVER_INFO {
		unsigned int type;
		char IP[50];
		char name[100];
		char hostname[100];
		char mac[20];
} MEDIA_SERVER_INFO_T;

/**
 * This structure contains the media server list informations.
 *
 */
typedef struct MEDIA_SERVER_LIST {
		int num;
		MEDIA_SERVER_INFO_T	*pServerInfo;
} MEDIA_SERVER_LIST_T;

/**
 * Callback Message of PLEX Media Server List Changing.
 */
typedef enum PMS_CB_MSG
{
	PMS_CB_MSG_NONE		= 0x00,
	PMS_CB_MSG_ADD		= 0x01,
	PMS_CB_MSG_DEL		= 0x02,
	PMS_CB_MSG_CHG		= 0x10,
	PMS_CB_MSG_LAST
} PMS_CB_MSG_T;

/**
 * This enumeration describes the media play state.
 *
 */
typedef enum ADDON_MEDIA_PLAY_STATE
{
	ADDON_MEDIA_STATE_STOP = 0, 	/**< Stop state */
	ADDON_MEDIA_STATE_PLAY,	/**< Play state */
	ADDON_MEDIA_STATE_PAUSE,	/**< Pause state */
	ADDON_MEDIA_STATE_ERROR	/**< Error state */
} ADDON_MEDIA_PLAY_STATE_T;
 
#ifdef __cplusplus
}
#endif

#endif  /* _ADDON_TYPES_H_ */

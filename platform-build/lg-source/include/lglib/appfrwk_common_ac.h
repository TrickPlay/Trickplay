/******************************************************************************
 *   LCD TV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2011 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/

/** @file appfrwk_common_ac.h
 *
 *  AC <-> Openapi common header
 *
 *  @author    dhjung (donghwan.jung@lge.com)
 *  @version   1.0
 *  @date       2011.06.20
 *  @note
 *  @see
 */

#ifndef _APPFRWK_COMMON_AC_H_
#define _APPFRWK_COMMON_AC_H_

#include "appfrwk_common_types.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Type of the Application Provider
 */
typedef enum
{
	AM_APP_ALL			= 0,		/**< All application (except DTV)*/
	AM_APP_SYSTEM		= 2,		/**< System application */
//	AM_APP_FXUI			= 3,		/**< DTV UI application using FX UI */
	AM_APP_PREMIUM		= 4,		/**< Contents Provider's application */
	AM_APP_DOWNLOADED	= 5,		/**< App Store application */
	AM_APP_TEST			= 6,		/**< Test application */
	AM_APP_LAST

} AM_APP_PROVIDER_T; //apptype c1과 통합 고려할 것

/**
 * Application state
 */
typedef enum
{
	AM_APP_STATE_NONE,
	AM_APP_STATE_LOAD,
	AM_APP_STATE_RUN,
	AM_APP_STATE_RUN_NF, 		//'not focused' running state
	AM_APP_STATE_TERM,
	AM_APP_STATE_LAST

} AM_APP_STATE_T;

/**
 * ExitCode
 */
typedef enum
{
	AM_EXITCODE_BAD_CRASH 	= -1,
	AM_EXITCODE_NOFOCUS		= 0,	/**< Exit with no focusing to other app.*/
	AM_EXITCODE_BACK,				// 종료 후 실행 전 App으로 돌아가기
	AM_EXITCODE_BACK_TO_DTV,
	AM_EXITCODE_BACK_TO_HOMEBOARD,
	AM_EXITCODE_BACK_TO_PREMIUM,
	AM_EXITCODE_BACK_TO_NETWORKSETTING,
	AM_EXITCODE_BACK_TO_SETUP,

#ifdef BDP_HOST
	AM_EXITCODE_BACK_TO_SWUPDATE,
#endif //BDP_HOST

	AM_EXITCODE_RETURN		= 0xe0,			// 종료 후 이전 상태로 돌아가기
	AM_EXITCODE_FORCED		= 0xf0, 		//모든 app 강제 종료
	AM_EXITCODE_RESETBACKLIST , 	/**< Exit with no focusing to other app and reset backlist.*/

	AM_EXITCODE_LAST 		= 0xff

} AM_EXITCODE_T;

/**
 * Type of application
 * Application type is ORed of AM_APP_TYPE_C1 | AM_APP_TYPE_C2
 */
typedef UINT32 AM_APP_TYPE_T;

/**
 * Type of application (for Category 1)
 */
typedef enum AM_APP_TYPE_C1
{
	AM_C1_MASK				=	(0xFF000000),		/**< Bit mask for C1*/
	AM_C1_SYSTEM			=	(0x00000000),		/**< System app */
	AM_C1_PREMIUM			=	(0x02000000),		/**< Premium app */
	AM_C1_DOWNLOADED		=	(0x03000000),		/**< Downloaded app */
	AM_C1_DOWNLOADED_USB	=	(0x04000000),		/**< Downloaded in USB app */
	AM_C1_TEST_USB		=	(0x05000000),		/**< Test app in USB */
	AM_C1_MAX
} AM_APP_TYPE_C1_T;

/**
 * Type of application (for Category 2)
 */
typedef enum AM_APP_TYPE_C2
{
	AM_C2_MASK		=	(0x00FF0000),				/**< Bit mask for C2*/
	AM_C2_TV		=	(0x00010000),				/**< TV app (native tv menu) */
	AM_C2_FXUI 		=	(0x00020000),			/**< FXUI app */
	AM_C2_FLASH		=	(0x00030000),			/**< Flash app */
	AM_C2_BROWSER	=	(0x00040000),				/**< Browser app */
	AM_C2_PLEX 		=	(0x00050000),			/**< PLEX app */
	AM_C2_TRICKPLAY	=	(0x00060000),				/**< Trick play app */
	AM_C2_NATIVE	=	(0x00070000),				/**< Native app */
	AM_C2_MARMALADE	=	(0x00080000),				/**< Marmalade (Ideaworks) app */
	AM_C2_ADOBEAIR	=	(0x00090000),			/**< Adobe air app */
	AM_C2_MAX
} AM_APP_TYPE_C2_T;

/**
 * Type of context
 */
typedef enum AM_CTXT_TYPE
{
	AM_CTXT_ALL			= 0xff,				/**< for all */
	AM_CTXT_NONE		= 0x00,				/**< always */
	AM_CTXT_HOME		= 0x01,				/**< in Home menu */
	AM_CTXT_LIVE		= (0x01<<1),				/**< in Live */
	AM_CTXT_EXT_INPUT	= (0x01<<2),			/**< in external input */
	AM_CTXT_EXT_3D_ON	= (0x01<<3),			/**< in 3D mode on */
	AM_CTXT_EXT_3D_OFF	= (0x01<<4),			/**< in 3D mode off */
	AM_CTXT_MAX
} AM_CTXT_TYPE_T;

/**
 * Type of video
 */
typedef enum AM_VIDEO_TYPE
{
	AM_VIDEO_NONE		= 0x00,				/**< Video is not used */
	AM_VIDEO_FULL		= 0x01,				/**< Full size video */
	AM_VIDEO_RESIZE		= 0x02,				/**< Resized video */
	AM_VIDEO_MAX
} AM_VIDEO_TYPE_T;

/**
 * Type of camera
 */
typedef enum AM_CAMERA_TYPE
{
	AM_CAMERA_NONE		= 0x00, 			/**< Camera is not used */
	AM_CAMERA_NORMAL	= 0x01, 			/**< Camera Ready : O, Gesture Cam : X */
	AM_CAMERA_GESTURE 	= 0x02, 			/**< Camera Ready : O, Gesture Cam : O */
	AM_CAMERA_MAX
} AM_CAMERA_TYPE_T;

/**
 * Type of Remocon
 */
typedef enum AM_MAGICRC_TYPE
{
	AM_MAGICRC_NONE		= 0x00, 			/**< Motion RC is not used */
	AM_MAGICRC_NORMAL	= 0x01, 			/**< Motion RC : O, Voice MRCU : X */
	AM_MAGICRC_VOICE	= 0x02, 			/**< Motion RC : O, Voice MRCU : O */
	AM_MAGICRC_MAX
} AM_MAGICRC_TYPE_T;

//SDP 연동 규격서 V.2.0.9 기준
typedef enum AM_UPDATE_TYPE
{	
	AM_UPDATE_NEED_NOT_TO_UPDATE			= 0x00, //Need not to update
	AM_UPDATE_NEED_TO_UPDATE, 						//Exist new version 
	AM_UPDATE_UNKNOWN_ERROR,						//Unknown error ex) Network Error
	AM_UPDATE_WRONG_APP_ID,							//A.009.01, Wrong App ID
	AM_UPDATE_APP_VERSION_INFO_NULL,				//A.009.02, App Version Info is NULL
	AM_UPDATE_APP_PURCHASE_INFO_NOT_EXIST,			//A.009.03, App Purchase Info is not existed
	AM_UPDATE_DEVICE_HW_NOT_SUPPORT,				//A.009.04, Device H/W do not support execution of this app
	AM_UPDATE_DEVICE_SW_NOT_SUPPORT,				//A.009.05, Device S/W do not support execution of this app
	AM_UPDATE_NSU_UPDATE_REQUIRED,					//A.009.06, NSU Update Required
	AM_UPDATE_APPINFO_NOT_FOUND,					//A.009.07, App Info Not Found
} AM_UPDATE_TYPE_T;

/**
 * Type of Image Size
 */
typedef enum AM_IMAGE_SIZE
{
	AM_IMAGE_SMALL = 0,				/**< XXSmall Image in manifest.xml */
	AM_IMAGE_MEDIUM,				/**< MSmall Image in manifest.xml, <icon> in system.xml, home_xx.png for Premium app  */
	AM_IMAGE_LARGE,					/**< icon_xx.png for premium */
	AM_MAX_IMAGE_SIZE_TYPE					/**< Image size type max Max */
} AM_IMAGE_SIZE_T;

/**
 * Type of Show in Myapps
 */
typedef enum AM_SHOW_IN_MYAPPS
{
	AM_SHOW_IN_MYAPPS_NO = 0,		
	AM_SHOW_IN_MYAPPS_YES,			
	AM_SHOW_IN_MYAPPS_COND,			
	AM_SHOW_IN_MYAPPS_ASK_SDP,		
			
} AM_SHOW_IN_MYAPPS_T;

/**
 * Application Information.
 */
typedef struct AM_APP_INFO
{
	UINT64 AUID;
	AM_APP_TYPE_T appType;		/**< AM_APP_TYPE_C1_T | AM_APP_TYPE_C2_T */
	char szName[AF_MAX_NAME_LEN];
	char szStringID[AF_MAX_NAME_LEN];
	char szIconPathArr[AM_MAX_IMAGE_SIZE_TYPE][AF_MAX_PATH_LEN];
	unsigned char szVersion[AF_MAX_VER_LEN];
	
	union _ATTR
	{
		struct _ATTR_BIT
		{
			BOOLEAN	bInMyApps:1;
			BOOLEAN bAdult:1;
			BOOLEAN	bCheckNetwork:1;
			BOOLEAN bUseNetwork:1;
			BOOLEAN bUse3D:1;
			BOOLEAN bLoadingEffect:1;
			BOOLEAN bEnableOnWidi:1;
			BOOLEAN bEnableOnDVR:1;	// 8
			BOOLEAN bCheckTime:1;
			
			BOOLEAN bLoadingAd:1;
			BOOLEAN bIDmgmt:1;			

			BOOLEAN	bDeactivation:1;
			BOOLEAN	bInCPBox:1;

			AM_CAMERA_TYPE_T useCamera:2;
			AM_MAGICRC_TYPE_T useMagic:2;	// 9

			AM_CTXT_TYPE_T contextType:8;	/**< for contextual menu */
			AM_VIDEO_TYPE_T videoType:3;	/**< for video type */
			AM_UPDATE_TYPE_T updateType:5;	/**< for update type */
		} bit;				// 33bit 사용 

		UINT64 val;
	} attr;
	time_t installTime;
} AM_APP_INFO_T;

/**
 * Application Deactivation Information.
 */
typedef struct AM_DEACTIVATION_INFO
{
	unsigned char szId[AF_MAX_NAME_LEN];
	unsigned char szQuestionTitle[AF_MAX_NAME_LEN];
	unsigned char szQuestionMsg[AF_MAX_NAME_LEN];
	unsigned char szCompleteTitle[AF_MAX_NAME_LEN];
	unsigned char szCompleteMsg[AF_MAX_NAME_LEN];
	unsigned char szProcessMode[AF_MAX_NAME_LEN];
	unsigned char szCmd[AF_MAX_PATH_LEN];
	unsigned char szFullPath[AF_MAX_PATH_LEN];
} AM_DEACTIVATION_INFO_T;

/**
 * Application List Type.
 */
typedef enum AM_APPLIST_TYPE
{
	AM_APPLIST_MYAPPS 			= (0x01),		/**< My Apps List */
	AM_APPLIST_MYAPPS_USB		= (0x02),		/**< My Apps for USB List */
	AM_APPLIST_TEST				= (0x03),		/**< USB Test App List */
	AM_APPLIST_PREMIUM 			= (0x04),		/**< Premium App List */
	AM_APPLIST_DOWNLOADED	 	= (0x05),		/**< Downloaded App List */
	AM_APPLIST_DOWNLOADED_USB	= (0x06),		/**< Downloaded USB App List */
	AM_APPLIST_MAX
} AM_APPLIST_TYPE_T;

/**
 * App Store Storage Status
 */
typedef enum AM_STORAGE_STATE
{
	AM_STORAGE_OK,								/**< App Store Storage OK */
	AM_STORAGE_DRM_FAIL,						/**< All Apps DRM Fail  */
	AM_STORAGE_NOT_MOUNT,						/**< App Store Not Mounted */

	AM_STORAGE_LAST

} AM_STORAGE_STATE_T;

/**
 * Device info
 */
typedef struct AM_DEVICE_INFO
{
	BOOLEAN bLoaded;
	BOOLEAN bChanged;

	char szModelName[32];		/**< Model Name, OSA_MD_GetModelName() */
	char szGroupLC[3];
	char szGroupUC[3];
	char szSmartCountry2[3];	/**< Smart TV Setting's country */
	char szSmartCountry3[4];
	char szSetupCountry2[3];	/**< Setup menu's country */
	char szSetupCountry3[4];
	char szLanguage2[3];
	char szLanguage3[4];

	BOOLEAN bDVR;
	BOOLEAN bPDP;
	BOOLEAN b3D;
	BOOLEAN bDTV;
	BOOLEAN	bCPBox;
	BOOLEAN bDualView;
	BOOLEAN	bPentouch;
	BOOLEAN bMemocast;
} AM_DEVICE_INFO_T;

/**
* App List Event
*/
typedef struct AM_APPLIST_EVENT
{
	UINT64 				AUID;
	AM_APPLIST_TYPE_T	appListType;
} AM_APPLIST_EVENT_T;

/**
* App Loading Event
*/
typedef struct AM_APPLOADING_EVENT
{
	UINT64 				AUID;
	BOOLEAN				bLoadingEffect;
	BOOLEAN				bLoadingAd;
} AM_APPLOADING_EVENT_T;

/**
 * Recent Information.
 */
typedef struct AM_APP_RECENT_INFO	/* ktj fixed */
{
	UINT64 AUID;
	char szName[AF_MAX_NAME_LEN];
	char szIconPath[AF_MAX_PATH_LEN];
	BOOLEAN bCheckNetwork;
	AM_APP_TYPE_T appType;		/**< AM_APP_TYPE_C1_T | AM_APP_TYPE_C2_T */
	char szStringID[AF_MAX_NAME_LEN];
} AM_APP_RECENT_INFO_T;

/**
 * Option Type.
 */
 typedef enum AM_APP_OPT
{
	AM_OPT_UNKNOWN					= 0x00,
	AM_OPT_CHECK_UPDATE_INTERVAL,
}AM_APP_OPT_T;

/**
 * BSI Print
 */
typedef enum AM_BSI_PRINT
{
	AM_BSI_APP_START = 0,		/**< Download App 의 시작  BSI print */
	AM_BSI_APP_END,				/**< Download App 의 종료  BSI print */
			
} AM_BSI_PRINT_T;

/**
 * SDP 로깅 
 */
typedef enum AM_ACTION_TYPE
{
	AM_ACTION_EXECUTE = 0,		/**< 실행 */
	AM_ACTION_TERMINATE,		/**< 종료 */
	AM_ACTION_INSTALL,			/**< 설치 */
	AM_ACTION_DELETE,			/**< 삭제 */ 
			
} AM_ACTION_TYPE_T;


#ifdef __cplusplus
}
#endif
#endif

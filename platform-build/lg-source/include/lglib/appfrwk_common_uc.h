/******************************************************************************
 *   LCD TV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2011 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/

/** @file appfrwk_common_uc.h
 *
 *  UC <-> Openapi common header
 *
 *  @author    dhjung (donghwan.jung@lge.com)
 *  @version   1.0
 *  @date       2011.06.20
 *  @note
 *  @see
 */

#ifndef _APPFRWK_COMMON_UC_H_
#define _APPFRWK_COMMON_UC_H_

#include "appfrwk_common_types.h"

#ifdef __cplusplus
extern "C" {
#endif

#define UC_MAX_CEK_LEN 32

//#define UC_USE_NEW_EVENT_TYPE

#ifdef UC_USE_NEW_EVENT_TYPE

/**
 * Update Controller Event Type
 */
#ifndef UC_EVENT_TYPE_T
typedef enum UC_EVENT_TYPE
{
	UC_EVT_UNKNOWN				= 0x00,		//Unknown event
	UC_EVT_INSTALL,							//Install
	UC_EVT_INSTALL_IN_LOCAL,				//Install in local
	UC_EVT_CANCEL_INSTALL_APP,				//Cancel install app
	UC_EVT_UNINSTALL_APP,					//Uninstall app
	UC_EVT_UPDATE_APP,						//Update app
	UC_EVT_CHECK_APP_UPDATE,				//Check app update
	UC_EVT_UPDATE_RO						//Update RO	
} __UC_EVENT_TYPE_T;
#define UC_EVENT_TYPE_T __UC_EVENT_TYPE_T
#endif //UC_EVENT_TYPE_T

#ifndef UC_EVENT_STATUS_T
typedef enum UC_EVENT_STATUS
{
	UC_STATUS_UNKNOWN			= 0x00,		//Unknown status
	UC_STATUS_START,						//Start
	UC_STATUS_PROCESSING,					//Processing
	UC_STATUS_COMPLETE,						//Complete
	UC_STATUS_DOWNLOAD_START,				//Download start		
	UC_STATUS_DOWNLOAD_PROCESSING,			//Download processing. Param1: Process rate, Param2: BPS
	UC_STATUS_DOWNLOAD_COMPLETE,			//Download complete
	UC_STATUS_INSTALL_START,				//Install start
	UC_STATUS_INSTALL_PROCESSING,			//Install processing. Param1: Process rate
	UC_STATUS_INSTALL_COMPLETE,				//Install complete
	UC_STATUS_NEED_TO_UPDATE,				//Need to update. Param1: TRUE if need to update, otherwise FALSE
	UC_STATUS_ERROR,						//Error. Param1: Error code
}__UC_EVENT_STATUS_T;
#define UC_EVENT_STATUS_T __UC_EVENT_STATUS_T
#endif //UC_EVENT_STATUS_T

#define UC_ERR_UNKNOWN					-1			//해당 Event에 대한 동작에 대해 알 수 없는 에러가 발생
#define UC_ERR_NOT_HANDLEED				-2			//해당 Event에 대한 동작을 처리할 수 없음.
#define UC_ERR_INVALID_PARAMS			-3			//해당 Event에 대한 동작에 대해 잘못된 param이 입력
#define UC_ERR_NETWORK					-4			//해당 Event에 대한 동작을 수행 중 Network 연결 에러가 발생
#define UC_ERR_NOT_ENOUGH_STORAGE		-5			//해당 Event에 대한 동작을 수행 중 Storage의 용량이 충분치 않음.
#define UC_ERR_NOT_ENOUGH_MEMORY		-6			//해당 Event에 대한 동작을 수행 중 Memory가 부족하여 malloc 실패함.
#define UC_ERR_NOT_EXIST_APPID			-7			//AppID에 해당하는 App이 설치되어 있지 않음. 
#define UC_ERR_ALREADY_INSTALLED		-8			//AppID에 해당하는 App이 이미 설치되어 있음

/**
 * Update Controller Event Structure
 *
 */
#ifndef UC_EVENT_T
typedef struct UC_EVENT {
	UC_EVENT_TYPE_T				eventType;			//현재 진행중인 Upctrl 동작에 대한 event type
	__UC_EVENT_STATUS_T			eventStatus;		//Event가 발생하게 된 상태
	UINT32						appID;				//App ID
	SINT32						eventData1;			//Param1
	SINT32						eventData2;			//Param2
} __UC_EVENT_T;
#define UC_EVENT_T __UC_EVENT_T
#endif


#else	//UC_USE_NEW_EVENT_TYPE

/**
 * Update Controller Event Type
 */
#ifndef UC_EVENT_TYPE_T
typedef enum UC_EVENT_TYPE
{
	UC_EVT_ERROR			= -1,		/**< 에러. */
	UC_EVT_INIT				= 0,		/**< 초기 상태*/
	UC_EVT_DOWNLOADING,					/**< 다운로드 중*/
	UC_EVT_DOWNLOADED,					/**< 다운로드 완료 */
	UC_EVT_INSTALLING,					/**< 인스톨 중 */
	UC_EVT_INSTALLED,					/**< 인스톨 완료 */
	UC_EVT_CANCELED,					/**< 취소 */
	UC_EVT_UNINSTALLING,				/**< 삭제 중 */
	UC_EVT_UNINSTALLED,					/**< 삭제 완료 */
	UC_EVT_NEEDTOUPDATE, 				/**< 업데이트 필요 */
	UC_EVT_REQDRM,						/**< DRM 요청 */
	UC_EVT_RESDRM,						/**< DRM 결과 */
	UC_EVT_SYNCINSTALLEDAPP_END,		/**< Cleanup Unregistered App 완료. */
	UC_EVT_LAST
} __UC_EVENT_TYPE_T;
#define UC_EVENT_TYPE_T __UC_EVENT_TYPE_T
#endif


/**
 * Update Controller Event Structure
 *
 */
#ifndef UC_EVENT_T
typedef struct UC_EVENT {
	UINT32 appID;						/**< App ID */
	UC_EVENT_TYPE_T eventType;			/**< EventType */
	UINT16 eventData1;					/**< Event Data1: Progress Rate, and so on */
	UINT16 eventData2;					/**< Event Data2: BPS, and so on */
} __UC_EVENT_T;
#define UC_EVENT_T __UC_EVENT_T
#endif


#endif	//UC_USE_NEW_EVENT_TYPE



#ifdef __cplusplus
}
#endif
#endif

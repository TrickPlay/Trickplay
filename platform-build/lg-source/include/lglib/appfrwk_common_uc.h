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

#define UC_ERR_UNKNOWN					-1			//�ش� Event�� ���� ���ۿ� ���� �� �� ���� ������ �߻�
#define UC_ERR_NOT_HANDLEED				-2			//�ش� Event�� ���� ������ ó���� �� ����.
#define UC_ERR_INVALID_PARAMS			-3			//�ش� Event�� ���� ���ۿ� ���� �߸��� param�� �Է�
#define UC_ERR_NETWORK					-4			//�ش� Event�� ���� ������ ���� �� Network ���� ������ �߻�
#define UC_ERR_NOT_ENOUGH_STORAGE		-5			//�ش� Event�� ���� ������ ���� �� Storage�� �뷮�� ���ġ ����.
#define UC_ERR_NOT_ENOUGH_MEMORY		-6			//�ش� Event�� ���� ������ ���� �� Memory�� �����Ͽ� malloc ������.
#define UC_ERR_NOT_EXIST_APPID			-7			//AppID�� �ش��ϴ� App�� ��ġ�Ǿ� ���� ����. 
#define UC_ERR_ALREADY_INSTALLED		-8			//AppID�� �ش��ϴ� App�� �̹� ��ġ�Ǿ� ����

/**
 * Update Controller Event Structure
 *
 */
#ifndef UC_EVENT_T
typedef struct UC_EVENT {
	UC_EVENT_TYPE_T				eventType;			//���� �������� Upctrl ���ۿ� ���� event type
	__UC_EVENT_STATUS_T			eventStatus;		//Event�� �߻��ϰ� �� ����
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
	UC_EVT_ERROR			= -1,		/**< ����. */
	UC_EVT_INIT				= 0,		/**< �ʱ� ����*/
	UC_EVT_DOWNLOADING,					/**< �ٿ�ε� ��*/
	UC_EVT_DOWNLOADED,					/**< �ٿ�ε� �Ϸ� */
	UC_EVT_INSTALLING,					/**< �ν��� �� */
	UC_EVT_INSTALLED,					/**< �ν��� �Ϸ� */
	UC_EVT_CANCELED,					/**< ��� */
	UC_EVT_UNINSTALLING,				/**< ���� �� */
	UC_EVT_UNINSTALLED,					/**< ���� �Ϸ� */
	UC_EVT_NEEDTOUPDATE, 				/**< ������Ʈ �ʿ� */
	UC_EVT_REQDRM,						/**< DRM ��û */
	UC_EVT_RESDRM,						/**< DRM ��� */
	UC_EVT_SYNCINSTALLEDAPP_END,		/**< Cleanup Unregistered App �Ϸ�. */
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

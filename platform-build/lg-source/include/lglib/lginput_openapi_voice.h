/******************************************************************************
 *   Software Center, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2008 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/

 /**
 *  @file 		lginput_openapi_voice.h
 *  @author 	hg.jeong (hg.jeong@lge.com)
 *  @version	0.1
 *  @date	Created    2011.08.
 *  @brief	voice open api
 */

#ifndef _LGINPUT_VOICEOPENAPI_H_
#define _LGINPUT_VOICEOPENAPI_H_


/******************************************************************************
	File Inclusions
******************************************************************************/

#include <dbus/dbus.h>
#ifdef __cplusplus
extern "C" {
#endif
#include "appfrwk_openapi_types.h"
#include "appfrwk_openapi_pm.h"

/******************************************************************************
	Macro Definitions
******************************************************************************/

#define	VOICE_EXIT		-1
#define VOICE_RESTART	-2

/******************************************************************************
	Extern Variables & Function Prototype Declarations
******************************************************************************/


/******************************************************************************
	Global Type Definitions
******************************************************************************/
	
/**
 * VOICE Status
 */
typedef enum tagVOICE_STATUS_T
{
	VOICE_OK						= 0,		// Voice OK
	VOICE_NOT_OK					= -1,		// Voice Not OK
	VOICE_ERR_TV_NETWORK			= -2,		// Ethernet cable is connected, it but doesn't working
	VOICE_ERR_TV_UNPLUGGED			= -3,		// Ethernet cable is disconnected
	VOICE_ERR_SERVER_UNREACHABLE	= -4,		// Ethernet cable is connected, but Voice server is unreachable
	VOICE_ERR_NO_INPUT				= -5,		// No voice data input from REMOTE
	
} VOICE_STATUS_T;

/**
 * VOICE 를 사용하는 APP Type
 */
typedef enum tagVOICE_APP_TYPE_T
{
	VOICE_APP_SEARCH	= 0,
	VOICE_APP_SNS		,
	VOICE_APP_BROWSER	,
	VOICE_APP_CP		,
	VOICE_APP_MAX		,

} VOICE_APP_TYPE_T;

typedef enum tagVOICE_MODE_TYPE_T
{
	VOICE_MODE_WORD = 0,
	VOICE_MODE_DICTATION,
	VOICE_MODE_MAX,	
}VOICE_MODE_TYPE_T;

/**
 * 현재 설정된 언어
 */
typedef enum tagVOICE_LANG_TYPE_T
{
	// TODO : DTV Process 에서 LANG TYPE 을 선언 한 곳을 사용 할 수 있는지 확인 필요함
	VOICE_GER		= 0,	// German, EU
	VOICE_ENG,				// English, UK
	VOICE_ENUS,				// English, US
	VOICE_ESES,				// Spanish, EU
	VOICE_ESUS,				// Spanish, US
	VOICE_FRCA,				// French, Canada
	VOICE_FRFR,				// French, EU
	VOICE_ITIT,				// 
	VOICE_KOKR,   			// KOKR 언어, 지역
	VOICE_SWE,				// Swedish 
	VOICE_NOR,				// Norwegian 
	VOICE_NLD,				// Dutch
	VOICE_RUS,				// Russian
	VOICE_ENAU,				// Australian English
	VOICE_CHMN,				// Chinese Mandarin
	VOICE_BRA,				// Brazilian
	VOICE_MAX,
} VOICE_LANG_TYPE_T;





/******************************************************************************
	Static Variables & Function Prototypes Declarations
******************************************************************************/

/******************************************************************************
	Global Variables & Function Prototypes Declarations
******************************************************************************/

HOA_STATUS_T	HOA_MRCU_InitializeVoice(void);
HOA_STATUS_T	HOA_MRCU_InitializeVoiceApp(UINT32 appType, UINT32 pid);
HOA_STATUS_T	HOA_MRCU_FinalizeVoiceApp(UINT32 pid);
HOA_STATUS_T	HOA_MRCU_SetVoiceLanguage(UINT32 langType);
HOA_STATUS_T	HOA_MRCU_SelectVoiceMode(VOICE_MODE_TYPE_T mode);
HOA_STATUS_T	HOA_MRCU_StartVoiceRecognition(void);
HOA_STATUS_T	HOA_MRCU_ExitVoiceRecognition(void);
HOA_STATUS_T	HOA_MRCU_RegisterVoiceCallback(LGINPUT_VOICE_CB_T  pfnCallback );
HOA_STATUS_T	HOA_MRCU_UnregisterVoiceCallback(void);
HOA_STATUS_T	HOA_MRCU_RegisterVoiceUiFuncCallback(LGINPUT_VOICE_UI_CB_T  pfnCB );
HOA_STATUS_T	HOA_MRCU_UnregisterVoiceUiFuncCallback(void);
HOA_STATUS_T	HOA_MRCU_SelectVoiceMultiResult(int index);
HOA_STATUS_T	HOA_MRCU_RegisterRMSCallback(LGINPUT_VOICE_RMS_CB_T pfnRMSCBFuncion);
HOA_STATUS_T	HOA_MRCU_UnregisterRMSCallback(void);



HOA_STATUS_T APP_HNDL_LGINPUT_VoiceSendNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);


HOA_STATUS_T APP_HNDL_LGINPUT_VoiceSendMultiResult(DBusConnection *conn, DBusMessage *msg, void *user_data);

#ifdef __cplusplus
}
#endif

#endif /* _LGINPUT_VOICEOPENAPI_H_ */


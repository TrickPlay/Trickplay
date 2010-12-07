/******************************************************************************
*	DTV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA.
*	Copyright(c) 1999 by LG Electronics Inc.
*
*	 All rights reserved. No part of this work may be reproduced, stored in a
*	 retrieval system, or transmitted by any means without prior written
*	 permission of LG Electronics Inc.
*****************************************************************************/

/** @file sp_ddi.h
*
*	SP Interface header file.
*
*	@author		jaeguk.lee(jaeguk.lee@lge.com)
*	@version	1.0
*	@date	  	2010.10.26
*	@note
*/


#ifndef _GOA_API_H_
#define _GOA_API_H_

/******************************************************************************
    Header File Guarder
******************************************************************************/
#include "EGL/egl.h"

/******************************************************************************
    Control Constants
******************************************************************************/
/******************************************************************************
    File Inclusions
******************************************************************************/
/******************************************************************************
    Macro Definitions
******************************************************************************/
#define OPENGLES_WINDOW_X 0x1000
#define OPENGLES_WINDOW_Y 0x1001
#define OPENGLES_WINDOW_WIDTH 0x1002
#define OPENGLES_WINDOW_HEIGHT 0x1003
#define OPENGLES_WINDOW_STRETCHTODISPLAY 0x1004
#define OPENGLES_WINDOW_FORMAT	0x1005
#define OPENGLES_WINDOW_NONE	0x1fff
	
#define OPENGLES_WIDNOW_MAX_WIDTH 1920
#define OPENGLES_WIDNOW_MAX_HEIGHT 1080

#define dbgprint(x...) GOA_UTIL_DEBUGPrint(x)

/******************************************************************************
    Type Definitions
******************************************************************************/
typedef struct 
{
	float				fRoll;	/**< roll angle */
	float				fPitch; /**< pitch angle */

	float				fXG;	 /**< X-axis acceleration */
	float				fYG;	 /**< Y-axis acceleration */
	float				fZG;	 /**< Z-axis acceleration */
	float				fTG;	 /**< XYZ-Resultant */

	float				fXR;	 /**< X-axis angular rate */
	float				fYR;	 /**< Y-axis angular rate */

	unsigned char		cButton;  /**< button */
	float				fBattery; /**< battery level */
	int 				nIR_Key;  /**< IR key */

} MOTION_DATA_T;


typedef struct 
{
	/* event callback mouse를 사용하였으면 TRUE를 리턴하고 사용하지 않았으면 FALSE를 리턴한다. */
	BOOLEAN (*pfnDirectMouseEventCallback)(float relative_fPosX, float relative_fPosY,
											float abs_fPosX, float abs_fPosY, MOTION_DATA_T* psMotion);
	BOOLEAN (*pfnPairingCheckCallback)(BOOLEAN pairing_result);
} SP_CALLBACKS_T;

typedef struct 
{
	SP_CALLBACKS_T directMouseCallback;
	APP_CALLBACKS_T callbacks;
} GOA_CALLBACK_T;

typedef enum 
{
	GOA_OK					= 0,	/**< HOA 함수가 성공적으로 수행 */
	GOA_HANDLED 			= 0,	/**< 주어진 요청사항에 대한 처리를 완료함 */
	GOA_ERROR				= -1,	/**< 함수 수행 중 에러 발생 */
	GOA_NOT_HANDLED 		= -1,	/**< 주어진 요청사항에 대한 처리를 하지 않음 */
	GOA_BLOCKED 			= -2,	/**< 다른 App.가 HOA를 독점적으로 사용하고 있어 수행되지 않음 */
	GOA_INVALID_PARAMS		= -3,	/**< 함수 인자에 잘못된 값이 들어있음 */
	GOA_NOT_ENOUGH_MEMORY	= -4,	/**< 메모리가 함수를 수행할 수 있을 만큼 충분하지 않음 */
	GOA_TIMEOUT 			= -5,	/**< 함수 수행 요청 후 일정 시간 내에 답이 오지 않음 */
	GOA_NOT_SUPPORTED		= -6,	/**< 버전 차이 등으로 인해 지원되지 않는 함수임 */
	GOA_BUFFER_FULL 		= -7,	/**< 버퍼에 데이터가 가득 차있어 함수가 수행되지 않음  */
	GOA_HOST_NOT_CONNECTED	= -8,	/**< Host가 연결되어 있지 않아 함수가 수행되지 않음  */
	GOA_VERSION_MISMATCH	= -9,	/**< App.와 library간에 버전이 맞지 않아 수행되지 않음 */
	GOA_ALREADY_REGISTERED	= -10,	/**< App.가 이미 Manager에 등록되어 있음 */
	GOA_LAST
} GOA_STATUS_T;

/**
 * openGL Window Format
*/
typedef enum 
{
  OPENGLES_WINDOW_PIXEL565 = 0, //pixel's format is 565(RGB)
  OPENGLES_WINDOW_PIXEL8888,
  OPENGLES_WINDOW_PIXEL_END
}OPENES_WINDOW_PIXEL_FORMAT_T;

/******************************************************************************
  Static Variables & Function Prototypes Declarations
 ******************************************************************************/

/******************************************************************************
    Function Declaration
******************************************************************************/
/**
 *	Initialize System for game running.
 *	@param	graphicMemory		[in]
 *	@param	systemMemory		[in]
 *	@param	goa_callback			[in]
 *	@return	GOA_STATUS
 */
GOA_STATUS_T GOA_SYSTEM_Initialize(UINT32 systemMemory, UINT32 graphicMemory, GOA_CALLBACK_T* goa_callbacks_t);
/**
 *	Finalize System for returning to the DTV System.
 *	@param	ADDON_EXITCODE_T		[in]
 *	@return	GOA_STATUS
 */
GOA_STATUS_T GOA_SYSTEM_Finalize(ADDON_EXITCODE_T exitCode);

/**
 *	Initialize Inputdevice for game running.
 *	@param	goa_callbacks_t		
 *
 *	@return	GOA_STATUS
 */
GOA_STATUS_T GOA_INPUTDEVICE_Initialize(GOA_CALLBACK_T* goa_callbacks_t);

/**
 *	Initialize Inputdevice for game running.
 *	@param	goa_callbacks_t		
 *
 *	@return	GOA_STATUS
 */
GOA_STATUS_T GOA_INPUTDEVICE_Finalize(void);


/**
 *  OpenGL ES Driver Initialize for Add-ON Process
 *
 * @param  pAttrList [in]  Attribute List
 * @return  the function succeeds, the return value is OK..
 */
GOA_STATUS_T GOA_OPENGLES_Initialize(const UINT32 *pAttrList);
/**
 *  OpenGL ES Driver Finalize for Add-ON Process
 *
 * @return  the function succeeds, the return value is OK..
 */
GOA_STATUS_T GOA_OPENGLES_Finalize(ADDON_EXITCODE_T exitCode);
/**
 *	This is the platfrom dependent call to create the correct type of native window for the platform
 *	we are currently using
 *
 * @return	EGLNativeWindowType
 */
EGLNativeWindowType GOA_OPENGLES_CreateNativeEGLWindow(void);
/**
 *  This is the platfrom dependent call to create the correct type of native window for the platform
 *  we are currently using
 *
 * @return   
 */
void GOA_OPENGLES_DestroyNativeEGLWindow(EGLNativeWindowType win);
/**
 *  Set GOA Debug levle
 *
 * @param  bdbgOnOff [in]  debug level
 * @return
 */
void GOA_UTIL_SetDBGLevel(BOOLEAN bdbgOnOff);

//---------------internal------------
GOA_STATUS_T GOA_CreateResponseSem(void);

GOA_STATUS_T GOA_WaitResponseSem(SINT32 timeout, UINT32 *pRet);

GOA_STATUS_T GOA_PostResponseSem(GOA_STATUS_T ret);

GOA_STATUS_T GOA_DestroyResponseSem(void);


GOA_STATUS_T DDI_SP_Initialize(SP_CALLBACKS_T* callback);
GOA_STATUS_T DDI_SP_Destroy(void);
void sp_task(void);


#endif /* end of _SP_DDI_H_ */

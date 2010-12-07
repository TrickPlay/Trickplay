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
	/* event callback mouse�� ����Ͽ����� TRUE�� �����ϰ� ������� �ʾ����� FALSE�� �����Ѵ�. */
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
	GOA_OK					= 0,	/**< HOA �Լ��� ���������� ���� */
	GOA_HANDLED 			= 0,	/**< �־��� ��û���׿� ���� ó���� �Ϸ��� */
	GOA_ERROR				= -1,	/**< �Լ� ���� �� ���� �߻� */
	GOA_NOT_HANDLED 		= -1,	/**< �־��� ��û���׿� ���� ó���� ���� ���� */
	GOA_BLOCKED 			= -2,	/**< �ٸ� App.�� HOA�� ���������� ����ϰ� �־� ������� ���� */
	GOA_INVALID_PARAMS		= -3,	/**< �Լ� ���ڿ� �߸��� ���� ������� */
	GOA_NOT_ENOUGH_MEMORY	= -4,	/**< �޸𸮰� �Լ��� ������ �� ���� ��ŭ ������� ���� */
	GOA_TIMEOUT 			= -5,	/**< �Լ� ���� ��û �� ���� �ð� ���� ���� ���� ���� */
	GOA_NOT_SUPPORTED		= -6,	/**< ���� ���� ������ ���� �������� �ʴ� �Լ��� */
	GOA_BUFFER_FULL 		= -7,	/**< ���ۿ� �����Ͱ� ���� ���־� �Լ��� ������� ����  */
	GOA_HOST_NOT_CONNECTED	= -8,	/**< Host�� ����Ǿ� ���� �ʾ� �Լ��� ������� ����  */
	GOA_VERSION_MISMATCH	= -9,	/**< App.�� library���� ������ ���� �ʾ� ������� ���� */
	GOA_ALREADY_REGISTERED	= -10,	/**< App.�� �̹� Manager�� ��ϵǾ� ���� */
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

#include "tp_common.h"
#include "tp_settings.h"
#include "tp_opengles.h"
#include "tp_controller.h"
#include "tp_system.h"


static UINT32 ulInitializedStep;

BOOLEAN TP_System_Initialize(void)
{
	DBG_PRINT_TP(NULL);

	HOA_STATUS_T	hoaStatus;
	APP_CALLBACKS_T	callbacks			= {
		TP_System_MsgHandler,
		TP_Controller_KeyEventCallback,
#ifdef MOUSE_SUPPORTED
		TP_Controller_MouseEventCallback
#else
		NULL
#endif
	};
	const UINT32	openglAttributes[]	= {
		OPENGLES_WINDOW_ATTRIB_X,		0,
		OPENGLES_WINDOW_ATTRIB_Y,		0,
		OPENGLES_WINDOW_ATTRIB_WIDTH,	TRICKPLAY_SCREEN_WIDTH,
		OPENGLES_WINDOW_ATTRIB_HEIGHT,	TRICKPLAY_SCREEN_HEIGHT,
		OPENGLES_WINDOW_ATTRIB_STRETCH,	TRICKPLAY_STRETCH_TO_SCREEN,
		OPENGLES_WINDOW_ATTRIB_NONE
	};

	ulInitializedStep = 0;

	if (!TP_OpenGLES_Initialize(openglAttributes))
	{
		DBG_PRINT_TP("TP_OpenGLES_Initialize() failed.");
		return FALSE;
	}
	++ulInitializedStep;	/* Done initialize step 1 */

	hoaStatus = HOA_APP_RegisterToMgr(&callbacks);
	if (hoaStatus != HOA_OK)
	{
		DBG_PRINT_TP("HOA_APP_RegisterToMgr() failed. (%d)", hoaStatus);
		TP_System_Finalize();
		return FALSE;
	}
	++ulInitializedStep;	/* Done initialize step 2 */

	hoaStatus = HOA_APP_SetReady();
	if (hoaStatus != HOA_OK)
	{
		DBG_PRINT_TP("HOA_APP_SetReady() failed. (%d)", hoaStatus);
		TP_System_Finalize();
		return FALSE;
	}
	++ulInitializedStep;	/* Done initialize step 3 */

	hoaStatus = HOA_APP_RequestFocus();
	if (hoaStatus != HOA_OK)
	{
		DBG_PRINT_TP("HOA_APP_RequestFocus() failed. (%d)", hoaStatus);
		TP_System_Finalize();
		return FALSE;
	}
	++ulInitializedStep;	/* Done initialize step 4 */

	return TRUE;
}

void TP_System_Finalize(void)
{
	DBG_PRINT_TP(NULL);

	if (ulInitializedStep > 3)
		HOA_APP_ReleaseFocus(EXITCODE_NORMAL);
	if (ulInitializedStep > 2)
		HOA_APP_SetTerminate();
	if (ulInitializedStep > 1)
		HOA_APP_DeregisterFromMgr(EXITCODE_NORMAL);
	if (ulInitializedStep > 0)
		TP_OpenGLES_Finalize();

	ulInitializedStep = 0;
}

void TP_System_EnableFullDisplay(void)
{
	DBG_PRINT_TP(NULL);

	HOA_TV_SetDisplayMode(ADDON_DISP_FULLUI);	/* This API always returns HOA_OK */
}

void TP_System_DisableFullDisplay(void)
{
	DBG_PRINT_TP(NULL);

	HOA_TV_SetDisplayMode(ADDON_DISP_NONE);		/* This API always returns HOA_OK */
}

extern void TP_QuitContext(void);

HOA_STATUS_T TP_System_MsgHandler(HOA_MSG_TYPE_T msg, UINT32 submsg, UINT8* pData, UINT16 dataSize)
{
	if (msg == HOA_MSG_TERMINATE)
	{
		DBG_PRINT_TP("msg: HOA_MSG_TERMINATE");
		TP_QuitContext();
	}

	return HOA_OK;
}


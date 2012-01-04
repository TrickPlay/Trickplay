#include <string.h>
#include <stdio.h>

#include "tp_common.h"
#include "tp_settings.h"
#include "tp_opengles.h"
#include "tp_controller.h"
#include "tp_system.h"

#include "appfrwk_openapi_ac.h"

static UINT32 ulInitializedStep;
static UINT64 gAuid;
static TP_DISPLAY_MODE_T gDispMode;

BOOLEAN TP_System_Initialize(int argc, char **argv)
{
	DBG_PRINT_TP("[TrickPlay] TP_System_Initialize ---------------------------------");

	HOA_STATUS_T	hoaStatus;
	HOA_PROC_CALLBACKS_T	callbacks			= {
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
	int i;

	ulInitializedStep = 0;

	for (i = 0 ; i < argc ; i++)
	{
		if (strcmp(argv[i], "--auid") == 0)
		{
			if ((i+1) < argc)
				sscanf(argv[i+1], "%llx", &gAuid);
			else
				gAuid = 0;
			break;
		}
	}
	DBG_PRINT_TP("AUID = %lld", gAuid);

	if (!TP_OpenGLES_Initialize(openglAttributes))
	{
		DBG_PRINT_TP("TP_OpenGLES_Initialize() failed.");
		return FALSE;
	}
	++ulInitializedStep;	/* Done initialize step 1 */

	//hoaStatus = HOA_APP_RegisterToMgr(&callbacks);
	hoaStatus = HOA_PROC_RegisterService(argc, argv, &callbacks);
	if (hoaStatus != HOA_OK)
	{
		DBG_PRINT_TP("HOA_PROC_RegisterService() failed. (%d)", hoaStatus);
		TP_System_Finalize();
		return FALSE;
	}
	++ulInitializedStep;	/* Done initialize step 2 */

	hoaStatus = HOA_PROC_SetReady();
	if (hoaStatus != HOA_OK)
	{
		DBG_PRINT_TP("HOA_PROC_SetReady() failed. (%d)", hoaStatus);
		TP_System_Finalize();
		return FALSE;
	}
	++ulInitializedStep;	/* Done initialize step 3 */


	// TODO keunbae.choi - Setresolution
	HOA_APP_SetResolution(gAuid, 0, 0, 1920, 1080, TRUE);
	
	//hoaStatus = HOA_APP_RequestToFocusedApp();
	// TODO sanggi0.lee - parameter AUID
	hoaStatus = HOA_APP_RequestToFocusedApp(gAuid);
	if (hoaStatus != HOA_OK)
	{
		DBG_PRINT_TP("HOA_APP_RequestToFocusedApp() failed. (%d)", hoaStatus);
		TP_System_Finalize();
		return FALSE;
	}
	++ulInitializedStep;	/* Done initialize step 4 */

	return TRUE;
}

void TP_System_Finalize(void)
{
	DBG_PRINT_TP(NULL);

	// TODO sanggi0.lee - remove
	#if 0
	if (ulInitializedStep > 3)
	{
		//HOA_APP_ReleaseFocus(EXITCODE_NORMAL);
		HOA_APP_ExitApp(gAuid, AM_EXITCODE_BACK);
	}

	if (ulInitializedStep > 2)
	{
		HOA_PROC_NotifyAppTermination();
	}
#endif

	if (ulInitializedStep > 1)
	{
		//HOA_APP_DeregisterFromMgr(EXITCODE_NORMAL);
		HOA_PROC_NotifyAppTermination();
		HOA_APP_ExitApp(gAuid, AM_EXITCODE_BACK);
		HOA_PROC_UnregisterService();
	}
	if (ulInitializedStep > 0)
		TP_OpenGLES_Finalize();

	ulInitializedStep = 0;
}

void TP_System_EnableFullDisplay(void)
{
	DBG_PRINT_TP(NULL);

	// TODO sanggi0.lee - display mode
	//HOA_CTRL_SetDisplayMode(HOA_DISP_FULLUI);	/* This API always returns HOA_OK */
	HOA_CTRL_SetDisplayMode(HOA_DISP_FULLVIDEO);	/* This API always returns HOA_OK */
}

void TP_System_DisableFullDisplay(void)
{
	DBG_PRINT_TP(NULL);

	// TODO sanggi0.lee - new function
	HOA_CTRL_SetAVBlock(FALSE,FALSE);
	HOA_CTRL_SetDisplayMode(HOA_DISP_NONE);		/* This API always returns HOA_OK */
}

TP_DISPLAY_MODE_T TP_System_GetDisplayMode(void)
{
	return gDispMode;
}

void TP_System_SetDisplayMode(TP_DISPLAY_MODE_T mode)
{
	HOA_DISPLAYMODE_T disp = HOA_DISP_NONE;

	switch (mode)
	{
	case TP_DISP_WIDGET:
		disp = HOA_DISP_UIWITHTV;
		HOA_CTRL_SetAVBlock(FALSE,FALSE);
		break;
	case TP_DISP_FULL:
		disp = HOA_DISP_FULLVIDEO;
		break;
	case TP_DISP_NONE:
	default:
		mode = TP_DISP_NONE;
		HOA_CTRL_SetAVBlock(FALSE,FALSE);
		break;
	}

	gDispMode = mode;

	DBG_PRINT_TP("mode=%d, disp=%d", mode, disp);

	HOA_CTRL_SetDisplayMode(disp);
}

extern void TP_QuitContext(void);

HOA_STATUS_T TP_System_MsgHandler(HOA_MSG_TYPE_T msg, UINT32 submsg, UINT8* pData, UINT16 dataSize)
{
	switch (msg)
	{
	case HOA_MSG_TERMINATE:
	case HOA_MSG_STOPLOADING:
	case HOA_MSG_THE_END:
		DBG_PRINT_TP("msg: HOA_MSG_TERMINATE");
		TP_QuitContext();
		break;
	default:
		break;
	}

	return HOA_OK;
}


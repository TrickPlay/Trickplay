#include "tp_common.h"
#include "tp_settings.h"
#include "tp_controller.h"
#include "tp_openapi.h"


static EGLNativeWindowType eglWindow = NULL;
static UINT32 ulInitializedStep;

BOOLEAN TP_OpenAPI_Initialize(void)
{
	DBG_PRINT_TP();

	HOA_STATUS_T	hoaStatus;
	APP_CALLBACKS_T	callbacks;
	const UINT32	openglAttributes[] = {
		OPENGLES_WINDOW_WIDTH,	TRICKPLAY_SCREEN_WIDTH,
		OPENGLES_WINDOW_HEIGHT, TRICKPLAY_SCREEN_HEIGHT,
		OPENGLES_WINDOW_FORMAT,	OPENGLES_WINDOW_PIXEL8888,
		OPENGLES_WINDOW_STRETCHTODISPLAY, 1,
		OPENGLES_WINDOW_NONE
	};

	callbacks.pfnMsgHandler			= TP_MsgHandler;
	callbacks.pfnKeyEventCallback	= TP_KeyEventCallback;
#ifdef INCLUDE_MOUSE
	callbacks.pfnMouseEventCallback	= TP_MouseEventCallback;
#else
	callbacks.pfnMouseEventCallback	= NULL;
#endif

	ulInitializedStep = 0;

	hoaStatus = HOA_APP_RegisterToMgr(&callbacks);
	if (hoaStatus != HOA_OK) {
		DBG_PRINT_TP("HOA_APP_RegisterToMgr() failed. (%d)", hoaStatus);
		TP_OpenAPI_Finalize();
		return FALSE;
	}
	++ulInitializedStep;	// Done initialize step 1

	hoaStatus = GOA_OPENGLES_Initialize(openglAttributes);
	if (hoaStatus != HOA_OK) {
		DBG_PRINT_TP("GOA_OPENGLES_Initialize() failed.");
		TP_OpenAPI_Finalize();
		return FALSE;
	}
	++ulInitializedStep;	// Done initialize step 2

	hoaStatus = HOA_APP_SetReady();
	if (hoaStatus != HOA_OK) {
		DBG_PRINT_TP("HOA_APP_SetReady() failed. (%d)", hoaStatus);
		TP_OpenAPI_Finalize();
		return FALSE;
	}
	++ulInitializedStep;	// Done initialize step 3

	hoaStatus = HOA_APP_RequestFocus();
	if (hoaStatus != HOA_OK) {
		DBG_PRINT_TP("HOA_APP_RequestFocus() failed. (%d)", hoaStatus);
		TP_OpenAPI_Finalize();
		return FALSE;
	}
	++ulInitializedStep;	// Done initialize step 4

	return TRUE;
}

void TP_OpenAPI_Finalize(void)
{
	DBG_PRINT_TP();

	if (eglWindow != NULL) {
		GOA_OPENGLES_DestroyNativeEGLWindow(eglWindow);
		eglWindow = NULL;
	}

	if (ulInitializedStep > 3) {
		HOA_APP_ReleaseFocus(EXITCODE_NORMAL);
	}
	if (ulInitializedStep > 2) {
		HOA_APP_SetTerminate();
	}
	if (ulInitializedStep > 1) {
		GOA_OPENGLES_Finalize(EXITCODE_NORMAL);
	}
	if (ulInitializedStep > 0) {
		HOA_APP_DeregisterFromMgr(EXITCODE_NORMAL);
	}

	ulInitializedStep = 0;
}

EGLNativeWindowType TP_OpenAPI_GetEGLNativeWindow(void)
{
	DBG_PRINT_TP();

	if (eglWindow == NULL) {
		eglWindow = GOA_OPENGLES_CreateNativeEGLWindow();
	}

	return eglWindow;
}

void TP_OpenAPI_EnableFullDisplay(void)
{
	DBG_PRINT_TP();

	HOA_TV_SetDisplayMode(ADDON_DISP_FULLUI);	// This API always returns HOA_OK
}

void TP_OpenAPI_DisableFullDisplay(void)
{
	DBG_PRINT_TP();

	HOA_TV_SetDisplayMode(ADDON_DISP_NONE);		// This API always returns HOA_OK
}

extern void TP_QuitContext(void);

HOA_STATUS_T TP_MsgHandler(HOA_MSG_TYPE_T msg, UINT32 submsg, UINT8 *pData, UINT16 dataSize)
{
	if (msg == HOA_MSG_TERMINATE) {
		DBG_PRINT_TP("msg: HOA_MSG_TERMINATE");
		TP_QuitContext();
	}

	return HOA_OK;
}


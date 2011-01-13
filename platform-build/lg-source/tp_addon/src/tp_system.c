#include "tp_common.h"
#include "tp_settings.h"
#include "tp_controller.h"
#include "tp_system.h"


static EGLNativeWindowType eglWindow = NULL;
static UINT32 ulInitializedStep;

BOOLEAN TP_System_Initialize(void)
{
	DBG_PRINT_TP();

	HOA_STATUS_T	hoaStatus;
	GOA_STATUS_T	goaStatus;
	APP_CALLBACKS_T	callbacks;
	GOA_CALLBACK_T	goa_callback;
	const UINT32	openglAttributes[] = {
		OPENGLES_WINDOW_WIDTH,	TRICKPLAY_SCREEN_WIDTH,
		OPENGLES_WINDOW_HEIGHT, TRICKPLAY_SCREEN_HEIGHT,
		OPENGLES_WINDOW_FORMAT,	OPENGLES_WINDOW_PIXEL8888,
		OPENGLES_WINDOW_STRETCHTODISPLAY, TRICKPLAY_STRETCH_TO_SCREEN,
		OPENGLES_WINDOW_NONE
	};

	callbacks.pfnMsgHandler			= TP_MsgHandler;
	callbacks.pfnKeyEventCallback	= TP_KeyEventCallback;
#ifdef INCLUDE_MOUSE
	callbacks.pfnMouseEventCallback	= TP_MouseEventCallback;
#else
	callbacks.pfnMouseEventCallback	= NULL;
#endif
	goa_callback.callbacks = callbacks;

	ulInitializedStep = 0;

	goaStatus = GOA_SYSTEM_Initialize(
			TRICKPLAY_REQUIRED_SYSTEM_MEMORY,
			TRICKPLAY_REQUIRED_GRAPHIC_MEMORY,
			&goa_callback);
	if (goaStatus != GOA_OK) {
		DBG_PRINT_TP("GOA_SYSTEM_Initialize() failed. (%d)", goaStatus);
		TP_System_Finalize();
		return FALSE;
	}
	++ulInitializedStep;	// Done initialize step 1

	goaStatus = GOA_OPENGLES_Initialize(openglAttributes);
	if (goaStatus != GOA_OK) {
		DBG_PRINT_TP("GOA_OPENGLES_Initialize() failed. (%d)", goaStatus);
		TP_System_Finalize();
		return FALSE;
	}
	++ulInitializedStep;	// Done initialize step 2

	if (HOA_APP_SetReady() != HOA_OK) {
		DBG_PRINT_TP("HOA_APP_SetReady() failed. (%d)", hoaStatus);
		TP_System_Finalize();
		return FALSE;
	}
	++ulInitializedStep;	// Done initialize step 3

	if (HOA_APP_RequestFocus() != HOA_OK) {
		DBG_PRINT_TP("HOA_APP_RequestFocus() failed. (%d)", hoaStatus);
		TP_System_Finalize();
		return FALSE;
	}
	++ulInitializedStep;	// Done initialize step 4

	return TRUE;
}

void TP_System_Finalize(void)
{
	DBG_PRINT_TP();

	if (eglWindow != NULL) {
		GOA_OPENGLES_DestroyNativeEGLWindow(eglWindow);
		eglWindow = NULL;
	}

	if (ulInitializedStep > 3)
		HOA_APP_ReleaseFocus(EXITCODE_NORMAL);
	if (ulInitializedStep > 2)
		HOA_APP_SetTerminate();
	if (ulInitializedStep > 1)
		GOA_OPENGLES_Finalize(EXITCODE_NORMAL);
	if (ulInitializedStep > 0)
		GOA_SYSTEM_Finalize(EXITCODE_NORMAL);

	ulInitializedStep = 0;
}

EGLNativeWindowType TP_System_GetEGLNativeWindow(void)
{
	DBG_PRINT_TP();

	if (eglWindow == NULL)
		eglWindow = GOA_OPENGLES_CreateNativeEGLWindow();

	return eglWindow;
}

void TP_System_EnableFullDisplay(void)
{
	DBG_PRINT_TP();

	HOA_TV_SetDisplayMode(ADDON_DISP_FULLUI);	// This API always returns HOA_OK
}

void TP_System_DisableFullDisplay(void)
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


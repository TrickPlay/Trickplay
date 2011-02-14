#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <libgen.h>

#include "tp_common.h"
#include "tp_settings.h"
#include "tp_system.h"
#ifdef INCLUDE_NEW_WMDRMPD
#include "tp_drm.h"
#endif
#include "tp_controller.h"
#include "tp_imagedecoder.h"
#include "tp_mediaplayer.h"


void *tp_egl_get_native_window(void)
{
	return TP_System_GetEGLNativeWindow();
}

static TPContext *pContext = NULL;
static char szAppPath[PATH_MAX];

#ifdef INCLUDE_NEW_WMDRMPD
static BOOLEAN _TP_GetAppID(int argc, const char *argv[], UINT32 *pAppID)
{
	if (pAppID == NULL) {
		return FALSE;
	}

	int i;

	for (i = 1; i < argc; ++i) {
		if (strcmp(argv[i], "-app_id") == 0) {
			*pAppID = atoi(argv[i + 1]);

			DBG_PRINT_TP("App ID is %u\n", *pAppID);
			return TRUE;
		}
	}

	DBG_PRINT_TP("could not find App ID argument.");

	*pAppID = 0;
	return FALSE;
}

static void _TP_RemovePathRecursive(const char *szPath)
{
	execlp("rm", "rm", "-rf", szPath, NULL);
}
#endif

static BOOLEAN _TP_GetAppDirectory(char *szAppDirectory, const char *szAppPath)
{
	if ((szAppDirectory == NULL) || (szAppPath == NULL)) {
		return FALSE;
	}

	char *tmp = strdup(szAppPath);
	if (tmp == NULL) {
		return FALSE;
	}

	strcpy(szAppDirectory, dirname(tmp));
	free(tmp);

	return TRUE;
}

static BOOLEAN _TP_InitContext(int argc, char *argv[])
{
	if (pContext != NULL) {
		DBG_PRINT_TP("TPContext is already initialized.");
		return TRUE;
	}
	if ((argc < 2) || (argv[1][0] == '\0')) {
		DBG_PRINT_TP("app path must be specified.");
		return FALSE;
	}

#ifdef INCLUDE_NEW_WMDRMPD
	UINT32 appID = 0;

	if (!_TP_GetAppID(argc, argv, &appID)) {
		return FALSE;
	}

	// Create the string which stores the path to decrypt app.
	// : make this path to hidden directory (with starting with dot(.)) following appID.
	sprintf(szAppPath, "%s/.%u", TRICKPLAY_DRM_DECRYPTED_BASE_PATH, appID);

	// Remove existing directory.
	if (access(szAppPath, F_OK) == 0) {
		_TP_RemovePathRecursive(szAppPath);
	}

	if (!TP_DRM_DecryptAppToPath(appID, argv[argc - 1], szAppPath)) {
		return FALSE;
	}
#else
	strcpy(szAppPath, argv[argc - 1]);
#endif

	// Initialize TrickPlay
	tp_init(&argc, &argv);

	// Create new TrickPlay context
	pContext = tp_context_new();
	if (pContext == NULL) {
		DBG_PRINT_TP("tp_context_new() failed.");
		return FALSE;
	}

	// Set app path
	tp_context_set(pContext, TP_APP_PATH, szAppPath);

	char szAppDirectory[PATH_MAX] = { '\0', };

	if (_TP_GetAppDirectory(szAppDirectory, argv[1])) {
		tp_context_set(pContext, TP_APP_SOURCES, szAppDirectory);
		tp_context_set(pContext, TP_SCAN_APP_SOURCES, TRICKPLAY_SCAN_APP_SOURCES);
	}

	// Set directories
	tp_context_set(pContext, TP_FONTS_PATH, TRICKPLAY_FONTS_PATH);
	tp_context_set(pContext, TP_DATA_PATH, TRICKPLAY_DATA_PATH);

	// Set screen geometry
	tp_context_set_int(pContext, TP_SCREEN_WIDTH, TRICKPLAY_SCREEN_WIDTH);
	tp_context_set_int(pContext, TP_SCREEN_HEIGHT, TRICKPLAY_SCREEN_HEIGHT);

#ifndef _TP_DEBUG
	// Prevent DEBUG messages from being logged for RELEASE builds
	tp_context_set_int(pContext, TP_LOG_DEBUG, 0);
#endif

	return TRUE;
}

static void _TP_SetRuntimeEnvs(void)
{
	setenv("CLUTTER_DISABLE_MIPMAPPED_TEXT", "1", 1);
#ifdef _TP_DEBUG
//	setenv("CLUTTER_DEBUG", "all", 1);
	setenv("CLUTTER_SHOW_FPS", "1", 1);
#endif
}

static BOOLEAN _TP_RunContext(void)
{
	if (pContext == NULL) {
		DBG_PRINT_TP("Context is NULL.");
		return FALSE;
	}

    // Run Trickplay - will not return until exit
	return (tp_context_run(pContext) == TP_RUN_OK) ? TRUE : FALSE;
}

void TP_QuitContext(void)
{
	if (pContext == NULL) {
		DBG_PRINT_TP("No current running app.");
		return;
	}

	tp_context_quit(pContext);
}

static void _TP_FiniContext(void)
{
	if (pContext != NULL) {
    	tp_context_free(pContext);
		pContext = NULL;
	}

#ifdef INCLUDE_NEW_WMDRMPD
	// remove DRM decrypted app
	_TP_RemovePathRecursive(szAppPath);
#endif
}

int main(int argc, char *argv[])
{
	int result = 1;

	if (!TP_System_Initialize()) {
		goto done;
	}

	_TP_SetRuntimeEnvs();

	if (!_TP_InitContext(argc, argv)) {
		goto done;
	}

	if (!TP_Controller_Initialize(pContext)
			|| !TP_MediaPlayer_Initialize(pContext)
			|| !TP_ImageDecoder_Initialize(pContext)) {
		goto done;
	}

	TP_System_EnableFullDisplay();
	result = _TP_RunContext() ? 0 : 1;
	TP_System_DisableFullDisplay();

done:
	TP_ImageDecoder_Finalize(pContext);
	TP_MediaPlayer_Finalize(pContext);
	TP_Controller_Finalize(pContext);

	_TP_FiniContext();

	TP_System_Finalize();

	return result;
}


#include <stdint.h>
#include <stdlib.h>

#include <trickplay/trickplay.h>

#include "tp_main.h"
#include "tp_controller.h"
#include "tp_imagedecoder.h"
#include "tp_mediaplayer.h"

// Override default library constructor and destructor
// See '-nostartfiles' link option in Makefile
#ifdef _TP_DEBUG
void _init(void)
{
	DBG_PRINT_TP("libtrickplay.so opened...");
}

void _fini(void)
{
	DBG_PRINT_TP("libtrickplay.so will close...");
}
#endif

static TPContext *pContext = NULL;

static BOOLEAN _TP_InitContext(void)
{
	DBG_PRINT_TP("_TP_InitContext");
	
	if (pContext != NULL) {
		DBG_PRINT_TP("TPContext already initialized.");
		return TRUE;
	}

	setenv("G_SLICE", "always-malloc", 1);

	// Initialize TrickPlay
	tp_init(NULL, NULL);

	// Create new TrickPlay context
	pContext = tp_context_new();
	if (pContext == NULL) {
		DBG_PRINT_TP("tp_context_new() failed.");
		return FALSE;
	}

	// Set app path
	if (getenv("TP_APP_PATH") == NULL) {
		DBG_PRINT_TP("app path does not specified.");
		return FALSE;
	}
	tp_context_set(pContext, TP_APP_PATH, getenv("TP_APP_PATH"));

    tp_context_set(pContext, TP_CONFIG_FROM_FILE , "/mnt/usb2/Drive1/trickplay/config" );
    
    // PABLO
    // All of the settings below can be made in the config file set above.
    
	// Set directories
	//tp_context_set(pContext, TP_FONTS_PATH, "/mnt/lgfont");
	//tp_context_set(pContext, TP_DATA_PATH, "/mnt/addon");

	// Set screen geometry
	//tp_context_set_int(pContext, TP_SCREEN_WIDTH, 1920);
	//tp_context_set_int(pContext, TP_SCREEN_HEIGHT, 1080);

#ifndef _TP_DEBUG
	// Prevent DEBUG messages from being logged for RELEASE builds
	//tp_context_set_int(pContext, TP_LOG_DEBUG, 0);
#endif

	return TRUE;
}

static void _TP_SetRuntimeEnv(void)
{
	DBG_PRINT_TP("_TP_SetRuntimeEnv");
	setenv("CLUTTER_DISABLE_MIPMAPPED_TEXT", "1", 1);
#ifdef _TP_DEBUG
	setenv("CLUTTER_SHOW_FPS", "1", 1);
#endif
}

static BOOLEAN _TP_RunContext(void)
{
	DBG_PRINT_TP("_TP_RunContext");
	if (pContext == NULL) {
		DBG_PRINT_TP("pContext is NULL.");
		return FALSE;
	}

	// Run TrickPlay - will not return until exit
	return (tp_context_run(pContext) == 0) ? TRUE : FALSE;
}

static void _TP_QuitContext(void)
{
	DBG_PRINT_TP("_TP_QuitContext");
	if (pContext == NULL) {
		DBG_PRINT_TP("No current running app.");
		return;
	}

	tp_context_quit(pContext);
}

static void _TP_FiniContext(void)
{
	DBG_PRINT_TP("_TP_FiniContext");
	if (pContext != NULL) {
		tp_context_free(pContext);
		pContext = NULL;
	}
}

#if 0
#include <malloc.h>
#define NATIVE_MALLOC_PADDING	(2 * sizeof(size_t))

static void memalign_test(int phase)
{
	size_t page_size = 100;
	void *aligned_memory = NULL;

	switch (phase) {
		case 0:
			posix_memalign(&aligned_memory, page_size, page_size - NATIVE_MALLOC_PADDING);
			break;
		case 1:
			aligned_memory = memalign(page_size, page_size - NATIVE_MALLOC_PADDING);
			break;
		case 2:
			aligned_memory = valloc(page_size - NATIVE_MALLOC_PADDING);
			break;
		default:
			break;
	}

	uint8_t *mem = (uint8_t *)aligned_memory;
	size_t addr = ((size_t)mem / page_size) * page_size;

	if (aligned_memory != (void *)addr) {
		printf("===== allocator_memalign() fails at phase %d !! ======\n", phase);
	}
}
#endif

BOOLEAN TrickPlay_Main(void)
{
	DBG_PRINT_TP("TrickPlay_Main");
	BOOLEAN res = FALSE;

#if 0
	memalign_test(0);
	memalign_test(1);
	memalign_test(2);
#endif

	if (!_TP_InitContext()) {
		goto done;
	}

	if (!TP_Controller_Initialize(pContext)		||
		!TP_ImageDecoder_Initialize(pContext)	||
		!TP_MediaPlayer_Initialize(pContext))
	{
		goto done;
	}

	_TP_SetRuntimeEnv();
	res = _TP_RunContext();

done:
	_TP_FiniContext();

	return res;
}

void TrickPlay_Quit(void)
{
	DBG_PRINT_TP("TrickPlay_Quit");
	_TP_QuitContext();
}


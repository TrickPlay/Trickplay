#include <string.h>

#include <trickplay/keys.h>
#include <trickplay/controller.h>

#include "util_api.h"

#include "tp_controller.h"


static TPControllerKeyMap _gKeyMap[] =
{
	// General buttons
	{ 0x07/*IR_KEY_LEFT_ARROW*/,	TP_KEY_LEFT },
	{ 0x40/*IR_KEY_UP_ARROW*/,		TP_KEY_UP },
	{ 0x06/*IR_KEY_RIGHT_ARROW*/,	TP_KEY_RIGHT },
	{ 0x41/*IR_KEY_DOWN_ARROW*/,	TP_KEY_DOWN },
	{ 0x44/*IR_KEY_ENTER*/,			TP_KEY_RETURN },
	{ 0x5B/*IR_KEY_EXIT*/,			TP_KEY_ESCAPE },

	{ 0x10/*IR_KEY_0*/,				TP_KEY_0 },
	{ 0x11/*IR_KEY_1*/,				TP_KEY_1 },
	{ 0x12/*IR_KEY_2*/,				TP_KEY_2 },
	{ 0x13/*IR_KEY_3*/,				TP_KEY_3 },
	{ 0x14/*IR_KEY_4*/,				TP_KEY_4 },
	{ 0x15/*IR_KEY_5*/,				TP_KEY_5 },
	{ 0x16/*IR_KEY_6*/,				TP_KEY_6 },
	{ 0x17/*IR_KEY_7*/,				TP_KEY_7 },
	{ 0x18/*IR_KEY_8*/,				TP_KEY_8 },
	{ 0x19/*IR_KEY_9*/,				TP_KEY_9 },

	// Vendor extensions

	// Color buttons
	{ 0x72/*IR_KEY_RED*/,			TP_KEY_RED },
	{ 0x71/*IR_KEY_GREEN*/,			TP_KEY_GREEN },
	{ 0x63/*IR_KEY_YELLOW*/,		TP_KEY_YELLOW },
	{ 0x61/*IR_KEY_BLUE*/,			TP_KEY_BLUE },

	// Transport control
	{ 0xB1/*IR_KEY_STOP*/,			TP_KEY_STOP },
	{ 0xB0/*IR_KEY_PLAY*/,			TP_KEY_PLAY },
	{ 0xBA/*IR_KEY_PAUSE*/,			TP_KEY_PAUSE },
	{ 0x8F/*IR_KEY_REW*/,			TP_KEY_REW },
	{ 0x8E/*IR_KEY_FF*/,			TP_KEY_FFWD },
	{ 0xB2/*IR_KEY_GOTOPREV*/,		TP_KEY_PREV },
	{ 0xB3/*IR_KEY_GOTONEXT*/,		TP_KEY_NEXT },
	{ 0xBD/*IR_KEY_REC*/,			TP_KEY_REC },

	// Navigation
	{ 0x43/*IR_KEY_MENU*/,			TP_KEY_MENU },
	{ 0xA9/*IR_KEY_GRIDGUIDE*/,		TP_KEY_GUIDE },
	{ 0x28/*IR_KEY_BACK*/,			TP_KEY_BACK },
//	{ 0,							TP_KEY_EXIT },
	{ 0xAA/*IR_KEY_INFO*/,			TP_KEY_INFO },
//	{ 0,							TP_KEY_TOOL },

	// Channels
	{ 0x00/*IR_KEY_CH_UP*/,			TP_KEY_CHAN_UP },
	{ 0x01/*IR_KEY_CH_DOWN*/,		TP_KEY_CHAN_DOWN },
//	{ 0,							TP_KEY_CHAN_LAST },
	{ 0x53/*IR_KEY_PRLIST*/,		TP_KEY_CHAN_LIST },
	{ 0x1E/*IR_KEY_FAVORITE*/,		TP_KEY_CHAN_FAV },

	// Audio
	{ 0x02/*IR_KEY_VOL_UP*/,		TP_KEY_VOL_UP },
	{ 0x03/*IR_KEY_VOL_DOWN*/,		TP_KEY_VOL_DOWN },
	{ 0x09/*IR_KEY_MUTE*/,			TP_KEY_MUTE },

	// Captions
	{ 0x39/*IR_KEY_CC*/,			TP_KEY_CC },

	{ 0,							0 }
};

static TPController *_gpRemoteController = NULL;

static void _TP_KeyEventCallback(UINT32 key, UINT32 keyType)
{
	switch (keyType) {
		case 0:		// KEY_PRESS
		case 1:		// KEY_REPEAT
			tp_controller_key_down(_gpRemoteController, key, 0);
			break;
	}
}

static BOOLEAN _TP_AddRemoteController(TPContext *pContext)
{
	if (pContext == NULL) {
		DBG_PRINT_TP("pContext is NULL.");
		return FALSE;
	}

	TPControllerSpec remoteSpec;

	memset(&remoteSpec, 0, sizeof(remoteSpec));
	remoteSpec.capabilities	= TP_CONTROLLER_HAS_KEYS;
	remoteSpec.key_map		= _gKeyMap;

	_gpRemoteController = tp_context_add_controller(pContext, "RemoteController", &remoteSpec, NULL);

	return (_gpRemoteController != NULL);
}

#ifdef INCLUDE_MOUSE
static TPController *_gpMouseController = NULL;

static void _TP_MouseEventCallback(SINT32 dx, SINT32 dy, UINT32 button_val, UINT32 gesture_ptr)
{
}

static void _TP_MouseGetParam(char req_type, UINT32 *nParam1, UINT32 *nParam2, UINT32 *nParam3, UINT32 *nParam4)
{
}

static BOOLEAN _TP_AddMouseController(TPContext *pContext)
{
	if (pContext == NULL) {
		DBG_PRINT_TP("pContext is NULL.");
		return FALSE;
	}

	TPControllerSpec mouseSpec;

	memset(&mouseSpec, 0, sizeof(mouseSpec));
	mouseSpec.capabilities	= TP_CONTROLLER_HAS_CLICLS;

	_gpMouseController = tp_context_add_controller(pContext, "MouseController", &mouseSpec, NULL);

	return (_gpMouseController != NULL);
}
#endif

BOOLEAN TP_Controller_Initialize(TPContext *pContext)
{
	DBG_PRINT_TP();

	if (pContext == NULL) {
		DBG_PRINT_TP("pContext is NULL.");
		return FALSE;
	}

	// add remote controller
	if (!_TP_AddRemoteController(pContext)) {
		DBG_PRINT_TP("fail to add remote controller.");
		return FALSE;
	}

#ifdef INCLUDE_MOUSE
	// add mouse controller
	if (!_TP_AddMouseController(pContext)) {
		DBG_PRINT_TP("fail to add mouse controller.");
		return FALSE;
	}
#endif

#ifndef INCLUDE_MOUSE
	API_UTIL_InitUIMessagingSystem(NULL, NULL, _TP_KeyEventCallback);
#else
	API_UTIL_InitUIMessagingSystem(NULL, NULL, _TP_KeyEventCallback, _TP_MouseEventCallback, _TP_MouseGetParam);
#endif

	return TRUE;
}


#include <string.h>

#include <addon_key.h>

#include <trickplay/keys.h>
#include <trickplay/controller.h>

#include "tp_common.h"
#include "tp_controller.h"


static TPControllerKeyMap _gKeyMap[] =
{
	// general buttons
	{ AO_IR_KEY_LEFT_ARROW,		TP_KEY_LEFT },
	{ AO_IR_KEY_UP_ARROW,		TP_KEY_UP },
	{ AO_IR_KEY_RIGHT_ARROW,	TP_KEY_RIGHT },
	{ AO_IR_KEY_DOWN_ARROW,		TP_KEY_DOWN },
	{ AO_IR_KEY_ENTER,			TP_KEY_RETURN },
	{ AO_IR_KEY_EXIT,			TP_KEY_EXIT },

	{ AO_IR_KEY_0,				TP_KEY_0 },
	{ AO_IR_KEY_1,				TP_KEY_1 },
	{ AO_IR_KEY_2,				TP_KEY_2 },
	{ AO_IR_KEY_3,				TP_KEY_3 },
	{ AO_IR_KEY_4,				TP_KEY_4 },
	{ AO_IR_KEY_5,				TP_KEY_5 },
	{ AO_IR_KEY_6,				TP_KEY_6 },
	{ AO_IR_KEY_7,				TP_KEY_7 },
	{ AO_IR_KEY_8,				TP_KEY_8 },
	{ AO_IR_KEY_9,				TP_KEY_9 },

	// Vendor extensions

	// Color buttons
	{ AO_IR_KEY_RED,			TP_KEY_RED },
	{ AO_IR_KEY_GREEN,			TP_KEY_GREEN },
	{ AO_IR_KEY_YELLOW,			TP_KEY_YELLOW },
	{ AO_IR_KEY_BLUE,			TP_KEY_BLUE },

	// Transport control
	{ AO_IR_KEY_STOP,			TP_KEY_STOP },
	{ AO_IR_KEY_PLAY,			TP_KEY_PLAY },
	{ AO_IR_KEY_PAUSE,			TP_KEY_PAUSE },
	{ AO_IR_KEY_REW,			TP_KEY_REW },
	{ AO_IR_KEY_FF,				TP_KEY_FFWD },
	{ AO_IR_KEY_GOTOPREV,		TP_KEY_PREV },
	{ AO_IR_KEY_GOTONEXT,		TP_KEY_NEXT },
	{ AO_IR_KEY_REC,			TP_KEY_REC },

	// Navigation
	{ AO_IR_KEY_MENU,			TP_KEY_MENU },
	{ AO_IR_KEY_GRIDGUIDE,		TP_KEY_GUIDE },
	{ AO_IR_KEY_BACK,			TP_KEY_BACK },
	{ AO_IR_KEY_EXIT,			TP_KEY_EXIT },
	{ AO_IR_KEY_INFO,			TP_KEY_INFO },
//	{ 0,						TP_KEY_TOOLS },

	// Channels
	{ AO_IR_KEY_CH_UP,			TP_KEY_CHAN_UP },
	{ AO_IR_KEY_CH_DOWN,		TP_KEY_CHAN_DOWN },
//	{ 0,						TP_KEY_CHAN_LAST },
	{ AO_IR_KEY_PRLIST,			TP_KEY_CHAN_LIST },
	{ AO_IR_KEY_FAVORITE,		TP_KEY_CHAN_FAV },

	// Audio
	{ AO_IR_KEY_VOL_UP,			TP_KEY_VOL_UP },
	{ AO_IR_KEY_VOL_DOWN,		TP_KEY_VOL_DOWN },
	{ AO_IR_KEY_MUTE,			TP_KEY_MUTE },

	// Captions
	{ AO_IR_KEY_CC,				TP_KEY_CC },

	{ 0,						0 }
};

static TPController	*_gpRemoteController = NULL;

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

static void _TP_RemoveRemoteController(TPContext *pContext)
{
	if (pContext == NULL)
		return;

	if (_gpRemoteController != NULL) {
		tp_context_remove_controller(pContext, _gpRemoteController);
		_gpRemoteController = NULL;
	}
}

#ifdef INCLUDE_MOUSE
static TPController	*_gpMouseController	 = NULL;

static BOOLEAN _TP_AddMouseController(TPContext *pContext)
{
	if (pContext == NULL) {
		DBG_PRINT_TP("pContext is NULL.");
		return FALSE;
	}

	TPControllerSpec mouseSpec;

	memset(&mouseSpec, 0, sizeof(mouseSpec));
	mouseSpec.capabilities	= TP_CONTROLLER_HAS_CLICKS;

	_gpMouseController = tp_context_add_controller(pContext, "MouseController", &mouseSpec, NULL);

	return (_gpMouseController != NULL);
}

static void _TP_RemoveMouseController(TPContext *pContext)
{
	if (pContext == NULL)
		return;

	if (_gpMouseController != NULL) {
		tp_context_remove_controller(pContext, _gpMouseController);
		_gpMouseController = NULL;
	}
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

	return TRUE;
}

void TP_Controller_Finalize(TPContext *pContext)
{
	DBG_PRINT_TP();

	if (pContext == NULL) {
		DBG_PRINT_TP("pContext is NULL.");
		return;
	}

	// remove remote controller
	_TP_RemoveRemoteController(pContext);

#ifdef INCLUDE_MOUDE
	// remove mouse controller
	_TP_RemoveMouseController(pContext);
#endif
}

BOOLEAN TP_KeyEventCallback(UINT32 key, ADDON_KEY_COND_T keyCond)
{
	if ((_gpRemoteController == NULL) || (keyCond >= ADDON_KEY_COND_LAST))
		return FALSE;

	DBG_PRINT_TP("KeyEvent: Key(%#x) KeyCond(%u)", key, keyCond);

	switch (keyCond) {
		case ADDON_KEY_PRESS:
			tp_controller_key_down(_gpRemoteController, key, 0);
			break;
		case ADDON_KEY_RELEASE:
			tp_controller_key_up(_gpRemoteController, key, 0);
			break;
		case ADDON_KEY_REPEAT:
			tp_controller_key_down(_gpRemoteController, key, 0);
			break;
		default:
			return FALSE;
	}

	return TRUE;
}

#ifdef INCLUDE_MOUSE
BOOLEAN TP_MouseEventCallback(SINT32 posX, SINT32 posY, UINT32 keyCode, ADDON_KEY_COND_T keyCond)
{
	// [TODO]
	return FALSE;
}
#endif


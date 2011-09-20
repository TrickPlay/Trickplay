#include <string.h>

#include "tp_common.h"
#include "tp_controller.h"

#include <addon_key.h>

#include <trickplay/keys.h>
#include <trickplay/controller.h>


static TPControllerKeyMap _gRemoteKeyMap[] =
{
	/*----------------------------------------------
	  General buttons
	 */
	{ AO_IR_KEY_LEFT_ARROW,		TP_KEY_LEFT },
	{ AO_IR_KEY_UP_ARROW,		TP_KEY_UP },
	{ AO_IR_KEY_RIGHT_ARROW,	TP_KEY_RIGHT },
	{ AO_IR_KEY_DOWN_ARROW,		TP_KEY_DOWN },
	{ AO_IR_KEY_ENTER,			TP_KEY_RETURN },
	{ AO_IR_KEY_EXIT,			TP_KEY_ESCAPE },

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

	/*----------------------------------------------
	  Vendor extensions
	 */

	/* Color buttons */
	{ AO_IR_KEY_RED,			TP_KEY_RED },
	{ AO_IR_KEY_GREEN,			TP_KEY_GREEN },
	{ AO_IR_KEY_YELLOW,			TP_KEY_YELLOW },
	{ AO_IR_KEY_BLUE,			TP_KEY_BLUE },

	/* Transport control */
	{ AO_IR_KEY_STOP,			TP_KEY_STOP },
	{ AO_IR_KEY_PLAY,			TP_KEY_PLAY },
	{ AO_IR_KEY_PAUSE,			TP_KEY_PAUSE },
	{ AO_IR_KEY_REW,			TP_KEY_REW },
	{ AO_IR_KEY_FF,				TP_KEY_FFWD },
	{ AO_IR_KEY_GOTOPREV,		TP_KEY_PREV },
	{ AO_IR_KEY_GOTONEXT,		TP_KEY_NEXT },
	{ AO_IR_KEY_REC,			TP_KEY_REC },

	/* Navigation */
	{ AO_IR_KEY_MENU,			TP_KEY_MENU },
	{ AO_IR_KEY_GRIDGUIDE,		TP_KEY_GUIDE },
	{ AO_IR_KEY_BACK,			TP_KEY_BACK },
	{ AO_IR_KEY_EXIT,			TP_KEY_EXIT },
	{ AO_IR_KEY_INFO,			TP_KEY_INFO },
/*	{ 0,						TP_KEY_TOOLS },*/

	/* Channels */
	{ AO_IR_KEY_CH_UP,			TP_KEY_CHAN_UP },
	{ AO_IR_KEY_CH_DOWN,		TP_KEY_CHAN_DOWN },
	{ AO_IR_KEY_FLASHBACK,		TP_KEY_CHAN_LAST },
	{ AO_IR_KEY_PRLIST,			TP_KEY_CHAN_LIST },
	{ AO_IR_KEY_FAVORITE,		TP_KEY_CHAN_FAV },

	/* Audio */
	{ AO_IR_KEY_VOL_UP,			TP_KEY_VOL_UP },
	{ AO_IR_KEY_VOL_DOWN,		TP_KEY_VOL_DOWN },
	{ AO_IR_KEY_MUTE,			TP_KEY_MUTE },

	/* Captions */
	{ AO_IR_KEY_CC,				TP_KEY_CC },

	{ 0,						0 }
};

static TPController* _gpRemoteController = NULL;

static BOOLEAN _Controller_AddRemoteController(TPContext* pContext)
{
	if (pContext == NULL)
		return FALSE;

	TPControllerSpec remoteSpec;

	memset(&remoteSpec, 0, sizeof(remoteSpec));
	remoteSpec.capabilities		= TP_CONTROLLER_HAS_KEYS;
	remoteSpec.key_map			= _gRemoteKeyMap;

	_gpRemoteController =
		tp_context_add_controller(
				pContext,
				"RemoteController", &remoteSpec,
				NULL);

	return (_gpRemoteController != NULL);
}

static void _Controller_RemoveRemoteController(TPContext* pContext)
{
	if (pContext == NULL)
		return;

	if (_gpRemoteController != NULL)
	{
		tp_context_remove_controller(pContext, _gpRemoteController);
		_gpRemoteController = NULL;
	}
}

#ifdef MOUSE_SUPPORTED
static TPController* _gpMouseController	= NULL;
static BOOLEAN		 _gbMouseEnabled;

static int _Controller_MouseCommandReceiver(
		TPController* pMouseController,
		unsigned int command,
		void* pParams, void* pUserData)
{
	int res = -1;

	if (pMouseController != _gpMouseController)
		return res;

	switch (command)
	{
		case TP_CONTROLLER_COMMAND_RESET:
			_gbMouseEnabled = FALSE;
			return 0;

		case TP_CONTROLLER_COMMAND_START_POINTER:
			_gbMouseEnabled = TRUE;
			return 0;

		case TP_CONTROLLER_COMMAND_STOP_POINTER:
			_gbMouseEnabled = FALSE;
			return 0;
	}

	return -1;
}

static BOOLEAN _Controller_AddMouseController(TPContext* pContext)
{
	if (pContext == NULL)
		return FALSE;

	TPControllerSpec mouseSpec;

	memset(&mouseSpec, 0, sizeof(mouseSpec));
	mouseSpec.capabilities		= TP_CONTROLLER_HAS_POINTER;
	mouseSpec.execute_command	= _Controller_MouseCommandReceiver;

	_gpMouseController =
		tp_context_add_controller(
				pContext,
				"MouseController", &mouseSpec,
				NULL);
	_gbMouseEnabled = FALSE;

	return (_gpMouseController != NULL);
}

static void _Controller_RemoveMouseController(TPContext* pContext)
{
	if (pContext == NULL)
		return;

	if (_gpMouseController != NULL)
	{
		tp_context_remove_controller(pContext, _gpMouseController);
		_gpMouseController = NULL;
	}

	_gbMouseEnabled = FALSE;
}
#endif

BOOLEAN TP_Controller_Initialize(TPContext* pContext)
{
	DBG_PRINT_TP(NULL);

	if (pContext == NULL)
		return FALSE;

	/* Add remote controller */
	if (!_Controller_AddRemoteController(pContext))
	{
		DBG_PRINT_TP("fail to add remote controller.");
		return FALSE;
	}

#ifdef MOUSE_SUPPORTED
	/* Add mouse controller */
	if (!_Controller_AddMouseController(pContext))
	{
		DBG_PRINT_TP("fail to add mouse controller.");
		return FALSE;
	}
#endif

	return TRUE;
}

void TP_Controller_Finalize(TPContext* pContext)
{
	DBG_PRINT_TP(NULL);

	if (pContext == NULL)
		return;

	/* Remove remote controller */
	_Controller_RemoveRemoteController(pContext);

#ifdef MOUSE_SUPPORTED
	/* Remove mouse controller */
	_Controller_RemoveMouseController(pContext);
#endif
}

BOOLEAN TP_Controller_KeyEventCallback(UINT32 key, ADDON_KEY_COND_T keyCond)
{
	if ((_gpRemoteController == NULL) || (keyCond >= ADDON_KEY_COND_LAST))
		return FALSE;

	DBG_PRINT_TP("KeyEvent: Key(%#4x) / KeyCond(%u)", key, keyCond);

	switch (keyCond)
	{
		case ADDON_KEY_PRESS:
			tp_controller_key_down(_gpRemoteController, key, 0,0);
			break;
		case ADDON_KEY_RELEASE:
			tp_controller_key_up(_gpRemoteController, key, 0,0);
			break;
		case ADDON_KEY_REPEAT:
			tp_controller_key_down(_gpRemoteController, key, 0,0);
			break;
		default:
			return FALSE;
	}

	return TRUE;
}

#ifdef MOUSE_SUPPORTED

BOOLEAN	TP_Controller_MouseEventCallback(
		SINT32 posX, SINT32 posY,
		UINT32 keyCode, ADDON_KEY_COND_T keyCond)
{
	if (!_gbMouseEnabled)
		return FALSE;

	if ((keyCode == AO_RF_KEY_NONE) || (keyCond == ADDON_KEY_COND_LAST))
	{
		tp_controller_pointer_move(_gpMouseController, posX, posY,0);
		return TRUE;
	}

	DBG_PRINT_TP("MouseEvent: X-pos(%4d) / Y-pos(%4d) / Key(%#4x) / KeyCond(%u)",
			posX, posY, keyCode, keyCond);

	int tpButton = 0;

	/* Currently just the OK key of MotionRemote can be handled in mouse event callback.
	   Other key events of MotionRemote are sent to key event callback. */
	if (keyCode == AO_RF_KEY_OK)
		tpButton = 1;

	switch (keyCond)
	{
		case ADDON_KEY_PRESS:
			tp_controller_pointer_button_down(_gpMouseController, tpButton, posX, posY,0);
			break;
		case ADDON_KEY_RELEASE:
			tp_controller_pointer_button_up(_gpMouseController, tpButton, posX, posY,0);
			break;
		case ADDON_KEY_REPEAT:
			tp_controller_pointer_button_down(_gpMouseController, tpButton, posX, posY,0);
			break;
		default:
			return FALSE;
	}

	return TRUE;
}

#ifdef USE_MOUSE_RAW_DATA
BOOLEAN	TP_Controller_MouseDirectEventCallback(
		float fRelX, float fRelY, float fAbsX, float fAbsY,
		MOTION_DATA_T* psMotion)
{
	return FALSE;
}

BOOLEAN	TP_Controller_MousePairingCheckCallback(BOOLEAN bPairing)
{
	return FALSE;
}
#endif /* USE_MOUSE_RAW_DATA */

#endif /* MOUSE_SUPPORTED */


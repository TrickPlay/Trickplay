#include <trickplay/mediaplayer.h>

#include "tp_mediaplayer.h"


BOOLEAN TP_MediaPlayer_Initialize(TPContext *pContext)
{
	DBG_PRINT_TP();

	if (pContext == NULL) {
		DBG_PRINT_TP("pContext is NULL.");
		return FALSE;
	}

	DBG_PRINT_TP("Media Player is not implemented.");
	return TRUE;
}


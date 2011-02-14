#ifndef __TP_CONTROLLER_H__
#define __TP_CONTROLLER_H__

#include <addon_types.h>

#include <trickplay/trickplay.h>


BOOLEAN	TP_Controller_Initialize(TPContext *pContext);
void	TP_Controller_Finalize(TPContext *pContext);

BOOLEAN TP_KeyEventCallback(UINT32 key, ADDON_KEY_COND_T keyCond);
#ifdef INCLUDE_MOUSE
BOOLEAN TP_MouseEventCallback(SINT32 posX, SINT32 posY, UINT32 keyCode, ADDON_KEY_COND_T keyCond);
#endif

#endif

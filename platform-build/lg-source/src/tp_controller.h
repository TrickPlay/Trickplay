#ifndef __TP_CONTROLLER_H__
#define __TP_CONTROLLER_H__

#include <sys/stat.h>

#include <appfrwk_openapi_types.h>

#include <trickplay/trickplay.h>

#ifdef __cplusplus
extern "C" {
#endif

BOOLEAN	TP_Controller_Initialize(TPContext* pContext);
void	TP_Controller_Finalize(TPContext* pContext);

BOOLEAN TP_Controller_KeyEventCallback(UINT32 key, PM_KEY_COND_T keyCond, PM_ADDITIONAL_INPUT_INFO_T event);
#ifdef MOUSE_SUPPORTED
BOOLEAN	TP_Controller_MouseEventCallback(
		SINT32 posX, SINT32 posY, UINT32 keyCode, PM_KEY_COND_T keyCond, PM_ADDITIONAL_INPUT_INFO_T event);
#  ifdef USE_MOUSE_RAW_DATA
BOOLEAN	TP_Controller_MouseDirectEventCallback(
		float fRelX, float fRelY, float fAbsX, float fAbsY,
		MOTION_DATA_T* psMotion);
BOOLEAN	TP_Controller_MousePairingCheckCallback(BOOLEAN bPairing);
#  endif
#endif

#ifdef __cplusplus
}
#endif

#endif /* __TP_CONTROLLER_H__ */


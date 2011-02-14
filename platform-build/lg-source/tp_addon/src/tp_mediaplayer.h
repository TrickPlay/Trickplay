#ifndef __TP_MEDIEPLAYER_H__
#define __TP_MEDIEPLAYER_H__

#include <addon_types.h>
#include <addon_hoa.h>

#include <trickplay/trickplay.h>


BOOLEAN	TP_MediaPlayer_Initialize(TPContext *pContext);
void	TP_MediaPlayer_Finalize(TPContext *pContext);

#endif

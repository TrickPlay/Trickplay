#ifndef __TP_PLAYCLIP_H__
#define __TP_PLAYCLIP_H__

#include <addon_types.h>

#include <trickplay/trickplay.h>

#ifdef __cplusplus
extern "C" {
#endif

BOOLEAN	TP_PlayClip_Initialize(TPContext* pContext);
void	TP_PlayClip_Finalize(TPContext* pContext);

int		TP_PlayClip_Play(TPMediaPlayer* pMP);
int		TP_PlayClip_Seek(TPMediaPlayer* pMP, double seconds);
int		TP_PlayClip_Pause(TPMediaPlayer* pMP);

int		TP_PlayClip_PlaySound(TPMediaPlayer* pMp, const char* szURI);

#ifdef __cplusplus
}
#endif

#endif /* __TP_PLAYCLIP_H__ */


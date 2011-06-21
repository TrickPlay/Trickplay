#ifndef __TP_PLAYSTREAM_H__
#define __TP_PLAYSTREAM_H__

#include <addon_types.h>

#include <trickplay/trickplay.h>

#ifdef __cplusplus
extern "C" {
#endif

BOOLEAN	TP_PlayStream_Initialize(TPContext* pContext);
void	TP_PlayStream_Finalize(TPContext* pContext);

int		TP_PlayStream_Play(TPMediaPlayer* pMP);
int		TP_PlayStream_Seek(TPMediaPlayer* pMP, double seconds);
int		TP_PlayStream_Pause(TPMediaPlayer* pMP);

#ifdef __cplusplus
}
#endif

#endif /* __TP_PLAYSTREAM_H__ */


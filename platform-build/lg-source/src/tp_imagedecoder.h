#ifndef __TP_IMAGEDECODER_H__
#define __TP_IMAGEDECODER_H__

#include <addon_types.h>

#include <trickplay/trickplay.h>

#ifdef __cplusplus
extern "C" {
#endif

BOOLEAN TP_ImageDecoder_Initialize(TPContext* pContext);
void	TP_ImageDecoder_Finalize(TPContext* pContext);

#ifdef __cplusplus
}
#endif

#endif /* __TP_IMAGEDECODER_H__ */


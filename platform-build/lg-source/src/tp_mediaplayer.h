#ifndef __TP_MEDIEPLAYER_H__
#define __TP_MEDIEPLAYER_H__

#include <addon_types.h>

#include <trickplay/trickplay.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct tagMediaInfoType {
	const char*			szURI;
	MEDIA_TRANSPORT_T	transType;
	MEDIA_FORMAT_T		formatType;
	MEDIA_CODEC_T		codecType;

	HOA_RECT_T			viewport;
} TP_MEDIA_INFO_T;

BOOLEAN				TP_MediaPlayer_Initialize(TPContext* pContext);
void				TP_MediaPlayer_Finalize(TPContext* pContext);

MEDIA_TRANSPORT_T	TP_MediaPlayer_GetTransportType(const char* szURI);
MEDIA_FORMAT_T		TP_MediaPlayer_GetFormatType(const char* szURI);
MEDIA_CODEC_T		TP_MediaPlayer_GetCodecType(const char* szURI);

BOOLEAN				TP_MediaPlayer_IsMainChAvailable(void);

#ifdef __cplusplus
}
#endif

#endif /* __TP_MEDIEPLAYER_H__ */


#ifndef __TP_OPENGLES_H__
#define __TP_OPENGLES_H__

#include <EGL/eglplatform.h>

#include <addon_types.h>
#include <addon_hoa.h>

#define OPENGLES_WINDOW_ATTRIB_X			0x1000
#define OPENGLES_WINDOW_ATTRIB_Y			0x1001
#define OPENGLES_WINDOW_ATTRIB_WIDTH		0x1002
#define OPENGLES_WINDOW_ATTRIB_HEIGHT		0x1003
#define OPENGLES_WINDOW_ATTRIB_STRETCH		0x1004
#define OPENGLES_WINDOW_ATTRIB_FORMAT		0x1005
#define OPENGLES_WINDOW_ATTRIB_NONE			0x1fff

#ifdef __cplusplus
extern "C" {
#endif

BOOLEAN				TP_OpenGLES_Initialize(const UINT32* pAttrList);
void				TP_OpenGLES_Finalize(void);

EGLNativeWindowType	TP_OpenGLES_GetEGLNativeWindow(void);

#ifdef __cplusplus
}
#endif

#endif /* __TP_OPENGLES_H__ */


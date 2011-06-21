#ifndef __TP_DRM_H__
#define __TP_DRM_H__

#ifdef __cplusplus
extern "C" {
#endif

BOOLEAN	TP_DRM_DecryptAppToPath(
		const UINT32 appID,
		const char *appPath, const char *targetPath);

#ifdef __cplusplus
}
#endif

#endif /* __TP_DRM_H__ */


#ifndef __TP_DRM_H__
#define __TP_DRM_H__

#ifdef __cplusplus
extern "C" {
#endif

// TODO sanggi0.lee - remove
#if 0
BOOLEAN	TP_DRM_DecryptAppToPath(
		const UINT32 appID,
		const char *appPath, const char *targetPath);
#endif

int TP_DRM_resource_loader(
	TPContext * context ,
	unsigned int resource_type,
	const char * filename,
	TPResourceReader * reader,
	void * user_data );

#ifdef __cplusplus
}
#endif

#endif /* __TP_DRM_H__ */


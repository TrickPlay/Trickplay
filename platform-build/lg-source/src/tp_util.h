#ifndef __TP_UTIL_H__
#define __TP_UTIL_H__

#include <stdio.h>
#include <sys/time.h>

#include <addon_types.h>

typedef struct timeval	TP_TIMESTAMP_T;

#ifdef __cplusplus
extern "C" {
#endif

BOOLEAN			TP_Util_IsDirectory(const char* szPath);
long			TP_Util_GetFileSize(FILE* fp);

TP_TIMESTAMP_T	TP_Util_GetTimestamp(void);
float			TP_Util_GetElapsedTime(TP_TIMESTAMP_T start, TP_TIMESTAMP_T end);

int TP_Util_DebugPrint(
		const char* szFunc,
		const char* szFile,
		int line,
		const char* szFormat,
		...);

#ifdef __cplusplus
}
#endif

#endif

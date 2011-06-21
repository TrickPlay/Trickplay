#include <stdarg.h>
#include <string.h>
#include <assert.h>
#include <sys/stat.h>

#include "tp_common.h"
#include "tp_util.h"


BOOLEAN TP_Util_IsDirectory(const char* szPath)
{
	if (szPath == NULL)
		DBG_PRINT_TP("path argument is NULL.");
	assert(szPath != NULL);

	struct stat statbuf;

	if (stat(szPath, &statbuf) != 0)
	{
		DBG_PRINT_TP("stat() failed. (%s)", szPath);
		return FALSE;
	}

	return S_ISDIR(statbuf.st_mode);
}

long TP_Util_GetFileSize(FILE* fp)
{
	if (fp == NULL)
		return -1;

	long endOffset;
	long curOffset = ftell(fp);

	fseek(fp, 0, SEEK_END);
	endOffset = ftell(fp);
	fseek(fp, curOffset, SEEK_SET);

	return endOffset;
}

TP_TIMESTAMP_T TP_Util_GetTimestamp(void)
{
	TP_TIMESTAMP_T timestamp;

	gettimeofday(&timestamp, NULL);

	return timestamp;
}

float TP_Util_GetElapsedTime(TP_TIMESTAMP_T start, TP_TIMESTAMP_T end)
{
	int sec	 = end.tv_sec - start.tv_sec;
	int usec = end.tv_usec - start.tv_usec;
	float result;

	result = usec;
	result /= (1000 * 1000);
	result += sec;

	return result;
}

int TP_Util_DebugPrint(
		const char* szFunc,
		const char* szFile,
		int line,
		const char* szFormat,
		...)
{
#ifndef _TP_DEBUG
	return 0;
#endif

	static const char *szPrefix = "TP: %.30s(%.12s:%3d)] ";
	char szBuffer[256];
	va_list list;

	sprintf(szBuffer, szPrefix, szFunc, szFile, line);

	if (szFormat == NULL)
	{
		strcat(szBuffer, "\n");
		return fprintf(stderr, szBuffer);
	}

	strcat(szBuffer, szFormat);
	strcat(szBuffer, "\n");

	va_start(list, szFormat);

	return vfprintf(stderr, szBuffer, list);
}


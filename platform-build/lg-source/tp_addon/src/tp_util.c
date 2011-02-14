#include <sys/time.h>

#include "tp_common.h"
#include "tp_util.h"


static struct timeval _gStart, _gEnd;

void TP_Util_StartTimer(void)
{
	gettimeofday(&_gStart, NULL);
}

void TP_Util_EndTimer(void)
{
	gettimeofday(&_gEnd, NULL);
}

float TP_Util_GetElapsedTime(void)
{
	int sec = _gEnd.tv_sec - _gStart.tv_sec;
	int usec = _gEnd.tv_usec - _gStart.tv_usec;
	float result;

	result = usec;
	result /= (1000 * 1000);
	result += sec;

	return result;
}


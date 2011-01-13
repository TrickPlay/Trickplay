#include <sys/time.h>

#include "tp_common.h"
#include "tp_util.h"


static struct timeval _gStart[64], _gEnd[64];
static int _gDepth = 0;

void RS_Debug_StartTimer(void)
{
	gettimeofday(&_gStart[_gDepth], NULL);

	++_gDepth;
	if (_gDepth > 63)
		_gDepth = 63;
}

void RS_Debug_EndTimer(void)
{
	--_gDepth;
	if (_gDepth < 0)
		_gDepth = 0;

	gettimeofday(&_gEnd[_gDepth], NULL);
}

float RS_Debug_GetElapsedTime(void)
{
	int sec = _gEnd[_gDepth].tv_sec - _gStart[_gDepth].tv_sec;
	int usec = _gEnd[_gDepth].tv_usec - _gStart[_gDepth].tv_usec;
	float result;

	result = usec;
	result /= 1000000;
	result += sec;

	return result;
}


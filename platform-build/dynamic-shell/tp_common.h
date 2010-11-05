#ifndef __TP_COMMON_H__
#define __TP_COMMON_H__

#include <stdio.h>

#include "common.h"

#ifndef DBG_PRINT_TP
#	ifdef _TP_DEBUG
#		define DBG_PRINT_TP(format, arg...)		printf("TrickPlay: %s(%d)] "format"\n", __FUNCTION__, __LINE__, ##arg)
#	else
#		define DBG_PRINT_TP(format, arg...)
#	endif
#endif

#endif


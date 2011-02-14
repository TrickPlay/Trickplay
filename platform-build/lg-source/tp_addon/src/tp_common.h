#ifndef __TP_COMMON_H__
#define __TP_COMMON_H__

#include <stdio.h>

#ifndef DBG_PRINT_TP
#	ifdef _TP_DEBUG
#		define	DBG_PRINT_TP(format, arg...)	fprintf(stderr, "TP: %.25s(%.8s:%d)] "format"\n", __FUNCTION__, __FILE__, __LINE__, ##arg)
#	else
#		define	DBG_PRINT_TP(format, arg...)
#	endif
#endif

#endif

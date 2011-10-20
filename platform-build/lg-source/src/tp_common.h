#ifndef __TP_COMMON_H__
#define __TP_COMMON_H__

#include <appfrwk_common_dbgfrwk.h>

#ifndef DBG_PRINT_TP
extern int TP_Util_DebugPrint(
		const char* szFunc, const char* szFile, int line,
		const char* szFormat, ...);
#if 0
#define DBG_PRINT_TP(format, arg...) dbgprint(format,##arg)
#else
#define	DBG_PRINT_TP(format, arg...)	\
	TP_Util_DebugPrint(__FUNCTION__, __FILE__, __LINE__, format, ##arg)
#endif
#endif

#endif /* __TP_COMMON_H__ */


/*
** ===========================================================================
**
**	Project	:	AccessUsb Interface library for TV
**	Author	:	MCurix Inc.
**	Version :	0.9.0 (1)
**	Created	:	2011-07-14
**	Description: 
**  Revision:  
**	
** ===========================================================================
*/
/////////////////////////////// aui_lib_tv.h /////////////////////////////////
#ifndef _AUI_LIB_TV_H_
#define _AUI_LIB_TV_H_

#include "aui_error_code.h"


#ifdef __cplusplus
extern "C" {
#endif

//---------------------------------------------------------
// Library version Structure
//---------------------------------------------------------
typedef struct _AUI_LIB_INFO {
	int		major;
	int		minor;
	int		revision;
	int		rebuild;	
} AUI_LIB_INFO;


//---------------------------------------------------------
// 버전 정보 획득
//---------------------------------------------------------
int aui_getLibInfo(AUI_LIB_INFO* pLibInfo);

//---------------------------------------------------------
// 라이브러리 초기화 및 해지
//---------------------------------------------------------
int aui_initLib(void* pInit);
int aui_releaseLib(void* pArgs);

//---------------------------------------------------------
// AccessUSB 검색 및 연결
//---------------------------------------------------------
int aui_openAccessUsb(void);

//---------------------------------------------------------
// AccessUSB의 남은 사용시간 및 사용 가능 획수 정보 획득
// (해당 정보를 가져오기 위한 함수입니다. 실제 검증은
//  aui_verifyAccessPermit 함수를 통해서 합니다.)
//  CheckOption : 1 - 남은 시간 검증(단위, 초)
//                2 - 남은 횟수 검증
//                3 - 시간 & 횟수
//---------------------------------------------------------
int aui_getValidationInfo(int *t_nChkOpt, int *t_nTimeLeft, int *t_nCountLeft);

//---------------------------------------------------------
// AccessUSB 유효성 검증 (AUI_R_SUCCESS 반환 성공)
// 검증 절차: 1. aui_initLib
//            2. aui_openAccessUsb
//            3. aui_verifyAccessPermit
//            4. aui_releaseLib
//---------------------------------------------------------
int aui_verifyAccessPermit(char *szPwd);

#ifdef __cplusplus
}
#endif

#endif

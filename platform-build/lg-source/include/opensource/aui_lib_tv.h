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
// ���� ���� ȹ��
//---------------------------------------------------------
int aui_getLibInfo(AUI_LIB_INFO* pLibInfo);

//---------------------------------------------------------
// ���̺귯�� �ʱ�ȭ �� ����
//---------------------------------------------------------
int aui_initLib(void* pInit);
int aui_releaseLib(void* pArgs);

//---------------------------------------------------------
// AccessUSB �˻� �� ����
//---------------------------------------------------------
int aui_openAccessUsb(void);

//---------------------------------------------------------
// AccessUSB�� ���� ���ð� �� ��� ���� ȹ�� ���� ȹ��
// (�ش� ������ �������� ���� �Լ��Դϴ�. ���� ������
//  aui_verifyAccessPermit �Լ��� ���ؼ� �մϴ�.)
//  CheckOption : 1 - ���� �ð� ����(����, ��)
//                2 - ���� Ƚ�� ����
//                3 - �ð� & Ƚ��
//---------------------------------------------------------
int aui_getValidationInfo(int *t_nChkOpt, int *t_nTimeLeft, int *t_nCountLeft);

//---------------------------------------------------------
// AccessUSB ��ȿ�� ���� (AUI_R_SUCCESS ��ȯ ����)
// ���� ����: 1. aui_initLib
//            2. aui_openAccessUsb
//            3. aui_verifyAccessPermit
//            4. aui_releaseLib
//---------------------------------------------------------
int aui_verifyAccessPermit(char *szPwd);

#ifdef __cplusplus
}
#endif

#endif

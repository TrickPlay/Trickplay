#ifndef	_NCG_AGENT_H
#define _NCG_AGENT_H

#ifdef	_WIN32
#include <io.h>
#else
#include <unistd.h>
#endif

#include "NCG_Def.h"

#ifdef	DLL_EXPORT
#define DLLFUNC __declspec(dllexport)
#else
	#ifdef	DLL_IMPORT
	#define DLLFUNC __declspec(dllimport)
	#else
	#define DLLFUNC
	#endif
#endif

#ifdef  __cplusplus
extern "C" {
#endif

	struct stat;

	//////////////////////////////////////////////////////////////////
	//
	// NCG Agent Core System
	//
	//////////////////////////////////////////////////////////////////

	/*****************************************************************
	���: NCG Agent�� ������ ����Ѵ�.
			NCG_Init()�� ȣ������ �ʾƵ� ��� �����ϸ�,
			��ȯ�� ���� free()����� �Ѵ�.
	��ȯ: ���� ���ڿ�
	����: ����
	*****************************************************************/
	DLLFUNC OUT_ALLOC char* NCG_GetVersion(void);

	/*****************************************************************
	���: NCG Agent�� �ʱ�ȭ�Ѵ�.
			���ο� ���̼��� DB�� �����ϸ� �о�´�.
			��, ������ NCG_ReadCIDDB(), NCG_ReadSIDDB()��
			ȣ������ �ʾƵ� �ȴ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hCore			- �ʱ�ȭ�� �����ϸ� �ڵ��� �����Ѵ�.
			szDeviceID		- ����� ID. ������ ����� �Ѵ�.
			szDeviceModel	- ����� �𵨸�. ������ ����� �Ѵ�.
							��) iPhone, Nexus_One, ...
			szLicenseDBPath	- ���̼��� ���õ� ������ ������ ���.
							�ݵ�� '�б� �� ����'�� ������ ��ο��� �Ѵ�.
							iPhone�� ��� ����/Documents ����,
							Android�� ��� ���� ���� ���� ����ϸ� �ȴ�.
			nEnableSecureStorage	- ���ȿ��� ��� ���θ� �����Ѵ�.
							�̸� ����ϱ� ���ؼ��� �ܸ�����,
							������ ������ �� ���� ���ȿ����� �����ؾ� �Ѵ�.
							�̸� ������� ������ Ƚ������ ���ݴ��� �� �ִ�.
							�ڼ��� ������ ���� ���� ����.
	*****************************************************************/
	DLLFUNC int		NCG_Init(	OUT_HANDLE	NCG_Core_Handle	*hCore,	// do not free(), please NCG_Clear()
						const		char	*szDeviceID,
						const		char	*szDeviceModel,
						const		char	*szLicenseDBPath,
						const		int		nEnableSecureStorage);

	/*****************************************************************
	���: NCG Agent�� �����ϰ� ���õ� �޸𸮸� ��ȯ�Ѵ�.
	��ȯ: ����
	����:	hCore			- NCG_Agent �ڵ�.
	*****************************************************************/
	DLLFUNC void	NCG_Clear(IN_OUT	NCG_Core_Handle	*hCore);


	/*****************************************************************
	���: ���̼��� ��û�� ������ ���۵Ǵ� Device ID ���� ��ȣ����
			���θ� �����Ѵ�.
			�⺻���� Device ID�� ��ȣ�ϵ��� �Ǿ� �����Ƿ�,
			NCG_GetDeviceIDSecret(1)�� ���� ȣ������ �ʾƵ� �ȴ�.
			Device ID�� ��ȯ���� �ʰ� �ǵ������� �����ؾ� �ϴ� ��쿡
			NCG_GetDeviceIDSecret(0)�� ȣ���Ѵ�
	��ȯ: ����.
	����:	hCore					- NCG_Agent �ڵ�.
			nEnableSecureDeviceID	- 1 (DeviceID ��ȣ) �Ǵ� 0 (��ȣ X)
	*****************************************************************/
	DLLFUNC int		NCG_EnableSecretDeviceID(	const NCG_Core_Handle	hCore,
											const int	nEnableSecureDeviceID);

	/*****************************************************************
	���: ���̼��� ��û�� ������ ���۵Ǵ� Device ID ���� ���Ѵ�.
			Device ID ���� ������ ���� ���Ͽ�
			NCG_Init() ���� �Է��� Device ID��
			one-way �Լ��� ����Ͽ� ��ȯ�Ѵ�.
			���������� �� ������ ��⸦ �ĺ��Ѵ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hCore			- NCG_Agent �ڵ�.
			szDeviceIDSecret_MIN40	- ����(�� �ĺ�)�� Device ID.
			nDeviceIDSecretLen		- ����(�� �ĺ�)�� Device ID ����
	*****************************************************************/
	DLLFUNC int		NCG_GetDeviceIDSecret(	const NCG_Core_Handle	hCore,
									OUT_REF	char	*szDeviceIDSecret_MIN40,
						OPTIONAL	OUT_REF	int		*nDeviceIDSecretLen);


	//////////////////////////////////////////////////////////////////
	//
	// NCG Login
	//
	//////////////////////////////////////////////////////////////////

	/*****************************************************************
	���: NCG ���� �α��� ��û �޽����� �����Ѵ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hCore			- NCG_Agent �ڵ�.
			szUserID		- ����� ID.
			szPassword		- ��й�ȣ.
			szReqMsgBuf_MIN2048	- RO ��û �޼���.
			nReqMsgLen			- RO ��û �޽��� ����.
	*****************************************************************/
	DLLFUNC int		NCG_MakeLoginRequestMsg(const NCG_Core_Handle	hCore,
									const	char	*szUserID,
									const	char	*szPassword,
									OUT_REF	char	*szReqMsgBuf_MIN2048,
						OPTIONAL	OUT_REF	int		*nReqMsgLen);


	//////////////////////////////////////////////////////////////////
	//
	// NCG Right Object (License) Request - Response - Save
	//
	//////////////////////////////////////////////////////////////////

	/*****************************************************************
	���: NCG ������ ������ Contents RO ��û �޼����� �����Ѵ�.
			��ȯ�� szReqMsgBuf�� 
			��ȯ�� szAcquisitionURL �� POST �����ͷ� ��û�� ��
			������ �����Ѵ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hCore			- NCG_Agent �ڵ�.
			hFile			- RO�� ��û�� ���� �ڵ�. 
			szUserID		- ����� ID.
			szOrderID		- �ֹ� ID.
			szReqMsgBuf_MIN2048		- RO ��û �޼���.
			nReqMsgLen				- RO ��û �޽��� ����.
			szAcquisitionURL_MIN256	- RO ��û URL.
			nAcquisitionURLLen		- RO ��û URL ����.
	*****************************************************************/
	DLLFUNC int		NCG_MakeContentsRORequestMsg(	const NCG_Core_Handle	hCore,
											const NCG_File_Handle	hFile,
											const char		*szUserID,
								OPTIONAL	const char		*szOrderID,
											OUT_REF	char	*szReqMsgBuf_MIN2048,
								OPTIONAL	OUT_REF	int		*nReqMsgLen,
											OUT_REF char	*szAcquisitionURL_MIN256,
								OPTIONAL	OUT_REF	int		*nAcquisitionURLLen);

	/*****************************************************************
	���: NCG ������ ���Ͽ� ���� ������ ID, ���̼��� ��û URL�� �˰� ���� ��,
			�� ������ ����Ͽ� RO ��û �޽����� �����Ѵ�.
			��ȯ�� szReqMsgBuf�� ���̼��� ��û URL�� POST �����ͷ� ��û�� ��
			������ �����Ѵ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hCore			- NCG_Agent �ڵ�.
			szUserID		- ����� ID.
			szContentsID	- ������ ID.
			szOrderID		- �ֹ� ID.
			szReqMsgBuf_MIN2048	- RO ��û �޼���.
			nReqMsgLen			- RO ��û �޽��� ����.
	*****************************************************************/
	DLLFUNC int		NCG_MakeContentsRORequestMsgWithCID(const NCG_Core_Handle	hCore,
												const char		*szUserID,
												const char		*szContentsID,
									OPTIONAL	const char		*szOrderID,
												OUT_REF	char	*szReqMsgBuf_MIN2048,
									OPTIONAL	OUT_REF	int		*nReqMsgLen);

	/*****************************************************************
	���: NCG ������ ������ Site RO ��û �޼����� �����Ѵ�.
			��ȯ�� szReqMsgBuf�� 
			��ȯ�� szAcquisitionURL�� POST �����ͷ� ��û�� ��
			������ �����Ѵ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hCore			- NCG_Agent �ڵ�.
			hFile			- RO�� ��û�� ���� �ڵ�. 
			szUserID		- ����� ID.
			szOrderID		- �ֹ� ID.
			szFilename		- RO�� ��û�� ������ ���� �̸�.
			szReqMsgBuf_MIN2048		- RO ��û �޼���.
			nReqMsgLen				- RO ��û �޽��� ����.
			szAcquisitionURL_MIN256	- RO ��û URL.
			nAcquisitionURLLen		- RO ��û URL ����.
	*****************************************************************/
	DLLFUNC int		NCG_MakeSiteRORequestMsg(	const NCG_Core_Handle	hCore,
										const NCG_File_Handle	hFile,
										const char		*szUserID,
							OPTIONAL	const char		*szOrderID,
										OUT_REF	char	*szReqMsgBuf_MIN2048,
							OPTIONAL	OUT_REF	int		*nReqMsgLen,
										OUT_REF char	*szAcquisitionURL_MIN256,
							OPTIONAL	OUT_REF	int		*nAcquisitionURLLen);

	/*****************************************************************
	���: NCG ������ ���Ͽ� ���� Site ID, ���̼��� ��û URL�� �˰� ���� ��,
			�� ������ ����Ͽ� RO ��û �޽����� �����Ѵ�.
			��ȯ�� szReqMsgBuf�� ���̼��� ��û URL�� POST �����ͷ� ��û�� ��
			������ �����Ѵ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hCore			- NCG_Agent �ڵ�.
			szUserID		- ����� ID.
			szSiteID		- Site ID.
			szOrderID		- �ֹ� ID.
			szReqMsgBuf_MIN2048	- RO ��û �޼���.
			nReqMsgLen			- RO ��û �޽��� ����.
	*****************************************************************/
	DLLFUNC int		NCG_MakeSiteRORequestMsgWithSID(	NCG_Core_Handle	hCore,
												const char		*szUserID,
												const char		*szSiteID,
									OPTIONAL	const char		*szOrderID,
												OUT_REF	char	*szReqMsgBuf_MIN2048,
									OPTIONAL	OUT_REF	int		*nReqMsgLen);

	/*****************************************************************
	���: NCG ������ ���Ͽ� ���� Session ID, ���̼��� ��û URL�� �˰� ���� ��,
			�� ������ ����Ͽ� RO ��û �޽����� �����Ѵ�.
			��ȯ�� szReqMsgBuf�� ���̼��� ��û URL�� POST �����ͷ� ��û�� ��
			������ �����Ѵ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hCore			- NCG_Agent �ڵ�.
			szSessionID		- ���� ID.
			szReqMsgBuf_MIN2048	- RO ��û �޼���.
			nReqMsgLen			- RO ��û �޽��� ����.
	*****************************************************************/
	DLLFUNC int		NCG_MakeRORequestMsgWithSSID(	const NCG_Core_Handle	hCore,
											const char		*szSessionID,
											OUT_REF	char	*szReqMsgBuf_MIN2048,
								OPTIONAL	OUT_REF	int		*nReqMsgLen);


	/*****************************************************************
	���: �����κ��� ������ �޽��� Ÿ���� �з��Ѵ�.
			������ �޽����� �ݵ�� NULL �� ������ ���ڿ��̾�� �Ѵ�.
	��ȯ:	NCG_RESPONSE_TYPE_UNKNOWON	- �� �� ���� Ÿ��.
			NCG_RESPONSE_TYPE_LOGIN		- �α��ο� ���� ����.
			NCG_RESPONSE_TYPE_RO		- Right Object (License).
			NCG_RESPONSE_TYPE_OID		- �ֹ� ID ���.
			NCG_RESPONSE_TYPE_PURCHASE_URL	- ���� URL.
	����:	szROResMsg		- ������ RO �޼���
			nResponseCode	- ������ RO ���� �ڵ�
	*****************************************************************/
	DLLFUNC int		NCG_RecognizeResponseMsgType(	const char		*szResponseMsg,
											OUT_REF int		*nResponseCode);

	/*****************************************************************
	���: NCG_SaveROResponseMsg() ���� �Ľ��� RO�� Log�� ������� �����Ѵ�.
			bFlag�� 1�� ������ ���Ŀ� ȣ��Ǵ� �Լ��� ������ ��ģ��.
			NCG_Log() ��ü�� Ȱ��ȭ �Ǿ� �־�߸� ��µȴ�.
			�⺻���� 0�̴�.
			�Ľ̵� ������� CEK�� ����ǹǷ�
			�����ÿ��� 1�� ����ϰ� ��ǰ ������ �Ҷ�����
			�ݵ�� 0�� �����ϰų� �� �Լ� ��ü�� ȣ������ �ʾƾ� �Ѵ�.
	��ȯ:	����.
	����:	bFlag		- �Ľ̵� RO ��� ���� (1 / 0)
	*****************************************************************/
	DLLFUNC void	NCG_EnableLogParsedXML( const int	bFlag);

	/*****************************************************************
	���: �����κ��� ������ �޽����� RO�� ��� �̸� ����, �Ľ�, �����Ѵ�.
			������ �޽����� �ݵ�� NULL �� ������ ���ڿ��̾�� �Ѵ�.
			���̼��� ��û Ÿ��(CID, SID, SSID)�� �����ϰ� ���ȴ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hCore			- NCG_Agent �ڵ�.
			szResMsg		- ������ �޼���
	*****************************************************************/
	DLLFUNC int		NCG_SaveROResponseMsg(	const NCG_Core_Handle	hCore,
									const char		*szResMsg);

	/*****************************************************************
	���: �����κ��� ������ �޽����� ���� URL�� ��� �̸� �����´�.
			������ �޽����� �ݵ�� NULL �� ������ ���ڿ��̾�� �Ѵ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	szResMsg		- ������ �޼���.
			szPurchaseURL	- �޽����� ���Ե� ���� URL.
			nPurchaseURLLen	- ���� URL ����.
			szTitle			- ���� URL ����.
			nTitleLen		- ���� URL ���� ����.
	*****************************************************************/
	DLLFUNC int		NCG_GetPurchaseURL(	const char		*szResMsg,
								OUT_ALLOC char	*szPurchaseURL,	// please free() after use
					OPTIONAL	OUT_REF	int		*nPurchaseURLLen,
								OUT_ALLOC char	*szTitle,		// please free() after use
					OPTIONAL	OUT_REF	int		*nTitleLen);

	/*****************************************************************
	���: �����κ��� ������ �޽����� �ֹ� ID(Order ID)�� ���
			�̿� ���� OrderID �ڵ��� �����Ѵ�.
			������ �޽����� �ݵ�� NULL �� ������ ���ڿ��̾�� �Ѵ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	szOIDsResMsg	- ������ �ֹ� ID ��� �޼���
			hOIDs			- �ֹ� ID ��� �ڵ�.
			nOIDCount		- �ֹ� ID ����.
	*****************************************************************/
	DLLFUNC int		NCG_GetOrderIDHandle(	const char		*szOIDsResMsg,
									OUT_HANDLE	NCG_OIDs_Handle	*hOIDs,	// do not free(), please NCG_ClearOrderIDHandle()
						OPTIONAL	OUT_REF	int		*nOIDCount);

	/*****************************************************************
	���: �ֹ� ID ��� �ڵ鿡 ����� �ֹ� ID ������ ��ȯ�Ѵ�.
	��ȯ: �ֹ� ID ����(0, ���) �Ǵ� �����ڵ�(����).
	����:	hOIDs			- �ֹ� ID ��� �ڵ�.
	*****************************************************************/
	DLLFUNC int		NCG_GetOrderIDCount(	const NCG_OIDs_Handle	hOIDs);

	/*****************************************************************
	���: �ֹ� ID ��� �ڵ鿡 ����� �ֹ� ID �� ������ �����´�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hOIDs			- �ֹ� ID ��� �ڵ�.
			nIndex			- �ֹ� ID index. 0 ~ n-1
			szOrderID		- �ֹ� ID ���ڿ�.
			nOrderIDLen		- �ֹ� ID ���ڿ� ����.
			szDescription	- �ֹ� ID�� ���� �ΰ� ����.
			nDescriptionLen - �ֹ� ID�� ���� �ΰ� ���� ����.
	*****************************************************************/
	DLLFUNC int		NCG_GetOrderIDInfo(	const NCG_OIDs_Handle	hOIDs,
								const int			nIndex,
								OUT_RESOURCE char	*szOrderID,		// do not free()
					OPTIONAL	OUT_REF int			*nOrderIDLen,
								OUT_RESOURCE char	*szDescription,	// do not free()
					OPTIONAL	OUT_REF int			*nDescriptionLen);

	/*****************************************************************
	���: �ֹ� ID ��� �ڵ��� �޸𸮿��� �����Ѵ�.
	��ȯ: ����.
	����:	hOIDs			- �ֹ� ID ��� �ڵ�.
	*****************************************************************/
	DLLFUNC void	NCG_ClearOrderIDHandle(	IN_OUT	NCG_OIDs_Handle	*hOIDs);


	//////////////////////////////////////////////////////////////////
	//
	// NCG Right Object (License) DB
	//
	//////////////////////////////////////////////////////////////////

	/*****************************************************************
	���: ���ÿ� ����� CID/SID ���� DB�� �д´�.
			���� CID/SID ���¸� �����ϰ� DB�� �������� �����Ѵ�.
			���� ����� ���� DB�� �����Ƿ�, �� ���� ����ó���ȴ�.
			NCG_Init() �ÿ� ���ο��� �ڵ����� ȣ���ϹǷ�
			�Ϲ������δ� ȣ������ �ʾƵ� �ȴ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hCore	- NCG_Agent �ڵ�.
	*****************************************************************/
	DLLFUNC int		NCG_ReadDB(	const NCG_Core_Handle	hCore);

	/*****************************************************************
	���: ���� CID/SID ���¸� ���� ���� DB�� ����Ѵ�.
			���̼��� ���� �� �ڵ����� ȣ��ǹǷ�
			�Ϲ������δ� ȣ������ �ʾƵ� �ȴ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hCore	- NCG_Agent �ڵ�.
	*****************************************************************/
	DLLFUNC int		NCG_WriteDB(	const NCG_Core_Handle	hCore);

	/*****************************************************************
	���: ���ÿ� ����� CID ���� DB�� �����Ѵ�.
			��⿡ ����� ��� CID ������ �����Ǹ�,
			NCG ������ ����� ���ؼ��� CID ���̼����� �ٽ� �޾ƿ;� �Ѵ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hCore	- NCG_Agent �ڵ�.
	*****************************************************************/
	DLLFUNC int		NCG_ClearCIDDB(const NCG_Core_Handle	hCore);

	/*****************************************************************
	���: ���ÿ� ����� SID ���� DB�� �����Ѵ�.
			��⿡ ����� ��� SID ������ �����Ǹ�,
			�ʿ信 ���� SID ���̼����� �ٽ� �޾ƿ;� �Ѵ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hCore	- NCG_Agent �ڵ�.
	*****************************************************************/
	DLLFUNC int		NCG_ClearSIDDB(const NCG_Core_Handle	hCore);

	/*****************************************************************
	���: ���ÿ� ����� CID ���̼��� �� ����� ������ �����Ѵ�.
			�Է¹��� �ð�
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hCore			- NCG_Agent �ڵ�.
			szCurrentGMT	- ���� GMT �ð�. �� �ð��� ����Ͽ����� �����Ѵ�.
			nCurrentGTM		- GMT �ð��� ��ȯ�� ����.
								�ݵ�� NCG_ConvertGMTtoCount()�� ����Ͽ�
								��ȯ�� ���̾�� �Ѵ�.
								���⿡ 0���� ū ���� ������,
								szCurrentGMT ��� �� ���� ����Ѵ�.
	*****************************************************************/
	DLLFUNC int		NCG_TrimCIDDB(	const NCG_Core_Handle	hCore,
							const char				*szGMTTime,
							const unsigned long		nCurrentGMT);

	/*****************************************************************
	���: ���ÿ� ����� SID ���̼��� �� ����� ������ �����Ѵ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hCore			- NCG_Agent �ڵ�.
			szCurrentGMT	- ���� GMT �ð�. �� �ð��� ����Ͽ����� �����Ѵ�.
			nCurrentGTM		- GMT �ð��� ��ȯ�� ����.
								�ݵ�� NCG_ConvertGMTtoCount()�� ����Ͽ�
								��ȯ�� ���̾�� �Ѵ�.
								���⿡ 0���� ū ���� ������,
								szCurrentGMT ��� �� ���� ����Ѵ�.
	*****************************************************************/
	DLLFUNC int		NCG_TrimSIDDB(	const NCG_Core_Handle	hCore,
							const char				*szGMTTime,
							const unsigned long		nCurrentGMT);

	/*****************************************************************
	���: DB������ ����� �� �ٷ� ���丮���� �������� �����Ѵ�.
			NCG_WriteDB()�� ���⼭ �Է��� ���� ���� ���� DB�� ����Ѵ�.
			0�� �Է��� ���, ���� �Լ����� NCG_WriteDB()�� ȣ���ϱ�
			�������� ���丮���� ������� �ʴ´�.
			NCG_SaveROResponseMsg()
			NCG_DecreaseRemainPlayCount()
			NCG_RemoveContentsLicense() / NCG_RemoveContentsLicenseWithCID()
			NCG_RemoveSiteLicense() / NCG_RemoveSiteLicenseWithSID()
			NCG_ClearCIDDB() / NCG_ClearSIDDB()
			NCG_TrimCIDDB() / NCG_TrimSIDDB()
	��ȯ: ����.
	����:	bFlag			- 1�̸� �ﰢ ���, 0�̸� ������� ����.
	*****************************************************************/
	DLLFUNC void	NCG_SetImmediatelyWriteDB(	const int	bFlag );

	/*****************************************************************
	���: ���ÿ� ����� CID, SID DB�� �ؽ�Ʈ���Ϸ� ����.
			���๮�ڴ� \r\n�� ����Ѵ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hCore			- NCG_Agent �ڵ�.
			szFilename		- ���������� �� ���� ���.
	*****************************************************************/
	DLLFUNC int		NCG_DumpDB(	const NCG_Core_Handle	hCore,
						const char				*szFilename);


	//////////////////////////////////////////////////////////////////
	//
	// NCG Contents 
	//
	//////////////////////////////////////////////////////////////////

	/*****************************************************************
	���: NCG ������ ���� ����� �����Ѱ� �����ϸ� �ڵ��� �����Ѵ�.
			��ü ������ �ƴ� ����� �����ϹǷ�, �ٿ�ε� �� �ߴܵ� �����̶�
			����� �ջ���� �ʾҴٸ� ������ �����Ѵ�.
			���̼��� ������ Ȯ������ �ʴ´�.
			������ ���Ͽ� ���ؼ� �� �Լ��� �ι� �̻� ȣ���ϸ�,
			�ι�° ���� ȣ�⿡���� ��� ������ ����ϰ� ������ ��ȯ�Ѵ�.
			������ ���ŵ� ��쿡��, NCG_ClearFileHandle()�� ȣ���� ��
			�� �Լ��� ȣ���ؾ� ������ �ٽ� ����.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	szFilename		- NCG ���� �̸�. ���� ��θ� �Է��ؾ� �Ѵ�.
			nEnableRead		- �ڵ鿡 ���Ͽ� ������ ���� ������ ��� true.
								�ܺο��� ������ ���� �� ��ȣȭ�� �ҰŸ� false.
								�Ʒ� ��� ����.
			bUsePOSIX		- ANSI FILE* ��� POSIX ������ ����� ��쿡 1�� ����.
			nFlag			- POSIX open()�� ����ϴ� flag. O_RDONLY ��.
								bUsePOSIX = 0 �� ��쿡�� 0 �Է�.
			nMode			- POSIX open()�� ����ϴ� mode. S_IRUSR ��.
								bUsePOSIX = 0 �� ��쿡�� 0 �Է�.
			hFile			- ��� ������ �����ϸ� �ڵ��� ��ȯ�Ѵ�.

	���:	nEnableRead = true �� ���,
				NCG_Read(), NCG_Seek(), NCG_Tell()�� ����Ͽ� ������
				���� �����Ѵ�. NCG_Read()�� ��ȣȭ�� �����͸� ��ȯ�Ѵ�.
				NCG_GetNewOffsetAndSize(), NCG_Decrypt() �� ����� �� ����.
			nEnableRead = false �� ���.
				������ SDK �ܺο��� ���� �� ��ȣȭ�ϰ��� �Ҷ� �����Ѵ�.
				NCG�� chunk ������ ��ȣ�ǹǷ�, ���� ��ġ�� ������ ��ȣȭ�� ������
				chunk ������ ��ȣ�� �� �ʿ��� �κ��� �߶� ����Ѵ�.
				NCG_GetNewOffsetAndSize()�� ����Ͽ� ��ȣ�� ���Ͽ� �о�� ��
				������ ��ġ�� ũ��(NCG chunk ����)�� ����Ͽ� ��ȯ�Ѵ�.
				�ش� ��ġ�� ũ�⸦ SDK �ܺο��� ���� ��	NCG_Decrypt() �� ��ȣ�Ѵ�.
				��ȣ ��, ��û�� ��ġ, ���� ���� ��ġ ���� ���̸� �̿��Ͽ�
				�ʿ��� ��ŭ �����͸� ����Ѵ�.
				�ڼ��� ������ �� �Լ��� ������ �����Ѵ�.
				NCG_Read(), NCG_Seek(), NCG_Tell()�� ����� �� ����.
	*****************************************************************/
	DLLFUNC int		NCG_OpenAndVerifyFile(	const char	*szFilename,
									const int	nEnableRead,
									const int	bUsePOSIX,
									const int	nFlag,
									const int	nMode,
									OUT_HANDLE	NCG_File_Handle*	hFile);

	/*****************************************************************
	���: NCG ����� �����ϰ�, �����ϸ� �ڵ��� �����Ѵ�.
			�ǽð� �ٿ�ε�&�÷��� �� ���� ��, ��� �κи� ���� ��
			������ ������ �� �ִ�.
			���⼭ ������ �ڵ��� nEnableRead = false�� ����.
			��, NCG_Read(), NCG_Seek(), NCG_Tell() ���� ����� �� ����.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	bszHeader_MIN2048	- NCG ������ ��� ����.
								����� ���̰� �����̹Ƿ� �����ְ� �Է��Ѵ�.
								�Ϲ������� ���ũ��� 2048����Ʈ �����̴�.
								���� ��� ���̰� �����ϴٸ�
								nHeader �� �ʿ��� ��� ���̸� �����Ѵ�.
			nHeaderLen		- bszHeader�� ����.
								���� ����� ������ �����ϸ�, �� ���̰� ª����
								�Լ��� �����ڵ带 ��ȯ�ϰ�
								�� ���� �ʿ��� ������� ����ȴ�.
								�� �� ũ�⸸ŭ ���۸� ���� �о
								�Լ��� ��ȣ���ؾ��Ѵ�.
			hFile			- ��� ������ �����ϸ� �ڵ��� ��ȯ�Ѵ�.
			nFilesize		- ���� ũ��.
								��� ���� ������ NCG ���� ��ü ũ�⸦
								�� �� �ִٸ� �Է��Ѵ�.
			nContentSize	- ����� ������ ������ ������ ũ�⸦ ��ȯ�Ѵ�.
								nFilesize �� �ԷµǾ��� ������ ��ȯ�� �� �ִ�.
								nFilesize �� 0�̶�� ��� ũ�⸦ ��ȯ�Ѵ�.
	*****************************************************************/
	DLLFUNC int		NCG_OpenAndVerifyHeader(const unsigned char	*bszHeader_MIN2048,
									IN_OUT int	*nHeaderLen,
									OUT_HANDLE	NCG_File_Handle*	hFile,
						OPTIONAL	const int	nFilesize,
						OPTIONAL	OUT_REF	int	*nContentsSize);

	/*****************************************************************
	���: NCG ������ ������ ��ȣ�ϱ� ���Ͽ� Ű�� �����Ѵ�.
	��� ������ ���� ������, ��ȣ�� ���Ͽ� ���������� �Ѵ�.
	��ȯ: ����
	����:	hFile		- NCG ���� �ڵ�.
			bszCEK		- ������ ��ȣ Ű.
	*****************************************************************/
	DLLFUNC void	NCG_SetCEKForce(	const NCG_File_Handle	hFile,
								const unsigned char		*bszCEK);

	/*****************************************************************
	���: NCG �������� �Ǵ��Ѵ�.
	��ȯ: true(1) �Ǵ� false(0) �Ǵ� �����ڵ�.
	����:	szFilename		- NCG ���� �̸�. ���� ��θ� �Է��ؾ� �Ѵ�.
	*****************************************************************/
	DLLFUNC int		NCG_IsNCGFile(	const char	*szFilename );

	/*****************************************************************
	���: NCG ������ ������� �Ǵ��Ѵ�.
	��ȯ: true(1) �Ǵ� false(0) �Ǵ� �����ڵ�.
	����:	bszHeader		- NCG ������ ��� ����.
								16����Ʈ �̻��̸� NCG ������� �Ǵ��� �� �ִ�.
	*****************************************************************/
	DLLFUNC int		NCG_IsNCGHeader(	const unsigned char	*bszHeader_MIN16 );

	/*****************************************************************
	���: NCG ���� ��� ������ ��ȯ�Ѵ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hFile			- NCG ���� �ڵ�.
			ncgHeaderInfo	- NCG �������� ��� ����.
	*****************************************************************/
	DLLFUNC int		NCG_GetHeaderInfo(	const NCG_File_Handle			hFile,
								OUT_RESOURCE NCG_Header_Info	**ncgHeaderInfo);
	
	/*****************************************************************
	���: NCG ���� ��� ���� �� Contents ID, Site ID, Acquisition URL��
		�ٷ� ��ȯ�Ѵ�. free() ����.
	��ȯ: �ش� ���� ���� ������ �Ǵ� NULL.
	����:	hFile			- NCG ���� �ڵ�.
	*****************************************************************/
	DLLFUNC OUT_RESOURCE	char*	NCG_GetContentsID	(const NCG_File_Handle	hFile);
	DLLFUNC OUT_RESOURCE	char*	NCG_GetSiteID		(const NCG_File_Handle	hFile);
	DLLFUNC OUT_RESOURCE	char*	NCG_AcquisitionURL	(const NCG_File_Handle	hFile);
	
	/*****************************************************************
	���: NCG ���Ͽ� ���� ���̼����� ã�� ���̼��� �ڵ��� ��ȯ�Ѵ�.
	��ȯ: ��ȣ����(NCGERR_SUCCEED(0x00)) �Ǵ� �����ڵ�.
	����:	hCore		- NCG_Agent �ڵ�.
			hFile		- NCG ���� �ڵ�.
			hLic		- NCG ���Ͽ� ���õ� ���̼��� �ڵ�
			nLicCount	- ���̼��� ����.
	*****************************************************************/
	DLLFUNC int		NCG_GetLicensesHandle(	const NCG_Core_Handle			hCore,
									const NCG_File_Handle			hFile,
									OUT_HANDLE	NCG_License_Handle	*hLic,
						OPTIONAL	OUT_REF int				*nLicCount);

	/*****************************************************************
	���: ���̼��� �ڵ��� nIndex ��° ���� �����´�
	��ȯ: ��ȣ����(NCGERR_SUCCEED(0x00)) �Ǵ� �����ڵ�.
	����:	hLic			- NCG ���̼��� �ڵ�
			nIndex			- ��ȸ�� ���̼��� ������ �ε���.
			ncgLicenseInfo	- ���̼��� ����
	*****************************************************************/
	DLLFUNC int		NCG_GetLicensesInfo(const NCG_License_Handle		*hLic,
								const int						nIndex,
								OUT_RESOURCE NCG_License_Info	**ncgLicenseInfo);	
	
	/*****************************************************************
	���: NCG ���Ͽ� ���̼��� ��, ����� ���̼����� �����Ѵ�.
			���ο��� ��밡������ �����ϴ� �ܰ踦 ��ġ��,
			���⼭ ������ ����(Ƚ�� ����, �Ⱓ���� ��)�ϸ� ��ȣȭ�� ���� �ʴ´�.
			bszCEK_MIN32�� �޸𸮸� �Ҵ��Ͽ� �����ϸ�,
			��ȣ�� Ű�� ��ȯ�޴´�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hFile			- NCG ���� �ڵ�.
			hLic			- NCG ���̼��� �ڵ�.
			nIndex			- ����� ���̼��� �ε���.
			szCurrentGMT	- ���� GMT �ð�.
								�� �Ⱓ�� �������� ���̼��� ���� ���θ� Ȯ���Ѵ�.
								SDK ���ο����� ��� �ð��� ���� �� �����Ƿ�
								���ø����̼ǿ��� ���� �ð��� �� �Է��Ѵ�.
								���̼��� �߱� ������ �����ϴ� �ð���
								GMT�� ���� LOCAL�� ���� �����Ƿ� �׿� �����.
								�⺻�� GMT�̴�.
			nCurrentGMT		- ���� GMT �ð��� ��ȯ�� ����.
								�ݵ�� NCG_ConvertGMTtoCount()�� ����Ͽ�
								��ȯ�� ���̾�� �Ѵ�.
								���⿡ 0���� ū ���� ������,
								szCurrentGMT ��� �� ���� ����Ѵ�.
			bszCEK_MIN32	- ��ȣ Ű.
	*****************************************************************/
	DLLFUNC int		NCG_SetLicense(	const NCG_File_Handle		hFile,
							const NCG_License_Handle	hLic,
							const int					nIndex,
							const char					*szCurrentGMT,
							const unsigned long			nCurrentGMT,
				OPTIONAL	OUT_REF	unsigned char		*bszCEK_MIN32);
	

	/*****************************************************************
	���: ������ ���� ������� ���̼��� ������ �����´�
	��ȯ: ��ȣ����(NCGERR_SUCCEED(0x00)) �Ǵ� �����ڵ�.
	����:	hFile			- NCG ���� �ڵ�.
			ncgLicenseInfo	- ���̼��� ����
	*****************************************************************/
	DLLFUNC int		NCG_GetLicensesInfoOfFile(const NCG_File_Handle			hFile,
									  OUT_RESOURCE NCG_License_Info	**ncgLicenseInfo);	
	
	/*****************************************************************
	���: NCG ���̼��� �ڵ��� �����Ѵ�.
	*****************************************************************/
	DLLFUNC void	NCG_ClearLicenseHandle(IN_OUT NCG_License_Handle	*hLic);

	/*****************************************************************
	���: NCG ���� ���Ƚ���� 1 �����Ѵ�.
			���� �� �ٷ� DB�� �����Ѵ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hCore			- NCG_Agent �ڵ�.
			hFile			- NCG ���� �ڵ�.
			nRemainCount	- ������ �� ���� ��� Ƚ��.
	*****************************************************************/
	DLLFUNC int		NCG_DecreaseRemainPlayCount(const NCG_Core_Handle	hCore,
										const NCG_File_Handle	hFile,
							OPTIONAL	OUT_REF int				*nRemainPlayCount);

	/*****************************************************************
	 ���: NCG ���ϰ� ����� Contents ���̼����� �����Ѵ�.
			�ش� ������, ���̼����� �ٽ� ȹ���� ������ ����� �� ����.
	 ��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	 ����:	hCore	- NCG_Agent �ڵ�.
			hFile	- NCG ���� �ڵ�.
	 *****************************************************************/
	DLLFUNC int		NCG_RemoveContentsLicense(	const NCG_Core_Handle	hCore,
										const NCG_File_Handle	hFile);
	
	/*****************************************************************
	���: Contents ID�� �ش��ϴ� Contents ���̼����� �����Ѵ�.
			�ش� ID�� ����ϴ� ������, ���̼����� �ٽ� ȹ���� ������ ����� �� ����.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hCore	- NCG_Agent �ڵ�.
			szCID	- Contents ID.
	*****************************************************************/
	DLLFUNC int		NCG_RemoveContentsLicenseWithCID(	const NCG_Core_Handle	hCore,
												const char				*szCID);
	
	/*****************************************************************
	���: NCG ���ϰ� ����� Site ���̼����� �����Ѵ�.
			�ش� ���� �Ӹ��� �ƴ϶� ������ Site ID�� ���� ���Ͽ� ������ ��ģ��.
			���� �������� ���� ���̼������� ������ ��ġ�� ������,
			�����װ� ���� �׷� �ó����������� ��뿡 �����Ѵ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hCore	- NCG_Agent �ڵ�.
			hFile	- NCG ���� �ڵ�.
	 *****************************************************************/
	DLLFUNC int		NCG_RemoveSiteLicense(	const NCG_Core_Handle	hCore,
									  const NCG_File_Handle	hFile);
	
	/*****************************************************************
	���: Site ID�� �ش��ϴ� Contents ���̼����� �����Ѵ�.
			������ Site ID�� ���� ���Ͽ� ������ ��ģ��.
			���� �������� ���� ���̼������� ������ ��ġ�� ������,
			�����װ� ���� �׷� �ó����������� ��뿡 �����Ѵ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hCore	- NCG_Agent �ڵ�.
			szSID	- Site ID.
	*****************************************************************/
	DLLFUNC int		NCG_RemoveSiteLicenseWithSID(	const NCG_Core_Handle	hCore,
											const char				*szSID);
	
	/*****************************************************************
	���: NCG ������ �д´�. ��ȣ�� �����Ͱ� ����ȴ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hFile		- NCG ���� �ڵ�.
			nToReadLen	- �о�� ���� ����.
			bszBuff		- ��ȣ�� NCG ������ ������.
			nReadedLen	- ������ �о ��ȣ��, �� bszBuff�� ������ ����.
	ȣ�Ⱑ��:
		NCG_OpenAndVerifyFile() ȣ�� �� nEnableRead = true
	ȣ��Ұ�(�����ڵ� ��ȯ):
		NCG_OpenAndVerifyFile() ȣ�� �� nEnableRead = false
		NCG_OpenAndVerifyHeader() ȣ�� ��
	*****************************************************************/
	DLLFUNC int		NCG_Read(	const NCG_File_Handle	hFile,
						const unsigned long		nToReadLen,
						OUT_REF unsigned char	*bszBuff,
						OUT_REF	unsigned long	*nReadedLen);

	/*****************************************************************
	���: NCG ���� �������� �̵��Ѵ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hFile		- NCG ���� �ڵ�.
			nOffset		- �̵��� ����.
			nMethod		- �̵� ������.
							fseek()�� ����
							SEEK_SET, SEEK_CUR, SEEK_END �� �ϳ��� �Է��Ѵ�.
	ȣ�Ⱑ��:
		NCG_OpenAndVerifyFile() ȣ�� �� nEnableRead = true
	ȣ��Ұ�(�����ڵ� ��ȯ):
		NCG_OpenAndVerifyFile() ȣ�� �� nEnableRead = false
		NCG_OpenAndVerifyHeader() ȣ�� ��
	*****************************************************************/
	DLLFUNC int		NCG_Seek(	const NCG_File_Handle	hFile,
						const long				nOffset,
						const int				nMethod);

	/*****************************************************************
	���: NCG ���� �������� �̵��ϰ� ���� ��ġ�� ��ȯ�Ѵ�.
	��ȯ: 0���� ū ���� �Ǵ� -1.
	����:	hFile		- NCG ���� �ڵ�.
			nOffset		- �̵��� ����.
			nMethod		- �̵� ������.
							lseek()�� ����
							SEEK_SET, SEEK_CUR, SEEK_END �� �ϳ��� �Է��Ѵ�.
	ȣ�Ⱑ��:
		NCG_OpenAndVerifyFile() ȣ�� �� nEnableRead = true
												bUsePOSIX   = false
	ȣ��Ұ�(-1 ��ȯ):
		NCG_OpenAndVerifyFile() ȣ�� �� nEnableRead = false
		NCG_OpenAndVerifyHeader() ȣ�� ��
	*****************************************************************/
	DLLFUNC int		NCG_Lseek(	const NCG_File_Handle	hFile,
						const long				nOffset,
						const int				nMethod);

	/*****************************************************************
	���: NCG ���� �������� ��ġ�� ��ȯ�Ѵ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hFile		- NCG ���� �ڵ�.
			nOffset		- NCG ���� ������ ��ġ ��.
	ȣ�Ⱑ��:
		NCG_OpenAndVerifyFile() ȣ�� �� nEnableRead = true
												bUsePOSIX   = true
	ȣ��Ұ�(�����ڵ� ��ȯ):
		NCG_OpenAndVerifyFile() ȣ�� �� nEnableRead = false
		NCG_OpenAndVerifyHeader() ȣ�� ��
	*****************************************************************/
	DLLFUNC int		NCG_Tell(	const NCG_File_Handle	hFile,
						OUT_REF	unsigned int	*nOffset);

	/*****************************************************************
	���: ���Ͽ� �����͸� ����. ��, POSIX ���ÿ��� �����ϴ�.
	��ȯ: ����� ũ�� (0���� ū ����) �Ǵ� -1.
	����:	hFile		- NCG ���� �ڵ� (��).
			bszBuff			- ����� ������.
			nToWriteLen		- ����� ������ ����.
	ȣ�Ⱑ��:
		NCG_OpenAndVerifyFile() ȣ�� �� nEnableRead = true
												bUsePOSIX   = true
												�Է� ������ ��
	ȣ��Ұ�(�����ڵ� ��ȯ):
		NCG_OpenAndVerifyFile() ȣ�� �� nEnableRead = false
		NCG_OpenAndVerifyHeader() ȣ�� ��
	*****************************************************************/
	DLLFUNC int		NCG_Write(	const NCG_File_Handle	hFile,
								const unsigned char	*bszBuff,
								const unsigned long	nToWriteLen);

	/*****************************************************************
	���: ���� ������ �����´�.
	��ȯ: 0 �Ǵ� -1.
	����:	szFilename		- ���� �̸�.
			statBuf			- ���� ����.
	*****************************************************************/
	DLLFUNC int		NCG_Stat(const char *szFilename,
						OUT_REF	struct stat *statBuf);

	/*****************************************************************
	���: ���� ������ �����´�.  POSIX ���ÿ��� �����ϴ�.
	��ȯ: 0 �Ǵ� -1.
	����:	hFile		- NCG ���� �ڵ�.
			statBuf			- ���� ����.
	ȣ�Ⱑ��:
		NCG_OpenAndVerifyFile() ȣ�� �� nEnableRead = true
												bUsePOSIX   = true
	ȣ��Ұ�(�����ڵ� ��ȯ):
		NCG_OpenAndVerifyFile() ȣ�� �� nEnableRead = false
		NCG_OpenAndVerifyHeader() ȣ�� ��
	*****************************************************************/
	DLLFUNC int		NCG_Fstat(	const NCG_File_Handle	hFile,
							OUT_REF	struct stat *statBuf);

	/*****************************************************************
	���: NCG ���ϳ��� ������ ũ�⸦ ��ȯ�Ѵ�.
			'NCG ���� ��ü ũ�� - NCG ��� ũ��'�� �����ϴ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hFile			- NCG ���� �ڵ�.
			nContentsSize	- NCG ���ϳ� ������ ũ��.
	*****************************************************************/
	DLLFUNC int		NCG_GetContentsSize(const NCG_File_Handle	hFile,
								OUT_REF	unsigned int	*nContentsSize);

	/*****************************************************************
	���: NCG ������ ��� ũ�⸦ ��ȯ�Ѵ�.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hFile			- NCG ���� �ڵ�.
			nHeaderSize		- NCG ���� ��� ũ��.
	 *****************************************************************/
	DLLFUNC int		NCG_GetHeaderSize(	const NCG_File_Handle	hFile,
								OUT_REF	unsigned int	*nHeaderSize);

	/*****************************************************************
	���: NCG ������ SDK �ܺο��� ���� �� ��ȣȭ�ϴ� ��쿡 ����Ѵ�.
			NCG_Decrypt()�� ¦�� �̷��� �Ѵ�.
			�ڼ��� ������ ��� ����.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hFile				- NCG ���� �ڵ�.
			nWantedStartOffset	- �б� ������ ���� ������.
			nWantedSize			- ���� ������ ����.
			nActualStartOffset	- ������ �о�� �� ���� ������.
			nAcutalSize			- ������ �о�� �� ������ ����.
			nFrontGap			- ���� �պκ� ����.

	���: 	NCG ������ chunk ������ ��ȣȭ�ǹǷ�,
			chunk �����θ� ��ȣ�� �����ϴ�.
			������ ���� �κк��� ���� ���� �����͸� ��ȣ�ϱ� ���ؼ� �о�� ��
			���� ���� ���������� ���� ����,
			�� chunk ���� ������ chunk ���� ���̸� ����Ͽ� ��ȯ�Ѵ�.
			�̷� ���Ͽ� �߻��ϴ� ���� ������ ���̸� ��ȯ�ϹǷ�
			��ȣ�� ���� �Ŀ�, ���� ���� ���̸�ŭ ������ �պκ��� ������.

			��) �� ������ ���� offset:700 ���� 10233 ����Ʈ�� �а��� �� ��.

			// ���� ��ġ, ���� ������.
			NCG_GetNewOffsetAndSize(hFile, 700, 10233,
									&nStart, &nSize, &nGap );

			// ���� ��ġ�� �̵�
			fseek(fp, nStart, SEEK_SET);

			// ���� ���̸�ŭ �б�
			fread(buff, 1, nSize, fp);
			
			// ��ȣ
			NCG_Decrypt(hFile, buff, nSize);

			// ��� �պκ��� �ǳʶپ� ������ ��ȯ
			return buff + nGap;

	ȣ�Ⱑ��:
		NCG_OpenAndVerifyFile() ȣ�� �� nEnableRead = false
		NCG_OpenAndVerifyHeader() ȣ�� ��
	ȣ��Ұ�(�����ڵ� ��ȯ):
		NCG_OpenAndVerifyFile() ȣ�� �� nEnableRead = true
	*****************************************************************/
	DLLFUNC int		NCG_GetNewOffsetAndSize(const NCG_File_Handle	hFile,
									const unsigned long		nWantedStartOffset,
									const unsigned long		nWantedSize,
									OUT_REF	unsigned long	*nActualStartOffset,
									OUT_REF unsigned long	*nAcutalSize,
									OUT_REF	unsigned long	*nFrontGap);


	/*****************************************************************
	���: NCG ������ chunk�� ��ȣ�Ѵ�.
			������ �Է��� chunk ������ �ƴ� ���, ��ȣȭ�� ���������
			�߸��� �����ͷ� ��ȣ�� �� �ִ�.
			��, ���� ���κ��� ������ �����ʹ� chunk ������ �ƴ� �� �ִ�.
			NCG_GetNewOffsetAndSize()�� ¦�� �̷��� �Ѵ�.
			�ڼ��� ������ NCG_GetNewOffsetAndSize()�� ��� ����.
	��ȯ: NCGERR_SUCCEED(0x00) �Ǵ� �����ڵ�.
	����:	hFile		- NCG ���� �ڵ�.
			bszData		- ��ȣȭ�� NCG ������ chunk.
			nDataLen	- NCG ������ ����.

	ȣ�Ⱑ��:
		NCG_OpenAndVerifyFile() ȣ�� �� nEnableRead = false
		NCG_OpenAndVerifyHeader() ȣ�� ��
	ȣ��Ұ�(�����ڵ� ��ȯ):
		NCG_OpenAndVerifyFile() ȣ�� �� nEnableRead = true
	*****************************************************************/
	DLLFUNC int		NCG_Decrypt(const NCG_File_Handle	hFile,
						IN_OUT unsigned char	*bszData,
						const unsigned int		nDataLen);

	/*****************************************************************
	���: NCG ���� �ڵ��� �����Ѵ�.
	��ȯ: ����
	����:	hFile		- NCG ���� �ڵ�.
	*****************************************************************/
	DLLFUNC void	NCG_ClearFileHandle(IN_OUT	NCG_File_Handle	*hFile);
	
	/*****************************************************************
	 ���: �Է¹��� GMT ���� �ð� ���ڿ��� ���ڷ� ��ȯ�Ѵ�.
			2010-01-01T00:00:00Z���κ��� ���� �ʸ� ��ȯ�Ѵ�.
			(�� ���� 31�Ϸ� ����)
			�Ⱓ�� ������ ���� �������� ���,
			�� szGMTTime�� ������ ���� ���� -1 (0xffffffff)�� ��ȯ�Ѵ�.
			szGMTTime ��ü�� NULL �̸� 0�� ��ȯ�Ѵ�. �����Ѱ� ȥ������ �ʵ��� �����ؾ��Ѵ�.
	 ��ȯ:	��ȯ�� �� (Sec)
	 ����:	szGMTTime	- GMT ���� �ð� ���ڿ�.
	 *****************************************************************/
	DLLFUNC unsigned long	NCG_ConvertGMTtoCount(const char	*szGMTTime);
	
	

	/*****************************************************************
	 ���: Multi Open�� ncgFileH ������ ���� ������ �ʱ�ȭ �Ѵ�.
			Manager�� NCG_Init()�� �θ��� �� �Լ��� ���������� ȣ������� Player������
			NCG ��� ��(NCG OpenAndVerify ����)�� �� �Լ��� ȣ���Ͽ� �ʱ�ȭ�� �����Ѵ�.
	 ��ȯ:	����.
	 ����:	����.
	 *****************************************************************/	
	DLLFUNC void InitFileInfo(void);
#ifdef  __cplusplus
}
#endif

#endif	// _NCG_AGENT_H



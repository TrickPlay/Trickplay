#ifndef	_NCG_AGENT_H
#define _NCG_AGENT_H

#include <unistd.h>
#include "NCG_Def.h"

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
	기능: NCG Agent를 초기화한다.
			내부에 라이센스 DB가 존재하면 읽어온다.
			즉, 별도로 NCG_ReadCIDDB(), NCG_ReadSIDDB()를
			호출하지 않아도 된다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hCore			- 초기화에 성공하면 핸들을 생성한다.
			szDeviceID		- 기기의 ID. 공백이 없어야 한다.
			szDeviceModel	- 기기의 모델명. 공백이 없어야 한다.
							예) iPhone, Nexus_One, ...
			szLicenseDBPath	- 라이센스 관련된 정보가 저장할 경로.
							반드시 '읽기 및 쓰기'가 가능한 경로여야 한다.
							iPhone의 경우 어플/Documents 폴더,
							Android의 경우 어플 폴더 등을 사용하면 된다.
			nEnableSecureStorage	- 보안영역 사용 여부를 설정한다.
							이를 사용하기 위해서는 단말에서,
							유저는 접근할 수 없는 보안영역을 제공해야 한다.
							이를 사용하지 않으면 횟수제는 공격당할 수 있다.
							자세한 사항은 별도 문서 참고.
	*****************************************************************/
	int		NCG_Init(	OUT_HANDLE	NCG_Core_Handle	*hCore,	// do not free(), please NCG_Clear()
						const		char	*szDeviceID,
						const		char	*szDeviceModel,
						const		char	*szLicenseDBPath,
						const		int		nEnableSecureStorage);

	/*****************************************************************
	기능: NCG Agent를 정리하고 관련된 메모리를 반환한다.
	반환: 없음
	인자:	hCore			- NCG_Agent 핸들.
	*****************************************************************/
	void	NCG_Clear(IN_OUT	NCG_Core_Handle	*hCore);


	//////////////////////////////////////////////////////////////////
	//
	// NCG Login
	//
	//////////////////////////////////////////////////////////////////

	/*****************************************************************
	기능: NCG 서버 로그인 요청 메시지를 생성한다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hCore			- NCG_Agent 핸들.
			szUserID		- 사용자 ID.
			szPassword		- 비밀번호.
			szReqMsgBuf_MIN2048	- RO 요청 메세지.
			nReqMsgLen			- RO 요청 메시지 길이.
	*****************************************************************/
	int		NCG_MakeLoginRequestMsg(const NCG_Core_Handle	hCore,
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
	기능: NCG 컨텐츠 파일의 Contents RO 요청 메세지를 생성한다.
			반환된 szReqMsgBuf를 
			반환된 szAcquisitionURL 의 POST 데이터로 요청한 후
			응답을 수신한다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hCore			- NCG_Agent 핸들.
			hFile			- RO를 요청할 파일 핸들. 
			szUserID		- 사용자 ID.
			szOrderID		- 주문 ID.
			szReqMsgBuf_MIN2048		- RO 요청 메세지.
			nReqMsgLen				- RO 요청 메시지 길이.
			szAcquisitionURL_MIN256	- RO 요청 URL.
			nAcquisitionURLLen		- RO 요청 URL 길이.
	*****************************************************************/
	int		NCG_MakeContentsRORequestMsg(	const NCG_Core_Handle	hCore,
											const NCG_File_Handle	hFile,
											const char		*szUserID,
								OPTIONAL	const char		*szOrderID,
											OUT_REF	char	*szReqMsgBuf_MIN2048,
								OPTIONAL	OUT_REF	int		*nReqMsgLen,
											OUT_REF char	*szAcquisitionURL_MIN256,
								OPTIONAL	OUT_REF	int		*nAcquisitionURLLen);

	/*****************************************************************
	기능: NCG 컨텐츠 파일에 대한 컨텐츠 ID, 라이센스 요청 URL을 알고 있을 때,
			이 정보를 사용하여 RO 요청 메시지를 생성한다.
			반환된 szReqMsgBuf를 라이센스 요청 URL의 POST 데이터로 요청한 후
			응답을 수신한다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hCore			- NCG_Agent 핸들.
			szUserID		- 사용자 ID.
			szContentsID	- 컨텐츠 ID.
			szOrderID		- 주문 ID.
			szReqMsgBuf_MIN2048	- RO 요청 메세지.
			nReqMsgLen			- RO 요청 메시지 길이.
	*****************************************************************/
	int		NCG_MakeContentsRORequestMsgWithCID(const NCG_Core_Handle	hCore,
												const char		*szUserID,
												const char		*szContentsID,
									OPTIONAL	const char		*szOrderID,
												OUT_REF	char	*szReqMsgBuf_MIN2048,
									OPTIONAL	OUT_REF	int		*nReqMsgLen);

	/*****************************************************************
	기능: NCG 컨텐츠 파일의 Site RO 요청 메세지를 생성한다.
			반환된 szReqMsgBuf를 
			반환된 szAcquisitionURL의 POST 데이터로 요청한 후
			응답을 수신한다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hCore			- NCG_Agent 핸들.
			hFile			- RO를 요청할 파일 핸들. 
			szUserID		- 사용자 ID.
			szOrderID		- 주문 ID.
			szFilename		- RO를 요청할 컨텐츠 파일 이름.
			szReqMsgBuf_MIN2048		- RO 요청 메세지.
			nReqMsgLen				- RO 요청 메시지 길이.
			szAcquisitionURL_MIN256	- RO 요청 URL.
			nAcquisitionURLLen		- RO 요청 URL 길이.
	*****************************************************************/
	int		NCG_MakeSiteRORequestMsg(	const NCG_Core_Handle	hCore,
										const NCG_File_Handle	hFile,
										const char		*szUserID,
							OPTIONAL	const char		*szOrderID,
										OUT_REF	char	*szReqMsgBuf_MIN2048,
							OPTIONAL	OUT_REF	int		*nReqMsgLen,
										OUT_REF char	*szAcquisitionURL_MIN256,
							OPTIONAL	OUT_REF	int		*nAcquisitionURLLen);

	/*****************************************************************
	기능: NCG 컨텐츠 파일에 대한 Site ID, 라이센스 요청 URL을 알고 있을 때,
			이 정보를 사용하여 RO 요청 메시지를 생성한다.
			반환된 szReqMsgBuf를 라이센스 요청 URL의 POST 데이터로 요청한 후
			응답을 수신한다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hCore			- NCG_Agent 핸들.
			szUserID		- 사용자 ID.
			szSiteID		- Site ID.
			szOrderID		- 주문 ID.
			szReqMsgBuf_MIN2048	- RO 요청 메세지.
			nReqMsgLen			- RO 요청 메시지 길이.
	*****************************************************************/
	int		NCG_MakeSiteRORequestMsgWithSID(	NCG_Core_Handle	hCore,
												const char		*szUserID,
												const char		*szSiteID,
									OPTIONAL	const char		*szOrderID,
												OUT_REF	char	*szReqMsgBuf_MIN2048,
									OPTIONAL	OUT_REF	int		*nReqMsgLen);

	/*****************************************************************
	기능: NCG 컨텐츠 파일에 대한 Session ID, 라이센스 요청 URL을 알고 있을 때,
			이 정보를 사용하여 RO 요청 메시지를 생성한다.
			반환된 szReqMsgBuf를 라이센스 요청 URL의 POST 데이터로 요청한 후
			응답을 수신한다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hCore			- NCG_Agent 핸들.
			szSessionID		- 세션 ID.
			szReqMsgBuf_MIN2048	- RO 요청 메세지.
			nReqMsgLen			- RO 요청 메시지 길이.
	*****************************************************************/
	int		NCG_MakeRORequestMsgWithSSID(	const NCG_Core_Handle	hCore,
											const char		*szSessionID,
											OUT_REF	char	*szReqMsgBuf_MIN2048,
								OPTIONAL	OUT_REF	int		*nReqMsgLen);


	/*****************************************************************
	기능: 서버로부터 수신한 메시지 타입을 분류한다.
			수신한 메시지는 반드시 NULL 로 끝나는 문자열이어야 한다.
	반환:	NCG_RESPONSE_TYPE_UNKNOWON	- 알 수 없는 타입.
			NCG_RESPONSE_TYPE_LOGIN		- 로그인에 대한 응답.
			NCG_RESPONSE_TYPE_RO		- Right Object (License).
			NCG_RESPONSE_TYPE_OID		- 주문 ID 목록.
			NCG_RESPONSE_TYPE_PURCHASE_URL	- 구매 URL.
	인자:	szROResMsg		- 수신한 RO 메세지
			nResponseCode	- 수신한 RO 응답 코드
	*****************************************************************/
	int		NCG_RecognizeResponseMsgType(	const char		*szResponseMsg,
											OUT_REF int		*nResponseCode);

	/*****************************************************************
	기능: 서버로부터 수신한 메시지가 RO인 경우 이를 검증, 파싱, 저장한다.
			수신한 메시지는 반드시 NULL 로 끝나는 문자열이어야 한다.
			라이센스 요청 타입(CID, SID, SSID)과 무관하게 통용된다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hCore			- NCG_Agent 핸들.
			szResMsg		- 수신한 메세지
	*****************************************************************/
	int		NCG_SaveROResponseMsg(	const NCG_Core_Handle	hCore,
									const char		*szResMsg);

	/*****************************************************************
	기능: 서버로부터 수신한 메시지가 구매 URL인 경우 이를 가져온다.
			수신한 메시지는 반드시 NULL 로 끝나는 문자열이어야 한다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	szResMsg		- 수신한 메세지.
			szPurchaseURL	- 메시지에 포함된 구매 URL.
			nPurchaseURLLen	- 구매 URL 길이.
			szTitle			- 구매 URL 제목.
			nTitleLen		- 구매 URL 제목 길이.
	*****************************************************************/
	int		NCG_GetPurchaseURL(	const char		*szResMsg,
								OUT_ALLOC char	*szPurchaseURL,	// please free() after use
					OPTIONAL	OUT_REF	int		*nPurchaseURLLen,
								OUT_ALLOC char	*szTitle,		// please free() after use
					OPTIONAL	OUT_REF	int		*nTitleLen);

	/*****************************************************************
	기능: 서버로부터 수신한 메시지가 주문 ID(Order ID)인 경우
			이에 대한 OrderID 핸들을 생성한다.
			수신한 메시지는 반드시 NULL 로 끝나는 문자열이어야 한다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	szOIDsResMsg	- 수신한 주문 ID 목록 메세지
			hOIDs			- 주문 ID 목록 핸들.
			nOIDCount		- 주문 ID 갯수.
	*****************************************************************/
	int		NCG_GetOrderIDHandle(	const char		*szOIDsResMsg,
									OUT_HANDLE	NCG_OIDs_Handle	*hOIDs,	// do not free(), please NCG_ClearOrderIDHandle()
						OPTIONAL	OUT_REF	int		*nOIDCount);

	/*****************************************************************
	기능: 주문 ID 목록 핸들에 저장된 주문 ID 갯수를 반환한다.
	반환: 주문 ID 갯수(0, 양수) 또는 에러코드(음수).
	인자:	hOIDs			- 주문 ID 목록 핸들.
	*****************************************************************/
	int		NCG_GetOrderIDCount(	const NCG_OIDs_Handle	hOIDs);

	/*****************************************************************
	기능: 주문 ID 목록 핸들에 저장된 주문 ID 및 설명을 가져온다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hOIDs			- 주문 ID 목록 핸들.
			nIndex			- 주문 ID index. 0 ~ n-1
			szOrderID		- 주문 ID 문자열.
			nOrderIDLen		- 주문 ID 문자열 길이.
			szDescription	- 주문 ID에 대한 부가 설명.
			nDescriptionLen - 주문 ID에 대한 부가 설명 길이.
	*****************************************************************/
	int		NCG_GetOrderIDInfo(	const NCG_OIDs_Handle	hOIDs,
								const int			nIndex,
								OUT_RESOURCE char	*szOrderID,		// do not free()
					OPTIONAL	OUT_REF int			*nOrderIDLen,
								OUT_RESOURCE char	*szDescription,	// do not free()
					OPTIONAL	OUT_REF int			*nDescriptionLen);

	/*****************************************************************
	기능: 주문 ID 목록 핸들을 메모리에서 정리한다.
	반환: 없음.
	인자:	hOIDs			- 주문 ID 목록 핸들.
	*****************************************************************/
	void	NCG_ClearOrderIDHandle(	IN_OUT	NCG_OIDs_Handle	*hOIDs);


	//////////////////////////////////////////////////////////////////
	//
	// NCG Right Object (License) DB
	//
	//////////////////////////////////////////////////////////////////

	/*****************************************************************
	기능: 로컬에 저장된 CID/SID 관련 DB를 읽는다.
			현재 CID/SID 상태를 무시하고 DB의 내용으로 복구한다.
			최초 수행시 관련 DB가 없으므로, 이 경우는 정상처리된다.
			NCG_Init() 시에 내부에서 자동으로 호출하므로
			일반적으로는 호출하지 않아도 된다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hCore	- NCG_Agent 핸들.
	*****************************************************************/
	int		NCG_ReadDB(	const NCG_Core_Handle	hCore);

	/*****************************************************************
	기능: 현재 CID/SID 상태를 로컬 관련 DB에 기록한다.
			라이센스 갱신 시 자동으로 호출되므로
			일반적으로는 호출하지 않아도 된다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hCore	- NCG_Agent 핸들.
	*****************************************************************/
	int		NCG_WriteDB(	const NCG_Core_Handle	hCore);

	/*****************************************************************
	기능: 로컬에 저장된 CID 관련 DB를 삭제한다.
			기기에 저장된 모든 CID 정보가 삭제되며,
			NCG 컨텐츠 재생을 위해서는 CID 라이센스를 다시 받아와야 한다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hCore	- NCG_Agent 핸들.
	*****************************************************************/
	int		NCG_ClearCIDDB(const NCG_Core_Handle	hCore);

	/*****************************************************************
	기능: 로컬에 저장된 SID 관련 DB를 삭제한다.
			기기에 저장된 모든 SID 정보가 삭제되며,
			필요에 따라 SID 라이센스를 다시 받아와야 한다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hCore	- NCG_Agent 핸들.
	*****************************************************************/
	int		NCG_ClearSIDDB(const NCG_Core_Handle	hCore);

	/*****************************************************************
	기능: 로컬에 저장된 CID 라이센스 중 만료된 내용을 삭제한다.
			입력받은 시간
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hCore			- NCG_Agent 핸들.
			szCurrentGMT	- 현재 GMT 시간. 이 시간이 경과하였으면 삭제한다.
			nCurrentGTM		- GMT 시간을 변환한 숫자.
								반드시 NCG_ConvertGMTtoCount()를 사용하여
								변환된 값이어야 한다.
								여기에 0보다 큰 값이 들어오면,
								szCurrentGMT 대신 이 값을 사용한다.
	*****************************************************************/
	int		NCG_TrimCIDDB(	const NCG_Core_Handle	hCore,
							const char				*szGMTTime,
							const unsigned long		nCurrentGMT);

	/*****************************************************************
	기능: 로컬에 저장된 SID 라이센스 중 만료된 내용을 삭제한다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hCore			- NCG_Agent 핸들.
			szCurrentGMT	- 현재 GMT 시간. 이 시간이 경과하였으면 삭제한다.
			nCurrentGTM		- GMT 시간을 변환한 숫자.
								반드시 NCG_ConvertGMTtoCount()를 사용하여
								변환된 값이어야 한다.
								여기에 0보다 큰 값이 들어오면,
								szCurrentGMT 대신 이 값을 사용한다.
	*****************************************************************/
	int		NCG_TrimSIDDB(	const NCG_Core_Handle	hCore,
							const char				*szGMTTime,
							const unsigned long		nCurrentGMT);

	/*****************************************************************
	기능: 로컬에 저장된 CID, SID DB를 텍스트파일로 쓴다.
			개행문자는 \r\n을 사용한다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hCore			- NCG_Agent 핸들.
			szFilename		- 덤프파일을 쓸 파일 경로.
	*****************************************************************/
	int		NCG_DumpDB(	const NCG_Core_Handle	hCore,
						const char				*szFilename);


	//////////////////////////////////////////////////////////////////
	//
	// NCG Contents 
	//
	//////////////////////////////////////////////////////////////////

	/*****************************************************************
	기능: NCG 파일을 열고 헤더를 검증한고 성공하면 핸들을 생성한다.
			전체 파일이 아닌 헤더만 검증하므로, 다운로드 중 중단된 파일이라도
			헤더만 손상되지 않았다면 검증에 성공한다.
			라이센스 정보는 확인하지 않는다.
			동일한 파일에 대해서 이 함수를 두번 이상 호출하면,
			두번째 이후 호출에서는 모든 과정을 통과하고 성공을 반환한다.
			파일이 갱신된 경우에는, NCG_ClearFileHandle()을 호출한 후
			이 함수를 호출해야 파일을 다시 연다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	szFilename		- NCG 파일 이름. 절대 경로를 입력해야 한다.
			nEnableRead		- 핸들에 대하여 파일을 직접 제어할 경우 true.
								외부에서 파일을 읽은 후 복호화만 할거면 false.
								아래 비고 참고.
			bUsePOSIX		- ANSI FILE* 대신 POSIX 연산을 사용할 경우에 1로 설정.
			nFlag			- POSIX open()시 사용하는 flag. O_RDONLY 등.
								bUsePOSIX = 0 인 경우에는 0 입력.
			nMode			- POSIX open()시 사용하는 mode. S_IRUSR 등.
								bUsePOSIX = 0 인 경우에는 0 입력.
			hFile			- 헤더 검증에 성공하면 핸들을 반환한다.

	비고:	nEnableRead = true 인 경우,
				NCG_Read(), NCG_Seek(), NCG_Tell()을 사용하여 파일을
				직접 제어한다. NCG_Read()는 복호화된 데이터를 반환한다.
				NCG_GetNewOffsetAndSize(), NCG_Decrypt() 는 사용할 수 없다.
			nEnableRead = false 인 경우.
				파일을 SDK 외부에서 읽은 후 복호화하고자 할때 설정한다.
				NCG는 chunk 단위로 암호되므로, 임의 위치의 내용을 복호화할 때에도
				chunk 단위로 복호한 후 필요한 부분을 잘라서 써야한다.
				NCG_GetNewOffsetAndSize()를 사용하여 복호를 위하여 읽어야 할
				파일의 위치와 크기(NCG chunk 단위)를 계산하여 반환한다.
				해당 위치와 크기를 SDK 외부에서 읽은 후	NCG_Decrypt() 로 복호한다.
				복호 후, 요청한 위치, 실제 읽은 위치 등의 차이를 이용하여
				필요한 만큼 데이터를 사용한다.
				자세한 설명은 각 함수의 설명을 참고한다.
				NCG_Read(), NCG_Seek(), NCG_Tell()는 사용할 수 없다.
	*****************************************************************/
	int		NCG_OpenAndVerifyFile(	const char	*szFilename,
									const int	nEnableRead,
									const int	bUsePOSIX,
									const int	nFlag,
									const int	nMode,
									OUT_HANDLE	NCG_File_Handle*	hFile);

	/*****************************************************************
	기능: NCG 헤더를 검증하고, 성공하면 핸들을 생성한다.
			실시간 다운로드&플레이 등 수행 시, 헤더 부분만 읽은 후
			검증을 수행할 수 있다.
			여기서 생성된 핸들은 nEnableRead = false와 같다.
			즉, NCG_Read(), NCG_Seek(), NCG_Tell() 등은 사용할 수 없다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	bszHeader_MIN2048	- NCG 파일의 헤더 버퍼.
								헤더의 길이가 가변이므로 여유있게 입력한다.
								일반적으로 헤더크기는 2048바이트 이하이다.
								만약 헤더 길이가 부족하다면
								nHeader 에 필요한 헤더 길이를 저장한다.
			nHeaderLen		- bszHeader의 길이.
								만약 헤더의 정보가 부족하면, 즉 길이가 짧으면
								함수는 에러코드를 반환하고
								이 값에 필요한 헤더값이 저장된다.
								이 값 크기만큼 버퍼를 새로 읽어서
								함수를 재호출해야한다.
			hFile			- 헤더 검증에 성공하면 핸들을 반환한다.
			nFilesize		- 파일 크기.
								헤더 등을 포함한 NCG 파일 전체 크기를
								알 수 있다면 입력한다.
			nContentSize	- 헤더를 제외한 순수한 컨텐츠 크기를 반환한다.
								nFilesize 이 입력되었을 때에만 반환할 수 있다.
								nFilesize 가 0이라면 헤더 크기를 반환한다.
	*****************************************************************/
	int		NCG_OpenAndVerifyHeader(const unsigned char	*bszHeader_MIN2048,
									IN_OUT int	*nHeaderLen,
									OUT_HANDLE	NCG_File_Handle*	hFile,
						OPTIONAL	const int	nFilesize,
						OPTIONAL	OUT_REF	int	*nContentsSize);

	/*****************************************************************
	기능: NCG 파일을 강제로 복호하기 위하여 키를 설정한다.
	헤더 검증은 하지 않으며, 복호를 위하여 길이측정만 한다.
	반환: 없음
	인자:	hFile		- NCG 파일 핸들.
			bszCEK		- 컨텐츠 복호 키.
	*****************************************************************/
	void	NCG_SetCEKForce(	const NCG_File_Handle	hFile,
								const unsigned char		*bszCEK);

	/*****************************************************************
	기능: NCG 파일인지 판단한다.
	반환: true(1) 또는 false(0) 또는 에러코드.
	인자:	szFilename		- NCG 파일 이름. 절대 경로를 입력해야 한다.
	*****************************************************************/
	int		NCG_IsNCGFile(	const char	*szFilename );

	/*****************************************************************
	기능: NCG 파일의 헤더인지 판단한다.
	반환: true(1) 또는 false(0) 또는 에러코드.
	인자:	bszHeader		- NCG 파일의 헤더 버퍼.
								16바이트 이상이면 NCG 헤더인지 판단할 수 있다.
	*****************************************************************/
	int		NCG_IsNCGHeader(	const unsigned char	*bszHeader_MIN16 );

	/*****************************************************************
	기능: NCG 파일 헤더 정보를 반환한다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hFile			- NCG 파일 핸들.
			ncgHeaderInfo	- NCG 컨텐츠의 헤더 정보.
	*****************************************************************/
	int		NCG_GetHeaderInfo(	const NCG_File_Handle			hFile,
								OUT_RESOURCE NCG_Header_Info	**ncgHeaderInfo);
	
	/*****************************************************************
	기능: NCG 파일 헤더 정보 중 Contents ID, Site ID, Acquisition URL을
		바로 반환한다. free() 금지.
	반환: 해당 값에 대한 포인터 또는 NULL.
	인자:	hFile			- NCG 파일 핸들.
	*****************************************************************/
	OUT_RESOURCE	char*	NCG_GetContentsID	(const NCG_File_Handle	hFile);
	OUT_RESOURCE	char*	NCG_GetSiteID		(const NCG_File_Handle	hFile);
	OUT_RESOURCE	char*	NCG_AcquisitionURL	(const NCG_File_Handle	hFile);
	
	/*****************************************************************
	기능: NCG 파일에 대한 라이센스를 찾아 라이센스 핸들을 반환한다.
	반환: 복호가능(NCGERR_SUCCEED(0x00)) 또는 에러코드.
	인자:	hCore		- NCG_Agent 핸들.
			hFile		- NCG 파일 핸들.
			hLic		- NCG 파일에 관련된 라이센스 핸들
			nLicCount	- 라이센스 갯수.
	*****************************************************************/
	int		NCG_GetLicensesHandle(	const NCG_Core_Handle			hCore,
									const NCG_File_Handle			hFile,
									OUT_HANDLE	NCG_License_Handle	*hLic,
						OPTIONAL	OUT_REF int				*nLicCount);

	/*****************************************************************
	기능: 라이센스 핸들의 nIndex 번째 값을 가져온다
	반환: 복호가능(NCGERR_SUCCEED(0x00)) 또는 에러코드.
	인자:	hLic			- NCG 라이센스 핸들
			nIndex			- 조회할 라이센스 정보의 인덱스.
			ncgLicenseInfo	- 라이센스 정보
	*****************************************************************/
	int		NCG_GetLicensesInfo(const NCG_License_Handle		*hLic,
								const int						nIndex,
								OUT_RESOURCE NCG_License_Info	**ncgLicenseInfo);	
	
	/*****************************************************************
	기능: NCG 파일에 라이센스 중, 사용할 라이센스를 설정한다.
			내부에서 사용가능한지 검증하는 단계를 거치며,
			여기서 검증이 실패(횟수 부족, 기간만료 등)하면 복호화가 되지 않는다.
			bszCEK_MIN32에 메모리를 할당하여 전달하면,
			복호용 키를 반환받는다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hFile			- NCG 파일 핸들.
			hLic			- NCG 라이센스 핸들.
			nIndex			- 사용할 라이센스 인덱스.
			szCurrentGMT	- 현재 GMT 시간.
								이 기간을 기준으로 라이센스 만료 여부를 확인한다.
								SDK 내부에서는 기기 시간을 얻어올 수 없으므로
								어플리케이션에서 현재 시간을 얻어서 입력한다.
								라이센스 발급 서버가 설정하는 시간이
								GMT일 수도 LOCAL일 수도 있으므로 그에 맞춘다.
								기본은 GMT이다.
			nCurrentGMT		- 현재 GMT 시간을 변환한 숫자.
								반드시 NCG_ConvertGMTtoCount()를 사용하여
								변환된 값이어야 한다.
								여기에 0보다 큰 값이 들어오면,
								szCurrentGMT 대신 이 값을 사용한다.
			bszCEK_MIN32	- 복호 키.
	*****************************************************************/
	int		NCG_SetLicense(	const NCG_File_Handle		hFile,
							const NCG_License_Handle	hLic,
							const int					nIndex,
							const char					*szCurrentGMT,
							const unsigned long			nCurrentGMT,
				OPTIONAL	OUT_REF	unsigned char		*bszCEK_MIN32);
	

	/*****************************************************************
	기능: 파일이 현재 사용중인 라이센스 정보를 가져온다
	반환: 복호가능(NCGERR_SUCCEED(0x00)) 또는 에러코드.
	인자:	hFile			- NCG 파일 핸들.
			ncgLicenseInfo	- 라이센스 정보
	*****************************************************************/
	int		NCG_GetLicensesInfoOfFile(const NCG_File_Handle			*hFile,
									  OUT_RESOURCE NCG_License_Info	**ncgLicenseInfo);	
	
	/*****************************************************************
	기능: NCG 라이센스 핸들을 정리한다.
	*****************************************************************/
	void	NCG_ClearLicenseHandle(IN_OUT NCG_License_Handle	*hLic);

	/*****************************************************************
	기능: NCG 파일 재생횟수를 1 차감한다.
			차감 후 바로 DB에 저장한다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hCore			- NCG_Agent 핸들.
			hFile			- NCG 파일 핸들.
			nRemainCount	- 차감함 후 남은 재생 횟수.
	*****************************************************************/
	int		NCG_DecreaseRemainPlayCount(const NCG_Core_Handle	hCore,
										const NCG_File_Handle	hFile,
							OPTIONAL	OUT_REF int				*nRemainPlayCount);

	/*****************************************************************
	 기능: NCG 파일과 연결된 Contents 라이센스를 삭제한다.
			해당 파일은, 라이센스를 다시 획득할 때까지 사용할 수 없다.
	 반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	 인자:	hCore	- NCG_Agent 핸들.
			hFile	- NCG 파일 핸들.
	 *****************************************************************/
	int		NCG_RemoveContentsLicense(	const NCG_Core_Handle	hCore,
										const NCG_File_Handle	hFile);
	
	/*****************************************************************
	기능: Contents ID에 해당하는 Contents 라이센스를 삭제한다.
			해당 ID를 사용하는 파일은, 라이센스를 다시 획득할 때까지 사용할 수 없다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hCore	- NCG_Agent 핸들.
			szCID	- Contents ID.
	*****************************************************************/
	int		NCG_RemoveContentsLicenseWithCID(	const NCG_Core_Handle	hCore,
												const char				*szCID);
	
	/*****************************************************************
	기능: NCG 파일과 연결된 Site 라이센스를 삭제한다.
			해당 파일 뿐만이 아니라 동일한 Site ID를 갖는 파일에 영향을 미친다.
			개별 컨텐츠에 대한 라이센스에는 영향을 미치지 않지만,
			월정액과 같은 그룹 시나리오에서는 사용에 주의한다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hCore	- NCG_Agent 핸들.
			hFile	- NCG 파일 핸들.
	 *****************************************************************/
	int		NCG_RemoveSiteLicense(	const NCG_Core_Handle	hCore,
									  const NCG_File_Handle	hFile);
	
	/*****************************************************************
	기능: Site ID에 해당하는 Contents 라이센스를 삭제한다.
			동일한 Site ID를 갖는 파일에 영향을 미친다.
			개별 컨텐츠에 대한 라이센스에는 영향을 미치지 않지만,
			월정액과 같은 그룹 시나리오에서는 사용에 주의한다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hCore	- NCG_Agent 핸들.
			szSID	- Site ID.
	*****************************************************************/
	int		NCG_RemoveSiteLicenseWithSID(	const NCG_Core_Handle	hCore,
											const char				*szSID);
	
	/*****************************************************************
	기능: NCG 파일을 읽는다. 복호된 데이터가 저장된다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hFile		- NCG 파일 핸들.
			nToReadLen	- 읽어올 파일 길이.
			bszBuff		- 복호된 NCG 컨텐츠 데이터.
			nReadedLen	- 실제로 읽어서 복호한, 즉 bszBuff에 저장한 길이.
	호출가능:
		NCG_OpenAndVerifyFile() 호출 시 nEnableRead = true
	호출불가(에러코드 반환):
		NCG_OpenAndVerifyFile() 호출 시 nEnableRead = false
		NCG_OpenAndVerifyHeader() 호출 시
	*****************************************************************/
	int		NCG_Read(	const NCG_File_Handle	hFile,
						const unsigned long		nToReadLen,
						OUT_REF unsigned char	*bszBuff,
						OUT_REF	unsigned long	*nReadedLen);

	/*****************************************************************
	기능: NCG 파일 오프셋을 이동한다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hFile		- NCG 파일 핸들.
			nOffset		- 이동할 길이.
			nMethod		- 이동 기준점.
							fseek()와 같이
							SEEK_SET, SEEK_CUR, SEEK_END 중 하나를 입력한다.
	호출가능:
		NCG_OpenAndVerifyFile() 호출 시 nEnableRead = true
	호출불가(에러코드 반환):
		NCG_OpenAndVerifyFile() 호출 시 nEnableRead = false
		NCG_OpenAndVerifyHeader() 호출 시
	*****************************************************************/
	int		NCG_Seek(	const NCG_File_Handle	hFile,
						const long				nOffset,
						const int				nMethod);

	/*****************************************************************
	기능: NCG 파일 오프셋을 이동하고 현재 위치를 반환한다.
	반환: 0보다 큰 정수 또는 -1.
	인자:	hFile		- NCG 파일 핸들.
			nOffset		- 이동할 길이.
			nMethod		- 이동 기준점.
							lseek()와 같이
							SEEK_SET, SEEK_CUR, SEEK_END 중 하나를 입력한다.
	호출가능:
		NCG_OpenAndVerifyFile() 호출 시 nEnableRead = true
												bUsePOSIX   = false
	호출불가(-1 반환):
		NCG_OpenAndVerifyFile() 호출 시 nEnableRead = false
		NCG_OpenAndVerifyHeader() 호출 시
	*****************************************************************/
	int		NCG_Lseek(	const NCG_File_Handle	hFile,
						const long				nOffset,
						const int				nMethod);

	/*****************************************************************
	기능: NCG 파일 오프셋의 위치를 반환한다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hFile		- NCG 파일 핸들.
			nOffset		- NCG 파일 오프셋 위치 값.
	호출가능:
		NCG_OpenAndVerifyFile() 호출 시 nEnableRead = true
												bUsePOSIX   = true
	호출불가(에러코드 반환):
		NCG_OpenAndVerifyFile() 호출 시 nEnableRead = false
		NCG_OpenAndVerifyHeader() 호출 시
	*****************************************************************/
	int		NCG_Tell(	const NCG_File_Handle	hFile,
						OUT_REF	unsigned int	*nOffset);

	/*****************************************************************
	기능: 파일에 데이터를 쓴다. 평문, POSIX 사용시에만 가능하다.
	반환: 기록한 크기 (0보다 큰 정수) 또는 -1.
	인자:	hFile		- NCG 파일 핸들 (평문).
			bszBuff			- 기록할 데이터.
			nToWriteLen		- 기록할 데이터 길이.
	호출가능:
		NCG_OpenAndVerifyFile() 호출 시 nEnableRead = true
												bUsePOSIX   = true
												입력 파일이 평문
	호출불가(에러코드 반환):
		NCG_OpenAndVerifyFile() 호출 시 nEnableRead = false
		NCG_OpenAndVerifyHeader() 호출 시
	*****************************************************************/
	int		NCG_Write(	const NCG_File_Handle	hFile,
								const unsigned char	*bszBuff,
								const unsigned long	nToWriteLen);

	/*****************************************************************
	기능: 파일 정보를 가져온다.
	반환: 0 또는 -1.
	인자:	szFilename		- 파일 이름.
			statBuf			- 파일 정보.
	*****************************************************************/
	int		NCG_Stat(const char *szFilename,
							OUT_REF	struct stat *statBuf);

	/*****************************************************************
	기능: 파일 정보를 가져온다.  POSIX 사용시에만 가능하다.
	반환: 0 또는 -1.
	인자:	hFile		- NCG 파일 핸들.
			statBuf			- 파일 정보.
	호출가능:
		NCG_OpenAndVerifyFile() 호출 시 nEnableRead = true
												bUsePOSIX   = true
	호출불가(에러코드 반환):
		NCG_OpenAndVerifyFile() 호출 시 nEnableRead = false
		NCG_OpenAndVerifyHeader() 호출 시
	*****************************************************************/
	int		NCG_Fstat(	const NCG_File_Handle	hFile,
							OUT_REF	struct stat *statBuf);

	/*****************************************************************
	기능: NCG 파일내의 컨텐츠 크기를 반환한다.
			'NCG 파일 전체 크기 - NCG 헤더 크기'와 동일하다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hFile			- NCG 파일 핸들.
			nContentsSize	- NCG 파일내 컨텐츠 크기.
	*****************************************************************/
	int		NCG_GetContentsSize(const NCG_File_Handle	hFile,
								OUT_REF	unsigned int	*nContentsSize);

	/*****************************************************************
	기능: NCG 파일의 헤더 크기를 반환한다.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hFile			- NCG 파일 핸들.
			nHeaderSize		- NCG 파일 헤더 크기.
	 *****************************************************************/
	int		NCG_GetHeaderSize(	const NCG_File_Handle	hFile,
								OUT_REF	unsigned int	*nHeaderSize);

	/*****************************************************************
	기능: NCG 파일을 SDK 외부에서 읽은 후 복호화하는 경우에 사용한다.
			NCG_Decrypt()와 짝을 이루어야 한다.
			자세한 내용은 비고 참고.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hFile				- NCG 파일 핸들.
			nWantedStartOffset	- 읽기 시작할 파일 오프셋.
			nWantedSize			- 읽을 데이터 길이.
			nActualStartOffset	- 실제로 읽어야 할 파일 오프셋.
			nAcutalSize			- 실제로 읽어야 할 데이터 길이.
			nFrontGap			- 버릴 앞부분 길이.

	비고: 	NCG 파일은 chunk 단위로 암호화되므로,
			chunk 단위로만 복호가 가능하다.
			파일의 임의 부분부터 임의 길이 데이터를 복호하기 위해서 읽어야 할
			실제 파일 시작지점과 실제 길이,
			즉 chunk 시작 지점과 chunk 들의 길이를 계산하여 반환한다.
			이로 인하여 발생하는 시작 지점의 차이를 반환하므로
			복호가 끝난 후에, 시작 지점 차이만큼 데이터 앞부분을 버린다.

			예) 평문 컨텐츠 기준 offset:700 부터 10233 바이트를 읽고자 할 때.

			// 실제 위치, 길이 얻어오기.
			NCG_GetNewOffsetAndSize(hFile, 700, 10233,
									&nStart, &nSize, &nGap );

			// 실제 위치로 이동
			fseek(fp, nStart, SEEK_SET);

			// 실제 길이만큼 읽기
			fread(buff, 1, nSize, fp);
			
			// 복호
			NCG_Decrypt(hFile, buff, nSize);

			// 블록 앞부분은 건너뛰어 버리고 반환
			return buff + nGap;

	호출가능:
		NCG_OpenAndVerifyFile() 호출 시 nEnableRead = false
		NCG_OpenAndVerifyHeader() 호출 시
	호출불가(에러코드 반환):
		NCG_OpenAndVerifyFile() 호출 시 nEnableRead = true
	*****************************************************************/
	int		NCG_GetNewOffsetAndSize(const NCG_File_Handle	hFile,
									const unsigned long		nWantedStartOffset,
									const unsigned long		nWantedSize,
									OUT_REF	unsigned long	*nActualStartOffset,
									OUT_REF unsigned long	*nAcutalSize,
									OUT_REF	unsigned long	*nFrontGap);


	/*****************************************************************
	기능: NCG 데이터 chunk를 복호한다.
			데이터 입력이 chunk 단위가 아닌 경우, 복호화는 수행되지만
			잘못된 데이터로 복호될 수 있다.
			단, 파일 끝부분을 포함한 데이터는 chunk 단위가 아닐 수 있다.
			NCG_GetNewOffsetAndSize()와 짝을 이루어야 한다.
			자세한 내용은 NCG_GetNewOffsetAndSize()의 비고 참고.
	반환: NCGERR_SUCCEED(0x00) 또는 에러코드.
	인자:	hFile		- NCG 파일 핸들.
			bszData		- 암호화된 NCG 데이터 chunk.
			nDataLen	- NCG 데이터 길이.

	호출가능:
		NCG_OpenAndVerifyFile() 호출 시 nEnableRead = false
		NCG_OpenAndVerifyHeader() 호출 시
	호출불가(에러코드 반환):
		NCG_OpenAndVerifyFile() 호출 시 nEnableRead = true
	*****************************************************************/
	int		NCG_Decrypt(const NCG_File_Handle	hFile,
						IN_OUT unsigned char	*bszData,
						const unsigned int		nDataLen);

	/*****************************************************************
	기능: NCG 파일 핸들을 정리한다.
	반환: 없음
	인자:	hFile		- NCG 파일 핸들.
	*****************************************************************/
	void	NCG_ClearFileHandle(IN_OUT	NCG_File_Handle	*hFile);
	
	/*****************************************************************
	 기능: 입력받은 GMT 형태 시간 문자열을 숫자로 변환한다.
			2010-01-01T00:00:00Z으로부터 지난 초를 반환한다.
			(매 월은 31일로 가정)
			기간이 제한이 없는 무제한인 경우,
			즉 szGMTTime의 내용이 없는 경우는 -1 (0xffffffff)을 반환한다.
			szGMTTime 자체가 NULL 이면 0을 반환한다. 무제한과 혼동하지 않도록 주의해야한다.
	 반환:	변환한 초 (Sec)
	 인자:	szGMTTime	- GMT 형태 시간 문자열.
	 *****************************************************************/
	unsigned long	NCG_ConvertGMTtoCount(const char	*szGMTTime);
	
	

#ifdef  __cplusplus
}
#endif

#endif	// _NCG_AGENT_H



#ifndef	_NCG_ERROR_H
#define _NCG_ERROR_H

#ifdef  __cplusplus
extern "C" {
#endif
	
	// 성공. 에러 없음.
#define	NCGERR_SUCCEED					0x00000000
	
	// 특별히 정의되지 않은 에러.
#define NCGERR_FAILED					0xFFFFFFFF
	
	
	//////////////////////////////////////////////////////////////////////
	// SDK 핸들 관련
	//////////////////////////////////////////////////////////////////////
	// NCG_Core_Handle가 입력되지 않았거나 NULL 인 경우
#define	NCGERR_INVALID_NCG_CORE_HANDLE		0xF0000101
	
	// NCG_File_Handle가 입력되지 않았거나 NULL 인 경우
#define	NCGERR_INVALID_NCG_FILE_HANDLE		0xF0000102
	
	// NCG_OIDs_Handle가 입력되지 않았거나 NULL 인 경우
#define	NCGERR_INVALID_NCG_OIDS_HANDLE		0xF0000103
	
	// NCG_License_Handle가 입력되지 않았거나 NULL 인 경우
#define	NCGERR_INVALID_NCG_LICENSE_HANDLE	0xF0000104
	
	
	//////////////////////////////////////////////////////////////////////
	// 시스템 정보 관련
	//////////////////////////////////////////////////////////////////////
	// 디바이스 ID가 입력되지 않은 경우.
	// NULL로 끝나는 문자열이어야 한다.
#define	NCGERR_INVALID_DEVICE_ID		0xF0000201
	
	// 디바이스 모델명이 입력되지 않은 경우.
	// NULL로 끝나는 문자열이어야 한다.
#define	NCGERR_INVALID_DEVICE_MODEL		0xF0000202
	
	
	
	//////////////////////////////////////////////////////////////////////
	// NCG 라이센스 요청-수신-업데이트 관련
	//////////////////////////////////////////////////////////////////////
	// 메세지를 받지 못함
#define	NCGERR_NO_RESPONSE				0xF0000301
	
	// 잘못된 라이센스 요청 타입.
	// 내부에서 발생한다.
#define	NCGERR_INVALID_REQUEST_TYPE		0xF0000302
	
	// Session ID를 입력하지 않거나 잘못된 경우.
#define	NCGERR_INVALID_SESSION_ID		0xF0000303
	
	// User ID를 입력하지 않거나 잘못된 경우.
#define	NCGERR_INVALID_USER_ID			0xF0000304
	
	// Password를 입력하지 않았거나 잘못된 경우
#define	NCGERR_INVALID_PASSWORD			0xF0000305
	
	// Content ID를 입력하지 않았거나,
	// NCG 파일 내의 CID가 손상되었거나 가져오지 못함.
#define	NCGERR_INVALID_CONTENT_ID		0xF0000306
	
	// Side ID를 입력하지 않았거나,
	// NCG 파일 내의 SID가 손상되었거나 가져오지 못함.
#define	NCGERR_INVALID_SITE_ID			0xF0000307
	
	// Reserved.
#define NCGERR_INVALID_GROUP_ID			0xF0000308
	
	// 서버에 전송할 클라이언트 Diffie-Hellman 키 생성 실패
#define	NCGERR_GENERATE_DH_KEY_FAIL		0xF0000309
	
	// 수신한 메시지가 xml 형식이 아님.
#define	NCGERR_INVALID_XML_RESPONSE		0xF000030A
	
	
	//////////////////////////////////////////////////////////////////////
	// 서버로 부터 수신한 메시지가 RO (Right Object, License)인 경우
	// RO 메세지의 형식이 올바르지 않음.
	// XML 문자열 자체가 손상되었거나,
	// 반드시 필요한 필드가 없는 경우이다.
#define	NCGERR_INVALID_RO_RESPONSE		0xF0000321
	
	// RO 메세지가 손상됨. (= 해시 검증 실패)
#define	NCGERR_INVALID_RO_RESPONSE_HASH	0xF0000322
	
	// RO 메세지에 포함된 Diffie-Hellman 값 가져오기 실패.
#define	NCGERR_INVALID_RO_RESPONSE_B	0xF0000323
	
	// 클라이언트 Diffie-Hellman 값이 존재하지 않았는데 서버로부터 값 받음.
	// 라이센스 요청 메시지 생성 단계에 오류가 있었는데 무시하고 요청한 경우
	// 요청 - 응답처리 짝을 맞추지 않은 경우에 발생한다.
	// 동시에 여러 요청과 응답을 처리할 수 없다.
	// 반드시 요청-처리, 요청-처리를 1:1로 처리해야 한다.
#define	NCGERR_NO_CLIENT_DH_KEY			0xF0000324
	
	// RO에 포함된 라이센스 형식 (XML) 오류.
#define	NCGERR_INVALID_LICENSE			0xF0000325
	
	// RO에 포함된 라이센스 타입 오류.
	// RO에 <cid> 혹은 <sid> 중 하나가 반드시 포함되어야 한다.
#define	NCGERR_INVALID_LICENSE_TYPE		0xF0000326
	
	// RO에 <cid> 가 포함되어 있으나 잘못된 라이센스.
	// <cid> RO XML 파싱에 실패한 경우이다.
#define	NCGERR_INVALID_CID_LICENSE_XML	0xF0000327
	
	// RO에 <sid> 가 포함되어 있으나 잘못된 라이센스.
	// <sid> RO XML 파싱에 실패한 경우이다.
#define	NCGERR_INVALID_SID_LICENSE_XML	0xF0000328
	
	// cid/sid RO에 포함된 <permission> XML 오류.
#define	NCGERR_INVALID_PERMISSION_XML	0xF0000329
	
	// RO는 정상이나 기기에 정보 업데이트 실패.
#define	NCGERR_UPDATE_LICENSE_FAIL		0xF000032A
	
	//////////////////////////////////////////////////////////////////////
	// 서버로 부터 수신한 메시지가 구매 URL 혹은 주문 ID 목록인 경우
	// 수신한 메시지 안에 OID가 더이상 없음.
	// 에러는 아닌 일반적인 상황이며, 내부에서 발생한다.
#define	NCGERR_INVALID_OID_LIST			0xF0000331
	
	// 함수 호출시 입력한 주문 ID 인덱스가 범위를 벗어남.
	// 0보다 작거나, 서버로부터 받은 주문 ID 갯수를 초과한 경우.
#define NCGERR_ORDERID_INDEX_OVERFLOW	0xF0000332
	
	// 구매 URL XML이 잘못됨.
#define NCGERR_INVALID_PURCHASE_URL		0xF0000333
	
	
	//////////////////////////////////////////////////////////////////////
	// NCG 라이센스 보관소 관련
	//////////////////////////////////////////////////////////////////////
	
	// 입력받은 DB 경로가 너무 김.
	// 경로길이가 230 이하여야 함
#define	NCGERR_TOO_LONG_LICENSE_DB_PATH	0xF0000401
	
	// 저장된 비밀값이 일치하지 않음.
	// 라이센스 파일 백업본이 존재할 가능성이 있음.
	// 횟수제를 사용할 때에 보안을 위해서 필요하다.
#define NCGERR_RANDOM_SECRET_MISMATCH	0xF0000402
	
	// CID DB 열기 실패
#define NCGERR_CID_DB_OPEN_FAIL			0xF0000411
	
	// CID DB 읽기 실패
#define NCGERR_CID_DB_READ_FAIL			0xF0000412
	
	// CID DB 쓰기 실패
#define NCGERR_CID_DB_WRITE_FAIL		0xF0000413
	
	// CID DB 삭제 실패
#define	NCGERR_CID_DB_DELETE_FAIL		0xF0000414
	
	// SID DB 열기 실패
#define NCGERR_SID_DB_OPEN_FAIL			0xF0000415
	
	// SID DB 읽기 실패
#define NCGERR_SID_DB_READ_FAIL			0xF0000416
	
	// SID DB 쓰기 실패
#define NCGERR_SID_DB_WRITE_FAIL		0xF0000417
	
	// SID DB 삭제 실패
#define	NCGERR_SID_DB_DELETE_FAIL		0xF0000418

	// DB 덤프 파일 생성 실패
#define	NCGERR_DUMP_CREATE_FAIL			0xF0000421
	
	
	//////////////////////////////////////////////////////////////////////
	// NCG 컨텐츠 관련
	//////////////////////////////////////////////////////////////////////
	// NCG 헤더가 존재하지 않거나 손상.
	// NCG 파일이 아닐 수 있다.
#define	NCGERR_INVALID_NCG_HEADER		0xF0000501
	
	// NCG 헤더가 손상 (= 해시 검증 실패).
#define NCGERR_MODIFIED_NCG_HEADER		0xF0000502
	
	// NCG 헤더에 포함된 XML에 오류가 있음.
#define	NCGERR_INVALID_NCG_XML_HEADER	0xF0000503
	
	// NCG 헤더 길이가 더 필요함.
	// 함수 설명에 따라 필요한 버퍼를 읽어들인 후 다시 호출한다.
#define NCGERR_NEEDED_MORE_HEADER_DATA	0xF0000504
	
	// NCG_Open() 시에 파일을 직접 열도록 지정하지 않고
	// NCG_Read(), NCG_Seek() 등을 호출할 때 발생한다.
#define NCGERR_NOT_ALLOWED_CALL			0xF0000511
	
	// NCG 파일 열기 실패.
	// 파일 존재하지 않음, 디렉토리 접근 권한 없음,
	// 시스템 문자열 인코딩으로 인해 찾을 수 없는 경우에 발생한다.
#define	NCGERR_FILE_OPEN_FAIL			0xF0000512
	
	// NCG 파일 포인터 이동 실패.
#define NCGERR_FILE_SEEK_FAIL			0xF0000513
	
	// NCG 파일 읽기 실패.
#define NCGERR_FILE_READ_FAIL			0xF0000514
	
	
	
	//////////////////////////////////////////////////////////////////////
	// NCG 컨텐츠 - 라이센스 관련
	//////////////////////////////////////////////////////////////////////
	// 기기에 저장된 라이센스가 없음.
	// 즉, 어떠한 NCG 파일도 열 수 없음
#define	NCGERR_NO_LICENSES_IN_DEVICE	0xF0000601
	
	// NCG 파일을 열기 위한 라이센스(CID)가 없음.
	// CID 라이센스는 반드시 필요하며,
	// SID 라이센스는 추가적으로 있을 수도, 없을 수도 있다.
#define	NCGERR_NO_LICENSE_FOR_FILE		0xF0000602 // must required
	
	// 함수 호출시 입력한 라이센스 인덱스가 범위를 벗어남.
	// 0보다 작거나, 라이센스 핸들이 가진 라이센스 갯수를 초과한 경우.
#define NCGERR_LICENSE_INDEX_OVERFLOW	0xF0000603
	
	// 재생 횟수가 무제한인 컨텐츠에 대한 재생 횟수 차감 시도
#define NCGERR_UNLIMITED_PLAYCOUNT		0xF0000604
	
	// 재생시간을 비교할 문자열, 즉 현재 시간이 올바른 GMT 포멧이 아님.
	// 반드시 2010-01-01T12:34:56Z 형태이어야 한다.
#define NCGERR_INVALID_GMT_FORMAT		0xF0000605
	
	// 현재 시간이 잘못된 값이 입력됨.
#define NCGERR_INVALID_CURRENT_GMT		0xF0000606

	// NCG 파일을 복호화할 권한이 지정되지 않은 상태에서 복호 시도.
	// 라이센스 설정( NCG_SetLicense() )에서 실패했음에도 복호 시도 했을 때 등.
#define NCGERR_NO_PERMISSION_FOR_FILE	0xF0000607
	
	// NCG 파일을 열 수 있는 기간 이전.
#define NCGERR_BEFORE_START_DATE		0xF0000611
	
	// NCG 파일을 열 수 있는 기간 이후. 즉 만료.
#define NCGERR_AFTER_END_DATE			0xF0000612
	
	// 재생 횟수가 만기된 컨텐츠에 대한 재생 횟수 차감 시도
	// 혹은 재생시도할 때 재생 횟수 만료
#define NCGERR_PLAYCOUNT_EXHAUSTION		0xF0000613
	
	// 라이센스 DB에서 CID 삭제 실패. 해당 CID가 없는 경우이다.
#define	NCGERR_CID_LICENSE_REMOVE_FAIL	0xF0000621
	
	// 라이센스 DB에서 SID 삭제 실패. 해당 SID가 없는 경우이다.
#define	NCGERR_SID_LICENSE_REMOVE_FAIL	0xF0000622

	// 라이센스 핸들을 요청했으나, 파일이 평문일 때
	// NCG_SetLicense() 나 NCG_SetCEKForce() 없이 read 를 할 수 있다.
#define	NCGERR_PLAIN_FILE				0xF0000631	
	
	
	
	//////////////////////////////////////////////////////////////////////
	// NCG 기타 에러
	//////////////////////////////////////////////////////////////////////
	// 메모리 할당 실패.
#define	NCGERR_MEMOEY_ALLOCATION_FAIL	0xF0001001
	
	// 함수 입력 파라미터가 올바르지 않은 경우.
	// OPTIONAL이 아닌 필요한 변수에 NULL 이 입력될 때 주로 발생.
#define NCGERR_INVALID_PARAMETER		0xF0001002
	
	// BASE64 인코딩 실패.
	// 라이센스 요청시 사용된다.
#define	NCGERR_BASE64ENCODE				0xF0001011
	
	// BASE64 디코딩 실패.
	// 라이센스 수신시 사용된다.
#define	NCGERR_BASE64DECODE				0xF0001012
	
	// URL 인코딩 실패.
	// 라이센스 요청시 사용된다.
#define	NCGERR_URLENCODE				0xF0001013
	
	// 오류 체크용 매크로
#define Succeed(x)	(x)	== NCGERR_SUCCEED
#define	Failed(x)	(x) != NCGERR_SUCCEED
	
#ifdef  __cplusplus
}
#endif

#endif	// _NCG_ERROR_H



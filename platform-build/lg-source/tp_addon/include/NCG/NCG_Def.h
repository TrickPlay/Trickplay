#ifndef	_NCG_DEF_H
#define _NCG_DEF_H

// Response Message type
#define NCG_RESPONSE_TYPE_UNKNOWN		0	// 미확인
#define NCG_RESPONSE_TYPE_LOGIN			1	// 로그인 응답
#define NCG_RESPONSE_TYPE_RO			2	// Right Object
#define NCG_RESPONSE_TYPE_OID			3	// 주문 ID 목록
#define NCG_RESPONSE_TYPE_PURCHASE_URL	4	// 구매 URL

// Verification Type
#define NCG_VERIFY_UNKNOWN	-1
#define NCG_VERIFY_OFFLINE	0
#define NCG_VERIFY_ONLINE	1

// Contents Encryption Key 길이
#define	NCG_CEK_LEN			32

// 핸들 포인터를 반환한다.
// 내부에서 메모리를 할당(malloc)해서 반환하므로,
// 변수를 참조(&)하거나 메모리를 미리 할당하지 말고
// 아무것도 가리키지 않는 순수한 포인터를 입력 인자로 넣는다.
// 사용이 끝나면 반드시 ~~_Clear() 함수를 호출해서 정리해야 한다.
#ifndef OUT_HANDLE	
#define OUT_HANDLE
#endif

// 리소스나 상수 포인터를 반환한다.
// free() 등을 호출하면 안된다.
#ifndef OUT_RESOURCE	
#define OUT_RESOURCE
#endif

// malloc() 된 포인터를 반환한다.
// 사용이 끝나면 반드시 free() 를 호출해서 정리해야 한다.
#ifndef OUT_ALLOC	
#define OUT_ALLOC
#endif

// 일반적인 call by reference 를 의미한다.
// 변수 정의 뒤에 '_MIN숫자'에 표시된 숫자 이상 할당되어야 한다.
// OUT_REF char* szReqMsg_MIN2048 // 최소 2048개 이상 할당된 배열/포인터 필요
// 뒤에 _MIN숫자 가 없으면 1개(배열 아닌 일반변수)` 있으면 된다.
#ifndef OUT_REF	
#define OUT_REF
#endif

// 입력받은 포인터 변수나 핸들의 값이 바뀐다.
// 상수를 입력하면 안된다.
#ifndef	IN_OUT
#define	IN_OUT
#endif

// 해당 값이 현재단계에서 사용할 수 없거나, 필요치 않은 경우에는
// NULL 혹은 숫자 0 을 입력할 수 있는 변수이다.
#ifndef	OPTIONAL
#define	OPTIONAL
#endif

typedef	void*	NCG_Core_Handle;
typedef void*	NCG_File_Handle;
typedef	void*	NCG_OIDs_Handle;
typedef	void*	NCG_License_Handle;

typedef struct _NCG_Header_Info
{
	// NCG 파일 내에 포함된 정보
	char	szContentsID[33];
	char	szSiteID[5];
	char	szAcquisitionURL[257];
	char	szSource[129];
	char	szPackDate[28];
	int		nEncryptionLevel;
	int		nRange;
} NCG_Header_Info;

typedef struct _NCG_License_Info 
{
	// 파일에 대한 라이센스 정보
	// 재생 권한 정보
	char	szPlayStartDate[28];
	char	szPlayEndDate[28];
	int		nPlayVerificationMethod;
	long	nPlayDurationHour;
	long	nPlayTotalCount;
	long	nPlayRemainCount;

	// 현재 버전에서는 다른 기기로 전송은 지원하지 않는다.
} NCG_License_Info;

#endif	// _NCG_DEF_H


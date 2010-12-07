#ifndef	_NCG_DEF_H
#define _NCG_DEF_H

// Response Message type
#define NCG_RESPONSE_TYPE_UNKNOWN		0	// ��Ȯ��
#define NCG_RESPONSE_TYPE_LOGIN			1	// �α��� ����
#define NCG_RESPONSE_TYPE_RO			2	// Right Object
#define NCG_RESPONSE_TYPE_OID			3	// �ֹ� ID ���
#define NCG_RESPONSE_TYPE_PURCHASE_URL	4	// ���� URL

// Verification Type
#define NCG_VERIFY_UNKNOWN	-1
#define NCG_VERIFY_OFFLINE	0
#define NCG_VERIFY_ONLINE	1

// Contents Encryption Key ����
#define	NCG_CEK_LEN			32

// �ڵ� �����͸� ��ȯ�Ѵ�.
// ���ο��� �޸𸮸� �Ҵ�(malloc)�ؼ� ��ȯ�ϹǷ�,
// ������ ����(&)�ϰų� �޸𸮸� �̸� �Ҵ����� ����
// �ƹ��͵� ����Ű�� �ʴ� ������ �����͸� �Է� ���ڷ� �ִ´�.
// ����� ������ �ݵ�� ~~_Clear() �Լ��� ȣ���ؼ� �����ؾ� �Ѵ�.
#ifndef OUT_HANDLE	
#define OUT_HANDLE
#endif

// ���ҽ��� ��� �����͸� ��ȯ�Ѵ�.
// free() ���� ȣ���ϸ� �ȵȴ�.
#ifndef OUT_RESOURCE	
#define OUT_RESOURCE
#endif

// malloc() �� �����͸� ��ȯ�Ѵ�.
// ����� ������ �ݵ�� free() �� ȣ���ؼ� �����ؾ� �Ѵ�.
#ifndef OUT_ALLOC	
#define OUT_ALLOC
#endif

// �Ϲ����� call by reference �� �ǹ��Ѵ�.
// ���� ���� �ڿ� '_MIN����'�� ǥ�õ� ���� �̻� �Ҵ�Ǿ�� �Ѵ�.
// OUT_REF char* szReqMsg_MIN2048 // �ּ� 2048�� �̻� �Ҵ�� �迭/������ �ʿ�
// �ڿ� _MIN���� �� ������ 1��(�迭 �ƴ� �Ϲݺ���)` ������ �ȴ�.
#ifndef OUT_REF	
#define OUT_REF
#endif

// �Է¹��� ������ ������ �ڵ��� ���� �ٲ��.
// ����� �Է��ϸ� �ȵȴ�.
#ifndef	IN_OUT
#define	IN_OUT
#endif

// �ش� ���� ����ܰ迡�� ����� �� ���ų�, �ʿ�ġ ���� ��쿡��
// NULL Ȥ�� ���� 0 �� �Է��� �� �ִ� �����̴�.
#ifndef	OPTIONAL
#define	OPTIONAL
#endif

typedef	void*	NCG_Core_Handle;
typedef void*	NCG_File_Handle;
typedef	void*	NCG_OIDs_Handle;
typedef	void*	NCG_License_Handle;

typedef struct _NCG_Header_Info
{
	// NCG ���� ���� ���Ե� ����
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
	// ���Ͽ� ���� ���̼��� ����
	// ��� ���� ����
	char	szPlayStartDate[28];
	char	szPlayEndDate[28];
	int		nPlayVerificationMethod;
	long	nPlayDurationHour;
	long	nPlayTotalCount;
	long	nPlayRemainCount;

	// ���� ���������� �ٸ� ���� ������ �������� �ʴ´�.
} NCG_License_Info;

#endif	// _NCG_DEF_H


#ifndef	_NCG_ERROR_H
#define _NCG_ERROR_H

#ifdef  __cplusplus
extern "C" {
#endif
	
	// ����. ���� ����.
#define	NCGERR_SUCCEED					0x00000000
	
	// Ư���� ���ǵ��� ���� ����.
#define NCGERR_FAILED					0xFFFFFFFF
	
	
	//////////////////////////////////////////////////////////////////////
	// SDK �ڵ� ����
	//////////////////////////////////////////////////////////////////////
	// NCG_Core_Handle�� �Էµ��� �ʾҰų� NULL �� ���
#define	NCGERR_INVALID_NCG_CORE_HANDLE		0xF0000101
	
	// NCG_File_Handle�� �Էµ��� �ʾҰų� NULL �� ���
#define	NCGERR_INVALID_NCG_FILE_HANDLE		0xF0000102
	
	// NCG_OIDs_Handle�� �Էµ��� �ʾҰų� NULL �� ���
#define	NCGERR_INVALID_NCG_OIDS_HANDLE		0xF0000103
	
	// NCG_License_Handle�� �Էµ��� �ʾҰų� NULL �� ���
#define	NCGERR_INVALID_NCG_LICENSE_HANDLE	0xF0000104
	
	
	//////////////////////////////////////////////////////////////////////
	// �ý��� ���� ����
	//////////////////////////////////////////////////////////////////////
	// ����̽� ID�� �Էµ��� ���� ���.
	// NULL�� ������ ���ڿ��̾�� �Ѵ�.
#define	NCGERR_INVALID_DEVICE_ID		0xF0000201
	
	// ����̽� �𵨸��� �Էµ��� ���� ���.
	// NULL�� ������ ���ڿ��̾�� �Ѵ�.
#define	NCGERR_INVALID_DEVICE_MODEL		0xF0000202
	
	
	
	//////////////////////////////////////////////////////////////////////
	// NCG ���̼��� ��û-����-������Ʈ ����
	//////////////////////////////////////////////////////////////////////
	// �޼����� ���� ����
#define	NCGERR_NO_RESPONSE				0xF0000301
	
	// �߸��� ���̼��� ��û Ÿ��.
	// ���ο��� �߻��Ѵ�.
#define	NCGERR_INVALID_REQUEST_TYPE		0xF0000302
	
	// Session ID�� �Է����� �ʰų� �߸��� ���.
#define	NCGERR_INVALID_SESSION_ID		0xF0000303
	
	// User ID�� �Է����� �ʰų� �߸��� ���.
#define	NCGERR_INVALID_USER_ID			0xF0000304
	
	// Password�� �Է����� �ʾҰų� �߸��� ���
#define	NCGERR_INVALID_PASSWORD			0xF0000305
	
	// Content ID�� �Է����� �ʾҰų�,
	// NCG ���� ���� CID�� �ջ�Ǿ��ų� �������� ����.
#define	NCGERR_INVALID_CONTENT_ID		0xF0000306
	
	// Side ID�� �Է����� �ʾҰų�,
	// NCG ���� ���� SID�� �ջ�Ǿ��ų� �������� ����.
#define	NCGERR_INVALID_SITE_ID			0xF0000307
	
	// Reserved.
#define NCGERR_INVALID_GROUP_ID			0xF0000308
	
	// ������ ������ Ŭ���̾�Ʈ Diffie-Hellman Ű ���� ����
#define	NCGERR_GENERATE_DH_KEY_FAIL		0xF0000309
	
	// ������ �޽����� xml ������ �ƴ�.
#define	NCGERR_INVALID_XML_RESPONSE		0xF000030A
	
	
	//////////////////////////////////////////////////////////////////////
	// ������ ���� ������ �޽����� RO (Right Object, License)�� ���
	// RO �޼����� ������ �ùٸ��� ����.
	// XML ���ڿ� ��ü�� �ջ�Ǿ��ų�,
	// �ݵ�� �ʿ��� �ʵ尡 ���� ����̴�.
#define	NCGERR_INVALID_RO_RESPONSE		0xF0000321
	
	// RO �޼����� �ջ��. (= �ؽ� ���� ����)
#define	NCGERR_INVALID_RO_RESPONSE_HASH	0xF0000322
	
	// RO �޼����� ���Ե� Diffie-Hellman �� �������� ����.
#define	NCGERR_INVALID_RO_RESPONSE_B	0xF0000323
	
	// Ŭ���̾�Ʈ Diffie-Hellman ���� �������� �ʾҴµ� �����κ��� �� ����.
	// ���̼��� ��û �޽��� ���� �ܰ迡 ������ �־��µ� �����ϰ� ��û�� ���
	// ��û - ����ó�� ¦�� ������ ���� ��쿡 �߻��Ѵ�.
	// ���ÿ� ���� ��û�� ������ ó���� �� ����.
	// �ݵ�� ��û-ó��, ��û-ó���� 1:1�� ó���ؾ� �Ѵ�.
#define	NCGERR_NO_CLIENT_DH_KEY			0xF0000324
	
	// RO�� ���Ե� ���̼��� ���� (XML) ����.
#define	NCGERR_INVALID_LICENSE			0xF0000325
	
	// RO�� ���Ե� ���̼��� Ÿ�� ����.
	// RO�� <cid> Ȥ�� <sid> �� �ϳ��� �ݵ�� ���ԵǾ�� �Ѵ�.
#define	NCGERR_INVALID_LICENSE_TYPE		0xF0000326
	
	// RO�� <cid> �� ���ԵǾ� ������ �߸��� ���̼���.
	// <cid> RO XML �Ľ̿� ������ ����̴�.
#define	NCGERR_INVALID_CID_LICENSE_XML	0xF0000327
	
	// RO�� <sid> �� ���ԵǾ� ������ �߸��� ���̼���.
	// <sid> RO XML �Ľ̿� ������ ����̴�.
#define	NCGERR_INVALID_SID_LICENSE_XML	0xF0000328
	
	// cid/sid RO�� ���Ե� <permission> XML ����.
#define	NCGERR_INVALID_PERMISSION_XML	0xF0000329
	
	// RO�� �����̳� ��⿡ ���� ������Ʈ ����.
#define	NCGERR_UPDATE_LICENSE_FAIL		0xF000032A
	
	//////////////////////////////////////////////////////////////////////
	// ������ ���� ������ �޽����� ���� URL Ȥ�� �ֹ� ID ����� ���
	// ������ �޽��� �ȿ� OID�� ���̻� ����.
	// ������ �ƴ� �Ϲ����� ��Ȳ�̸�, ���ο��� �߻��Ѵ�.
#define	NCGERR_INVALID_OID_LIST			0xF0000331
	
	// �Լ� ȣ��� �Է��� �ֹ� ID �ε����� ������ ���.
	// 0���� �۰ų�, �����κ��� ���� �ֹ� ID ������ �ʰ��� ���.
#define NCGERR_ORDERID_INDEX_OVERFLOW	0xF0000332
	
	// ���� URL XML�� �߸���.
#define NCGERR_INVALID_PURCHASE_URL		0xF0000333
	
	
	//////////////////////////////////////////////////////////////////////
	// NCG ���̼��� ������ ����
	//////////////////////////////////////////////////////////////////////
	
	// �Է¹��� DB ��ΰ� �ʹ� ��.
	// ��α��̰� 230 ���Ͽ��� ��
#define	NCGERR_TOO_LONG_LICENSE_DB_PATH	0xF0000401
	
	// ����� ��а��� ��ġ���� ����.
	// ���̼��� ���� ������� ������ ���ɼ��� ����.
	// Ƚ������ ����� ���� ������ ���ؼ� �ʿ��ϴ�.
#define NCGERR_RANDOM_SECRET_MISMATCH	0xF0000402
	
	// CID DB ���� ����
#define NCGERR_CID_DB_OPEN_FAIL			0xF0000411
	
	// CID DB �б� ����
#define NCGERR_CID_DB_READ_FAIL			0xF0000412
	
	// CID DB ���� ����
#define NCGERR_CID_DB_WRITE_FAIL		0xF0000413
	
	// CID DB ���� ����
#define	NCGERR_CID_DB_DELETE_FAIL		0xF0000414
	
	// SID DB ���� ����
#define NCGERR_SID_DB_OPEN_FAIL			0xF0000415
	
	// SID DB �б� ����
#define NCGERR_SID_DB_READ_FAIL			0xF0000416
	
	// SID DB ���� ����
#define NCGERR_SID_DB_WRITE_FAIL		0xF0000417
	
	// SID DB ���� ����
#define	NCGERR_SID_DB_DELETE_FAIL		0xF0000418

	// DB ���� ���� ���� ����
#define	NCGERR_DUMP_CREATE_FAIL			0xF0000421
	
	
	//////////////////////////////////////////////////////////////////////
	// NCG ������ ����
	//////////////////////////////////////////////////////////////////////
	// NCG ����� �������� �ʰų� �ջ�.
	// NCG ������ �ƴ� �� �ִ�.
#define	NCGERR_INVALID_NCG_HEADER		0xF0000501
	
	// NCG ����� �ջ� (= �ؽ� ���� ����).
#define NCGERR_MODIFIED_NCG_HEADER		0xF0000502
	
	// NCG ����� ���Ե� XML�� ������ ����.
#define	NCGERR_INVALID_NCG_XML_HEADER	0xF0000503
	
	// NCG ��� ���̰� �� �ʿ���.
	// �Լ� ���� ���� �ʿ��� ���۸� �о���� �� �ٽ� ȣ���Ѵ�.
#define NCGERR_NEEDED_MORE_HEADER_DATA	0xF0000504
	
	// NCG_Open() �ÿ� ������ ���� ������ �������� �ʰ�
	// NCG_Read(), NCG_Seek() ���� ȣ���� �� �߻��Ѵ�.
#define NCGERR_NOT_ALLOWED_CALL			0xF0000511
	
	// NCG ���� ���� ����.
	// ���� �������� ����, ���丮 ���� ���� ����,
	// �ý��� ���ڿ� ���ڵ����� ���� ã�� �� ���� ��쿡 �߻��Ѵ�.
#define	NCGERR_FILE_OPEN_FAIL			0xF0000512
	
	// NCG ���� ������ �̵� ����.
#define NCGERR_FILE_SEEK_FAIL			0xF0000513
	
	// NCG ���� �б� ����.
#define NCGERR_FILE_READ_FAIL			0xF0000514
	
	
	
	//////////////////////////////////////////////////////////////////////
	// NCG ������ - ���̼��� ����
	//////////////////////////////////////////////////////////////////////
	// ��⿡ ����� ���̼����� ����.
	// ��, ��� NCG ���ϵ� �� �� ����
#define	NCGERR_NO_LICENSES_IN_DEVICE	0xF0000601
	
	// NCG ������ ���� ���� ���̼���(CID)�� ����.
	// CID ���̼����� �ݵ�� �ʿ��ϸ�,
	// SID ���̼����� �߰������� ���� ����, ���� ���� �ִ�.
#define	NCGERR_NO_LICENSE_FOR_FILE		0xF0000602 // must required
	
	// �Լ� ȣ��� �Է��� ���̼��� �ε����� ������ ���.
	// 0���� �۰ų�, ���̼��� �ڵ��� ���� ���̼��� ������ �ʰ��� ���.
#define NCGERR_LICENSE_INDEX_OVERFLOW	0xF0000603
	
	// ��� Ƚ���� �������� �������� ���� ��� Ƚ�� ���� �õ�
#define NCGERR_UNLIMITED_PLAYCOUNT		0xF0000604
	
	// ����ð��� ���� ���ڿ�, �� ���� �ð��� �ùٸ� GMT ������ �ƴ�.
	// �ݵ�� 2010-01-01T12:34:56Z �����̾�� �Ѵ�.
#define NCGERR_INVALID_GMT_FORMAT		0xF0000605
	
	// ���� �ð��� �߸��� ���� �Էµ�.
#define NCGERR_INVALID_CURRENT_GMT		0xF0000606

	// NCG ������ ��ȣȭ�� ������ �������� ���� ���¿��� ��ȣ �õ�.
	// ���̼��� ����( NCG_SetLicense() )���� ������������ ��ȣ �õ� ���� �� ��.
#define NCGERR_NO_PERMISSION_FOR_FILE	0xF0000607
	
	// NCG ������ �� �� �ִ� �Ⱓ ����.
#define NCGERR_BEFORE_START_DATE		0xF0000611
	
	// NCG ������ �� �� �ִ� �Ⱓ ����. �� ����.
#define NCGERR_AFTER_END_DATE			0xF0000612
	
	// ��� Ƚ���� ����� �������� ���� ��� Ƚ�� ���� �õ�
	// Ȥ�� ����õ��� �� ��� Ƚ�� ����
#define NCGERR_PLAYCOUNT_EXHAUSTION		0xF0000613
	
	// ���̼��� DB���� CID ���� ����. �ش� CID�� ���� ����̴�.
#define	NCGERR_CID_LICENSE_REMOVE_FAIL	0xF0000621
	
	// ���̼��� DB���� SID ���� ����. �ش� SID�� ���� ����̴�.
#define	NCGERR_SID_LICENSE_REMOVE_FAIL	0xF0000622

	// ���̼��� �ڵ��� ��û������, ������ ���� ��
	// NCG_SetLicense() �� NCG_SetCEKForce() ���� read �� �� �� �ִ�.
#define	NCGERR_PLAIN_FILE				0xF0000631	
	
	
	
	//////////////////////////////////////////////////////////////////////
	// NCG ��Ÿ ����
	//////////////////////////////////////////////////////////////////////
	// �޸� �Ҵ� ����.
#define	NCGERR_MEMOEY_ALLOCATION_FAIL	0xF0001001
	
	// �Լ� �Է� �Ķ���Ͱ� �ùٸ��� ���� ���.
	// OPTIONAL�� �ƴ� �ʿ��� ������ NULL �� �Էµ� �� �ַ� �߻�.
#define NCGERR_INVALID_PARAMETER		0xF0001002
	
	// BASE64 ���ڵ� ����.
	// ���̼��� ��û�� ���ȴ�.
#define	NCGERR_BASE64ENCODE				0xF0001011
	
	// BASE64 ���ڵ� ����.
	// ���̼��� ���Ž� ���ȴ�.
#define	NCGERR_BASE64DECODE				0xF0001012
	
	// URL ���ڵ� ����.
	// ���̼��� ��û�� ���ȴ�.
#define	NCGERR_URLENCODE				0xF0001013
	
	// ���� üũ�� ��ũ��
#define Succeed(x)	(x)	== NCGERR_SUCCEED
#define	Failed(x)	(x) != NCGERR_SUCCEED
	
#ifdef  __cplusplus
}
#endif

#endif	// _NCG_ERROR_H



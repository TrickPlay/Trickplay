#ifndef	_NCG_SECURE_STORAGE_H
#define _NCG_SECURE_STORAGE_H

#ifdef  __cplusplus
extern "C" {
#endif

	// ������ ����ҿ��� �����͸� �о�´�.
	// �ý��� ȯ�濡 ����, Ȥ�� ���ø����̼� �䱸�� �°� �����ϵ���
	// NCG_SecureStorage.c ������ ������ �����ؾ��Ѵ�.
	// �⺻�� �׽�Ʈ�����μ�, read() �� �����ϴ�.
	// ������� �ʴ���, ���� 0�� ��ȯ�ϴ� �Լ��� �����ؾ� �Ѵ�.
	int		NCG_ReadSecret(	char		*szSecretData, 
							const int	nDataLen);

	// �Է¹��� �����͸� ������ ����ҿ� ����Ѵ�.
	// �ý��� ȯ�濡 ����, Ȥ�� ���ø����̼� �䱸�� �°� �����ϵ���
	// NCG_SecureStorage.c ������ ������ �����ؾ��Ѵ�.
	// �⺻�� �׽�Ʈ�����μ�, fwrite() �� �����ϴ�.
	// ������� �ʴ���, ���� 0�� ��ȯ�ϴ� �Լ��� �����ؾ� �Ѵ�.
	int		NCG_WriteSecret(const char	*szSecretData, 
							const int	nDataLen);
	
	// ���� �׽�Ʈ������, ������ ����� ��� ���Ͽ� ���� ���Ͽ�
	// ���� ������ ���ϸ��� �����ִ� �Լ�.
	// ���� �ܸ���� ���õ� ������ �ʿ� ����.
	int		NCG_SetFakeSecureStoragePath(const char	*szFakePath);
	

#ifdef  __cplusplus
}
#endif

#endif	// _NCG_SECURE_STORAGE_H


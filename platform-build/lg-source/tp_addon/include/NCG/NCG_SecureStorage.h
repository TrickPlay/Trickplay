#ifndef	_NCG_SECURE_STORAGE_H
#define _NCG_SECURE_STORAGE_H

#ifdef  __cplusplus
extern "C" {
#endif

	// 안전한 저장소에서 데이터를 읽어온다.
	// 시스템 환경에 맞춰, 혹은 어플리케이션 요구에 맞게 동작하도록
	// NCG_SecureStorage.c 파일의 내용을 변경해야한다.
	// 기본은 테스트용으로서, read() 와 동일하다.
	// 사용하지 않더라도, 단지 0을 반환하는 함수라도 존재해야 한다.
	int		NCG_ReadSecret(	char		*szSecretData, 
							const int	nDataLen);

	// 입력받은 데이터를 안전한 저장소에 기록한다.
	// 시스템 환경에 맞춰, 혹은 어플리케이션 요구에 맞게 동작하도록
	// NCG_SecureStorage.c 파일의 내용을 변경해야한다.
	// 기본은 테스트용으로서, fwrite() 와 동일하다.
	// 사용하지 않더라도, 단지 0을 반환하는 함수라도 존재해야 한다.
	int		NCG_WriteSecret(const char	*szSecretData, 
							const int	nDataLen);
	
	// 단지 테스트용으로, 안전한 저장소 대신 파일에 쓰기 위하여
	// 접근 가능한 파일명을 정해주는 함수.
	// 실제 단말기로 포팅될 때에는 필요 없다.
	int		NCG_SetFakeSecureStoragePath(const char	*szFakePath);
	

#ifdef  __cplusplus
}
#endif

#endif	// _NCG_SECURE_STORAGE_H


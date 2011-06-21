#ifndef	_NCG_LOG_H
#define _NCG_LOG_H

#ifdef  __cplusplus
extern "C" {
#endif

	// 콘솔 메시지 등으로 로그를 출력한다.
	// 시스템 환경에 맞춰, 혹은 어플리케이션 요구에 맞게 동작하도록
	// NCG_Log.c 파일의 내용을 변경해야한다. 기본은 printf() 와 동일하다.
	int		NCG_Log(const char	*szFormat, ... );
	
	void	NCG_EnableLog(int	nEnable);

#ifdef  __cplusplus
}
#endif

#endif	// _NCG_LOG_H



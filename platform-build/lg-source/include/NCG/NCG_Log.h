#ifndef	_NCG_LOG_H
#define _NCG_LOG_H

#ifdef  __cplusplus
extern "C" {
#endif

	// �ܼ� �޽��� ������ �α׸� ����Ѵ�.
	// �ý��� ȯ�濡 ����, Ȥ�� ���ø����̼� �䱸�� �°� �����ϵ���
	// NCG_Log.c ������ ������ �����ؾ��Ѵ�. �⺻�� printf() �� �����ϴ�.
	int		NCG_Log(const char	*szFormat, ... );
	
	void	NCG_EnableLog(int	nEnable);

#ifdef  __cplusplus
}
#endif

#endif	// _NCG_LOG_H



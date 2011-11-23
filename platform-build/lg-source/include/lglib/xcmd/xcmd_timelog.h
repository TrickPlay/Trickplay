#ifndef	_XCMD_TIMELOG_H_
#define	_XCMD_TIMELOG_H_

/*-----------------------------------------------------------------------------
    #include ���ϵ�
    (File Inclusions)
------------------------------------------------------------------------------*/
#include	<stdio.h>

#ifdef	__cplusplus
extern "C"
{
#endif /* __cplusplus */


/*------------------------------------------------------------------------------
	��ũ�� �Լ� ����
	(Macro Definitions)
------------------------------------------------------------------------------*/

#ifndef MARK_FN_START	/* common/osa timelog���� ȣȯ���� ����... ���� �ʿ�. */

#define	MARK_FN_START				"FN_START"
#define	MARK_FN_END					"FN_END"
#define	MARK_CHFN_START				"CHFN_START"
#define	MARK_CHFN_END				"CHFN_END"
#define	MARK_PT						"PT"
#define	MARK_CHPT					"CHPT"

#endif

/*------------------------------------------------------------------------------
	�� ����
	(Type Definitions)
------------------------------------------------------------------------------*/


/*------------------------------------------------------------------------------
	Public Extern ���������� �Լ� prototype ����
	(Extern Variables & Function Prototype Declarations)
------------------------------------------------------------------------------*/
extern void cmd_timelog_mark(const char *mark, const char *desc);
extern void cmd_timelog_mark_pt(const char * desc);
extern void cmd_timelog_mark_fn_start(const char * desc);
extern void cmd_timelog_mark_fn_end(const char * desc);

extern void cmd_timelog_start(void);
extern void cmd_timelog_end(void);
extern void cmd_timelog_show(char * title);

/*------------------------------------------------------------------------
*	Public Function Declaration
*-----------------------------------------------------------------------*/
/* Function to add new command into menu, in cmd_debug.c	*/

/*------------------------------------------------------------------------
*	Private Function Declaration
*-----------------------------------------------------------------------*/

#ifdef	__cplusplus
}
#endif /* __cplusplus */

#endif	/*	_XCMD_DEBUG_H_ */

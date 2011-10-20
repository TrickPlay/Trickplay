/******************************************************************************
 *	 DTV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *	 Copyright(c) 1999 by LG Electronics Inc.
 *
 *	 All rights reserved. No part of this work may be reproduced, stored in a
 *	 retrieval system, or transmitted by any means without prior written
 *	 permission of LG Electronics Inc.
 *****************************************************************************/

/** @file common.h
 *
 *	Common Used Type Definitions.
 *
 *	@author 	Changwook Lim (changwook.im@lge.com)
 *	@version	1.0
 *	@date		2005. 6. 1
 *	@note
 *	@see
 */

/******************************************************************************
	Header File Guarder
******************************************************************************/


#ifndef _XOSA_MM_H_
#define _XOSA_MM_H_

#ifdef __cplusplus
extern "C" {
#endif

/*-----------------------------------------------------------------------------
	(Control Constants)
------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------
*	include files
*-----------------------------------------------------------------------*/
#include "dbgfrwk_types.h"

/*------------------------------------------------------------------------
*	constant definitions
*-----------------------------------------------------------------------*/


/******************************************************************************
	매크로 함수 정의 (Macro Definitions)
******************************************************************************/

/*------------------------------------------------------------------------
*	include files
*-----------------------------------------------------------------------*/

/*--------------------------------------------------------------------------+
| Constant Define
+---------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------
| Macros for task memory check flag mask
+---------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------
*	type definitions
*----------------------------------------------------------------------------*/

typedef struct
{
	char 	name[CMN_NM_MAX];
	char 	libname[CMN_BUF_LEN];

	void	(* p_init)	(void);
	void *	(* p_malloc)(size_t size) ;
	void	(* p_free)	(void *ptr);
	void *	(* p_calloc)(size_t nmemb, size_t size);
	void *	(* p_realloc)(void *ptr, size_t size);
	void *	(* p_memalign)(size_t alignment, size_t bytes);
	int 	(* p_posix_memalign)(void **memptr, size_t alignment, size_t size);
	void *	(* p_valloc) (size_t size);
	void	(* p_show)(FILE * fp);
	void	(* p_snapshot)(void);
}osa_mm_op_t;


/*------------------------------------------------------------------------
*	Public Function Declaration
*-----------------------------------------------------------------------*/
extern void osa_mm_show(void);
extern void osa_mm_fshow(FILE * fp);
extern void osa_mm_snapshot(void);
extern int 	osa_mm_register(char * p_libname, char * p_name);
extern int 	osa_mm_register_op (osa_mm_op_t * op);
extern void osa_mm_init_op(osa_mm_op_t * op);
extern int 	osa_mm_ctrl_byname(char * p_name);
extern int 	osa_mm_ctrl_byidx (int idx);

/*------------------------------------------------------------------------
*	Private Function Declaration
*-----------------------------------------------------------------------*/

#ifdef __cplusplus
}
#endif

#endif  /* _XOSA_MM_H_ */

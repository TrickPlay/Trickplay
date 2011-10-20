/******************************************************************************

	  LGE. LCD DTV RESEARCH LABORATORY
	  COPYRIGHT(c) LGE CO.,LTD. 1998-2007. SEOUL, KOREA.
	  All rights are reserved.
	  No part of this work covered by the copyright hereon may be
	  reproduced, stored in a retrieval system, in any form or
	  by any means, electronic, mechanical, photocopying, recording
	  or otherwise, without the prior permission of LG Electronics.

	  FILE NAME   : dbgfrwk.h
	  VERSION     : 1.0
	  AUTHOR      : changwook.im
	  DATE          : 2011/7/23
	  DESCRIPTION	: This is a sample header file for using LG Debug Framework
*******************************************************************************/
#ifndef _APPFRWK_DBGFRWK_H_
#define _APPFRWK_DBGFRWK_H_

#ifdef __cplusplus
extern "C" {
#endif

/*-----------------------------------------------------------------------
	control constants
------------------------------------------------------------------------*/

/*------------------------------------------------------------------------
*	include files
*-----------------------------------------------------------------------*/
#include "xcmd_api.h"
#include "xosa_api.h"
#include "xlibc_api.h"
#include "init_api.h"
#include "tmgr_api.h"

/*------------------------------------------------------------------------
*	constant definitions
*-----------------------------------------------------------------------*/
#define DEFAULT_PRINT_MASK CMD_MASK_DEFAULT

/********************************************************
				USER DEFINE POINT
**********************************************************/
#define PRNT_MOD_APPFRWK			(0)
#define PRNT_MOD_OPENAPI			(1)
#define PRNT_MOD_SVC___1			(2)
#define PRNT_MOD_SVC___2			(3)
#define PRNT_MOD_BROWSER			(4)
#define PRNT_MOD_UNDEF_2			(5)
#define PRNT_MOD_UNDEF_3			(6)
#define PRNT_MOD_UNDEF_4			(7)
#define PRNT_MOD_UNDEF_5			(8)
#define PRNT_MOD_UNDEF_6			(9)

/********************************************************
				USER DEFINE POINT
**********************************************************/
/*---------------- APPFRWK(PM/AC/UC/COMMON/SCF)  ----------------*/
#define PM_PRINT(format, args...)						cmd_mask_print(PRNT_MOD_APPFRWK, 0, format, ##args)
#define	PM_SEND_PRINT(format, args...)					cmd_mask_print(PRNT_MOD_APPFRWK, 1, format, ##args)
#define	PM_INPUT_PRINT(format, args...) 				cmd_mask_print(PRNT_MOD_APPFRWK, 2, format, ##args)
#define	AF_PRINT(format, args...) 						cmd_mask_print(PRNT_MOD_APPFRWK, 3, format, ##args)
#define	PM_INPUTMGR_PRINT(format, args...) 				cmd_mask_print(PRNT_MOD_APPFRWK, 4, format, ##args)
#define	PM_CURSOR_PRINT(format, args...) 				cmd_mask_print(PRNT_MOD_APPFRWK, 5, format, ##args)
#define AF_UNDEF_PRINT_6(format, args...)				cmd_mask_print(PRNT_MOD_APPFRWK, 6, format, ##args)
#define	AF_UNDEF_PRINT_7(format, args...) 				cmd_mask_print(PRNT_MOD_APPFRWK, 7, format, ##args)
#define	AF_UNDEF_PRINT_8(format, args...) 				cmd_mask_print(PRNT_MOD_APPFRWK, 8, format, ##args)
#define	AF_UNDEF_PRINT_9(format, args...) 				cmd_mask_print(PRNT_MOD_APPFRWK, 9, format, ##args)
#define	AM_PRINT(format, args...) 						cmd_mask_print(PRNT_MOD_APPFRWK,10, "%s: " format, __FUNCTION__, ##args)
#define	UC_PRINT(format, args...) 						cmd_mask_print(PRNT_MOD_APPFRWK,11, format, ##args)
#define	AM_XML_PRINT(format, args...) 					cmd_mask_print(PRNT_MOD_APPFRWK,12, format, ##args)
#define	AF_UNDEF_PRINT_13(format, args...) 				cmd_mask_print(PRNT_MOD_APPFRWK,13, format, ##args)
#define	AF_UNDEF_PRINT_14(format, args...) 				cmd_mask_print(PRNT_MOD_APPFRWK,14, format, ##args)
#define	AF_UNDEF_PRINT_15(format, args...) 				cmd_mask_print(PRNT_MOD_APPFRWK,15, format, ##args)
#define	AF_UNDEF_PRINT_16(format, args...) 				cmd_mask_print(PRNT_MOD_APPFRWK,16, format, ##args)
#define	AF_UNDEF_PRINT_17(format, args...) 				cmd_mask_print(PRNT_MOD_APPFRWK,17, format, ##args)
#define AF_UNDEF_PRINT_18(format, args...)				cmd_mask_print(PRNT_MOD_APPFRWK,18, format, ##args)
#define	AF_UNDEF_PRINT_19(format, args...)				cmd_mask_print(PRNT_MOD_APPFRWK,19, format, ##args)
#define	SCF_PRINT(format, args...)						cmd_mask_print(PRNT_MOD_APPFRWK,20, format, ##args)
#define	AF_UNDEF_PRINT_21(format, args...)				cmd_mask_print(PRNT_MOD_APPFRWK,21, format, ##args)
#define	AF_UNDEF_PRINT_22(format, args...) 				cmd_mask_print(PRNT_MOD_APPFRWK,22, format, ##args)
#define	AF_UNDEF_PRINT_23(format, args...) 				cmd_mask_print(PRNT_MOD_APPFRWK,23, format, ##args)
#define	AF_UNDEF_PRINT_24(format, args...) 				cmd_mask_print(PRNT_MOD_APPFRWK,24, format, ##args)
#define	AF_UNDEF_PRINT_25(format, args...) 				cmd_mask_print(PRNT_MOD_APPFRWK,25, format, ##args)
#define	AF_UNDEF_PRINT_26(format, args...) 				cmd_mask_print(PRNT_MOD_APPFRWK,26, format, ##args)
#define	AF_UNDEF_PRINT_27(format, args...) 				cmd_mask_print(PRNT_MOD_APPFRWK,27, format, ##args)
#define AF_UNDEF_PRINT_28(format, args...)				cmd_mask_print(PRNT_MOD_APPFRWK,28, format, ##args)
#define AF_UNDEF_PRINT_29(format, args...)				cmd_mask_print(PRNT_MOD_APPFRWK,29, format, ##args)
#define AF_UNDEF_PRINT_30(format, args...)				cmd_mask_print(PRNT_MOD_APPFRWK,30, format, ##args)
#define AF_UNDEF_PRINT_31(format, args...)				cmd_mask_print(PRNT_MOD_APPFRWK,31, format, ##args)

/*---------------- OPENAPI(AF/BC/MF/SI/LI/FX)  ----------------*/
#define AF_OPAPI_PRINT(format, args...)					cmd_mask_print(PRNT_MOD_OPENAPI, 0, format, ##args)
#define	BC_OPAPI_PRINT(format, args...)					cmd_mask_print(PRNT_MOD_OPENAPI, 1, format, ##args)
#define	MF_OPAPI_PRINT(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI, 2, format, ##args)
#define	SI_OPAPI_PRINT(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI, 3, format, ##args)
#define	LI_OPAPI_PRINT(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI, 4, format, ##args)
#define	FX_OPAPI_PRINT(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI, 5, format, ##args)
#define OA_UNDEF_PRINT_6(format, args...)				cmd_mask_print(PRNT_MOD_OPENAPI, 6, format, ##args)
#define	OA_UNDEF_PRINT_7(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI, 7, format, ##args)
#define	OA_UNDEF_PRINT_8(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI, 8, format, ##args)
#define	OA_UNDEF_PRINT_9(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI, 9, format, ##args)
#define	OA_UNDEF_PRINT_10(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI,10, format, ##args)
#define	OA_UNDEF_PRINT_11(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI,11, format, ##args)
#define	OA_UNDEF_PRINT_12(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI,12, format, ##args)
#define	OA_UNDEF_PRINT_13(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI,13, format, ##args)
#define	OA_UNDEF_PRINT_14(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI,14, format, ##args)
#define	OA_UNDEF_PRINT_15(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI,15, format, ##args)
#define	OA_UNDEF_PRINT_16(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI,16, format, ##args)
#define	OA_UNDEF_PRINT_17(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI,17, format, ##args)
#define OA_UNDEF_PRINT_18(format, args...)				cmd_mask_print(PRNT_MOD_OPENAPI,18, format, ##args)
#define	OA_UNDEF_PRINT_19(format, args...)				cmd_mask_print(PRNT_MOD_OPENAPI,19, format, ##args)
#define	OA_UNDEF_PRINT_20(format, args...)				cmd_mask_print(PRNT_MOD_OPENAPI,20, format, ##args)
#define	OA_UNDEF_PRINT_21(format, args...)				cmd_mask_print(PRNT_MOD_OPENAPI,21, format, ##args)
#define	OA_UNDEF_PRINT_22(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI,22, format, ##args)
#define	OA_UNDEF_PRINT_23(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI,23, format, ##args)
#define	OA_UNDEF_PRINT_24(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI,24, format, ##args)
#define	OA_UNDEF_PRINT_25(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI,25, format, ##args)
#define	OA_UNDEF_PRINT_26(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI,26, format, ##args)
#define	OA_UNDEF_PRINT_27(format, args...) 				cmd_mask_print(PRNT_MOD_OPENAPI,27, format, ##args)
#define OA_UNDEF_PRINT_28(format, args...)				cmd_mask_print(PRNT_MOD_OPENAPI,28, format, ##args)
#define OA_UNDEF_PRINT_29(format, args...)				cmd_mask_print(PRNT_MOD_OPENAPI,29, format, ##args)
#define OA_UNDEF_PRINT_30(format, args...)				cmd_mask_print(PRNT_MOD_OPENAPI,30, format, ##args)
#define OA_UNDEF_PRINT_31(format, args...)				cmd_mask_print(PRNT_MOD_OPENAPI,31, format, ##args)

/*---------------- SVC___1(FX/SDP)  ----------------*/
#define	SDP_MAIN_PRINT(format, args...)					cmd_mask_print(PRNT_MOD_SVC___1, 0, format, ##args)
#define	SDP_DNLD_PRINT(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1, 1, format, ##args)
#define FXUI_MAIN_PRINT(format, args...)				cmd_mask_print(PRNT_MOD_SVC___1, 2, format, ##args)
#define	FXUI_PLY_PRINT(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1, 3, format, ##args)
#define	S1_UNDEF_PRINT_4(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1, 4, format, ##args)
#define	S1_UNDEF_PRINT_5(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1, 5, format, ##args)
#define S1_UNDEF_PRINT_6(format, args...)				cmd_mask_print(PRNT_MOD_SVC___1, 6, format, ##args)
#define	S1_UNDEF_PRINT_7(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1, 7, format, ##args)
#define	S1_UNDEF_PRINT_8(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1, 8, format, ##args)
#define	S1_UNDEF_PRINT_9(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1, 9, format, ##args)
#define	S1_UNDEF_PRINT_10(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1,10, format, ##args)
#define	S1_UNDEF_PRINT_11(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1,11, format, ##args)
#define	S1_UNDEF_PRINT_12(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1,12, format, ##args)
#define	S1_UNDEF_PRINT_13(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1,13, format, ##args)
#define	S1_UNDEF_PRINT_14(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1,14, format, ##args)
#define	S1_UNDEF_PRINT_15(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1,15, format, ##args)
#define	S1_UNDEF_PRINT_16(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1,16, format, ##args)
#define	S1_UNDEF_PRINT_17(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1,17, format, ##args)
#define S1_UNDEF_PRINT_18(format, args...)				cmd_mask_print(PRNT_MOD_SVC___1,18, format, ##args)
#define	S1_UNDEF_PRINT_19(format, args...)				cmd_mask_print(PRNT_MOD_SVC___1,19, format, ##args)
#define	S1_UNDEF_PRINT_20(format, args...)				cmd_mask_print(PRNT_MOD_SVC___1,20, format, ##args)
#define	S1_UNDEF_PRINT_21(format, args...)				cmd_mask_print(PRNT_MOD_SVC___1,21, format, ##args)
#define	S1_UNDEF_PRINT_22(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1,22, format, ##args)
#define	S1_UNDEF_PRINT_23(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1,23, format, ##args)
#define	S1_UNDEF_PRINT_24(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1,24, format, ##args)
#define	S1_UNDEF_PRINT_25(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1,25, format, ##args)
#define	S1_UNDEF_PRINT_26(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1,26, format, ##args)
#define	S1_UNDEF_PRINT_27(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___1,27, format, ##args)
#define S1_UNDEF_PRINT_28(format, args...)				cmd_mask_print(PRNT_MOD_SVC___1,28, format, ##args)
#define S1_UNDEF_PRINT_29(format, args...)				cmd_mask_print(PRNT_MOD_SVC___1,29, format, ##args)
#define S1_UNDEF_PRINT_30(format, args...)				cmd_mask_print(PRNT_MOD_SVC___1,30, format, ##args)
#define S1_UNDEF_PRINT_31(format, args...)				cmd_mask_print(PRNT_MOD_SVC___1,31, format, ##args)

/*---------------- SVC___2(LGINPUT/MEDIAFRAMEWORK)  ----------------*/
#define MF_MSG_PRINT(format, args...)					cmd_mask_print(PRNT_MOD_SVC___2, 0, format, ##args)
#define	MF_DBG_PRINT(format, args...)					cmd_mask_print(PRNT_MOD_SVC___2, 1, format, ##args)
#define	MF_ERR_PRINT(format, args...) 					cmd_mask_print(PRNT_MOD_SVC___2, 2, format, ##args)
#define	LI_PRINT(format, args...) 						cmd_mask_print(PRNT_MOD_SVC___2, 3, format, ##args)
#define	S2_UNDEF_PRINT_4(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___2, 4, format, ##args)
#define	S2_UNDEF_PRINT_5(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___2, 5, format, ##args)
#define S2_UNDEF_PRINT_6(format, args...)				cmd_mask_print(PRNT_MOD_SVC___2, 6, format, ##args)
#define	S2_UNDEF_PRINT_7(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___2, 7, format, ##args)
#define	S2_UNDEF_PRINT_8(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___2, 8, format, ##args)
#define	S2_UNDEF_PRINT_9(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___2, 9, format, ##args)
#define	S2_UNDEF_PRINT_10(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___2,10, format, ##args)
#define	S2_UNDEF_PRINT_11(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___2,11, format, ##args)
#define	S2_UNDEF_PRINT_12(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___2,12, format, ##args)
#define	S2_UNDEF_PRINT_13(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___2,13, format, ##args)
#define	S2_UNDEF_PRINT_14(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___2,14, format, ##args)
#define	S2_UNDEF_PRINT_15(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___2,15, format, ##args)
#define	S2_UNDEF_PRINT_16(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___2,16, format, ##args)
#define	S2_UNDEF_PRINT_17(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___2,17, format, ##args)
#define S2_UNDEF_PRINT_18(format, args...)				cmd_mask_print(PRNT_MOD_SVC___2,18, format, ##args)
#define	S2_UNDEF_PRINT_19(format, args...)				cmd_mask_print(PRNT_MOD_SVC___2,19, format, ##args)
#define	S2_UNDEF_PRINT_20(format, args...)				cmd_mask_print(PRNT_MOD_SVC___2,20, format, ##args)
#define	S2_UNDEF_PRINT_21(format, args...)				cmd_mask_print(PRNT_MOD_SVC___2,21, format, ##args)
#define	S2_UNDEF_PRINT_22(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___2,22, format, ##args)
#define	S2_UNDEF_PRINT_23(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___2,23, format, ##args)
#define	S2_UNDEF_PRINT_24(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___2,24, format, ##args)
#define	S2_UNDEF_PRINT_25(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___2,25, format, ##args)
#define	S2_UNDEF_PRINT_26(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___2,26, format, ##args)
#define	S2_UNDEF_PRINT_27(format, args...) 				cmd_mask_print(PRNT_MOD_SVC___2,27, format, ##args)
#define S2_UNDEF_PRINT_28(format, args...)				cmd_mask_print(PRNT_MOD_SVC___2,28, format, ##args)
#define S2_UNDEF_PRINT_29(format, args...)				cmd_mask_print(PRNT_MOD_SVC___2,29, format, ##args)
#define S2_UNDEF_PRINT_30(format, args...)				cmd_mask_print(PRNT_MOD_SVC___2,30, format, ##args)
#define S2_UNDEF_PRINT_31(format, args...)				cmd_mask_print(PRNT_MOD_SVC___2,31, format, ##args)

/*----------------  BROWSER  ----------------*/
#define BR_INTERFACE_PRINT(format, args...)				cmd_mask_print(PRNT_MOD_BROWSER, 0, format, ##args)
#define	BR_UNDEF_PRINT_1(format, args...)				cmd_mask_print(PRNT_MOD_BROWSER, 1, format, ##args)
#define	BR_UNDEF_PRINT_2(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER, 2, format, ##args)
#define	BR_UNDEF_PRINT_3(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER, 3, format, ##args)
#define	BR_UNDEF_PRINT_4(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER, 4, format, ##args)
#define	BR_UNDEF_PRINT_5(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER, 5, format, ##args)
#define BR_UNDEF_PRINT_6(format, args...)				cmd_mask_print(PRNT_MOD_BROWSER, 6, format, ##args)
#define	BR_UNDEF_PRINT_7(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER, 7, format, ##args)
#define	BR_UNDEF_PRINT_8(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER, 8, format, ##args)
#define	BR_UNDEF_PRINT_9(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER, 9, format, ##args)
#define	BR_UNDEF_PRINT_10(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER,10, format, ##args)
#define	BR_MEDIA_PLUGIN(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER,11, format, ##args)
#define	BR_UNDEF_PRINT_12(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER,12, format, ##args)
#define	BR_UNDEF_PRINT_13(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER,13, format, ##args)
#define	BR_UNDEF_PRINT_14(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER,14, format, ##args)
#define	BR_UNDEF_PRINT_15(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER,15, format, ##args)
#define	BR_UNDEF_PRINT_16(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER,16, format, ##args)
#define	BR_UNDEF_PRINT_17(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER,17, format, ##args)
#define BR_UNDEF_PRINT_18(format, args...)				cmd_mask_print(PRNT_MOD_BROWSER,18, format, ##args)
#define	BR_UNDEF_PRINT_19(format, args...)				cmd_mask_print(PRNT_MOD_BROWSER,19, format, ##args)
#define	BR_UNDEF_PRINT_20(format, args...)				cmd_mask_print(PRNT_MOD_BROWSER,20, format, ##args)
#define	BR_UNDEF_PRINT_21(format, args...)				cmd_mask_print(PRNT_MOD_BROWSER,21, format, ##args)
#define	BR_UNDEF_PRINT_22(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER,22, format, ##args)
#define	BR_UNDEF_PRINT_23(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER,23, format, ##args)
#define	BR_UNDEF_PRINT_24(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER,24, format, ##args)
#define	BR_UNDEF_PRINT_25(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER,25, format, ##args)
#define	BR_UNDEF_PRINT_26(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER,26, format, ##args)
#define	BR_UNDEF_PRINT_27(format, args...) 				cmd_mask_print(PRNT_MOD_BROWSER,27, format, ##args)
#define BR_UNDEF_PRINT_28(format, args...)				cmd_mask_print(PRNT_MOD_BROWSER,28, format, ##args)
#define BR_UNDEF_PRINT_29(format, args...)				cmd_mask_print(PRNT_MOD_BROWSER,29, format, ##args)
#define BR_UNDEF_PRINT_30(format, args...)				cmd_mask_print(PRNT_MOD_BROWSER,30, format, ##args)
#define BR_UNDEF_PRINT_31(format, args...)				cmd_mask_print(PRNT_MOD_BROWSER,31, format, ##args)

/*------------------------------------------------------------------------
*	macro function definitions
*-----------------------------------------------------------------------*/

/*------------------------------------------------------------------------
*	type definitions
*-----------------------------------------------------------------------*/

/*------------------------------------------------------------------------
*	function declaration
*-----------------------------------------------------------------------*/

#ifdef AF_USE_DBGFRWK

#ifdef __DBGFRWK_MASK__

/********************************************************
				USER DEFINE POINT
**********************************************************/
static cmd_mask_group_attr_t	_gAppFrwkAttr =
{
	"APPFRWK", PRNT_MOD_APPFRWK,
	{
		/*pName | num | nm_flag | color*/
		{ "PM", 	   	0, 1, 0 }, 		{ "PM_SEND",	1, 1, 0 },
		{ "PM_INPUT",	2, 1, 0 }, 		{ "AF",			3, 1, 0 },
		{ "PM_INPUTMGR",4, 1, 0 }, 		{ "PM_CURSOR",	5, 1, 0 },
		{ "UNDEF_6", 	6, 1, 0 }, 		{ "UNDEF_7",	7, 1, 0 },
		{ "UNDEF_8",   	8, 1, 0 }, 		{ "UNDEF_9",	9, 1, 0 },
		{ "AM",  		10, 1, 0 },		{ "UC",			11, 1, 0 },
		{ "AM_XML",		12, 1, 0 },		{ "AM_CRIT",	13, 1, 0 },
		{ "UNDEF_14",  	14, 1, 0 },		{ "UNDEF_15",	15, 1, 0 },
		{ "UNDEF_16",  	16, 1, 0 },		{ "UNDEF_17",	17, 1, 0 },
		{ "UNDEF_18",  	18, 1, 0 },		{ "UNDEF_19",	19, 1, 0 },
		{ "SCF",  		20, 1, 0 },		{ "UNDEF_21",	21, 1, 0 },
		{ "UNDEF_22",	22, 1, 0 },		{ "UNDEF_23",	23, 1, 0 },
		{ "UNDEF_24", 	24, 1, 0 },		{ "UNDEF_25",	25, 1, 0 },
		{ "UNDEF_26",  	26, 1, 0 },		{ "UNDEF_27",	27, 1, 0 },
		{ "UNDEF_28",  	28, 1, 0 },		{ "UNDEF_29", 	29, 1, 0 },
		{ "UNDEF_30",  	30, 1, 0 },		{ "UNDEF_31",	31, 1, 0 }
	}
};

static cmd_mask_group_attr_t	_gOpenApiAttr =
{
	"OPENAPI", PRNT_MOD_OPENAPI,
	{
		/*pName | num | nm_flag | color*/
		{ "AF_OPAPI",	0, 1, 0 }, 		{ "BC_OPAPI",	1, 1, 0 },
		{ "MF_OPAPI",	2, 1, 0 }, 		{ "SI_OPAPI",	3, 1, 0 },
		{ "LI_OPAPI",	4, 1, 0 }, 		{ "FX_OPAPI",	5, 1, 0 },
		{ "UNDEF_6", 	6, 1, 0 }, 		{ "UNDEF_7",	7, 1, 0 },
		{ "UNDEF_8",   	8, 1, 0 }, 		{ "UNDEF_9",	9, 1, 0 },
		{ "UNDEF_10",  	10, 1, 0 },		{ "UNDEF_11",	11, 1, 0 },
		{ "UNDEF_10",	12, 1, 0 },		{ "UNDEF_13",	13, 1, 0 },
		{ "UNDEF_14",  	14, 1, 0 },		{ "UNDEF_15",	15, 1, 0 },
		{ "UNDEF_16",  	16, 1, 0 },		{ "UNDEF_17",	17, 1, 0 },
		{ "UNDEF_18",  	18, 1, 0 },		{ "UNDEF_19",	19, 1, 0 },
		{ "UNDEF_10",  	20, 1, 0 },		{ "UNDEF_21",	21, 1, 0 },
		{ "UNDEF_22",	22, 1, 0 },		{ "UNDEF_23",	23, 1, 0 },
		{ "UNDEF_24", 	24, 1, 0 },		{ "UNDEF_25",	25, 1, 0 },
		{ "UNDEF_26",  	26, 1, 0 },		{ "UNDEF_27",	27, 1, 0 },
		{ "UNDEF_28",  	28, 1, 0 },		{ "UNDEF_29", 	29, 1, 0 },
		{ "UNDEF_30",  	30, 1, 0 },		{ "UNDEF_31",	31, 1, 0 }
	}
};

static cmd_mask_group_attr_t	_gSvc1Attr =
{
	"FX/SDP", PRNT_MOD_SVC___1,
	{
		/*pName | num | nm_flag | color*/
		{ "SDP_MAIN",	0, 1, 0 }, 		{ "SDP_DNLD",	1, 1, 0 },
		{ "FXUI_MAIN",	2, 1, 0 }, 		{ "FXUI_PLY",	3, 1, 0 },
		{ "UNDEF_4",	4, 1, 0 }, 		{ "UNDEF_5",	5, 1, 0 },
		{ "UNDEF_6", 	6, 1, 0 }, 		{ "UNDEF_7",	7, 1, 0 },
		{ "UNDEF_8",   	8, 1, 0 }, 		{ "UNDEF_9",	9, 1, 0 },
		{ "UNDEF_10",  	10, 1, 0 },		{ "UNDEF_11",	11, 1, 0 },
		{ "UNDEF_12",	12, 1, 0 },		{ "UNDEF_13",	13, 1, 0 },
		{ "UNDEF_14",  	14, 1, 0 },		{ "UNDEF_15",	15, 1, 0 },
		{ "UNDEF_16",  	16, 1, 0 },		{ "UNDEF_17",	17, 1, 0 },
		{ "UNDEF_18",  	18, 1, 0 },		{ "UNDEF_19",	19, 1, 0 },
		{ "UNDEF_20",  	20, 1, 0 },		{ "UNDEF_21",	21, 1, 0 },
		{ "UNDEF_22",	22, 1, 0 },		{ "UNDEF_23",	23, 1, 0 },
		{ "UNDEF_24", 	24, 1, 0 },		{ "UNDEF_25",	25, 1, 0 },
		{ "UNDEF_26",  	26, 1, 0 },		{ "UNDEF_27",	27, 1, 0 },
		{ "UNDEF_28",  	28, 1, 0 },		{ "UNDEF_29", 	29, 1, 0 },
		{ "UNDEF_30",  	30, 1, 0 },		{ "UNDEF_31",	31, 1, 0 }
	}
};

static cmd_mask_group_attr_t	_gSvc2Attr =
{
	"LI/MF", PRNT_MOD_SVC___2,
	{
		/*pName | num | nm_flag | color*/
		{ "MF_MSG",		0, 1, 0 }, 		{ "MF_DBG",		1, 1, 0 },
		{ "MF_ERR",		2, 1, 0 }, 		{ "LGINPUT",	3, 1, 0 },
		{ "UNDEF_4",	4, 1, 0 }, 		{ "UNDEF_5",	5, 1, 0 },
		{ "UNDEF_6", 	6, 1, 0 }, 		{ "UNDEF_7",	7, 1, 0 },
		{ "UNDEF_8",   	8, 1, 0 }, 		{ "UNDEF_9",	9, 1, 0 },
		{ "UNDEF_10",  	10, 1, 0 },		{ "UNDEF_11",	11, 1, 0 },
		{ "UNDEF_12",	12, 1, 0 },		{ "UNDEF_13",	13, 1, 0 },
		{ "UNDEF_14",  	14, 1, 0 },		{ "UNDEF_15",	15, 1, 0 },
		{ "UNDEF_16",  	16, 1, 0 },		{ "UNDEF_17",	17, 1, 0 },
		{ "UNDEF_18",  	18, 1, 0 },		{ "UNDEF_19",	19, 1, 0 },
		{ "UNDEF_20",  	20, 1, 0 },		{ "UNDEF_21",	21, 1, 0 },
		{ "UNDEF_22",	22, 1, 0 },		{ "UNDEF_23",	23, 1, 0 },
		{ "UNDEF_24", 	24, 1, 0 },		{ "UNDEF_25",	25, 1, 0 },
		{ "UNDEF_26",  	26, 1, 0 },		{ "UNDEF_27",	27, 1, 0 },
		{ "UNDEF_28",  	28, 1, 0 },		{ "UNDEF_29", 	29, 1, 0 },
		{ "UNDEF_30",  	30, 1, 0 },		{ "UNDEF_31",	31, 1, 0 }
	}
};

static cmd_mask_group_attr_t	_gBrowserAttr =
{
	"BROWSER", PRNT_MOD_BROWSER,
	{
		/*pName | num | nm_flag | color*/
		{ "Interface",	0, 1, 0 }, 		{ "UNDEF_1",	1, 1, 0 },
		{ "UNDEF_2",	2, 1, 0 }, 		{ "UNDEF_3",	3, 1, 0 },
		{ "UNDEF_4",	4, 1, 0 }, 		{ "UNDEF_5",	5, 1, 0 },
		{ "UNDEF_6", 	6, 1, 0 }, 		{ "UNDEF_7",	7, 1, 0 },
		{ "UNDEF_8",   	8, 1, 0 }, 		{ "UNDEF_9",	9, 1, 0 },
		{ "UNDEF_10",  	10, 1, 0 },		{ "Media plugin",	11, 1, 0 },
		{ "UNDEF_12",	12, 1, 0 },		{ "UNDEF_13",	13, 1, 0 },
		{ "UNDEF_14",  	14, 1, 0 },		{ "UNDEF_15",	15, 1, 0 },
		{ "UNDEF_16",  	16, 1, 0 },		{ "UNDEF_17",	17, 1, 0 },
		{ "UNDEF_18",  	18, 1, 0 },		{ "UNDEF_19",	19, 1, 0 },
		{ "UNDEF_20",  	20, 1, 0 },		{ "UNDEF_21",	21, 1, 0 },
		{ "UNDEF_22",	22, 1, 0 },		{ "UNDEF_23",	23, 1, 0 },
		{ "UNDEF_24", 	24, 1, 0 },		{ "UNDEF_25",	25, 1, 0 },
		{ "UNDEF_26",  	26, 1, 0 },		{ "UNDEF_27",	27, 1, 0 },
		{ "UNDEF_28",  	28, 1, 0 },		{ "UNDEF_29", 	29, 1, 0 },
		{ "UNDEF_30",  	30, 1, 0 },		{ "UNDEF_31",	31, 1, 0 }
	}
};

/********************************************************
				USER DEFINE POINT
**********************************************************/
static cmd_mask_group_attr_t * _gMaskAttr [] =
{
	&_gAppFrwkAttr,
	&_gOpenApiAttr,
	&_gSvc1Attr,
	&_gSvc2Attr,
	&_gBrowserAttr,
	NULL
};

#endif
#endif

#ifdef __cplusplus
}
#endif

#endif  /* _PM_DBGFRWK_H_ */

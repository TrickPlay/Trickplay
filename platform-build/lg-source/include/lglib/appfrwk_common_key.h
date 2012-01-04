/******************************************************************************
*	DTV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA.
*	Copyright(c) 1999 by LG Electronics Inc.
*
*	 All rights reserved. No part of this work may be reproduced, stored in a
*	 retrieval system, or transmitted by any means without prior written
*	 permission of LG Electronics Inc.
*****************************************************************************/

/** @file 	appfrwk_remocon_key.h
*
*	define key & key type(REMOTE/LOCAL/)
*
*	@author 	Kun-IL Lee(dreamer@lge.com)
*	@version	1.0
*	@date	  	1999.12.3
*	@note
*/

/*---------------------------------------------------------
    (Header File Guarder )
---------------------------------------------------------*/
#ifndef _APPFRWK_COMMON_KEY_H_
#define	_APPFRWK_COMMON_KEY_H_

/*---------------------------------------------------------
    Control 상수 정의
    (Control Constants)
---------------------------------------------------------*/

/*---------------------------------------------------------
    #include 파일들
    (File Inclusions)
---------------------------------------------------------*/
#include <linux/input.h>

#ifdef __cplusplus
extern "C" {
#endif
/*---------------------------------------------------------
    상수 정의
    (Constant Definitions)
    linux/input.h에 존재하는 키는 그대로 mapping하고
    아닌 경우는 중복을 막기 위해 lge_base위에 정의한다.
---------------------------------------------------------*/
#define KEY_LG_BASE						KEY_MAX
#define	LGE_BASE(x)						(KEY_LG_BASE+(x))	/* x 는 0x1ff(511)개를 절대로 초과할 수 없다. 만약 초과시 linux/input.h 및 기타 수정 필수*/
#define KEY_LG_MAX							LGE_BASE(0x1ff)	/* x 는 0x1ff(511)개를 절대로 초과할 수 없다. 만약 초과시 linux/input.h 및 기타 수정 필수*/

/*	KEYs definition */

#define IR_KEY_COMP_RGB_HDMI            LGE_BASE(0x01)		/* 멀티미디어 : 지원 안함 */
#define IR_KEY_STORE_POWER              LGE_BASE(0x02)		/* Store Power On */
#define IR_KEY_LOCAL_DIMMING            LGE_BASE(0x03)		/* Local Dimming Demo */
#define IR_KEY_DASH                     LGE_BASE(0x04)		/* 0x4C Dash(-) */
#define IR_KEY_FLASHBACK                LGE_BASE(0x05)		/* 0x1A 이전채널 */
#define IR_KEY_HOME                     LGE_BASE(0x06)		/* 홈메뉴 */
#define IR_KEY_HOME_US                  LGE_BASE(0x07)		/* 홈메뉴 */
#define IR_KEY_RESLIST                  LGE_BASE(0x08)		/* 예약목록 */
#define IR_KEY_MARK                     LGE_BASE(0x09)		/* 마크 */
#define IR_KEY_LIVETV                   LGE_BASE(0x0a)		/* 0x9E Live TV */
#define IR_KEY_HCEC                     LGE_BASE(0x0b)
#define IR_KEY_TELETEXT                 LGE_BASE(0x0c)		/* Teletext(EU) */
#define IR_KEY_TEXTOPTION               LGE_BASE(0x0d)		/* Teletext(EU) */
#define IR_KEY_TEXTMODE                 LGE_BASE(0x0e)		/* Text mode(List) */
#define IR_KEY_TEXTMIX                  LGE_BASE(0x0f)		/* Text mix */
#define IR_KEY_TEXTSUBPAGE              LGE_BASE(0x10)		/* Text subpage(time) */
#define IR_KEY_TEXTREVEAL               LGE_BASE(0x11)		/* Text Reveal */
#define IR_KEY_FREEZE                   LGE_BASE(0x12)		/* Freeze */
#define IR_KEY_DA                       LGE_BASE(0x13)		/* Digital/Analog TV */
#define IR_KEY_PRLIST                   LGE_BASE(0x14)		/* Program List */
#define IR_KEY_DIGITALSETUP             LGE_BASE(0x15)		/* Digital Setup */
#define IR_KEY_POSITION                 LGE_BASE(0x16)		/* PIP Position/Text Update */
#define IR_KEY_SIZE                     LGE_BASE(0x17)		/* Text Size */
#define IR_KEY_GUIDEPAL                 LGE_BASE(0x18)		/* Guide(For PAL TV) */
#define IR_KEY_TV_RADIO                 LGE_BASE(0x19)
#define IR_KEY_QMENU                    LGE_BASE(0x1a)
#define IR_KEY_PIP                      LGE_BASE(0x1b)		/* 동시 화면 */
#define IR_KEY_TIMER                    LGE_BASE(0x1c)		/* 취침예약 */
#define IR_KEY_XD                       LGE_BASE(0x1d)		/* XD키 */
#define IR_KEY_ASPECT_RATIO             LGE_BASE(0x1e)		/* 화면크기 */
#define IR_KEY_SAP                      LGE_BASE(0x1f)		/* 음성다중 */
#define IR_KEY_CC                       LGE_BASE(0x20)		/* 자막방송 */
#define IR_KEY_EZPIC                    LGE_BASE(0x21)		/* 자동영상 */
#define IR_KEY_EZSOUND                  LGE_BASE(0x22)		/* 자동음성 */
#define IR_KEY_ADJUST                   LGE_BASE(0x23)		/* 조정메뉴 */
#define IR_KEY_EJECT                    LGE_BASE(0x24)		/* M/C 꺼내기 */
#define IR_KEY_DWTS                     LGE_BASE(0x25)		/* Delayed/Sync TS */
#define IR_KEY_MHEG                     LGE_BASE(0x26)		/* 데이터 방송 키 */
#define IR_KEY_ACAP                     LGE_BASE(0x27)		/* 데이터 방송 키 */
//#define IR_KEY_ACAP                     LGE_BASE(0x28)		/* 데이터 방송 키 */
#define IR_KEY_MHP                      LGE_BASE(0x29)		/* 데이터 방송 키 */
#define IR_KEY_SCR_KEYBOARD             LGE_BASE(0x2a)		/* screen keboard */
#define IR_KEY_AUTODEMO                 LGE_BASE(0x2b)
#define IR_KEY_AUTOSCAN                 LGE_BASE(0x2c)
#define IR_KEY_CHADDDEL                 LGE_BASE(0x2d)
#define IR_KEY_GOTOPREV                 LGE_BASE(0x2e)		/* Skip Backward */
#define IR_KEY_GOTONEXT                 LGE_BASE(0x2f)		/* Skip Forward */
#define IR_KEY_EMANUAL_PAGEPREV         LGE_BASE(0x30)		/* e-manual page forward */
#define IR_KEY_EMANUAL_PAGENEXT         LGE_BASE(0x31)		/* e-manual page backword */
#define IR_KEY_MOUSE_MCH                LGE_BASE(0x32)		// ???
#define IR_KEY_PAIRING_START            LGE_BASE(0x33)
#define IR_KEY_PAIRING_STOP             LGE_BASE(0x34)
#define IR_KEY_3D                       LGE_BASE(0x35)		//by hwangbos 20091214 IR_KEY_PAIRING_START //0xDB /* 3D on/off */
#define IR_KEY_3D_MODE                  LGE_BASE(0x36)		//by hwangbos 20091214 IR_KEY_PAIRING_STOP //0xDC /* 3D mode */
#define IR_KEY_3D_LR                    LGE_BASE(0x37)		/* 3D L/R */

	//	Broadband 관련
#define IR_KEY_YAHOO                    LGE_BASE(0x38)		/* YAHOO*/
#define IR_KEY_NETCAST                  LGE_BASE(0x39)		/* NETCAST */

	/* TV extension key */
#define IR_KEY_FORMAT_CHANGE            LGE_BASE(0x3a)		// 0x10E1

	/* DVR extension key */
#define IR_KEY_SLOW_FORWARD             LGE_BASE(0x3b)		// 0x11B0
#define IR_KEY_TIME_SHIFT               LGE_BASE(0x3c)		// 0x11BB /* 타임시프트 */


#define IR_KEY_GAMEMODE                 LGE_BASE(0x3d)		/* game mode - 070901 */
#define IR_KEY_AD                       LGE_BASE(0x3e)		/* Audio Description - 091109 */
#define IR_KEY_FAMILY                   LGE_BASE(0x3f)		/* Family Mode - 100323 */
#define IR_KEY_CRICKET                  LGE_BASE(0x40)		/* Cricket Mode - 100323 */
#define IR_KEY_BS                       LGE_BASE(0x41)
#define IR_KEY_BS_NUM_1                 LGE_BASE(0x42)
#define IR_KEY_BS_NUM_2                 LGE_BASE(0x43)
#define IR_KEY_BS_NUM_3                 LGE_BASE(0x44)
#define IR_KEY_BS_NUM_4                 LGE_BASE(0x45)
#define IR_KEY_BS_NUM_5                 LGE_BASE(0x46)
#define IR_KEY_BS_NUM_6                 LGE_BASE(0x47)
#define IR_KEY_BS_NUM_7                 LGE_BASE(0x48)
#define IR_KEY_BS_NUM_8                 LGE_BASE(0x49)
#define IR_KEY_BS_NUM_9                 LGE_BASE(0x4a)
#define IR_KEY_BS_NUM_10                LGE_BASE(0x4b)
#define IR_KEY_BS_NUM_11                LGE_BASE(0x4c)
#define IR_KEY_BS_NUM_12                LGE_BASE(0x4d)
#define IR_KEY_CS1                      LGE_BASE(0x4e)
#define IR_KEY_CS1_NUM_1                LGE_BASE(0x4f)
#define IR_KEY_CS1_NUM_2                LGE_BASE(0x50)
#define IR_KEY_CS1_NUM_3                LGE_BASE(0x51)
#define IR_KEY_CS1_NUM_4                LGE_BASE(0x52)
#define IR_KEY_CS1_NUM_5                LGE_BASE(0x53)
#define IR_KEY_CS1_NUM_6                LGE_BASE(0x54)
#define IR_KEY_CS1_NUM_7                LGE_BASE(0x55)
#define IR_KEY_CS1_NUM_8                LGE_BASE(0x56)
#define IR_KEY_CS1_NUM_9                LGE_BASE(0x57)
#define IR_KEY_CS1_NUM_10               LGE_BASE(0x58)
#define IR_KEY_CS1_NUM_11               LGE_BASE(0x59)
#define IR_KEY_CS1_NUM_12               LGE_BASE(0x5a)
#define IR_KEY_CS2                      LGE_BASE(0x5b)
#define IR_KEY_CS2_NUM_1                LGE_BASE(0x5c)
#define IR_KEY_CS2_NUM_2                LGE_BASE(0x5d)
#define IR_KEY_CS2_NUM_3                LGE_BASE(0x5e)
#define IR_KEY_CS2_NUM_4                LGE_BASE(0x5f)
#define IR_KEY_CS2_NUM_5                LGE_BASE(0x60)
#define IR_KEY_CS2_NUM_6                LGE_BASE(0x61)
#define IR_KEY_CS2_NUM_7                LGE_BASE(0x62)
#define IR_KEY_CS2_NUM_8                LGE_BASE(0x63)
#define IR_KEY_CS2_NUM_9                LGE_BASE(0x64)
#define IR_KEY_CS2_NUM_10               LGE_BASE(0x65)
#define IR_KEY_CS2_NUM_11               LGE_BASE(0x66)
#define IR_KEY_CS2_NUM_12               LGE_BASE(0x67)
#define IR_KEY_TER                      LGE_BASE(0x68)
#define IR_KEY_TER_NUM_1                LGE_BASE(0x69)
#define IR_KEY_TER_NUM_2                LGE_BASE(0x6a)
#define IR_KEY_TER_NUM_3                LGE_BASE(0x6b)
#define IR_KEY_TER_NUM_4                LGE_BASE(0x6c)
#define IR_KEY_TER_NUM_5                LGE_BASE(0x6d)
#define IR_KEY_TER_NUM_6                LGE_BASE(0x6e)
#define IR_KEY_TER_NUM_7                LGE_BASE(0x6f)
#define IR_KEY_TER_NUM_8                LGE_BASE(0x70)
#define IR_KEY_TER_NUM_9                LGE_BASE(0x71)
#define IR_KEY_TER_NUM_10               LGE_BASE(0x72)
#define IR_KEY_TER_NUM_11               LGE_BASE(0x73)
#define IR_KEY_TER_NUM_12               LGE_BASE(0x74)
#define IR_KEY_3DIGIT_INPUT             LGE_BASE(0x75)		//Japan Only - newly added
#define IR_KEY_BML_DATA                 LGE_BASE(0x76)		//Japan Only - newly added
#define IR_KEY_JAPAN_DISPLAY            LGE_BASE(0x77)		//Japan Only - newly added
#define IR_KEY_LEFT_SCROLL_1ST          LGE_BASE(0x78)		/* T-CON 좌1*/
#define IR_KEY_LEFT_SCROLL_2ND          LGE_BASE(0x79)		/* T-CON 좌2*/
#define IR_KEY_LEFT_SCROLL_3RD          LGE_BASE(0x7a)		/* T-CON 좌3*/
#define IR_KEY_LEFT_SCROLL_4TH          LGE_BASE(0x7b)		/* T-CON 좌4*/
#define IR_KEY_LEFT_SCROLL_5TH          LGE_BASE(0x7c)		/* T-CON 좌5*/
#define IR_KEY_RIGHT_SCROLL_1ST         LGE_BASE(0x7d)		/* T-CON 우1*/
#define IR_KEY_RIGHT_SCROLL_2ND         LGE_BASE(0x7e)		/* T-CON 우2*/
#define IR_KEY_RIGHT_SCROLL_3RD         LGE_BASE(0x7f)		/* T-CON 좌3*/
#define IR_KEY_RIGHT_SCROLL_4TH         LGE_BASE(0x80)		/* T-CON 좌4*/
#define IR_KEY_RIGHT_SCROLL_5TH         LGE_BASE(0x81)		/* T-CON 좌5*/

	/* factory key */
#define IR_KEY_EYE_Q                    LGE_BASE(0x82)
#define IR_KEY_IN_STOP                  LGE_BASE(0x83)
#define IR_KEY_IN_START                 LGE_BASE(0x84)
#define IR_KEY_P_CHECK                  LGE_BASE(0x85)
#define IR_KEY_HDMI_CHECK               LGE_BASE(0x86)		//[081020 leekyungho] : IR_KEY_HDMI_CHECK(0xA6) 기능 UI 대응
#define IR_KEY_S_CHECK                  LGE_BASE(0x87)
#define IR_KEY_POWERONLY                LGE_BASE(0x88)
#define IR_KEY_ADJ                      LGE_BASE(0x89)
#define IR_KEY_FRONT_AV                 LGE_BASE(0x8a)
#define IR_KEY_FMODE_INIT               LGE_BASE(0x8b)
#define IR_KEY_FMODE_START              LGE_BASE(0x8c)
#define IR_KEY_FMODE_F1                 LGE_BASE(0x8d)
#define IR_KEY_IN_TIME                  LGE_BASE(0x8e)
#define IR_KEY_LAMP_RESET               LGE_BASE(0x8f)		/* for KOR model */
#define IR_KEY_DISPMODE_READY           LGE_BASE(0x90)		/* for KOR model */
#define IR_KEY_BLUETOOTH                LGE_BASE(0x91)
#define IR_KEY_USB_CHECK                LGE_BASE(0x92)		/* 081106 swbyun : IR_KEY_USB_CHECK(0xEE) 기능 UI 대응 */
#define IR_KEY_USB2_CHECK               LGE_BASE(0x93)		/* stonedef - 091121 : USB 2 port JPEG, MP3 자동 play */


#define IR_KEY_TILT                     LGE_BASE(0x94)		/* Module Pattern Generation */


	/* DMS 요구사항에 의해 추가된 Key Code로
		생산 line에서 사용하는 별도의 Remocon이 있음
		Test를 위해서 별도의 Key code를 사용해야함.*/
#define IR_KEY_POWERSAVING_TEST         LGE_BASE(0x95)		/* DMS 요구사항 반영 */

	/* front key */
#define IR_FRONTKEY_INPUT_SELECT        LGE_BASE(0x96)
#define IR_FRONTKEY_MENU                LGE_BASE(0x97)
#define IR_FRONTKEY_ENTER               LGE_BASE(0x98)
#define IR_FRONTKEY_CH_UP               LGE_BASE(0x99)
#define IR_FRONTKEY_CH_DOWN             LGE_BASE(0x9a)
#define IR_FRONTKEY_VOL_UP              LGE_BASE(0x9b)
#define IR_FRONTKEY_VOL_DOWN            LGE_BASE(0x9c)
#define IR_FRONTKEY_POWER               LGE_BASE(0x9d)


#define IR_KEY_MULTICHANNEL             LGE_BASE(0x9e)		// 0x10FA
#define IR_KEY_WIDGET                   LGE_BASE(0x9f)		// 0x10FB
#define IR_KEY_SETUP                    LGE_BASE(0xa0)		// 0x10FC
#define IR_KEY_MULTIMEDIA               LGE_BASE(0xa1)		// 0x10FD
#define IR_KEY_FLASHGAME                LGE_BASE(0xa2)		// 0x10FE
#define IR_KEY_PHOTOLIST                LGE_BASE(0xa3)		// 0x10FF
#define IR_KEY_MUSICLIST                LGE_BASE(0xa4)		// 0x1100
#define IR_KEY_MOVIELIST                LGE_BASE(0xa5)		// 0x1101
#define IR_KEY_DIRECTOSD                LGE_BASE(0xa6)		// 0x1102
#define IR_KEY_EMANUAL                  LGE_BASE(0xa7)		// 0x1103
#define IR_KEY_BT_MENU                  LGE_BASE(0xa8)		// 0x1104
#define IR_KEY_VIR_INPUTLIST            LGE_BASE(0xa9)		// 0x1105
#define IR_KEY_GAME_REAL_SWING          LGE_BASE(0xaa)		// 0x1106
#define IR_KEY_GAME_SUDO_SWING          LGE_BASE(0xab)		// 0x1107
#define IR_KEY_CUBEMENU                 LGE_BASE(0xac)		// 0x1108
#define IR_KEY_SIMPLINK                 LGE_BASE(0xad)		// 0x110a
#define IR_KEY_MYMEDIA                  LGE_BASE(0xae)		// 0x110b
#define DSC_IR_KEY_PWRON                LGE_BASE(0xaf)
#define DSC_IR_KEY_PWROFF               LGE_BASE(0xb0)
#define DSC_IR_KEY_ARC4X3               LGE_BASE(0xb1)
#define DSC_IR_KEY_ARC16X9              LGE_BASE(0xb2)
#define DSC_IR_KEY_ARCZOOM              LGE_BASE(0xb3)
#define DSC_IR_KEY_TV                   LGE_BASE(0xb4)
#define DSC_IR_KEY_DTV                  LGE_BASE(0xb5)
#define DSC_IR_KEY_CADTV                LGE_BASE(0xb6)
#define DSC_IR_KEY_VIDEO1               LGE_BASE(0xb7)
#define DSC_IR_KEY_VIDEO2               LGE_BASE(0xb8)
#define DSC_IR_KEY_VIDEO3               LGE_BASE(0xb9)
#define DSC_IR_KEY_COMP1                LGE_BASE(0xba)
#define DSC_IR_KEY_COMP2                LGE_BASE(0xbb)
#define DSC_IR_KEY_COMP3                LGE_BASE(0xbc)		/* stonedef - 091121, Component 3 Hotkey */
#define DSC_IR_KEY_RGBPC                LGE_BASE(0xbd)
#define DSC_IR_KEY_RGBDTV               LGE_BASE(0xbe)
#define DSC_IR_KEY_RGBDVI               LGE_BASE(0xbf)
#define DSC_IR_KEY_HDMI1                LGE_BASE(0xc0)
#define DSC_IR_KEY_HDMI2                LGE_BASE(0xc1)
	//기판 모드 대응 see _SUMODE_CircuitModeKeyHandler()
#define DSC_IR_KEY_HDMI3                LGE_BASE(0xc2)
#define DSC_IR_KEY_HDMI4                LGE_BASE(0xc3)
#define DSC_IR_KEY_VOL30                LGE_BASE(0xc4)		/* VOL 30 */
#define DSC_IR_KEY_VOL50                LGE_BASE(0xc5)		/* VOL 50 */
#define DSC_IR_KEY_VOL80                LGE_BASE(0xc6)		/* VOL 80 */
#define DSC_IR_KEY_VOL100               LGE_BASE(0xc7)		/* VOL 100 */
#define DSC_IR_KEY_SUBSTRATE            LGE_BASE(0xc8)		/* 기판 Mode 진입 */
#define DSC_IR_KEY_MULTI_PIP            LGE_BASE(0xc9)		/* 기판 Mode 초기화 기능 추가 */
#define DSC_IR_KEY_WB_MODE              LGE_BASE(0xca)		/* WB Mode 진입 */
#define DSC_IR_KEY_POWERONLY_OFF        LGE_BASE(0xcb)		/* PowerOnly 해제 */


	/* 아래 키 들은 자가 진단을 위해 사용함*/
#define DSC_IR_KEY_SELF_DIAG_00         LGE_BASE(0xcc)		/* 자가 진단 Group 1, 2, 3 */
#define DSC_IR_KEY_SELF_DIAG_10         LGE_BASE(0xcd)		/* 자가 진단 Group 1*/
#define DSC_IR_KEY_SELF_DIAG_20         LGE_BASE(0xce)		/* 자가 진단 Group 2*/
#define DSC_IR_KEY_SELF_DIAG_30         LGE_BASE(0xcf)		/* 자가 진단 Group 3*/
#define DSC_IR_KEY_SELF_DIAG_11         LGE_BASE(0xd0)		/* 자가 진단 AV */
#define DSC_IR_KEY_SELF_DIAG_12         LGE_BASE(0xd1)		/* 자가 진단 component */
#define DSC_IR_KEY_SELF_DIAG_13         LGE_BASE(0xd2)		/* 자가 진단 RGB */
#define DSC_IR_KEY_SELF_DIAG_21         LGE_BASE(0xd3)		/* 자가 진단 HDMI1 */
#define DSC_IR_KEY_SELF_DIAG_22         LGE_BASE(0xd4)		/* 자가 진단 HDMI2 */
#define DSC_IR_KEY_SELF_DIAG_23         LGE_BASE(0xd5)		/* 자가 진단 HDMI3 */
#define DSC_IR_KEY_SELF_DIAG_24         LGE_BASE(0xd6)		/* 자가 진단 HDMI4 */
#define DSC_IR_KEY_SELF_DIAG_25         LGE_BASE(0xd7)		/* 자가 진단 HDMI5 */
#define DSC_IR_KEY_SELF_DIAG_31         LGE_BASE(0xd8)		/* 자가 진단 RF - 사용 안함 */

#define IR_KEY_AUTOCONFIGURE            LGE_BASE(0xd9)		/* Auto Configuration*/

	//hojin.koh_110219 - Add Japan Model two byte key code definition.
	//IR_KEY_HOTELMODE, IR_KEY_HOTELMODE_READY 를 Virtual Key Code로 변경.
#define IR_KEY_HOTELMODE                LGE_BASE(0xda)		// 0x05CF
#define IR_KEY_HOTELMODE_READY          LGE_BASE(0xdb)		// 0x0523
#define IR_KEY_MYAPPS					LGE_BASE(0xdc)		/* GP4 New key value */
#ifdef INCLUDE_PENTOUCH
#define IR_KEY_PENTOUCH					LGE_BASE(0xdf)
#endif

//changwook.joo_111011 - Add Japan Model two byte key code definition.
// IR_KEY_SET_REGIST를 Virtual key code로 변경.
#define IR_KEY_SETCHANNEL				LGE_BASE(0xe0)
#define IR_KEY_PAIRING_M4				LGE_BASE(0xe1)

#define IR_KEY_POWER					KEY_POWER			/* 0x08 전원  */
#define IR_KEY_TV						KEY_TV				/* 0x0F TV */
#define IR_KEY_TV_VIDEO 				KEY_VIDEO_NEXT		/* 0x0B  TV/외부입력 */
#define IR_KEY_0						KEY_0				/*  0x10 숫자 0 */
#define IR_KEY_1						KEY_1				/* 0x11 숫자 1 */
#define IR_KEY_2						KEY_2				/* 0x12  숫자 2 */
#define IR_KEY_3						KEY_3				/* 0x13  숫자 3 */
#define IR_KEY_4						KEY_4				/* 0x14  숫자 4 */
#define IR_KEY_5						KEY_5				/* 0x15  숫자 5 */
#define IR_KEY_6						KEY_6				/* 0x16  숫자 6 */
#define IR_KEY_7						KEY_7				/* 0x17  숫자 7 */
#define IR_KEY_8						KEY_8				/* 0x18  숫자 8 */
#define IR_KEY_9						KEY_9				/* 0x19  숫자 9 */
#define IR_KEY_CH_UP					KEY_CHANNELUP		/* 0x00  채널 + */
#define IR_KEY_CH_DOWN					KEY_CHANNELDOWN		/* 0x01  채널 - */
#define IR_KEY_VOL_UP					KEY_VOLUMEUP		/* 0x02  음량 + */
#define IR_KEY_VOL_DOWN 				KEY_VOLUMEDOWN		/* 0x03  음량 - */
#define IR_KEY_MUTE 					KEY_MUTE			/* 0x09 조용히 */
#define IR_KEY_FAVORITE 				KEY_FAVORITES		/* 0x1E 선호채널  */
#define IR_KEY_MENU 					KEY_MENU			/* 0x43 메뉴 */
#define IR_KEY_GRIDGUIDE				KEY_PROGRAM			/* 0xA9 전체방송 */
#define IR_KEY_INFO 					KEY_INFO			/* 0xAA 현재방송 */
#define IR_KEY_EXIT 					KEY_EXIT			/* 0x5B 취소 */
#define IR_KEY_UP_ARROW 				KEY_UP				/* 0x40 UP	 */
#define IR_KEY_DOWN_ARROW				KEY_DOWN			/* 0x41 DOWN  */
#define IR_KEY_LEFT_ARROW				KEY_LEFT			/* 0x07 MINUS */
#define IR_KEY_RIGHT_ARROW				KEY_RIGHT			/* 0x06 PLUS  */
#define IR_KEY_ENTER					KEY_ENTER			/* 0x44 확인   */
#define IR_KEY_BACK						KEY_PREVIOUS 		/* 0x28 Back */
	//#define IR_KEY_BACK					KEY_BACK			/* 0x28 Back */
#define IR_KEY_RED						KEY_RED
#define IR_KEY_GREEN					KEY_GREEN
#define IR_KEY_YELLOW					KEY_YELLOW
#define IR_KEY_BLUE 					KEY_BLUE
#define IR_KEY_PLAY 					KEY_PLAY			/* 0xB0 재생 */
#define IR_KEY_PAUSE					KEY_PAUSE			/* 0xBA  일시정지 */
#define IR_KEY_STOP 					KEY_STOP			/* 0xB1 정지 */
#define IR_KEY_REC						KEY_RECORD			/* 0xBD 녹화 */
#define IR_KEY_REW						KEY_REWIND   		/* 0x8F 되감기	*/
#define IR_KEY_FF						KEY_FASTFORWARD    	/* 0x8E 빨리감기 */

	/* 화면 밝기 */
#define IR_KEY_BRIGHTNESS_UP			KEY_BRIGHTNESSUP	/* 0xE0 화면밝기+ */
#define IR_KEY_BRIGHTNESS_DOWN			KEY_BRIGHTNESSDOWN	/* 0xE1 화면밝기- */


#define IR_KEY_PIP_CH_UP				IR_KEY_GREEN		/* 부화면+ */
#define IR_KEY_PIP_CH_DOWN				IR_KEY_RED			/* 부화면- */
#define IR_KEY_PIP_INPUT				IR_KEY_BLUE			/* 부입력 */
#define IR_KEY_SWAP						IR_KEY_YELLOW		/* 주부전환 */

	//Ch Edit에서 Color key대응
	//Lock 메뉴에서 Block channel 에 Green color key 추가함
#define IR_KEY_CHEDIT_AUTO_SORT			IR_KEY_GREEN
	//#define IR_KEY_CHEDIT_DEL 			IR_KEY_GREEN
#define IR_KEY_CHEDIT_MOVE				IR_KEY_YELLOW
#define IR_KEY_CHEDIT_SKIP          	IR_KEY_BLUE

	// Delete key
#define IR_KEY_LOCK_DEL					IR_KEY_RED


#define IR_KEY_MODE						IR_KEY_RED			/* R */
#define IR_KEY_TIMER_LIST				IR_KEY_BLUE			/* B */
#define IR_KEY_MANUAL_TIMER				IR_KEY_YELLOW		/* Y */
#define IR_KEY_DATE 					IR_KEY_GREEN		/* N */

	/* TV extension key */
#define IR_KEY_PAGE_UP					IR_KEY_CH_UP
#define IR_KEY_PAGE_DOWN				IR_KEY_CH_DOWN
#define IR_KEY_PAGE_RIGHT				IR_KEY_SYNC
#define IR_KEY_PAGE_LEFT				IR_KEY_MV2START


#define IR_KEY_GUIDE					IR_KEY_GRIDGUIDE

	/* DVR extension key */
#define IR_KEY_MV2START 				IR_KEY_GOTOPREV		/* 처음 보기 */
#define IR_KEY_SYNC 					IR_KEY_GOTONEXT		/* 끝 보기 */
#define IR_KEY_RESUME					IR_KEY_PLAY
#define IR_KEY_PAUSE_SLOWFWD			IR_KEY_PAUSE
#define IR_KEY_IREPLAY					IR_KEY_GOTOPREV
#define IR_KEY_SKIPFWD					IR_KEY_GOTONEXT


#define IR_KEY_RECLIST					IR_KEY_GREEN 		/* 한국향 dvr ready에서 green키를 reclist (녹화목록) 키로 이용함. */
#define IR_KEY_REPEAT					IR_KEY_BLUE 		/* 한국향 dvr ready에서 blue키를 repeat (구간반복) 키로 이용함. */	// IR_KEY_MARK
#define IR_KEY_EDIT						IR_KEY_YELLOW 		/* GP2 dvr ready에서 YELLOW키를 edit (구간편집) 키로 이용함. */
#define IR_KEY_EZ_ADJUST        		IR_KEY_ADJ
#define IR_KEY_DISPMODE					IR_KEY_AUTODEMO

	/* front key */
#define IR_FRONTKEY_TVGUIDE 			IR_FRONTKEY_INPUT_SELECT


#define IR_KEY_CONTENTSLINK				IR_KEY_FLASHGAME


	/* 아래 키 들은 자가 진단을 위해 사용함*/
#define DSC_IR_KEY_SELF_DIAG_32			IR_KEY_SCR_KEYBOARD /*자가 진단 DTV - 사용 안함 */

	//#define IR_KEY_INFORMATION			0x1B				/* Information(EU) */
	//#define IR_KEY_TEXTHOLD					0x65				/* ext Hold */
	//#define IR_KEY_SUBTITLE				0x56				/* Subtitle ( It will be combine with 0x39) */
	//#define IR_KEY_MOUSE_MENU 			0x3A
#define IR_KEY_MOUSE_OK					BTN_MOUSE			// 0x29
	//#define IR_KEY_FREEZE 				0x1010
#define IR_KEY_RESREGIST				0x118A

	/* T-CON */
#define IR_KEY_TCON_UP					0x30F0	/* T-CON Virtual Key */
#define IR_KEY_TCON_UPRIGHT				0x30F1	/* T-CON Virtual Key */
#define IR_KEY_TCON_RIGHT				0x30F2	/* T-CON Virtual Key */
#define IR_KEY_TCON_DOWNRIGHT			0x30F3	/* T-CON Virtual Key */
#define IR_KEY_TCON_DOWN				0x30F4	/* T-CON Virtual Key */
#define IR_KEY_TCON_DOWNLEFT			0x30F5	/* T-CON Virtual Key */
#define IR_KEY_TCON_LEFT				0x30F6	/* T-CON Virtual Key */
#define IR_KEY_TCON_UPLEFT				0x30F7	/* T-CON Virtual Key */

	/* Factory Mode */
#define IR_VIRKEY_SHOWMSG_ADJUST		0x2021
#define IR_VIRKEY_CHANGE_SOURCE_AV1		0x2022
#define IR_VIRKEY_CHANGE_SOURCE_COMP1	0x2023
#define IR_VIRKEY_CHANGE_SOURCE_RGB 	0x2024
#define IR_VIRKEY_ADJUST_UPD			0x2025
#define IR_VIRKEY_ADJUST_AD 			0x2026				/* ADC 조정을 위해 사용 */
#define IR_VIRKEY_ADAVOSD				0x2027

	/* front key */
	//#define IR_FRONTKEY_AV					0x51				/* 조정 remocon key - 생산시 front AV로 전환하는데 사용 */


	//#define DSC_IR_KEY_CATV				0xF0				/* 임시 DSC key 할당(CATV,DTV,CADTV,HDMI2 ) */



	/************************************************************
		Virtual Keys for media box
	************************************************************/
#define WL_VIRKEY_AV1					0x4010
#define WL_VIRKEY_AV2					0x4011
#define WL_VIRKEY_COMP1					0x4012
#define WL_VIRKEY_COMP2					0x4013
#define WL_VIRKEY_RGB					0x4014
#define WL_VIRKEY_HDMI1					0x4015
#define WL_VIRKEY_HDMI2					0x4016
#define WL_VIRKEY_HDMI3					0x4017
#define WL_VIRKEY_HDMI4					0x4018

	/************************************************************
		Virtual Keys for Commercial
	************************************************************/
#define IR_VIRKEY_ASPECTRATIO			0x5000

#define IR_VIRKEY_CONTRAST				0x5004
#define IR_VIRKEY_BRIGHTNESS			0x5005
#define IR_VIRKEY_COLOR					0x5006
#define IR_VIRKEY_SHARPNESS				0x5007
#define IR_VIRKEY_COLORTEMP				0x5008
#define IR_VIRKEY_TINT					0x5009
#define IR_VIRKEY_TREBLE				0x500A
#define IR_VIRKEY_BASS					0x500B
#define IR_VIRKEY_BALANCE				0x500C
#define IR_VIRKEY_DVIPC					0x500D
#define IR_VIRKEY_DTV					0x500E
#define IR_VIRKEY_PIP					0x500F
#define IR_VIRKEY_DW					0x5010
#define IR_VIRKEY_ISM_METHOD			0x5011
#define IR_VIRKEY_ORBITER_TIME			0x5012
#define IR_VIRKEY_ORBITER_PIXEL			0x5013
#define IR_VIRKEY_KEY_LOCK				0x5014
#define IR_VIRKEY_OSD_SELECT			0x5015
#define IR_VIRKEY_ANTENNA				0x5016
#define IR_VIRKEY_CABLE					0x5017
#define IR_VIRKEY_LOWPOWER				0x5019
#define IR_VIRKEY_ADDDELETE				0x5020
#define IR_VIRKEY_EYEQGREEN				0x5021
#define IR_VIRKEY_VOLUME				0x5022
#define IR_VIRKEY_AUTOCONFIG			0x5023
#define IR_VIRKEY_RED					0x5028
#define IR_VIRKEY_BLUE					0x5029
#define IR_VIRKEY_GREEN					0x5030
#define IR_VIRKEY_EQ					0x5031
#define IR_VIRKEY_BACKLIGHT				0x5032
#define IR_VIRKEY_OAD					0x5026
#define IR_VIRKEY_BAD_CABLE_SIGNAL		0x5027

	/*hdcho Text hold 기능 수행위한 key*/
#define IR_VIRKEY_TEXTHOLD				0x5028
	/*ymseo Rec Key valid check 없이 instant rec 진입을 위한 key*/
#define IR_VIRKEY_REC					0x5033


#define IR_VIRKEY_3D_ONOFF				0x5034
#define IR_VIRKEY_3D_3DTO2D				0x5035
#define IR_VIRKEY_3D_2DTO3D				0x5036
#define IR_VIRKEY_3DOPT_IMG_CORRECT		0x5037
#define IR_VIRKEY_3DOPT_DEPTH			0x5038
#define IR_VIRKEY_3DOPT_VIEWPOINT		0x5039
#define IR_VIRKEY_3DOPT_OPTIMIZATION	0x5040
#define IR_VIRKEY_3DOPT_PIC_SIZE		0x5041
#define IR_VIRKEY_3DOPT_BALANCE			0x5042
#define IR_VIRKEY_3DOPT_COLOUR_CORRECT  0x5043
#define IR_VIRKEY_3DOPT_SOUND_ZOOM      0x5044
#define IR_VIRKEY_3DOPT_NORMAL_IMAGE    0x5045
#define IR_VIRKEY_3DOPT_MODE            0x5046
#define IR_VIRKEY_3DOPT_ONSTARTSETTING  0x5047
#define IR_VIRKEY_TEXTDISPLAY           0x5048

	//--------------------------------------------------//
	//			Magic Motion Remote RF Key				//
	//--------------------------------------------------//
	//#define RF_KEY_NUM						14
#define MM_RF_KEY_NONE					0x0000
#define MM_RF_KEY_POWER					0x0080
#define MM_RF_KEY_MUTE					0x0001
#define MM_RF_KEY_OK					0x0002
#define MM_RF_KEY_VOL_UP				0x0004
#define MM_RF_KEY_VOL_DOWN				0x0008
#define MM_RF_KEY_CH_UP					0x0010
#define MM_RF_KEY_CH_MULTI				0x0020
#define MM_RF_KEY_CH_DOWN				0x0040

#define MM_RF_KEY_UP					0x00F1
#define MM_RF_KEY_DOWN					0x00F2
#define MM_RF_KEY_LEFT					0x00F3
#define MM_RF_KEY_RIGHT					0x00F4
#define MM_RF_KEY_MENU					0x00F5

	//--------------------------------------------------//
	//			Magic Motion Remote UI Key				//
	//--------------------------------------------------//
// to be 	deleted start !!!!!!!!!!
#define RF_KEY_NONE 					0x0000
#define RF_KEY_OK						0x0100
#define RF_KEY_WHEEL					0x0200
#define RF_KEY_MUTE						0x0400
#define RF_KEY_VOL_DOWN				0x0800
#define RF_KEY_VOL_UP					0x1000
#define RF_KEY_CH_DOWN				0x2000
#define RF_KEY_CH_UP					0x4000
#define RF_KEY_CH_MULTI				0x8000

#define RF_KEY_UP						0x0001
#define RF_KEY_DOWN					0x0002
#define RF_KEY_DRAG						0x0004
#define RF_KEY_REPEAT					0x0008

#define RF_KEY_OK_DOWN				(RF_KEY_OK | RF_KEY_DOWN)
#define RF_KEY_OK_UP					(RF_KEY_OK | RF_KEY_UP)
#define RF_KEY_OK_DRAG					(RF_KEY_OK | RF_KEY_DRAG)
#define RF_KEY_OK_REPEAT				(RF_KEY_OK | RF_KEY_DRAG | RF_KEY_REPEAT)
#define RF_KEY_VOL_UP_UP				(RF_KEY_VOL_UP | RF_KEY_UP)
#define RF_KEY_VOL_DOWN_UP			(RF_KEY_VOL_DOWN| RF_KEY_UP)
#define RF_KEY_CH_UP_UP				(RF_KEY_CH_UP | RF_KEY_UP)
#define RF_KEY_CH_DOWN_UP				(RF_KEY_CH_DOWN | RF_KEY_UP)
// to be deleted end!!!!!!!!!!!!!!

#define RF_KEY_LAUNCHER				IR_KEY_MYAPPS
#define RF_KEY_3D_MODE				IR_KEY_3D_MODE
#define RF_KEY_HOME						IR_KEY_HOME
#define RF_KEY_EMANUAL				IR_KEY_EMANUAL


//#define CURSOR_ON_INIT					(0x8000 | 0x0000)
//#define RF_KEY_GESTURECH_DOWN			(0x8000 | RF_KEY_DOWN)
//#define RF_KEY_GESTURECH_UP


/*	definitions of special keys for LGE	*/

#define KEY_LGE_DEBUG_CURSOR				0x4A0
#define KEY_LGE_MRCU_VOICE_RECOGSTART		0x4A1
#define KEY_LGE_MRCU_VOICE_RECOGSUCCESS		0x4A2
#define KEY_LGE_MRCU_VOICE_RECOGING			0x4A3
#define KEY_LGE_MRCU_VOICE_RECOGFAIL		0x4A4
#define KEY_LGE_MRCU_VOICE_EXIT				0x4A5
#define KEY_LGE_MRCU_VOICE_NOINPUTERROR		0x4A6
#define KEY_LGE_MRCU_VOICE_NETWORKERROR		0x4A7
#define KEY_LGE_MRCU_VOICE_SERVERERROR		0x4A8
#define KEY_LGE_MRCU_VOICE_MULTIRECOGSTART	0x4A9

#define KEY_LGE_MRCU_PAIR_START			0x4AA
#define KEY_LGE_MRCU_PAIR_STOP			0x4AB
#define KEY_LGE_MRCU_PAIR_OK   			0x4AC
#define KEY_LGE_MRCU_PAIR_NG			    0x4AD
#define KEY_LGE_CURSOR_SHOW			    0x4AE
#define KEY_LGE_CURSOR_HIDE			    0x4AF

#define KEY_LGE_MRCU_GESTURE_IDLE_START			0x4B0
#define KEY_LGE_MRCU_GESTURE_WEB_START			0x4B1
#define KEY_LGE_MRCU_GESTURE_CHECK			0x4B2
#define KEY_LGE_MRCU_GESTURE_RIGHT				0x4B3
#define KEY_LGE_MRCU_GESTURE_CIRCLE			0x4B4
#define KEY_LGE_MRCU_GESTURE_CIRCLE_INVERSE	0x4B5
#define KEY_LGE_MRCU_GESTURE_INVALID			0x4B6
#define KEY_LGE_MRCU_GESTURE_FAIL				0x4B7
#define KEY_LGE_MRCU_GESTURE_END				0x4B8
#define KEY_LGE_MRCU_DISCONNECTED				0x4B9
#define KEY_LGE_WIFI_DISCONNECTED				0x4BA
#define KEY_LGE_MRCU_LOW_BATTERY				0x4BB
#define KEY_LGE_WIFI_SMARTTEXTEND            0x4BC
#define KEY_LGE_MRCU_LOW_SIGNAL_STRENGTH		0x4BD
#define KEY_LGE_MRCU_GESTURE_SHAKE			0x4BE

#define KEY_LGE_MRCU_VOICE_BUTTONENABLE		0x4C1
#define KEY_LGE_MRCU_VOICE_BUTTONDISABLE	0x4C2

#define KEY_LGE_GESTURECAMERA_POWER_OFF		 0x4D1		// Gesture Camera 2011. 10.15
#define KEY_LGE_GESTURECAMERA_READY_FORUSE	 0x4D2		// Gesture camera 2011. 11. 14
#define KEY_LGE_GESTURECAMERA_HAND_ACTIVATED 0x4D3		// Gesture Camera 2011. 11. 18

#define KEY_LGE_INPUT_FIRST				        0x4F0	// Print input's list

#define KEY_LGE_INPUT_PRINT				(KEY_LGE_INPUT_FIRST + 1)	// Print input's list
#define KEY_LGE_INPUT_CHECK				(KEY_LGE_INPUT_PRINT + 1)
#define KEY_LGE_INPUT_LAST				(KEY_LGE_INPUT_CHECK + 1)
/***********************************************
*  0x4FE  is LAST KEY VALUE. Do not exceed the value.   *
************************************************/

/*	definitions of sensor data and packet ID*/

#define ABS_LGE_GYRO_X	 	0x21
#define ABS_LGE_GYRO_Y 	 	0x22
#define ABS_LGE_GYRO_Z	 	0x23
#define ABS_LGE_ACCEL_X	 	0x24
#define ABS_LGE_ACCEL_Y	 	0x25
#define ABS_LGE_ACCEL_Z 	0x26
#define ABS_LGE_QUATERNION_X		0x27
#define ABS_LGE_QUATERNION_Y		0x29
#define ABS_LGE_QUATERNION_Z		0x3a
#define ABS_LGE_QUATERNION_W		0x3b

/*---------------------------------------------------------
    매크로 함수 정의
    (Macro Definitions)
---------------------------------------------------------*/
/*	Key Type 확인
*/
#define IS_KEY_TYPE_REMOTE( x )		(((x) == KEY_TYPE_REMOTE_SINGLE) || ((x) == KEY_TYPE_REMOTE_REPEAT))
#define IS_KEY_TYPE_LOCAL( x )		(((x) == KEY_TYPE_LOCAL_SINGLE ) || ((x) == KEY_TYPE_LOCAL_REPEAT ))
#define	IS_KEY_TYPE_SINGLE( x )		(((x) == KEY_TYPE_REMOTE_SINGLE) || ((x) == KEY_TYPE_LOCAL_SINGLE ))
#define	IS_KEY_TYPE_REPEAT( x )		(((x) == KEY_TYPE_REMOTE_REPEAT) || ((x) == KEY_TYPE_LOCAL_REPEAT ))

#ifdef INCLUDE_REMOTESVC
#define	IS_KEY_TYPE_REMOTESVC( x )	(((x) == KEY_TYPE_REMOTESVC))
#endif

/*---------------------------------------------------------
    Type 정의
    (Type Definitions)
---------------------------------------------------------*/

/**
 * 	KEY(event) Type
 *
 * @see	the 2nd paramter of UI_KEY_RESULT_T UI_MAIN_SendKeyToUI( UINT32 key, UINT32 keyType );
 */
/**
 * bk1472(최배권 책임 comment -
 * enumeration type에서는 platform 별 system 별 분기가 필요 없도록
 * 작성 바랍니다.
 */
typedef enum
{
	/*	KEY TYPE	definition */
	KEY_TYPE_REMOTE_SINGLE		=	0x0000,	/**< KEY TYPE:	remocom single	*/
	KEY_TYPE_REMOTE_REPEAT		=	0x0001,	/**< KEY TYPE:	remocom repeat	*/
	KEY_TYPE_LOCAL_SINGLE		=	0x0002,	/**< KEY TYPE:	local single	*/
	KEY_TYPE_LOCAL_REPEAT		=	0x0003,	/**< KEY TYPE:	local repeat	*/
	KEY_TYPE_COMMAND			=	0x0004, /**< KEY TYPE:	RS232C command*/
//#ifdef INCLUDE_BUILT_IN_LOG
	KEY_TYPE_RF_SINGLE			= 	0x0005, /**< KEY TYPE:	RF single */
	KEY_TYPE_RF_REPEAT			= 	0x0006, /**< KEY TYPE:	RF single */
//#endif

#ifdef INCLUDE_MOUSE
	KEY_TYPE_MOUSE_OFF_SINGLE	=   0x0007, /**< KEY TYPE:	mouse off IR Key single */
#endif

#ifdef INCLUDE_REMOTESVC
	KEY_TYPE_REMOTESVC			=   0x0008, /**< KEY TYPE:	for remote service */
#endif
	KEY_TYPE_RELEASE				=	0x0009,
	KEY_TYPE_HID_SINGLE			=	0x000A,
	KEY_TYPE_HID_REPEAT				=	0x000B,
	KEY_TYPE_LAST							/**< KEY TYPE:	last value		*/

}	KEY_TYPE_T;

/*---------------------------------------------------------
    함수 선언
    (Function Declaration)
---------------------------------------------------------*/

#ifdef __cplusplus
}
#endif
#endif  /* _APPFRWK_COMMON_KEY_H_ */

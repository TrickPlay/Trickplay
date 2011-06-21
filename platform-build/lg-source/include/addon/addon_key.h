/******************************************************************************
 *   Software Center, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2010 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/

/** @file addon_key.h
 *
 *  Addon key definition
 *
 *  @author     YoungJin Ro (youngjin.ro@lge.com)
 *  @version    1.0
 *  @date       2010.03.16
 *  @note
 *  @see
 */

/******************************************************************************
	Header File Guarder
******************************************************************************/
#ifndef _ADDON_KEY_H_
#define	_ADDON_KEY_H_

#ifdef __cplusplus
extern "C" {
#endif

/******************************************************************************
	전역 제어 상수 (Control Constants)
******************************************************************************/

/******************************************************************************
	#include 파일들 (File Inclusions)
******************************************************************************/

/******************************************************************************
	상수 정의(Constant Definitions)
******************************************************************************/

/************************************************************
	DTV Key Definition
************************************************************/

/* TV remote control key */
#define AO_IR_KEY_POWER					0x0008				/*  전원  */
#define AO_IR_KEY_TV					0x000F				/*  TV */
#define AO_IR_KEY_TV_VIDEO 				0x000B				/*  TV/외부입력 */
#define AO_IR_KEY_COMP_RGB_HDMI			0x0098				/*  멀티미디어 : 지원 안함 */

#define AO_IR_KEY_0						0x0010				/*  숫자 0 */
#define AO_IR_KEY_1						0x0011				/*  숫자 1 */
#define AO_IR_KEY_2						0x0012				/*  숫자 2 */
#define AO_IR_KEY_3						0x0013				/*  숫자 3 */
#define AO_IR_KEY_4						0x0014				/*  숫자 4 */
#define AO_IR_KEY_5						0x0015				/*  숫자 5 */
#define AO_IR_KEY_6						0x0016				/*  숫자 6 */
#define AO_IR_KEY_7						0x0017				/*  숫자 7 */
#define AO_IR_KEY_8						0x0018				/*  숫자 8 */
#define AO_IR_KEY_9						0x0019				/*  숫자 9 */
#define AO_IR_KEY_DASH 					0x004C				/*  Dash(-) */
#define AO_IR_KEY_FLASHBACK				0x001A				/*  이전채널 */

#define AO_IR_KEY_CH_UP					0x0000				/*  채널 + */
#define AO_IR_KEY_CH_DOWN				0x0001				/*  채널 - */
#define AO_IR_KEY_VOL_UP				0x0002				/*  음량 + */
#define AO_IR_KEY_VOL_DOWN 				0x0003				/*  음량 - */

#define AO_IR_KEY_HOME 					0x007C				/*  홈메뉴 */
#define AO_IR_KEY_HOME_US 				0x00C8				/*  홈메뉴 */
#define AO_IR_KEY_MUTE 					0x0009				/*  조용히 */
#define AO_IR_KEY_FAVORITE 				0x001E				/*  선호채널  */

#define AO_IR_KEY_MENU 					0x0043				/*  메뉴 */

#define AO_IR_KEY_NETCAST				0x0059
#define AO_IR_KEY_YAHOO					0x0058

#define AO_IR_KEY_GRIDGUIDE				0x00A9				/*  전체방송 */
#define AO_IR_KEY_INFO 					0x00AA				/*  현재방송 */
#define AO_IR_KEY_EXIT 					0x005B				/*  취소 */

#define AO_IR_KEY_UP_ARROW 				0x0040				/*  UP	 */
#define AO_IR_KEY_DOWN_ARROW			0x0041				/*  DOWN  */
#define AO_IR_KEY_LEFT_ARROW			0x0007				/*  MINUS */
#define AO_IR_KEY_RIGHT_ARROW			0x0006				/*  PLUS  */
#define AO_IR_KEY_ENTER					0x0044				/*  확인   */

#define AO_IR_KEY_RECLIST				0x0090				/*  녹화목록 */
#define AO_IR_KEY_RESLIST 				0x0089				/*  예약목록 */

#define AO_IR_KEY_MARK 					0x007D				/*  마크 */
#define AO_IR_KEY_LIVETV				0x009E				/*  Live TV */
#define AO_IR_KEY_HCEC					0x007E

#define AO_IR_KEY_TELETEXT 				0x0020				/* Teletext(EU) */
#define AO_IR_KEY_TEXTOPTION 			0x0021				/* Teletext(EU) */
#define AO_IR_KEY_TEXTMODE				0x0022				/* Text mode(List) */
#define AO_IR_KEY_TEXTMIX				0x0024				/* Text mix */
#define AO_IR_KEY_TEXTSUBPAGE			0x0026				/* Text subpage(time) */
#define AO_IR_KEY_BACK					0x0028				/* Back */
#define AO_IR_KEY_TEXTREVEAL			0x002A				/* Text Reveal */

#define AO_IR_KEY_FREEZE				0x0065				/* Freeze  */
#define AO_IR_KEY_DA					0x0050				/* Digital/Analog TV */
#define AO_IR_KEY_PRLIST				0x0053				/* Program List */
#define AO_IR_KEY_DIGITALSETUP			0x005F				/* Digital Setup */
#define AO_IR_KEY_POSITION				0x0062				/* PIP Position/Text Update */
#define AO_IR_KEY_SIZE					0x0064				/* Text Size */
#define AO_IR_KEY_GUIDEPAL				0x00AB				/* Guide(For PAL TV) */
#define AO_IR_KEY_TV_RADIO				0x00F0
#define AO_IR_KEY_QMENU					0x0045

#define AO_IR_KEY_PIP					0x0060				/* 동시 화면 */
#define AO_IR_KEY_PIP_CH_UP				0x0071				/* 부화면+ */
#define AO_IR_KEY_PIP_CH_DOWN			0x0072				/* 부화면- */
#define AO_IR_KEY_PIP_INPUT				0x0061				/* 부입력 */

#define AO_IR_KEY_TIMER					0x000E				/* 취침예약 */
#define AO_IR_KEY_XD					0x0092				/* XD키  */
#define AO_IR_KEY_ASPECT_RATIO 			0x0079				/* 화면크기 */
#define AO_IR_KEY_SWAP 					0x0063				/* 주부전환 */

#define AO_IR_KEY_SAP					0x000A				/* 음성다중 */
#define AO_IR_KEY_CC					0x0039				/* 자막방송 */
#define AO_IR_KEY_EZPIC					0x004D				/* 자동영상  */
#define AO_IR_KEY_EZSOUND				0x0052				/* 자동음성 */

#define AO_IR_KEY_ADJUST				0x00CB				/* 조정메뉴  */
#define AO_IR_KEY_EJECT					0x00CA				/* M/C 꺼내기  */
#define AO_IR_KEY_DWTS					0x0067				/* Delayed/Sync TS */

#define AO_IR_KEY_MHEG					0x009F				/* 데이터 방송 키 */
#define AO_IR_KEY_ACAP					0x009F				/* 데이터 방송 키 */

#define AO_IR_KEY_SCR_KEYBOARD			0x0032				/* screen keboard */
#define AO_IR_KEY_AUTODEMO 				0x0080
#define AO_IR_KEY_AUTOSCAN 				0x0054
#define AO_IR_KEY_CHADDDEL 				0x0055

#define AO_IR_KEY_PLAY 					0x00B0				/* 재생 */
#define AO_IR_KEY_PAUSE					0x00BA				/* 일시정지 */
#define AO_IR_KEY_STOP 					0x00B1				/* 정지 */
#define AO_IR_KEY_REC					0x00BD				/* 녹화 */

#define AO_IR_KEY_REW					0x008F   			/* 되감기	*/
#define AO_IR_KEY_FF					0x008E           	/* 빨리감기 */
#define AO_IR_KEY_GOTOPREV 				0x00B2				/* Skip Backward */
#define AO_IR_KEY_GOTONEXT 				0x00B3				/* Skip Forward */

#define AO_IR_KEY_EMANUAL_PAGEPREV		0x00B4				/* e-manual page forward    */
#define AO_IR_KEY_EMANUAL_PAGENEXT		0x00B5				/* e-manual page backword */

#define AO_IR_KEY_RED					AO_IR_KEY_PIP_CH_DOWN
#define AO_IR_KEY_GREEN					AO_IR_KEY_PIP_CH_UP
#define AO_IR_KEY_YELLOW				AO_IR_KEY_SWAP
#define AO_IR_KEY_BLUE 					AO_IR_KEY_PIP_INPUT

#define AO_IR_KEY_CHEDIT_AUTO_SORT		AO_IR_KEY_GREEN
#define AO_IR_KEY_CHEDIT_MOVE			AO_IR_KEY_YELLOW
#define AO_IR_KEY_CHEDIT_SKIP          	AO_IR_KEY_BLUE

#define AO_IR_KEY_LOCK_DEL				AO_IR_KEY_RED

#define AO_IR_KEY_MODE					AO_IR_KEY_RED		/* R */
#define AO_IR_KEY_TIMER_LIST			AO_IR_KEY_BLUE		/* B */
#define AO_IR_KEY_MANUAL_TIMER			AO_IR_KEY_YELLOW	/* Y */
#define AO_IR_KEY_DATE 					AO_IR_KEY_GREEN		/* N */

/* TV extension key */
#define AO_IR_KEY_PAGE_UP				AO_IR_KEY_CH_UP
#define AO_IR_KEY_PAGE_DOWN				AO_IR_KEY_CH_DOWN
#define AO_IR_KEY_PAGE_RIGHT			AO_IR_KEY_SYNC
#define AO_IR_KEY_PAGE_LEFT				AO_IR_KEY_MV2START
#define AO_IR_KEY_FORMAT_CHANGE			0x10E1
#define AO_IR_KEY_GUIDE					AO_IR_KEY_GRIDGUIDE

/* DVR extension key */
#define AO_IR_KEY_MV2START 				AO_IR_KEY_GOTOPREV		/* 처음 보기 */
#define AO_IR_KEY_SYNC 					AO_IR_KEY_GOTONEXT		/* 끝 보기 */
#define AO_IR_KEY_RESUME				AO_IR_KEY_PLAY
#define AO_IR_KEY_PAUSE_SLOWFWD			AO_IR_KEY_PAUSE
#define AO_IR_KEY_SLOW_FORWARD			0x11B0
#define AO_IR_KEY_IREPLAY				AO_IR_KEY_GOTOPREV
#define AO_IR_KEY_SKIPFWD				AO_IR_KEY_GOTONEXT
#define AO_IR_KEY_TIME_SHIFT			0x11BB				/* 타임시프트 */

#define AO_IR_KEY_REPEAT				AO_IR_KEY_BLUE 		/* 한국향 dvr ready에서 blue키를 repeat (구간반복) 키로 이용함. */

/* 화면 밝기 */
#define AO_IR_KEY_BRIGHTNESS_UP			0x0033				/* 화면밝기+ */
#define AO_IR_KEY_BRIGHTNESS_DOWN		0x0034				/* 화면밝기- */

#define AO_IR_KEY_GAMEMODE				0x0030				/* game mode */

/* T-CON */
#define AO_IR_KEY_TCON_UP				0x30F0	/* T-CON Virtual Key */
#define AO_IR_KEY_TCON_UPRIGHT			0x30F1	/* T-CON Virtual Key */
#define AO_IR_KEY_TCON_RIGHT			0x30F2	/* T-CON Virtual Key */
#define AO_IR_KEY_TCON_DOWNRIGHT		0x30F3	/* T-CON Virtual Key */
#define AO_IR_KEY_TCON_DOWN				0x30F4	/* T-CON Virtual Key */
#define AO_IR_KEY_TCON_DOWNLEFT			0x30F5	/* T-CON Virtual Key */
#define AO_IR_KEY_TCON_LEFT				0x30F6	/* T-CON Virtual Key */
#define AO_IR_KEY_TCON_UPLEFT			0x30F7	/* T-CON Virtual Key */

#define AO_IR_KEY_LEFT_SCROLL_1ST		0x00A0 	/* T-CON 좌1*/
#define AO_IR_KEY_LEFT_SCROLL_2ND		0x00A1 	/* T-CON 좌2*/
#define AO_IR_KEY_LEFT_SCROLL_3RD		0x00A2 	/* T-CON 좌3*/
#define AO_IR_KEY_LEFT_SCROLL_4TH		0x00A3 	/* T-CON 좌4*/
#define AO_IR_KEY_LEFT_SCROLL_5TH		0x00A7 	/* T-CON 좌5*/
#define AO_IR_KEY_RIGHT_SCROLL_1ST		0x00B4 	/* T-CON 우1*/
#define AO_IR_KEY_RIGHT_SCROLL_2ND		0x00B5 	/* T-CON 우2*/
#define AO_IR_KEY_RIGHT_SCROLL_3RD		0x00B7 	/* T-CON 좌3*/
#define AO_IR_KEY_RIGHT_SCROLL_4TH		0x00B9 	/* T-CON 좌4*/
#define AO_IR_KEY_RIGHT_SCROLL_5TH		0x00BB 	/* T-CON 좌5*/

/* factory key */
#define AO_IR_KEY_EYE_Q					0x0095
#define AO_IR_KEY_IN_STOP         		0x00FA
#define AO_IR_KEY_IN_START        		0x00FB
#define AO_IR_KEY_P_CHECK         		0x00FC
#define AO_IR_KEY_HDMI_CHECK			0x00A6
#define AO_IR_KEY_S_CHECK         		0x00FD
#define AO_IR_KEY_POWERONLY   			0x00FE
#define AO_IR_KEY_ADJ	   				0x00FF
#define AO_IR_KEY_EZ_ADJUST        		AO_IR_KEY_ADJ
#define AO_IR_KEY_FRONT_AV	   			0x0051
#define AO_IR_KEY_FMODE_INIT			0x0027
#define AO_IR_KEY_FMODE_START			0x00EA
#define AO_IR_KEY_FMODE_F1				0x00EB
#define AO_IR_KEY_IN_TIME          		0x0026
#define AO_IR_KEY_LAMP_RESET			0x0035				/* for KOR model */
#define AO_IR_KEY_DISPMODE_READY		0x00EC				/* for KOR model */
#define AO_IR_KEY_DISPMODE				AO_IR_KEY_AUTODEMO
#define AO_IR_KEY_BLUETOOTH				0x001F
#define AO_IR_KEY_USB_CHECK				0x00EE				

#define AO_IR_KEY_TILT					0x00F9				/* Module Pattern Generation */
#define AO_IR_KEY_HOTELMODE				0x00CF				/* 조정 리모콘의 TILT key에 할당 */
#define AO_IR_KEY_HOTELMODE_READY		0x0023

#define AO_IR_KEY_POWERSAVING_TEST		0x00FB				/* DMS 요구사항 반영 */

/* Factory Mode */
#define AO_VT_KEY_SHOWMSG_ADJUST		0x2021
#define AO_VT_KEY_CHANGE_SOURCE_AV1		0x2022
#define AO_VT_KEY_CHANGE_SOURCE_COMP1	0x2023
#define AO_VT_KEY_CHANGE_SOURCE_RGB 	0x2024
#define AO_VT_KEY_ADJUST_UPD			0x2025
#define AO_VT_KEY_ADJUST_AD 			0x2026				/* ADC 조정을 위해 사용 */
#define AO_VT_KEY_ADAVOSD				0x2027

/* front key */
#define AO_FP_KEY_INPUT_SELECT		0x10F6
#define AO_FP_KEY_MENU				0x10F5
#define AO_FP_KEY_ENTER				0x10F7
#define AO_FP_KEY_CH_UP				0x10F3
#define AO_FP_KEY_CH_DOWN			0x10F4
#define AO_FP_KEY_VOL_UP			0x10F1
#define AO_FP_KEY_VOL_DOWN			0x10F2
#define AO_FP_KEY_TVGUIDE 			AO_FP_KEY_INPUT_SELECT
#define AO_FP_KEY_POWER				0x10F8

#define AO_DC_KEY_PWRON				0x00C4
#define AO_DC_KEY_PWROFF			0x00C5
#define AO_DC_KEY_ARC4X3			0x0076
#define AO_DC_KEY_ARC16X9			0x0077
#define AO_DC_KEY_ARCZOOM			0x00AF
#define AO_DC_KEY_TV				0x00D6
#define AO_DC_KEY_DTV				0x00F1
#define AO_DC_KEY_CADTV				0x00F2
#define AO_DC_KEY_VIDEO1			0x005A
#define AO_DC_KEY_VIDEO2			0x00D0
#define AO_DC_KEY_VIDEO3			0x00D1
#define AO_DC_KEY_COMP1				0x00BF
#define AO_DC_KEY_COMP2				0x00D4
#define AO_DC_KEY_RGBPC				0x00D5
#define AO_DC_KEY_RGBDTV			0x00D7
#define AO_DC_KEY_RGBDVI			0x00C6
#define AO_DC_KEY_HDMI1				0x00CE
#define AO_DC_KEY_HDMI2				0x00CC
#define AO_DC_KEY_HDMI3				0x00E9
#define AO_DC_KEY_HDMI4				0x00DA
#define AO_DC_KEY_VOL30				0x0085				/* VOL  30 */
#define AO_DC_KEY_VOL50				0x0086				/* VOL  50 */
#define AO_DC_KEY_VOL80				0x0084				/* VOL  80 */
#define AO_DC_KEY_VOL100			0x0087				/* VOL 100 */
#define AO_DC_KEY_SUBSTRATE			0x0088				/* 기판 Mode 진입 */
#define AO_DC_KEY_MULTI_PIP			0x0070				/* 기판 Mode 초기화 기능 추가 */
#define AO_DC_KEY_WB_MODE  			0x0069				/* WB Mode 진입 */
#define AO_DC_KEY_POWERONLY_OFF		0x00F8				/* PowerOnly 해제 */

/* Virtual Keys for Commercial */
#define AO_VT_KEY_ASPECTRATIO			0x5000

#define AO_VT_KEY_CONTRAST				0x5004
#define AO_VT_KEY_BRIGHTNESS			0x5005
#define AO_VT_KEY_COLOR					0x5006
#define AO_VT_KEY_SHARPNESS				0x5007
#define AO_VT_KEY_COLORTEMP				0x5008
#define AO_VT_KEY_TINT					0x5009
#define AO_VT_KEY_TREBLE				0x500A
#define AO_VT_KEY_BASS					0x500B
#define AO_VT_KEY_BALANCE				0x500C

#define AO_VT_KEY_DVIPC					0x500D
#define AO_VT_KEY_DTV					0x500E

#define AO_VT_KEY_PIP					0x500F
#define AO_VT_KEY_DW					0x5010

#define AO_VT_KEY_ISM_METHOD			0x5011
#define AO_VT_KEY_ORBITER_TIME			0x5012
#define AO_VT_KEY_ORBITER_PIXEL			0x5013
#define AO_VT_KEY_KEY_LOCK				0x5014
#define AO_VT_KEY_OSD_SELECT			0x5015

#define AO_VT_KEY_ANTENNA				0x5016
#define AO_VT_KEY_CABLE					0x5017
#define AO_VT_KEY_LOWPOWER				0x5019
#define AO_VT_KEY_ADDDELETE				0x5020
#define AO_VT_KEY_EYEQGREEN				0x5021

#define AO_VT_KEY_RED					0x5028
#define AO_VT_KEY_BLUE					0x5029
#define AO_VT_KEY_GREEN					0x5030
#define AO_VT_KEY_EQ					0x5031
#define AO_VT_KEY_BACKLIGHT				0x5032

#define AO_VT_KEY_OAD					0x5026
#define AO_VT_KEY_BAD_CABLE_SIGNAL		0x5027
#define AO_VT_KEY_TEXTHOLD				0x5028

/************************************************************
	BDP Key Definition
************************************************************/

/* BDP remote control key */
#define AO_IR_KEY_OPEN				0xA10F				/* Open */
#define AO_IR_KEY_CLOSE				AO_IR_KEY_OPEN		/* Close */
#define AO_IR_KEY_VIDEOPIP			0xA11F				/* Video PIP */
#define AO_IR_KEY_AUDIOPIP			0xA13F				/* Audio PIP */
#define AO_IR_KEY_SUBTITLEONOFF		0xA14F				/* Subtitle on/oF */
#define AO_IR_KEY_A2B				0xA15F				/* Repeat A to B */
#define AO_IR_KEY_AUDIO				0xA16F				/* Audio */
#define AO_IR_KEY_ANGLE				0xA18F				/* Angle */

#define AO_IR_KEY_DISPLAY			0xA30F				/* Display menu */
#define AO_IR_KEY_DISCMENU			0xA32F				/* Disc menu */

#define AO_IR_KEY_ZOOM				0xA51F				/* Zoom */
#define AO_IR_KEY_CURSOR			0xA52F				/* Cursor */
#define AO_IR_KEY_MARKER			0xA53F				/* Marker */
#define AO_IR_KEY_TITLE				0xA54F				/* Title */
#define AO_IR_KEY_POPUP				0xA55F				/* Pop up */
#define AO_IR_KEY_GRACENOTE			0xA56F				/* GraceNote */

#define AO_IR_KEY_SEARCH			0xA64F				/* Search */
#define AO_IR_KEY_BWSCAN			0xA66F				/* Backward scan */
#define AO_IR_KEY_FWSCAN			0xA67F				/* Forward scan */
#define AO_IR_KEY_BWSKIP2			0xA69F				/* Backward skip */
#define AO_IR_KEY_FWSKIP2			0xA6AF				/* Forward skip */

#define AO_IR_KEY_CLEAR				0xA7AF				/* Clear */
#define AO_IR_KEY_RESOLUTION		0xA7BF				/* Video resolution */
#define AO_IR_KEY_PICTURE			0xA7CF				/* Video enhancement */

#define AO_IR_KEY_LOCK				0xA80F				/* Child lock */
#define AO_IR_KEY_RANDOM			0xA81F				/* Random */
#define AO_IR_KEY_SETUP				0xA82F				/* Setup menu */
	
#define AO_IR_KEY_TUNER				0xA93F				/* Radio */
#define AO_IR_KEY_INPUT				0xA94F				/* Aux input */
#define AO_IR_KEY_WOOFERVOL			0xA98F				/* Woofer volume */
#define AO_IR_KEY_NIGHT				0xA99F				/* Night equalizer */
#define AO_IR_KEY_IPOD				0xA9AF				/* iPod */
#define AO_IR_KEY_SPKSETUP			0xA9BF				/* Speaker setup */
#define AO_IR_KEY_OPTICAL			0xA9CF				/* Optical */
#define AO_IR_KEY_MICVOLUMEUP		0xA9DF				/* MIC Volum up */
#define AO_IR_KEY_MICVOLUMEDOWN		0xA9EF				/* MIC Volume down */
#define AO_IR_KEY_CDARCHIVING		0xA9FF				/* DISC Archiving */

/* BDP front panel key */
#define AO_FP_KEY_OPEN				0xAF01				/* Open */
#define AO_FP_KEY_CLOSE				AO_FP_KEY_OPEN		/* Close */
#define AO_FP_KEY_PLAY				0xAF02				/* Play */
#define AO_FP_KEY_PAUSE				0xAF03				/* Pause */
#define AO_FP_KEY_STOP				0xAF04				/* Stop */
#define AO_FP_KEY_BWSKIP			0xAF05				/* Backward skip */
#define AO_FP_KEY_FWSKIP			0xAF06				/* Forward  skip */
#define AO_FP_KEY_BWSCAN			0xAF07				/* Backward scan */
#define AO_FP_KEY_FWSCAN			0xAF08				/* Forward  scan */
#define AO_FP_KEY_HOME				0xAF09				/* Home	menu */
#define AO_FP_KEY_RESOLUTION		0xAF0B				/* Resolution */
#define AO_FP_KEY_FUNCTION			0xAF0E				/* Change Function */
#define AO_FP_KEY_JOGACT			0xAF0F				/* Jog action */

/************************************************************
	Reserve Key Definition
************************************************************/
#define AO_RV_KEY_RESERVE0			0xA000				/* Reserve 0 */
#define AO_RV_KEY_RESERVE1			0xA001				/* Reserve 1 */
#define AO_RV_KEY_RESERVE2			0xA002				/* Reserve 2 */
#define AO_RV_KEY_RESERVE3			0xA003				/* Reserve 3 */
#define AO_RV_KEY_RESERVE4			0xA004				/* Reserve 4 */
#define AO_RV_KEY_RESERVE5			0xA005				/* Reserve 5 */
#define AO_RV_KEY_RESERVE6			0xA006				/* Reserve 6 */
#define AO_RV_KEY_RESERVE7			0xA007				/* Reserve 7 */
#define AO_RV_KEY_RESERVE8			0xA008				/* Reserve 8 */
#define AO_RV_KEY_RESERVE9			0xA009				/* Reserve 9 */

/************************************************************
	Motion Mouse Key Definition
************************************************************/	
#define AO_RF_KEY_NONE   			0x0000
#define AO_RF_KEY_MENU  			0x0100				/* MUTE */
#define AO_RF_KEY_OK                0x0200
#define AO_RF_KEY_VOL_UP            0x0400
#define AO_RF_KEY_VOL_DOWN          0x0800
#define AO_RF_KEY_CH_UP            	0x1000
#define AO_RF_KEY_CH_MULTI          0x2000
#define AO_RF_KEY_CH_DOWN           0x4000

/******************************************************************************
	매크로 함수 정의 (Macro Definitions)
******************************************************************************/

/******************************************************************************
	형 정의 (Type Definitions)
******************************************************************************/

/******************************************************************************
	함수 선언 (Function Declarations)
******************************************************************************/

#ifdef __cplusplus
}
#endif
#endif  /* _ADDON_KEY_H_ */


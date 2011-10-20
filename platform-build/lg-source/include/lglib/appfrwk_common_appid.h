/******************************************************************************
 *   Software Platform Lab, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2011 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/

/** @file   appfrwk_common_appid.h
 *
 *  Application ID
 *
 *  @author	Hyejeong Lee (hyejeong.lee@lge.com)
 *  @version    1.0
 *  @date       2011.05.24
 *  @note
 *  @see
 */

#ifndef _APPFRWK_COMMON_APPID_H_
#define _APPFRWK_COMMON_APPID_H_

#ifdef __cplusplus
extern "C" {
#endif

/*
 * predefined AUID
 *
 */
#define HOA_AUID_DTVUI      			0x00000000FFFFFFFF
#define HOA_AUID_SMARTSHARE			1
#define HOA_AUID_PREMIUM    			2
#define HOA_AUID_LGAPPS				3
#define HOA_AUID_MYAPPS     			4
#define HOA_AUID_HOMEBOARD  			9
#define HOA_AUID_SEARCH				10
#define HOA_AUID_MEDIALINK				11
#define HOA_AUID_WEBBROWSER			12
#define HOA_AUID_MYINFO		  		13
#define HOA_AUID_SMARTTVSETTING		14
#define HOA_AUID_LGAPPSDETAIL  		15
#define HOA_AUID_MEMOCAST  			17
#define HOA_AUID_LAUNCHER				18
#define HOA_AUID_SOCIALCENTER			19
//#define	HOA_AUID_3DCHANGE				20
//#define HOA_AUID_3DSETTING			21

// launcher
#define HOA_AUID_REMOTEKEY			100		
#define HOA_AUID_INPUT		  			101
#define HOA_AUID_SETUP			  		102
#define HOA_AUID_RECENT				105
#define HOA_AUID_TVGUIDE				106
#define HOA_AUID_DVR					107
#define HOA_AUID_QMENU					108
#define HOA_AUID_LOGIN			  		109
#define HOA_AUID_CONFIRMUSER			110
#define HOA_AUID_NETWORKSETTING		111
#define HOA_AUID_MANUAL				112

// SMARTSHARE
#define HOA_AUID_SMARTSHARESETTING	120
#define HOA_AUID_SMARTSHAREPLAYER	121
#define HOA_AUID_SMARTSHAREHELP		122
#define HOA_AUID_SMARTSHAREVIDEO	123	// Contents Type
#define HOA_AUID_SMARTSHAREPHOTO	124 // Contents Type
#define HOA_AUID_SMARTSHAREMUSIC	125 // Contents Type
#define HOA_AUID_SMARTSHAREFILE		126 // Linked Device File List
#define HOA_AUID_SMARTSHARECEC		127 // Set Simplink

#define HOA_AUID_HBBTV				200
#define HOA_AUID_WASU				201
#define HOA_AUID_CNTV				202
#define HOA_AUID_TEST				999

#ifdef __cplusplus
}
#endif
#endif

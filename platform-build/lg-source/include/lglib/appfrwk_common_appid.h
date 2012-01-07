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
#define HOA_AUID_SMARTSHARE				1
#define HOA_AUID_PREMIUM    			2
#define HOA_AUID_LGAPPS					3
#define HOA_AUID_MYAPPS     			4
#define HOA_AUID_HOMEBOARD  			9
#define HOA_AUID_SEARCH					10
#define HOA_AUID_MEDIALINK				11
#define HOA_AUID_WEBBROWSER				12
#define HOA_AUID_MYINFO		  			13
#define HOA_AUID_SMARTTVSETTING			14
#define HOA_AUID_LGAPPSDETAIL  			15
#define HOA_AUID_MEMOCAST  				17
#define HOA_AUID_LAUNCHER				18
#define HOA_AUID_SOCIALCENTER			19
#define HOA_AUID_3DCHANGE				20
#define HOA_AUID_3DCHANGEAPP			21
#define HOA_AUID_ADPOPUP				22
#define HOA_AUID_ADPREMIUM				23
#define HOA_AUID_DUALPLAY				24

// bar list
#define HOA_AUID_SIMPLINKBAR			25
#define HOA_AUID_MHLBAR					26
#define HOA_AUID_DIIVABAR				27
#define HOA_AUID_UNIVERSALREMOTEBAR		28
#define HOA_AUID_WIFIDISPLAYBAR			29


#define HOA_AUID_LIVETV					99
/* launcher*/
// native
#define HOA_AUID_REMOTEKEY				100
#define HOA_AUID_INPUT		  			101
#define HOA_AUID_SETUP			  		102
#define HOA_AUID_RECENT					105
#define HOA_AUID_TVGUIDE				106
#define HOA_AUID_DVR					107
#define HOA_AUID_QMENU					108
#define HOA_AUID_LOGIN			  		109
#define HOA_AUID_CONFIRMUSER			110
#define HOA_AUID_NETWORKSETTING			111
#define HOA_AUID_MANUAL					112
#define HOA_AUID_TERMS					113
#define HOA_AUID_LEGALNOTICE			114
#define HOA_AUID_QMENUCP				115
#define HOA_AUID_ASPECTRATIO			116
#define HOA_AUID_PRLIST					117
#define HOA_AUID_CHANNELBROWSER			118
#define HOA_AUID_SIMPLINK				119

// SMARTSHARE
#define HOA_AUID_SMARTSHARESETTING		120
#define HOA_AUID_SMARTSHAREPLAYER		121
#define HOA_AUID_SMARTSHAREHELP			122
#define HOA_AUID_SMARTSHAREVIDEO		123	// Contents Type
#define HOA_AUID_SMARTSHAREPHOTO		124 // Contents Type
#define HOA_AUID_SMARTSHAREMUSIC		125 // Contents Type
#define HOA_AUID_SMARTSHAREFILE			126 // Linked Device File List
#define HOA_AUID_SMARTSHARECEC			127 // Set Simplink
#define HOA_AUID_SMARTSHAREDMR			128 // DMR
#define HOA_AUID_SMARTSHAREDVR			129 // Recorded TV
#define HOA_AUID_SMARTSHAREDVRWITHTAB	130


// CP
#define HOA_AUID_SMARTMAP				140
#define HOA_AUID_3DWORLD				141
#define HOA_AUID_KPOP					142

// AD
#define HOA_AUID_ADMOVIEPLAYER			150

#define HOA_AUID_HBBTV					200
// CHINA
#define HOA_AUID_WASU					201
#define HOA_AUID_CNTV					202
#define HOA_AUID_AWIND					203
#define HOA_AUID_TEST					999


// 100000000~ : Reserved for BDP
// BDP
#ifdef BDP_HOST
#define HOA_AUID_SWUPDATE			100000000
#endif //BDP_HOST

#ifdef __cplusplus
}
#endif
#endif

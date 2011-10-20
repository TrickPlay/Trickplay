/******************************************************************************
 *   LCD TV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2011 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/

/** @file appfrwk_common_names.h
 *
 *  Application framework name header(PM/AC/UC/Openapi common)
 *
 *  @author    donghwan.jung (donghwan.jung@lge.com)
 *  @version   1.0
 *  @date       2011.06.09
 *  @note
 *  @see
 */

#ifndef _APPFRWK_COMMON_NAMES_H_
#define _APPFRWK_COMMON_NAMES_H_

#ifdef __cplusplus
extern "C" {
#endif

/*
 * Service Names
 */
#define AF_SERVICE_SPECIAL			"lg.service.special."				/* 안죽어야 하는 service */
#define AF_SERVICE_NORMAL			"lg.service.normal."				/* 죽여도 되는 service */
#define AF_SERVICE_SEND				".send"
#define AF_SERVICE_INPUT			".input"
#define AF_SERVICE_EVENT			".event"
#define AF_SERVICE_CALLBACK			".callback"
#define AF_SERVICE_MULTI			".multi"
#define AF_SERVICE_DNLD				".dnld"								/* sdpif sub */
#define AF_SERVICE_MBSH				".membership"						/* sdpif sub */
#define AF_SERVICE_SNS				".sns"								/* sdpif sub */
#define AF_SERVICE_APPS				".apps"								/* sdpif sub */
#define AF_SERVICE_ADV				".adv"								/* sdpif sub */

#define AF_NAME_PROCESSMANAGER		"processmanager"
#define AF_NAME_BROADCAST			"broadcast"
#define AF_NAME_SDPIF				"sdpif"
#define AF_NAME_UPCTRL				"upctrl"
#define AF_NAME_APPCTRL				"appctrl"
#define AF_NAME_LGINPUT				"lginput"
#define AF_NAME_MEDIAFRAMEWORK		"mediaframework"
#define AF_NAME_BROWSER				"browser"
#define AF_NAME_FXUI				"fxui"
#define AF_NAME_SEARCH				"search"
#define AF_NAME_ADOBEAIR			"adobeair"
#define AF_NAME_SMARTSHARE			"smartshare"
#define AF_NAME_HOMEDASHBOARD		"homedashboard"
#define AF_NAME_LGAPPS				"lgapps"
#define AF_NAME_MYAPPS				"myapps"
#define AF_NAME_PREMIUM				"premium"
#define AF_NAME_RUNP2P				"runp2p"
#define AF_NAME_WASU				"wasu"
#define AF_NAME_CNTV				"cntv"
#define AF_NAME_VUDU				"vudu"
#define AF_NAME_CINEMANOW			"cinemanow"
#define AF_NAME_NETFLIX				"netflix"
#define AF_NAME_AIRPLAY				"airplay"
#define AF_NAME_TRICKPLAY			"trickplay"
#define AF_NAME_UNITY3D				"unity3D"
#define AF_NAME_DEFAULT				"default"

#define AF_SERVICE_PROCESSMANAGER	AF_SERVICE_SPECIAL	AF_NAME_PROCESSMANAGER
#define AF_SERVICE_BROADCAST		AF_SERVICE_SPECIAL	AF_NAME_BROADCAST
#define AF_SERVICE_SDPIF			AF_SERVICE_SPECIAL	AF_NAME_SDPIF
#define AF_SERVICE_UPCTRL			AF_SERVICE_SPECIAL	AF_NAME_UPCTRL
#define AF_SERVICE_APPCTRL			AF_SERVICE_SPECIAL	AF_NAME_APPCTRL
#define AF_SERVICE_LGINPUT			AF_SERVICE_SPECIAL	AF_NAME_LGINPUT
#define AF_SERVICE_MEDIAFRAMEWORK	AF_SERVICE_SPECIAL	AF_NAME_MEDIAFRAMEWORK
#define AF_SERVICE_HOMEDASHBOARD	AF_SERVICE_SPECIAL	AF_NAME_HOMEDASHBOARD

#define AF_SERVICE_SMARTSHARE		AF_SERVICE_NORMAL	AF_NAME_SMARTSHARE
#define AF_SERVICE_PREMIUM			AF_SERVICE_NORMAL	AF_NAME_PREMIUM
#define AF_SERVICE_LGAPPS			AF_SERVICE_NORMAL	AF_NAME_LGAPPS
#define AF_SERVICE_MYAPPS			AF_SERVICE_NORMAL	AF_NAME_MYAPPS
#define AF_SERVICE_BROWSER			AF_SERVICE_NORMAL	AF_NAME_BROWSER
#define AF_SERVICE_FXUI				AF_SERVICE_NORMAL	AF_NAME_FXUI
#define AF_SERVICE_ADOBEAIR			AF_SERVICE_NORMAL	AF_NAME_ADOBEAIR
#define AF_SERVICE_RUNP2P			AF_SERVICE_NORMAL	AF_NAME_RUNP2P
#define AF_SERVICE_WASU				AF_SERVICE_NORMAL	AF_NAME_WASU
#define AF_SERVICE_CNTV				AF_SERVICE_NORMAL	AF_NAME_CNTV
#define AF_SERVICE_VUDU				AF_SERVICE_NORMAL	AF_NAME_VUDU
#define AF_SERVICE_CINEMANOW		AF_SERVICE_NORMAL	AF_NAME_CINEMANOW
#define AF_SERVICE_NETFLIX			AF_SERVICE_NORMAL	AF_NAME_NETFLIX
#define AF_SERVICE_AIRPLAY			AF_SERVICE_NORMAL	AF_NAME_AIRPLAY
#define AF_SERVICE_TRICKPLAY		AF_SERVICE_NORMAL	AF_NAME_TRICKPLAY
#define AF_SERVICE_UNITY3D			AF_SERVICE_NORMAL	AF_NAME_UNITY3D
#define AF_SERVICE_DEFAULT			AF_SERVICE_NORMAL	AF_NAME_DEFAULT
#define AF_SERVICE_SEARCH			AF_SERVICE_NORMAL	AF_NAME_SEARCH

#define AF_ADD_SVC(X)				"--service "X

/*
 * Object Path
 */
#define AF_PATH_APP					"/hoa/app"
#define AF_PATH_PROC				"/hoa/proc"
#define AF_PATH_UC					"/hoa/uc"
#define AF_PATH_TV					"/hoa/tv"
#define AF_PATH_MEDIA				"/hoa/media"
#define AF_PATH_SDPIF				"/hoa/sdpif"
#define AF_PATH_LGINPUT				"/hoa/lginput"

/*
 * Interface
 */
#define	AF_IF_SERVICE				"lg.if.service"
#define	AF_IF_COMMON				"lg.if.common"

/*
 * Service & App ELF Path
 */
#define AF_ELF_AC					"/usr/local/bin/appctrl"
#define AF_ELF_UC					"/usr/local/bin/upctrl"
#define AF_ELF_LI					"/usr/local/bin/lginput"
#define AF_ELF_MF					"/usr/local/bin/mediaframework"
#define AF_ELF_FXUI					"/usr/local/bin/fxui"
#define AF_ELF_SDPIF				"/usr/local/bin/sdpif"
#define AF_ELF_DTV					"/mnt/lg/lgapp/RELEASE"
#define AF_ELF_BR					"/mnt/browser/run3556"
#define AF_ELF_SC					"/mnt/addon/stagecraft/bin/stagecraft"
#define AF_ELF_AIR					"/mnt/addon/airfortv/bin/airfortv"
#define AF_ELF_RUNP2P				"/mnt/cnetv/runp2p"
#define AF_ELF_WASU					"/mnt/cnetv/wasumain"
#define AF_ELF_CNTV					"/mnt/cnetv/cntvmain"
#define AF_ELF_VUDU					"/mnt/addon/vudu/bin/vudu.sh"
#define AF_ELF_CINEMA				"/mnt/addon/cinemanow/bin/cnstart.sh"
#define AF_ELF_NETFLIX				"/mnt/addon/netflix/bin/netflix.sh"

/*
 * Master swf
 */
#define AF_MASTER_HOMEDASH			"smartTV_UI_master.swf"
#define AF_MASTER_SEARCH			"search.swf"


#ifdef __cplusplus
}
#endif
#endif

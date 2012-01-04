/******************************************************************************
 *   LCD TV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2011 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/


/** @file appfrwk_openapi_types.h
 *
 *  Openapi Types header
 *
 *  @author    dhjung (donghwan.jung@lge.com)
 *  @version    1.0
 *  @date       2011.06.01
 *  @note
 *  @see
 */
#ifndef _APPFRWK_OPENAPI_TYPES_H_
#define _APPFRWK_OPENAPI_TYPES_H_

#include <dbus/dbus.h>
#include "appfrwk_common.h"
#include "appfrwk_common_types.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct
{
	char *path;
	char *interface;
	char *member;
	HOA_STATUS_T (*func)(DBusConnection *conn, DBusMessage *msg, void *user_data);
	char *matchrule;

} HOA_HNDL_CONF_T;

/*
 bc_openapi
*/

#define MAXCHANNELNAME	64
#define MAXCHANNELLISTSIZE 10
#define  MAX_BLACKOUT_STRING 128
#define  MAX_INPUT_SOURCE_STRING	64

#define MAX_ONID_LIST_SIZE 10

#define  MAX_EVENT_DESC_LEN 2048
#define  MAX_EVENT_NAME_LEN 254


/**
 *	Time structure.
 */
#ifndef TIME_T
typedef struct
{
	UINT16		year;		/**< year		: 1970 ~ 65535 */
	UINT8		month;		/**< month		: 1 ~ 12	   */
	UINT8		day;		/**< day		: 1 ~ 31	   */
	UINT8		hour;		/**< hour		: 0 ~ 23	   */
	UINT8		minute; 	/**< minute 	: 0 ~ 59	   */
	UINT8		second; 	/**< second 	: 0 ~ 59	   */
} __TIME_T;
#define TIME_T  __TIME_T
#endif

#ifndef  API_CHANNEL_NUM_T
/**
 * Channel Num Information.
 */
typedef struct	API_CHANNEL_NUM
{
	UINT8		sourceIndex;	/**<   Source of channel : TV_INPUT_TYPE_T	*/
	UINT16		physicalNum;	/**<   Physical channel Number:  1-135	*/
	UINT16		majorNum;		/**<  Major number(1~9999) : 2bit(TV/Radio/Data flag), 14bit(user number) */
	UINT16		minorNum;		/**<  Minor number of channel : received LCN	*/
#ifdef INCLUDE_SYS_ISDB
	UINT16		tsID;			/**<   ts ID								*/
	UINT16		svcID;			/**<   service ID(program No)				*/
#endif
} __API_CHANNEL_NUM_T;
#define API_CHANNEL_NUM_T   __API_CHANNEL_NUM_T
#endif

/**
 *	HOA_CHANNEL_INFO structure.
 */
typedef struct HOA_CHANNEL_INFO
{
	API_CHANNEL_NUM_T	channelNum;						/**< Channel Number */
	UINT8				channelName[MAXCHANNELNAME];	/**< Channel Name */
	UINT16				programNo;						/**< Program number */
   	UINT16				sourceId;							/**< Source ID */
   	UINT16				tsId;								/**< Transport Stream ID */
   	UINT8				serviceType;						/**< Service Type */
} HOA_CHANNEL_INFO_T;

/* for epg recommand*/
typedef struct HOA_EVENT_DETAIL
{
	API_CHANNEL_NUM_T	channelNum;						/**< Channel Number */
	char				channelName[MAXCHANNELNAME];	/**< Channel Name */
	UINT16				programNo;						/**< Program number */
   	UINT16				sourceId;							/**< Source ID */
   	UINT16				tsId;								/**< Transport Stream ID */
   	UINT8				serviceType;						/**< Service Type */
	char				eventName[MAX_EVENT_NAME_LEN];
	char				eventDesc[MAX_EVENT_DESC_LEN];
	UINT16				eventLen;						/**< Program number */
   	UINT16				descLen;
//	char				s_time[8];
//	char				e_time[8];
	TIME_T				sTime;
	TIME_T				eTime;
} HOA_EVENT_DETAIL_T;


/**
 *	HOA_CHANNEL_LIST structure.
 */
typedef struct HOA_CHANNEL_LIST
{
	UINT16				channelNum;			/**< Channel의 갯수 */
//	HOA_CHANNEL_INFO_T	*pChannelList;		/**< Channel의 array (channelNum 만큼) */
	HOA_CHANNEL_INFO_T	channelList[MAXCHANNELLISTSIZE];
	UINT16				channelCount;		/**< 현재 채널 리스트의 유효 개수. 이 번호 이후의 채널 리스트에는 데이터가 없음. */
	UINT16				nextChannelNum;		/**< Channel List 의 Max size 를 넘을 경우, 다음 시작 채널 순서 번호 (0이면 종료.). */

} HOA_CHANNEL_LIST_T;

//for channel log
typedef struct HOA_TUNER_INPUT_TYPE_INFO
{
	int							serviceCount;
	int							onidCount;
	UINT32						onidList[MAX_ONID_LIST_SIZE];
} HOA_TUNER_INPUT_TYPE_INFO_T;

typedef enum
{
	HOA_ANTENNA_ANALOG_DECODABLE = 0,
    HOA_ANTENNA_DIGITAL_DECODABLE,
	HOA_CABLE_ANALOG_DECODABLE,
	HOA_CABLE_DIGITAL_DECODABLE,
	HOA_OCABLE_ANALOG_DECODABLE,
	HOA_OCABLE_DIGITAL_DECODABLE,
	HOA_SATELITE_DIGITAL_DECODABLE
} HOA_TUNER_INPUT_TYPE_T;




/**
 * 예약녹화의 type
 */
typedef enum SCHEDULE_TYPE
{
	SCHEDULE_NONE,						/**< None */
	SCHEDULE_RECORD,						/**< 녹화 예약 */
	SCHEDULE_VCRRECORD,					/**< VCR 녹화 예약  */
	SCHEDULE_WATCH,						/**< 시청 예약 */
	SCHEDULE_REMIND	 = SCHEDULE_WATCH,	/**< 시청 예약 */
} SCHEDULE_TYPE_T;

/**
 *	repeat types for reservation.
 */
typedef enum SCHEDULE_REPEAT
{
	SCHEDULE_REPEAT_NONE=0,		/**< none */
	SCHEDULE_REPEAT_ONCE,			/**< once */
	SCHEDULE_REPEAT_DAILY,			/**< daily */
	SCHEDULE_REPEAT_WEEKLY,		/**< weekly */
	SCHEDULE_REPEAT_MON2FRI,		/**< monday ~ friday */
	SCHEDULE_REPEAT_MON2TUE,		/**< monday ~ tuesday - korea only */
	SCHEDULE_REPEAT_WED2THU,		/**< wednesday ~ thursday - korea only */
	SCHEDULE_REPEAT_SAT2SUN,		/**< saterday ~ sunday */
	SCHEDULE_REPEAT_MAX				/**< number of repeat types */ // position is important
} SCHEDULE_REPEAT_T;

/**
 * Application Type
 */
typedef enum HOA_APP_TYPE
{
	HOA_APP_ALL			= 0,				/**< All application */
	HOA_APP_HOST		= (1<<1),			/**< DTV */
	HOA_APP_PROC		= (1<<2),			/**< Other Process */
	HOA_APP_LAST
} HOA_APP_TYPE_T;

/**
 * Aspect Ratio
 */
typedef enum HOA_ASPECT_RATIO
{
	/** For 16X9 monitor : 전체 화면\n
	 *  For 4X3 monitor : Letter box */
	HOA_ARC_16X9,

	/** Just Scan- 08년 새로 추가된 spec */
	HOA_ARC_JUSTSCAN,

	/** Set By Program. 4X3 신호는 4X3으로, 16X9 신호는 16X9로 (Original) */
	HOA_ARC_SET_BY_PROGRAM,

    /** For 16X9 monitor : 양쪽에 BlackBar를 가진 4X3(PillarBox)\n
	 *  For 4X3 monitor : 전체 화면 */
	HOA_ARC_4X3,

	/** monitor, source에 상관 없이 항상 전체 화면 */
	HOA_ARC_FULL,

    /** For 16X9 monitor : 상하 늘임\n
	 *  For 4X3 monitor : 무시됨 */
	HOA_ARC_ZOOM,

	HOA_ARC_NUMBER
} HOA_ASPECT_RATIO_T;


/**
 * Main menu List ID
 *
 */
typedef enum TAG_HOA_MENU_LIST_ID {

	/*VIDEO*/
	HOA_IDMENU_VIDEO = 0x100,
	HOA_IDMENU_VIDEO_ARC,
	HOA_IDMENU_VIDEO_TRID,
	HOA_IDMENU_VIDEO_EZPICTURE,
	HOA_IDMENU_VIDEO_EZCAL,
	HOA_IDMENU_VIDEO_EYEQ,
	HOA_IDMENU_VIDEO_BACKLIGHT,
	HOA_IDMENU_VIDEO_CONTRAST,
	HOA_IDMENU_VIDEO_BRIGHTNESS,
	HOA_IDMENU_VIDEO_SHARPNESS,
	HOA_IDMENU_VIDEO_HSHARPNESS,
	HOA_IDMENU_VIDEO_VSHARPNESS,
	HOA_IDMENU_VIDEO_COLOR,
	HOA_IDMENU_VIDEO_TINT,
	HOA_IDMENU_VIDEO_COLORTMEP,
	HOA_IDMENU_VIDEO_ADVANCED,
	HOA_IDMENU_VIDEO_PICTURERESET,
	HOA_IDMENU_VIDEO_SCREEN,
	HOA_IDMENU_VIDEO_TRUMOTION,
	HOA_IDMENU_VIDEO_LOCALDIMMING,
	HOA_IDMENU_VIDEO_MAX,

	/*AUDIO*/
	HOA_IDMENU_AUDIO = 0x200,
	HOA_IDMENU_AUDIO_EZSOUND,
	HOA_IDMENU_AUDIO_EQUALIZER,
	HOA_IDMENU_AUDIO_VOLUMEMODE,
	HOA_IDMENU_AUDIO_NATURALSOUND,
	HOA_IDMENU_AUDIO_SOUNDTYPE,
	HOA_IDMENU_AUDIO_SRS,
	HOA_IDMENU_AUDIO_CLEARVOICE,
	HOA_IDMENU_AUDIO_LIPSYNC,
	HOA_IDMENU_AUDIO_AUDIOSET,
	HOA_IDMENU_AUDIO_MAX,

	/*CAHNNEL*/
	HOA_IDMENU_CHANNEL = 0x300,
	HOA_IDMENU_CHANNEL_AUTOTUN,
	HOA_IDMENU_CHANNEL_MANUALTUN,
	HOA_IDMENU_CHANNEL_CHEDIT,
	HOA_IDMENU_CHANNEL_REMOTESET,
	HOA_IDMENU_CHANNEL_BOOSTER,
	HOA_IDMENU_CHANNEL_CIINFO,
	HOA_IDMENU_CHANNEL_CABLEOPTION,
	HOA_IDMENU_CHANNEL_SATELLITESET,
	HOA_IDMENU_CHANNEL_SATELLITEUPDATE,
	HOA_IDMENU_CHANNEL_REGIONALPROG,
	HOA_IDMENU_CHANNEL_CHANNELFREQ,
	HOA_IDMENU_CHANNEL_SCANOPTION,
	HOA_IDMENU_CHANNEL_SYSTEMCOLOR,
	HOA_IDMENU_CHANNEL_ANTENNASET,
	HOA_IDMENU_CHANNEL_BCAS,
	HOA_IDMENU_CHANNEL_MAX,

	/*TIME*/
	HOA_IDMENU_TIME = 0x400,
	HOA_IDMENU_TIME_CLOCK,
	HOA_IDMENU_TIME_OFFTIMER,
	HOA_IDMENU_TIME_ONTIMER,
	HOA_IDMENU_TIME_SLEEPTIMER,
	HOA_IDMENU_TIME_AUTOOFF,
	HOA_IDMENU_TIME_AUTOMATICSTANDBY,
	HOA_IDMENU_TIME_MAX,

	/*LOCK*/
	HOA_IDMENU_LOCK = 0x500,
	HOA_IDMENU_LOCK_SETPASSWORD,
	HOA_IDMENU_LOCK_LOCKSYSTEM,
	HOA_IDMENU_LOCK_BLOCKEDIT,
	HOA_IDMENU_LOCK_PARENTAL,
	HOA_IDMENU_LOCK_CANRATINGE,
	HOA_IDMENU_LOCK_CANRATINGF,
	HOA_IDMENU_LOCK_MOVIER,
	HOA_IDMENU_LOCK_RATINGCHILD,
	HOA_IDMENU_LOCK_RATINGGENERAL,
	HOA_IDMENU_LOCK_BRATING,
	HOA_IDMENU_LOCK_DRRT,
	HOA_IDMENU_LOCK_JRATING,
	HOA_IDMENU_LOCK_INPUTBLOCK,
	HOA_IDMENU_LOCK_MAX,

	/*OPTION*/
	HOA_IDMENU_OPTION = 0x600,
	HOA_IDMENU_OPTION_LANGUAGE,
	HOA_IDMENU_OPTION_ZIPCODE,
	HOA_IDMENU_OPTION_ECOSAVING,
	HOA_IDMENU_OPTION_COUNTRY,
	HOA_IDMENU_OPTION_CAPTION,
	HOA_IDMENU_OPTION_ASSISTANCE,
	HOA_IDMENU_OPTION_HARDHEARING,
	HOA_IDMENU_OPTION_ADDITIONALAUDIO,
	HOA_IDMENU_OPTION_POWERBUTTON,
	HOA_IDMENU_OPTION_ISMTYPE,
	HOA_IDMENU_OPTION_DATASERVICE,
	HOA_IDMENU_OPTION_MHPAUTOSTART,
	HOA_IDMENU_OPTION_HBBTV,
	HOA_IDMENU_OPTION_MHEGGUIDE,
	HOA_IDMENU_OPTION_FREEVIEW,
	HOA_IDMENU_OPTION_POINTING,
	HOA_IDMENU_OPTION_DIVXOPTION,
	HOA_IDMENU_OPTION_FACTORYRESET,
	HOA_IDMENU_OPTION_SETID,
	HOA_IDMENU_OPTION_LOCATIONMODE,
	HOA_IDMENU_OPTION_IRBLASTER,
	HOA_IDMENU_OPTION_MAX,

	/*NETWORK*/
	HOA_IDMENU_NETWORK = 0x700,
	HOA_IDMENU_NETWORK_SETTING,
	HOA_IDMENU_NETWORK_STATUS,
	HOA_IDMENU_NETWORK_WIFI_DIRECT,
	HOA_IDMENU_NETWORK_SMART_SHARE,
	HOA_IDMENU_NETWORK_ESN,
	HOA_IDMENU_NETWORK_MAX,

	/*SUPPORT*/
	HOA_IDMENU_SUPPORT = 0x800,
	HOA_IDMENU_SUPPORT_SWU,
	HOA_IDMENU_SUPPORT_PICTURETEST,
	HOA_IDMENU_SUPPORT_SOUNDTEST,
	HOA_IDMENU_SUPPORT_SIGNALTEST,
	HOA_IDMENU_SUPPORT_INFO,
	HOA_IDMENU_SUPPORT_INITPREMIUM,
	HOA_IDMENU_SUPPORT_EMANUAL,
	HOA_IDMENU_SUPPORT_MAX,
} HOA_MENU_LIST_ID_T;


/**
 * Audio Mode
 */
typedef enum HOA_AUDIO_MODE
{
	HOA_AUDIO_MODE_NORMAL,						/**< H/W setting그대로 */
	HOA_AUDIO_MODE_MONO,						/**< Mono */
	HOA_AUDIO_MODE_STEREO						/**< Stereo */
} HOA_AUDIO_MODE_T;

/**
 *	Smart Text notify
 */
typedef enum
{
	HOST_USER_SMART_MSG_NOTI		=	0x00000001,
	HOST_USER_SMART_MSG_SHOW		=	0x00000010,
	HOST_USER_SMART_MSG_HIDE		=	0x00000100,
	HOST_USER_SMART_MSG_LAST		=	0x40000000
} ADDON_HOST_USER_SMART_MSG_T;

/**
 *	Smart Text structure
 */
typedef struct ADDON_SMART_TEXT
{
	UINT16 positionX;
	UINT16 positionY;
	CHAR textString[2048+1];
} ADDON_SMART_TEXT_T;

/**
 * Structure of rectangular
 */
typedef struct HOA_RECT
{
	UINT16					x;			/**< x */
	UINT16					y;			/**< y */
	UINT16					width;		/**< width */
	UINT16					height;		/**< height */
} __attribute__((packed)) HOA_RECT_T;

/**
 * Event Information Flags
 */
typedef struct HOA_EVENT_FLAG
{
	UINT8 			bATSC:1;			/**< 1 : ATSC, 0 : DVB */
	UINT8			bAudioLang:1;		/**< 1 : Audio language info exists (audioLang is valid), 0 : Not exists */
	UINT8			bClosedCaption:1;	/**< 1 : Closed caption exists, 0 : Not exists */
	UINT8			bSubtitle:1;		/**< 1 : Subtitle exists, 0 : Not exists */
	UINT8			bSecondAudio:1;		/**< 1 : Second audio exists, 0 : Not exists */
	UINT8			bRating:1;			/**< 1 : Rating info exists (rating is valid), 0 : Not exists */
	UINT8			dummy:2;
} HOA_EVENT_FLAG_T;

/**
 * Dimension list - type structure
 * used for rating information
 */
typedef struct ATSC_DIMENSION_LIST
{
	UINT8			ratingDim;			/**<  0x00: rating dimension index (ex:MPAA) */
	UINT8			ratingVal;			/**<  0x01: rating value (ex: PG-14 ) */
										/**<  0x02: 4 bytes */
} ATSC_DIMENSION_L_T;

/**
 * Region list - type structure
 * used for rating information
 */
typedef struct ATSC_REGION_LIST
{
	UINT8			region;				/**<  0x00: rating region */
	UINT8			numOfDimensions;	/**<  0x01: number of rating dimensions */
	ATSC_DIMENSION_L_T 	pRatingValue[8];		/**<  0x02: rating value */
										/**<  0x06: 8 bytes */
} ATSC_REGION_LIST_T;

/**
 * Rating list - type structure
 * used for rating information.
 */
typedef struct ATSC_RATING_LIST
{
	UINT8				numOfRegions;		/**<  0x00: number of rating regions */
	ATSC_REGION_LIST_T 	pRegionList[8]; 		/**<  0x01: rating region list */
											/**<  0x05: 8 bytes */
} ATSC_RATING_LIST_T;

/**
 * Structure for parental rating descriptor in raw format.
 * EN 300-468
 */
typedef struct DVB_RATING
{
	UINT32 countryCode:24;				/**< Country code (ISO 3166, ETR 162) */
	UINT32 rating:8;					/**< Rating */
} DVB_RATING_T;

/**
 *	Event Information
 */
typedef struct HOA_EVENT_INFO
{
	TIME_T				startTime;	/**< Event Start TIme */
	TIME_T				endTime;	/**< Event End Time */
	unsigned long		duration;

	HOA_EVENT_FLAG_T	flags;		/**< Flags of various condition */

	UINT8				genreNum;		/**< Genre Information number */

	unsigned char		nameLen;	/**< Length of Event Name */
	unsigned char		descLen;	/**< Length of Event Description */
	UINT16				extDescLen;	/**< Length of Event Extended Description */

	UINT32				audioLang;	/**< Audio Language in ISO639 code */

	UINT8				pGenre[2];		/**< Genre Information */

	char				pName[128]; 	/**< Event Name (PSIP:multistring->string) */
	char				pDesc[256];		/**< Event Description (SI:description, PSIP(evContents):multistring->string) */
	char				pExtDesc[256];	/**< Event Extended Description (SI:extended description) */
	UINT16				eventID;

	/**
	 * For Rating.
	 */
	union RATING_UNION_T{
		ATSC_RATING_LIST_T	atscRatingList;		/**< Rating Region List */
		DVB_RATING_T		dvbRating;			/**< Rating for DVB */
	} 					rating;
} HOA_EVENT_INFO_T;

/**
 * HOA_EVENT_INFO_LIST.
 */
typedef struct HOA_EVENT_INFO_LIST
{
	UINT16					eventInfoNum;		/**< Event Info의 갯수 */
	HOA_EVENT_INFO_T		pEventInfoList[5];	/**< Array of Event Info (eventInfoNum 만큼) */
} HOA_EVENT_INFO_LIST_T;

/**
 * reserved recording user set value.
 */
typedef struct HOA_RESREC_USR_SET_VALUE
{
	API_CHANNEL_NUM_T 	resrec_ch;	/**< Reserved channel 0-1=video1, 0-2=video2 */
	TIME_T			startTime;		/**< Record Start Time*/
	UINT32			duration;		/**< Record duration. Endtime은 startTime+duration으로 계산한다. */
	SCHEDULE_REPEAT_T		repeat;	/**< 반복 종류  */
	SCHEDULE_TYPE_T			select;	/**< 예약 종류 */
} HOA_RESREC_USR_SET_VALUE_T;

/**
 * Scheduled recording&watching list information.
 */
typedef struct HOA_SCHEDULE_INFO
{
	HOA_RESREC_USR_SET_VALUE_T 	usrSetValue;		/**< Recorded Prog. Id set by MME! */
	UINT32		reserveId;		/**< Reservation Id. */
	UINT8		title[128];		/**<  PSIP/KBPS Title */
	UINT8		pchName[12];   /**< Channel Name */
} HOA_SCHEDULE_INFO_T;

/**
 * Scheduled recording&watching list.
 */
typedef struct HOA_SCHEDULE_INFO_LIST
{
	UINT16				scheduleInfoNum;		/**< Schedule Info의 갯수 */
	HOA_SCHEDULE_INFO_T	*pScheduleInfoList;		/**< Array of schedule info (scheduleInfoNum 만큼) */
} HOA_SCHEDULE_INFO_LIST_T;

/**
 * OSD Type
 */
typedef enum HOA_CTRL_OSD_TYPE
{
	HOA_OSD_NONE = -1,			/**< None */
	HOA_OSD_MAIN = 0,			/**< Main OSD */
	HOA_OSD_SUB = 1,			/**< Sub OSD */
	HOA_OSD_SUB_2 = 2,			/**< Sub2 OSD */
	HOA_OSD_SUB_3 = 3,			/**< Sub3 OSD */
	HOA_OSD_NUM
} HOA_CTRL_OSD_TYPE_T;

/**
 * OSD Update Type
 */
typedef enum HOA_CTRL_OSD_UPDATE_TYPE
{
	HOA_OSD_UPDATE_NORMAL = 0,		/**< Normal Update */
	HOA_OSD_UPDATE_FLIPONLY,		/**< Flip only Update */
	HOA_OSD_UPDATE_NUM
} HOA_CTRL_OSD_UPDATE_TYPE_T;

/**
 * Panel Support Type.
 *
 */
typedef enum HOA_TV_PANEL_ATTRIBUTE_TYPE
{
	HOA_PANEL_RESOLUTIONTYPE,		/**< Get Resolution Type (HOA_DISPLAYPANEL_RES_T) */
	HOA_PANEL_DISPLAYTYPE,			/**< Get Display Type (HOA_DISPLAYPANEL_T) */
	HOA_PANEL_BACKLIGHTTYPE,		/**< Get Back Light Type (HOA_TV_BACKLIGHT_TYPE_T) */
	HOA_PANEL_FRCFRAMERATE,			/**< Get FRC Frame Rate (UINT32, Hz) */
	HOA_PANEL_INCH,					/**< Get Inch (UINT32, Inch) */

	HOA_PANEL_LAST
} HOA_TV_PANEL_ATTRIBUTE_TYPE_T;

/**
 * TV General Info.
 */
typedef struct HOA_TV_INFO
{
	char projectName[32];	/**< Project Name, OSA_MD_GetProjectName() */
	char modelName[32];		/**< Model Name, OSA_MD_GetModelName() */
	char hwVer[32];			/**< Hardware Version, OSA_MD_GetEventBoardType(), tv_system.c 참조 */
	char swVer[32];			/**< Software Version, G_FIRMWARE_VERSION */
	char ESN[32];			/**< ESN, API_NSU_GetESN() */
	char toolTypeName[32];	/**< Tool type name, OSA_MD_GetToolType(), toolitem.h */
	char serialNumber[32];
	char modelInch[8];		/** model inch from UI_SUMODE_GetInchTypeString() */
	char countryGroup[8];	/** countryGroup from UI_SUMODE_GetCountryGroupString*/
} HOA_TV_INFO_T;

/**
 * Rating Type.
 */
typedef enum HOA_RATING_TYPE
{
	HOA_RATING_GENERAL,			/**< General Rating */
	HOA_RATING_CHILDREN,		/**< Children Rating */
	HOA_RATING_MPAA,			/**< MPAA Rating */
	HOA_RATING_CAN_ENG,			/**< Canadian-English Rating */
	HOA_RATING_CAN_FRA,			/**< Canadian-French Rating */
	HOA_RATING_BRA,				/**< Brazil Rating */
	HOA_RATING_JPN,				/**< Japan Rating */
	HOA_RATING_DVB,				/**< DVB Rating */
	HOA_RATING_LAST
} HOA_RATING_TYPE_T;

/**
 * General Rating의 각 index.
 */
typedef enum HOA_RATING_GENERAL_IDX
{
	HOA_RT_GEN_AGE,				/**< Age */
	HOA_RT_GEN_DIALOGUE,		/**< Dialogue */
	HOA_RT_GEN_LANGUAGE,		/**< Language */
	HOA_RT_GEN_SEX,				/**< Sex */
	HOA_RT_GEN_VIOLENCE,		/**< Violence */
	HOA_RT_GEN_NUM
} HOA_RATING_GENERAL_IDX_T;

/**
 * Children Rating의 각 index.
 */
typedef enum HOA_RATING_CHILDREN_IDX
{
	HOA_RT_CHL_AGE,			/**< Age */
	HOA_RT_CHL_VIOLENCE,	/**< Violence */
	HOA_RT_CHL_NUM
} HOA_RATING_CHILDREN_IDX_T;

/**
 * General Rating.
 */
typedef	 enum
{
	HOA_RT_GEN_ALL				= 0,	/**< All */
	HOA_RT_GEN_TV_G				= 1,	/**< G */
	HOA_RT_GEN_TV_PG			= 2,	/**< PG */
	HOA_RT_GEN_TV_14			= 3,	/**< 14 */
	HOA_RT_GEN_TV_MA			= 4,	/**< MA */
	HOA_RT_GEN_NONE						/**< None */
} HOA_RATING_GENERAL_T;

/**
 * Children Rating.
 */
typedef		enum
{
	HOA_RT_CHL_ALL				= 0,	/**< All */
	HOA_RT_CHL_TV_Y				= 1,	/**< Y */
	HOA_RT_CHL_TV_Y7			= 2,	/**< Y7 */
	HOA_RT_CHL_TV_ALL			= 3,	/**< All */
	HOA_RT_CHL_NONE						/**< None */
} HOA_RATING_CHILDREN_T;

/**
 * MPAA Rating.
 */
typedef 	enum
{
	HOA_RT_MPAA_ALL				= 0,	/**< All */
	HOA_RT_MPAA_NA				= 1,	/**< NA */
	HOA_RT_MPAA_G				= 2,	/**< G */
	HOA_RT_MPAA_PG				= 3,	/**< PG */
	HOA_RT_MPAA_PG_13			= 4,	/**< PG 13 */
	HOA_RT_MPAA_R				= 5,	/**< R */
	HOA_RT_MPAA_NC_17			= 6,	/**< NC 17 */
	HOA_RT_MPAA_X				= 7,	/**< X */
	HOA_RT_MPAA_NR				= 8,	/**< NR */
	HOA_RT_MPAA_NONE					/**< None */
} HOA_RATING_MPAA_T;

/**
 * Canadian English Rating.
 */
typedef 	enum
{
	HOA_RT_CAN_E_ALL			= 0,	/**< All */
	HOA_RT_CAN_E_EXEMPT			= 1,	/**< Exempt */
	HOA_RT_CAN_E_CHILDREN		= 2,	/**< Children */
	HOA_RT_CAN_E_8_PLUS			= 3,	/**< 8+ */
	HOA_RT_CAN_E_GENERAL		= 4,	/**< General */
	HOA_RT_CAN_E_PG				= 5,	/**< PG */
	HOA_RT_CAN_E_14_PLUS		= 6,	/**< 14+ */
	HOA_RT_CAN_E_18_PLUS		= 7,	/**< 18+ */
	HOA_RT_CAN_E_NONE					/**< None */
} HOA_RATING_CAN_ENG_T;

/**
 * Canadian French Rating.
 */
typedef 	enum
{
	HOA_RT_CAN_F_ALL			= 0,	/**< All */
	HOA_RT_CAN_F_EXEMPT			= 1,	/**< Exempt */
	HOA_RT_CAN_F_GENERAL		= 2,	/**< General */
	HOA_RT_CAN_F_8_PLUS			= 3,	/**< 8+ */
	HOA_RT_CAN_F_13_PLUS		= 4,	/**< 13+ */
	HOA_RT_CAN_F_16_PLUS		= 5,	/**< 16+ */
	HOA_RT_CAN_F_18_PLUS		= 6,	/**< 18+ */
	HOA_RT_CAN_F_NONE					/**< None */
} HOA_RATING_CAN_FRE_T;

/**
 *BR_age_Rating.
 */
typedef	 enum
{
	HOA_RT_BRA_ALL					= 0,	/**< All */
	HOA_RT_BRA_AGE_L				= 1,	/**< Age L */
	HOA_RT_BRA_AGE_10				= 2,	/**< Age 10 */
	HOA_RT_BRA_AGE_12				= 3,	/**< Age 12 */
	HOA_RT_BRA_AGE_14				= 4,	/**< Age 14 */
	HOA_RT_BRA_AGE_16				= 5,	/**< Age 16 */
	HOA_RT_BRA_AGE_18				= 6,	/**< Age 18 */
	HOA_RT_BRA_NONE							/**< None */
} HOA_RATING_BR_T;

/**
 *DVB Rating.
 */
typedef	 enum
{
	HOA_RT_DVB_ALL					= 0,	/**< All */
	HOA_RT_DVB_AGE_4				= 1,	/**< Age 4 */
	HOA_RT_DVB_AGE_5				= 2,	/**< Age 5 */
	HOA_RT_DVB_AGE_6				= 3,	/**< Age 6 */
	HOA_RT_DVB_AGE_7				= 4,	/**< Age 7 */
	HOA_RT_DVB_AGE_8				= 5,	/**< Age 8 */
	HOA_RT_DVB_AGE_9				= 6,	/**< Age 9 */
	HOA_RT_DVB_AGE_10				= 7,	/**< Age 10 */
	HOA_RT_DVB_AGE_11				= 8,	/**< Age 11 */
	HOA_RT_DVB_AGE_12				= 9,	/**< Age 12 */
	HOA_RT_DVB_AGE_13				= 10,	/**< Age 13 */
	HOA_RT_DVB_AGE_14				= 11,	/**< Age 14 */
	HOA_RT_DVB_AGE_15				= 12,	/**< Age 15 */
	HOA_RT_DVB_AGE_16				= 13,	/**< Age 16 */
	HOA_RT_DVB_AGE_17				= 14,	/**< Age 17 */
	HOA_RT_DVB_AGE_18				= 15,	/**< Age 18 */
	HOA_RT_DVB_NONE							/**< None */
} HOA_RATING_DVB_T;

/**
 * Display Mode
 */
typedef enum HOA_DISPLAYMODE
{
	HOA_DISP_NONE,										/**< UI가 없을 경우 */
	HOA_DISP_UIWITHTV,									/**< 기존 TV화면 위에 UI가 겹쳐서 보일 경우 */
	HOA_DISP_FULLUI,									/**< 전체 화면으로 UI가 보이고, 기존 TV가 보이지 않아야 할 경우 (UI전환이 느린 대신 Media 재생시 빨리 시작됨) */
	HOA_DISP_FULLVIDEO,									/**< 전체 화면으로 Video가 재생되는 경우 */
	HOA_DISP_FULLIMAGE,									/**< 전체 화면으로 Image가 재생되는 경우 */
	HOA_DISP_FULLUIFAST,								/**< 전체 화면으로 UI가 보이고, 기존 TV가 보이지 않아야 할 경우 (UI전환이 빠른 대신 Media 재생시 느리게 시작됨) */
	HOA_DISP_FULLUIKEEP,								/**< Dimming On/Off하지 않고 기존 UI 그대로 유지 (Netflix 2.1 trick/pause mode시 사용) */

	HOA_DISP_UIWITHTV_VCS,								/**< 기존 TV화면 위에 VCS UI가 겹쳐서 보일 경우 */
	HOA_DISP_UIWITHTV_VCSAUDIO,							/**< 기존 TV화면 위에 UI가 겹쳐서 보이고 소리는 VCS Audio*/
	HOA_DISP_FULLUI_VCSAUDIO,							/**< 전체 UI에 소리는 VCS Audio (Video는 TV source) */
	HOA_DISP_FULLVCSAV,									/**< VCS Audio + Video */

	HOA_DISP_FULLVIDEOWITH3D,							/**< 전체 화면 Video(3D)가 재생되는 경우 */

	HOA_DISP_FULLUIWITHTV,								/**< 전체 화면에 UI가 나오고 작은 TV 화면이 나오는 경우 */
	HOA_DISP_FULLVIDEONVS,								/**< 전체 화면으로 Video가 재생되는 경우(Video Setting menu 없음) */
	HOA_DISP_WIDGETMODE,								/**< TV를 왼쪽으로 밀고 오른쪽에 Widgetmode UI가 보이는 경우 */

	HOA_DISP_NUM

} HOA_DISPLAYMODE_T;

/**
 * This enumeration describes the media channel.
 *
 */
typedef enum MEDIA_CHANNEL {
	MEDIA_CH_UNKNOWN 	= -1,							/**< Unknown channel. Host에서만 사용. */
	MEDIA_CH_A			= 0,							/**< Channel A */
	MEDIA_CH_B			= 1,							/**< Channel B */
	MEDIA_CH_C			= 2,							/**< Channel C */
	MEDIA_CH_PLAY_NUM	= 3,
#if 1	/* temporary. 함부로 풀지 마시오. MEDIA_CH_NUM 틀어지면 바이너리들 다시 빌드해야함: 추후 코드 수정 예정 */
	MEDIA_CH_THUMBNAIL	= MEDIA_CH_PLAY_NUM,			/**< Channel for Thumbnail  Extraction (Thumbnail manager), not for Play */
	MEDIA_CH_EX			= MEDIA_CH_THUMBNAIL,
	MEDIA_CH_SMH		= MEDIA_CH_THUMBNAIL,
	MEDIA_CH_NUM		= 4,
#else
	MEDIA_CH_THUMBNAIL	= MEDIA_CH_PLAY_NUM,			/**< Channel for Thumbnail  Extraction (Thumbnail manager), not for Play */
//	MEDIA_CH_EX											/**< Channel for Media Info Extraction (UI), not for Play */
//	MEDIA_CH_SMH,										/**< Channel for Media Info Extraction (SMH), not for Play */
	MEDIA_CH_NUM
#endif
} MEDIA_CHANNEL_T;

/**
 * 3D Types for Media play
 */
typedef enum MEDIA_3D_TYPES {
	MEDIA_3D_NONE 					= 0x00,

	//added, interim format - half
	MEDIA_3D_SIDE_BY_SIDE_HALF		= 0x01,
	MEDIA_3D_SIDE_BY_SIDE_HALF_LR	= MEDIA_3D_SIDE_BY_SIDE_HALF,

	MEDIA_3D_SIDE_BY_SIDE_HALF_RL	= 0x02,
	MEDIA_3D_TOP_AND_BOTTOM_HALF	= 0x03,
	MEDIA_3D_BOTTOM_AND_TOP_HALF	= 0x04,
	MEDIA_3D_CHECK_BOARD 			= 0x05, /**< for T/B, S/S, Checker, Frame Seq*/
	MEDIA_3D_FRAME_SEQUENTIAL 		= 0x06, /**< for T/B, S/S, Checker, Frame Seq*/
	MEDIA_3D_COLUMN_INTERLEAVE 		= 0x07, /**< for H.264*/

	//added, Full format
	MEDIA_3D_SIDE_BY_SIDE_LR		= 0x08,
	MEDIA_3D_SIDE_BY_SIDE_RL		= 0x09,
	MEDIA_3D_FRAME_PACKING 			= 0x0A, /**< Full format*/
	MEDIA_3D_FIELD_ALTERNATIVE 		= 0x0B, /**< Full format*/
	MEDIA_3D_LINE_ALTERNATIVE 		= 0x0C, /**< Full format*/
	MEDIA_3D_DUAL_STREAM 			= 0x0D, /**< Full format*/
	MEDIA_3D_2DTO3D 				= 0x0E,	/**< Full format*/

} MEDIA_3D_TYPES_T;

typedef struct
{
	/* to support the seamless play on MTK platform - SSPK, Netflix, HLS. */
	BOOLEAN	bSeamlessPlay;	// from CP	// default should be FALSE
	UINT32	maxWidth;		// from CP
	UINT32	maxHeight;		// from CP
} MEDIA_VIDEO_ADAPTIVE_INFO_T;

/**
 * Callback Message of Media play
 */
typedef enum MEDIA_CB_MSG
{
	MEDIA_CB_MSG_NONE			= 0x00,					/**< message 없는 상태 */
	MEDIA_CB_MSG_PLAYEND,								/**< media data의 끝이어서 재생이 종료됨 */
	MEDIA_CB_MSG_PLAYSTART,								/**< media가 실제로 재생 시작됨 */

	MEDIA_CB_MEDIAFRAMEWORK_END,						/* PM이 mediaframework 를 종료하는 경우*/
	//MEDIA_CB_MSG_3DTVFORMAT_NONE	= 0x100,			/**< 3D Format None */
	//MEDIA_CB_MSG_3DTVFORMAT_SIDE_BY_SIDE_HALF,			/**< 3D Format Side by Side */
	//MEDIA_CB_MSG_3DTVFORMAT_SIDE_BY_SIDE_LR,			/**< 3D Format Side by Side with LR */
	//MEDIA_CB_MSG_3DTVFORMAT_SIDE_BY_SIDE_RL,			/**< 3D Format Side by Side with RL*/
	//MEDIA_CB_MSG_3DTVFORMAT_TOP_AND_BOTTOM_HALF,		/**< 3D Format Top and Bottom */
	//MEDIA_CB_MSG_3DTVFORMAT_FRAMEPACKING,				/**< 3D Format Framepacking */

	// for specific applications.
	MEDIA_CB_MSG_SPECIAL_START 		= 0x200,
	MEDIA_CB_MSG_CONNECTED,								/**< html 5 */
	MEDIA_CB_MSG_LOADED_METADATA,						/**< html 5 */
	MEDIA_CB_MSG_SEEK_DONE,								/**< SmartShare */
	MEDIA_CB_MSG_BUFFERING_PERCENT_0	= 0x300,		/**< China CP */
	MEDIA_CB_MSG_BUFFERING_PERCENT_10,
	MEDIA_CB_MSG_BUFFERING_PERCENT_20,
	MEDIA_CB_MSG_BUFFERING_PERCENT_30,
	MEDIA_CB_MSG_BUFFERING_PERCENT_40,
	MEDIA_CB_MSG_BUFFERING_PERCENT_50,
	MEDIA_CB_MSG_BUFFERING_PERCENT_60,
	MEDIA_CB_MSG_BUFFERING_PERCENT_70,
	MEDIA_CB_MSG_BUFFERING_PERCENT_80,
	MEDIA_CB_MSG_BUFFERING_PERCENT_90,
	MEDIA_CB_MSG_BUFFERING_PERCENT_100,
	MEDIA_CB_MSG_SPECIAL_END   		= 0x4FF,

	// for internal use.
	MEDIA_CB_MSG_STOPPED 			= 0x300,			/**< SMH 정보, Thumbnail 추출용 */
	MEDIA_CB_MSG_PAUSE_DONE, 							/**< SMH 정보 추출용 */
	MEDIA_CB_MSG_RESUME_DONE, 							/**< for WIDEVINE */
	MEDIA_CB_MSG_THUMBNAIL_EXTRACTED, 					/**< Thumbnail 추출용 */
	MEDIA_CB_MSG_THUMBNAIL_ERROR, 						/**< Thumbnail 추출 도중 에러 **/
	MEDIA_CB_MSG_THUMBNAIL_TIMEOUT, 					/**< Thumbnail 추출 도중 timeout **/


    // old error msg //
	MEDIA_CB_MSG_ERR_PLAYING	= 0xf000,				/**< 재생중 error 발생 */
	MEDIA_CB_MSG_ERR_BUFFERFULL,						/**< 재생중 buffer full 발생 */
	MEDIA_CB_MSG_ERR_BUFFERLOW,							/**< 재생중 buffer low 발생 */
	MEDIA_CB_MSG_ERR_NOT_FOUND,							/**< 재생하려는 path혹은 url에서 파일 발견되지 않음 */
	MEDIA_CB_MSG_ERR_CODEC_NOT_SUPPORTED,				/**< html 5 */
	MEDIA_CB_MSG_ERR_BUFFER_20MS,						/**< 재생중 buffer data 20msec 남음 */
	MEDIA_CB_MSG_ERR_BUFFER_40MS,						/**< 재생중 buffer data 40msec 남음 */
	MEDIA_CB_MSG_ERR_BUFFER_60MS,						/**< 재생중 buffer data 60msec 남음 */
	MEDIA_CB_MSG_ERR_BUFFER_80MS,						/**< 재생중 buffer data 80msec 남음 */
	MEDIA_CB_MSG_ERR_BUFFER_100MS,						/**< 재생중 buffer data 100msec 남음 */
	MEDIA_CB_MSG_ERR_BUFFER_120MS,						/**< 재생중 buffer data 120msec 남음 */
	MEDIA_CB_MSG_ERR_BUFFER_140MS,						/**< 재생중 buffer data 140msec 남음 */
	MEDIA_CB_MSG_ERR_BUFFER_160MS,						/**< 재생중 buffer data 160msec 남음 */
	MEDIA_CB_MSG_ERR_BUFFER_180MS,						/**< 재생중 buffer data 180msec 남음 */
	MEDIA_CB_MSG_ERR_BUFFER_200MS,						/**< 재생중 buffer data 200msec 남음 */
	MEDIA_CB_MSG_ERR_AUDIO_DECODING_FAILED,				/**< 재생 중 audio decoding error 발생 (잘못된 스트림), 재생 중지되지는 않음 */
    // end old error msg //
    /* gstrreamer core error msg */
    MEDIA_CB_MSG_START_GST_MSG, //d16
	MEDIA_CB_MSG__GST_CORE_ERROR_FAILED, // a general error which doesn't fit in any other category. Make sure you add a custom message to the error call.
	MEDIA_CB_MSG__GST_CORE_ERROR_TOO_LAZY, // do not use this except as a placeholder for deciding where to go while developing code.
	MEDIA_CB_MSG__GST_CORE_ERROR_NOT_IMPLEMENTED, // use this when you do not want to implement this functionality yet.
	MEDIA_CB_MSG__GST_CORE_ERROR_STATE_CHANGE, // used for state change errors.
	MEDIA_CB_MSG__GST_CORE_ERROR_PAD, // used for pad-related errors.
	MEDIA_CB_MSG__GST_CORE_ERROR_THREAD, // used for thread-related errors.
	MEDIA_CB_MSG__GST_CORE_ERROR_NEGOTIATION, // used for negotiation-related errors.
	MEDIA_CB_MSG__GST_CORE_ERROR_EVENT, //  used for event-related errors.
	MEDIA_CB_MSG__GST_CORE_ERROR_SEEK, // used for seek-related errors.
	MEDIA_CB_MSG__GST_CORE_ERROR_CAPS, //  used for caps-related errors.
	MEDIA_CB_MSG__GST_CORE_ERROR_TAG, //  used for negotiation-related errors.
	MEDIA_CB_MSG__GST_CORE_ERROR_MISSING_PLUGIN, // used if a plugin is missing.
	MEDIA_CB_MSG__GST_CORE_ERROR_CLOCK, // used for clock related errors.
	MEDIA_CB_MSG__GST_CORE_ERROR_DISABLED, //d30 // used if functionality has been disabled at compile time (Since: 0.10.13).
    /* gstreamer library error msg */
	MEDIA_CB_MSG__GST_LIBRARY_ERROR_FAILED, // a general error which doesn't fit in any other category. Make sure you add a custom message to the error call.
	MEDIA_CB_MSG__GST_LIBRARY_ERROR_TOO_LAZY, // do not use this except as a placeholder for deciding where to go while developing code.
	MEDIA_CB_MSG__GST_LIBRARY_ERROR_INIT, // used when the library could not be opened.
	MEDIA_CB_MSG__GST_LIBRARY_ERROR_SHUTDOWN, // used when the library could not be closed.
	MEDIA_CB_MSG__GST_LIBRARY_ERROR_SETTINGS, // used when the library doesn't accept settings.
	MEDIA_CB_MSG__GST_LIBRARY_ERROR_ENCODE, // used when the library generated an encoding error.
    /* gstreamer resource error msg */
	MEDIA_CB_MSG__GST_RESOURCE_ERROR_FAILED, // a general error which doesn't fit in any other category. Make sure you add a custom message to the error call.
	MEDIA_CB_MSG__GST_RESOURCE_ERROR_TOO_LAZY, // do not use this except as a placeholder for deciding where to go while developing code.
	MEDIA_CB_MSG__GST_RESOURCE_ERROR_NOT_FOUND, // used when the resource could not be found.
	MEDIA_CB_MSG__GST_RESOURCE_ERROR_BUSY, //d40 // used when resource is busy.
	MEDIA_CB_MSG__GST_RESOURCE_ERROR_OPEN_READ, // used when resource fails to open for reading.
	MEDIA_CB_MSG__GST_RESOURCE_ERROR_OPEN_WRITE, // used when resource fails to open for writing.
	MEDIA_CB_MSG__GST_RESOURCE_ERROR_OPEN_READ_WRITE, // used when resource cannot be opened for both reading and writing, or either (but unspecified which).
	MEDIA_CB_MSG__GST_RESOURCE_ERROR_CLOSE, // used when the resource can't be closed.
	MEDIA_CB_MSG__GST_RESOURCE_ERROR_READ, // used when the resource can't be read from.
	MEDIA_CB_MSG__GST_RESOURCE_ERROR_WRITE, // used when the resource can't be written to.
	MEDIA_CB_MSG__GST_RESOURCE_ERROR_SEEK, // used when a seek on the resource fails.
	MEDIA_CB_MSG__GST_RESOURCE_ERROR_SYNC, // used when a synchronize on the resource fails.
	MEDIA_CB_MSG__GST_RESOURCE_ERROR_SETTINGS, // used when settings can't be manipulated on.
	MEDIA_CB_MSG__GST_RESOURCE_ERROR_NO_SPACE_LEFT, //d50 // used when the resource has no space left.
    /* gstreamer stream error msg */
	MEDIA_CB_MSG__GST_STREAM_ERROR_FAILED, // a general error which doesn't fit in any other category. Make sure you add a custom message to the error call.
	MEDIA_CB_MSG__GST_STREAM_ERROR_TOO_LAZY, // do not use this except as a placeholder for deciding where to go while developing code.
	MEDIA_CB_MSG__GST_STREAM_ERROR_NOT_IMPLEMENTED, // use this when you do not want to implement this functionality yet.
	MEDIA_CB_MSG__GST_STREAM_ERROR_TYPE_NOT_FOUND, // used when the element doesn't know the stream's type.
	MEDIA_CB_MSG__GST_STREAM_ERROR_WRONG_TYPE, // used when the element doesn't handle this type of stream.
	MEDIA_CB_MSG__GST_STREAM_ERROR_CODEC_NOT_FOUND, // used when there's no codec to handle the stream's type.
	MEDIA_CB_MSG__GST_STREAM_ERROR_DECODE, // used when decoding fails.
	MEDIA_CB_MSG__GST_STREAM_ERROR_ENCODE, // used when encoding fails.
	MEDIA_CB_MSG__GST_STREAM_ERROR_DEMUX, // used when demuxing fails.
	MEDIA_CB_MSG__GST_STREAM_ERROR_MUX, // used when muxing fails.
	MEDIA_CB_MSG__GST_STREAM_ERROR_FORMAT, // used when the stream is of the wrong format (for example, wrong caps).
	MEDIA_CB_MSG__GST_STREAM_ERROR_DECRYPT, // used when the stream is encrypted and can't be decrypted because this is not supported by the element. (Since: 0.10.20)
	MEDIA_CB_MSG__GST_STREAM_ERROR_DECRYPT_NOKEY, // used when the stream is encrypted and can't be decrypted because no suitable key is available. (Since: 0.10.20)
    MEDIA_CB_MSG_END_GST_MSG,

	MEDIA_CB_MSG_ERR_NET_DISCONNECTED	= 0xff00,		/**< network이 끊김 */
	MEDIA_CB_MSG_ERR_NET_BUSY,							/**< network이 사용중 */
	MEDIA_CB_MSG_ERR_NET_CANNOT_PROCESS,				/**< 기타 이유로 network이 사용 불가함 */
	MEDIA_CB_MSG_ERR_NET_CANNOT_CONNECT,				/**< html 5 */
	MEDIA_CB_MSG_ERR_NET_SLOW,							/**< network가 느림 */

	MEDIA_CB_MSG_ERR_WMDRM_CANNOT_PROCESS	= 0xff10,	/**< WMDRM license error. */
	MEDIA_CB_MSG_ERR_WMDRM_LIC_FAILLOCAL,				/**< WMDRM license error. 저장된 license가 없음. */
	MEDIA_CB_MSG_ERR_WMDRM_LIC_FAILTRANSFER,			/**< WMDRM license error. license 전송중 error & 전송된 license error. */
	MEDIA_CB_MSG_ERR_WMDRM_LIC_EXPIRED,					/**< WMDRM license error. 저장된 License가 만료됨. */
	MEDIA_CB_MSG_REQ_ONLY_PLAY_AGAIN,					/**< Live streaming 중, network 연결 상태 오류로 media play재시도가 요청됨.  */
	MEDIA_CB_MSG_ERR_VERIMATRIX_DRM_FAILED,				/**< Verimatrix DRM 모듈 API 실행시 error message 처리를 위해 추가. */

	MEDIA_CB_MSG_LAST

} MEDIA_CB_MSG_T;

//#ifdef INCLUDE_ACTVILA 
typedef enum MEDIA_ACTVILA_CB_MSG
{
	ACTVILA_CB_MSG_REQUEST_SYNTAX_ERROR = -1, 
	ACTVILA_CB_MSG_OBJECT_TAG_ERROR = -10,
	ACTVILA_CB_MSG_A_TAG_ERROR = -20, 
	ACTVILA_CB_MSG_GET_METAFILE_ERROR = -1000, 
	ACTVILA_CB_MSG_METAFILE_DATA_ERROR = -2000, 
	ACTVILA_CB_MSG_LLI_VERIFY_ERROR = -2020, 
	ACTVILA_CB_MSG_GET_DRM_KEY_ERROR = -3000, 
	ACTVILA_CB_MSG_INVALID_DRM_KEY_ERROR = -4000, 
	ACTVILA_CB_MSG_NET_CANNOT_CONNECT = -5000,  
	ACTVILA_CB_MSG_SDP_SYNTAX_ERROR = -6000,
	ACTVILA_CB_MSG_RECV_STREAM_ERROR = -7000, 
	ACTVILA_CB_MSG_LAST 
} MEDIA_ACTVILA_CB_MSG_T;

//#endif 

/**
 * Callback Message EX of Media play
 */
#define MEDIA_CB_EX_PARAM_LEN 4

typedef enum MEDIA_CB_MSG_EX
{
	MEDIA_CB_EX_MSG_NONE			= 0x00,					/**< message 없는 상태 */
    MEDIA_CB_EX_MSG_SUBT_FOUND,
    MEDIA_CB_EX_MSG_POSITION_UPDATED,
	MEDIA_CB_EX_MSG_LAST

} MEDIA_CB_EX_MSG_T;

/**
 * This enumeration describes the media play state.
 *
 */
typedef enum MEDIA_PLAY_STATE
{
	MEDIA_STATE_STOP = 0, 	/**< Stop state */
	MEDIA_STATE_PLAY,	/**< Play state */
	MEDIA_STATE_PAUSE,	/**< Pause state */
	MEDIA_STATE_ERROR	/**< Error state */
} MEDIA_PLAY_STATE_T;

/**
 * Callback Message of PLEX Media Server List Changing.
 */
typedef enum PMS_CB_MSG
{
	PMS_CB_MSG_NONE		= 0x00,
	PMS_CB_MSG_ADD		= 0x01,
	PMS_CB_MSG_DEL		= 0x02,
	PMS_CB_MSG_CHG		= 0x10,
	PMS_CB_MSG_LAST
} PMS_CB_MSG_T;

/**
*  Callback Message of Billing
*/
typedef enum BILLING_CB_MSG
{
	BILLING_CB_MSG_NONE		= 0x00,
	BILLING_CB_MSG_RESPOND_PURCHASE,
	BILLING_CB_MSG_RESPOND_REQUESTLOGIN,
	BILLING_CB_MSG_RESPOND_REQUESTCONFIRMUSER,
	BILLING_CB_MSG_RESPOND_CHANGEPWD, /* change password */
	WEBSNS_CB_XML_DATA 		= 0x100,
	BILLING_CB_MSG_LAST
} BILLING_CB_MSG_T;

/**
* SDPIF Purchase information
*/
typedef struct SDPIF_PURCHASE_IN{
	UINT16	prdtIDLen;
	UINT16	prdtNameLen;
	char	realPurAmt[16];
	char	currCode[8];
	char	prdtID[96];
	char	prdtName[96];
	char	etc[3072];
} SDPIF_PURCHASE_IN_T;

typedef void (*BILLING_CB_T)(BILLING_CB_MSG_T msg, UINT16 dataSize, UINT8 *pData);

/**
 * Callback Message of Image Processing
 */
typedef enum IMAGE_CB_MSG
{
	IMAGE_CB_MSG_NONE	= 0x00,
	IMAGE_CB_MSG_PLAY_SUCCESS,
	IMAGE_CB_MSG_PLAY_FAIL,
	IMAGE_CB_MSG_PLAY_ERR_NOT_FOUND,
	IMAGE_CB_MSG_CACHE_ERR_NOT_FOUND,
	IMAGE_CB_MSG_CANCEL_CACHE_DONE,
	IMAGE_CB_MSG_PLAY_DOWNLOAD_SUCCESS,
	IMAGE_CB_MSG_CACHE_SUCCESS,
	IMAGE_CB_MSG_PLAY_DOWNLOAD_FAIL,
	IMAGE_CB_MSG_CACHE_FAIL,
	IMAGE_CB_MSG_CACHE_ALREADY_DONE,
	IMAGE_CB_MSG_CANCEL_CACHE_FAIL
} IMAGE_CB_MSG_T;

/**
 * Typedef of callback function to get notice about playback end.
 */
typedef void (*CTRL_IMAGE_CB_T)(MEDIA_CHANNEL_T ch, IMAGE_CB_MSG_T msg, UINT32 imageID);

typedef enum MEDIA_TRANSPORT
{
	/**< gp4 media types >**/

	MEDIA_TRANS_USB				= 0x01,		/**< SmartShare USB. File Play시 선택. */
	MEDIA_TRANS_DLNA			= 0x02,		/**< SmartShare DLNA. File Play시 선택. */
	MEDIA_TRANS_HTTP_DOWNLOAD	= 0x05,		/**< HTTP Progressive download play시 선택. */
	MEDIA_TRANS_URI				= 0x06,		/**< 기본 URI play시 선택: local file, streaming 모두 가능 */
	MEDIA_TRANS_BUFFERCLIP		= 0x10,		/**< Clip Buffer Play시 선택. */
	MEDIA_TRANS_BUFFERSTREAM	= 0x11,		/**< Stream Play시 선택. */
	MEDIA_TRANS_SKYPE			= 0x12,		/**< Skype용 Stream Play시 선택. */
	MEDIA_TRANS_WIDEVINE		= 0x13,		/**< Widevine Stream Play시 선택. */
	MEDIA_TRANS_ORANGE_VOD		= 0x16,		/**< Orange VoD Play시 선택. */
	MEDIA_TRANS_MSIIS			= 0x17,		/**< MS Smooth Streaming시 선택. */
	MEDIA_TRANS_WFD				= 0x18, 	/**< SmartShare Wifi Display Play시 선택. */
	MEDIA_TRANS_HLS 			= 0x19, 	/**< Http Live Streaming시 선택. */
	MEDIA_TRANS_AD 				= 0x20,  	/**< 광고 재생시 선택: FF & Seek disable되고 광고 정보 전달용 함수 호출됨. */
    MEDIA_TRANS_JPMARLIN		= 0x22, 	/**< japan marlin Play시 선택. */
    MEDIA_TRANS_FCC 			= 0x23, 	/**< FCC Streaming시 선택. */
#if 1
	/**< obsolete >**/

	MEDIA_TRANS_FILE	= 0x01,		/**< File. File Play시 선택. */
	//MEDIA_TRANS_DLNA	= 0x02,		/**< DLNA. File Play시 선택. */
	MEDIA_TRANS_YOUTUBE	= 0x03,		/**< YouTube. File Play시 선택. */
	MEDIA_TRANS_YAHOO	= 0x04,		/**< Yahoo Video. File Play시 선택. */
	//MEDIA_TRANS_HTTP_DOWNLOAD	= 0x05,		/**< HTTP Progressive download play시 선택. */
	MEDIA_TRANS_MSDL	= 0x06,		/**< MSDL을 이용한 play시 선택. */
	MEDIA_TRANS_MSDL_ONESHOT	= 0x07,		/**< MSDL OneShot URL을 이용한 play시 선택. */
	MEDIA_TRANS_MSDL_LOCAL_MEDIA	= 0x08,		/**< Media Link, DLNA등 Local 망의 미디어를 play시 선택. */
	//MEDIA_TRANS_BUFFERCLIP		= 0x10,		/**< Clip Buffer Play시 선택. */
	//MEDIA_TRANS_BUFFERSTREAM	= 0x11,		/**< Stream Play시 선택. */
	//MEDIA_TRANS_SKYPE			= 0x12,		/**< Skype용 Stream Play시 선택. */
	//MEDIA_TRANS_WIDEVINE			= 0x13,		/**< Widevine Stream Play시 선택. */
	MEDIA_TRANS_RTSP			= 0x14, 	/**< RTSP Stream Play시 선택. */
	MEDIA_TRANS_RTSP_VERIMATRIX	= 0x15, 	/**< Verimatrix DRM용 RTSP Stream Play시 선택. */
	//MEDIA_TRANS_ORANGE_VOD		= 0x16,		/**< Orange VoD Play시 선택. */ //reserved..
	//MEDIA_TRANS_MSIIS		= 0x17,		/**< MS Smooth Streaming시 선택. */// reserved..
	//MEDIA_TRANS_WFD	= 0x18, 	/**< Wifi Display Play시 선택. */
	//MEDIA_TRANS_HLS = 0x19, 	/**< Http Live Streaming시 선택. */

#endif
} MEDIA_TRANSPORT_T;

/**
 * HbbTV function pointer
 */
#ifndef HBBTV_PFN
typedef void* (*HBBTV_MALLOC_T) ( UINT32 sz );
typedef void (*HBBTV_CB_T) ( HBBTV_MALLOC_T funcMAlloc, UINT8 **ppSerOutData, UINT32 *pnSerOutDataSz, UINT8 *pSerInData, UINT32 nSerInData );
#define HBBTV_PFN
#endif

/**
 * This enumeration describes file format(container type) of media.
 *
 */
typedef enum MEDIA_FORMAT
{
	MEDIA_FORMAT_RAW	= 0x00,			/**< File Format이 따로 없고, Audio 또는 Video codec으로 encoding 된 raw data */
	MEDIA_FORMAT_WAV	= 0x01,			/**< wave file format (Audio). */
	MEDIA_FORMAT_MP3	= 0x02,			/**< mp3 file format (Audio). */
	MEDIA_FORMAT_AAC	= 0x03,			/**< aac file format (Audio). */
	MEDIA_FORMAT_AVI	= (0x01<<8),	/**< avi file format (Video). */
	MEDIA_FORMAT_MP4	= (0x02<<8),	/**< mpeg4 file format (Video). */
	MEDIA_FORMAT_MPEG1	= (0x03<<8),	/**< mpeg1 file format (Video). */
	MEDIA_FORMAT_MPEG2	= (0x04<<8),	/**< mpeg2 file format (Video). */
	MEDIA_FORMAT_ASF	= (0x05<<8),	/**< asf file format (Video). */
	MEDIA_FORMAT_MKV	= (0x06<<8),	/**< mkv file format (Video). */
	MEDIA_FORMAT_JPG	= (0x08<<16),	/**< jpeg file format (Image). */
	MEDIA_FORMAT_PNG	= (0x09<<16),	/**< png file format (Image). */
	MEDIA_FORMAT_CIF	= (0x0A<<16),	/**< cif file format (Image). */
	MEDIA_FORMAT_FLV	= (0x0B<<8),	/**< flv file format (Video). */
	MEDIA_FORMAT_F4V	= (0x0C<<8),	/**< f4v file format (Video). */
	MEDIA_FORMAT_ISM	= (0x0D<<8),	/**< ism file format (Video). */

	MEDIA_FORMAT_AUDIO_MASK	= 0xFF,			/**< Audio file format mask */
	MEDIA_FORMAT_VIDEO_MASK	= (0xFF<<8),	/**< Video file format mask */
	MEDIA_FORMAT_IMAGE_MASK	= (0xFF<<16)	/**< Image file format mask */
} MEDIA_FORMAT_T;

/**
 * Type definition of Media Codec.
 * MEDIA_CODEC_T는 MEDIA_CODEC_AUDIO_T, MEDIA_CODEC_VIDEO_T, MEDIA_CODEC_IMAGE_T의 ORing을 통해 나타낸다.
 *
 */
typedef UINT32 	MEDIA_CODEC_T;


typedef struct MEDIA_BUFFER_INFO
{
	UINT32				vidRemainedSize;	// for ES - byte
	UINT32				audRemainedSize;	// for ES - byte
	UINT32				totalRemainedSize;
} MEDIA_BUFFER_INFO_T;

/**
 * This structure contains the media play informations
 *
 */
typedef struct MEDIA_PLAY_INFO
{
	MEDIA_PLAY_STATE_T 	playState;		/**< Media play state */
	UINT32 				elapsedMS;		/**< Elapsed time in millisecond */
	UINT32				durationMS;		/**< Total duration in millisecond */

	UINT32				bufBeginSec;	/**< Buffering된 stream의 가장 앞 부분. */
	UINT32				bufEndSec;		/**< Buffering된 stream의 가장 뒷 부분. */
	SINT32				bufRemainSec;	/**< Buffering된 stream의 남은 부분. */
	SINT8				bufPercent;		/**< Buffering된 stream의 전체 버퍼 크기 대비 용량(0~100 퍼센트) */
	MEDIA_BUFFER_INFO_T	bufRemainedSize;	//

	SINT32				instantBps;		/**< 현재의 Stream 전송 속도. */
	SINT32				totalBps;		/**< 전체 Stream 전송 속도. */
	UINT32				streamBitRate;
	UINT32				numOfRates;
	UINT32				curIndexOfRate;
	MEDIA_CB_MSG_T		lastCBMsg;		/**< 가장 최근에 불린 Callback Message */

	UINT32 playErrorNum;					/**< 가장 최근에 발생한 Cinemanow play error number */
} MEDIA_PLAY_INFO_T;

/**
 * Typedef of callback function to get notice about playback end.
 */
typedef void (*MEDIA_PLAY_CB_T)(MEDIA_CHANNEL_T ch, MEDIA_CB_MSG_T msg);
typedef void (*MEDIA_PLAY_CB_EX_T)(MEDIA_CHANNEL_T ch, MEDIA_CB_EX_MSG_T msg, UINT32 cb_param[4]);

//#ifdef INCLUDE_ACTVILA
typedef void (*MEDIA_ACTVILA_CB_T)(MEDIA_CHANNEL_T ch, MEDIA_ACTVILA_CB_MSG_T msg);
//#endif 


/**
 * Type of captured image
 */
typedef struct MEDIA_CAPTURED_IMAGE
{
	MEDIA_FORMAT_T format;				/**< Image Encoding type */

	UINT32	dataLen;					/**< Captured Image Total Length */
	UINT8	*pData;						/**< Captured Image */
} MEDIA_CAPTURED_IMAGE_T;

/**
 * Media Source Information
 */
typedef struct MEDIA_SOURCE_INFO
{
	char			title[512];			/**< Title of source */
	char			artist[512];		/**< artist of source */
	char			copyright[512];		/**< copyright of source */
	char			album[512];			/**< album of source */
	char			genre[512];			/**< genre of source */
	UINT16			titleSize;			/**< Size of title string */
	TIME_T			date;				/**< Creation date of source */
	UINT32			dataSize;			/**< Total length of source */
	MEDIA_FORMAT_T	format;				/**< Media format (container type) of source */
	MEDIA_CODEC_T	codec;				/**< Media Codec of source */
	UINT16			width;				/**< Width of source. (Not valid when audio ony) */
	UINT16			height;				/**< Height of source. (Not valid when audio ony) */
	UINT32			durationMS;			/**< Total duration in millisecond */
	SINT32			targetBitrateBps;	/**< Needed average bitrate in bps (bits per second) */
	BOOLEAN			bIsValidDuration;	/**< durationMS가 유효한 값인지. (FALSE면 duration이 없는 경우 ex)live ) */
	BOOLEAN			bIsSeekable;		/**< HOA_MEDIA_SeekClip is available(TRUE) or not*/
	BOOLEAN			bIsScannable;		/**< HOA_MEDIA_SetPlaySpeed is available(TRUE) or not */
} MEDIA_SOURCE_INFO_T;

/**
 * This structure contains the media server informations.
 *
 */
typedef struct MEDIA_SERVER_INFO {
		unsigned int type;
		char IP[50];
		char name[100];
		char hostname[100];
		char mac[20];
} MEDIA_SERVER_INFO_T;

/**
 * This structure contains the media server list informations.
 *
 */
typedef struct MEDIA_SERVER_LIST {
		int num;
		MEDIA_SERVER_INFO_T	*pServerInfo;
} MEDIA_SERVER_LIST_T;

typedef void (*PMS_CB_T)(MEDIA_CHANNEL_T ch, PMS_CB_MSG_T msg); 	//added 10.08.12

/**
 * This enumeration describes the media audio information
 *
 */
typedef enum HOA_MEDIA_AUDIO_PROP_TYPE
{
	HOA_AUDIO_LANGUAGE_NONE	= 0x0001,	/**< Audio language none */
	HOA_AUDIO_LANGUAGE	= 0x0010,	/**< Auiod language */
	HOA_AUDIO_LANGUAGE_MAX	= 0x4000	/**< Enum end */
} HOA_MEDIA_AUDIO_PROP_TYPE_T;

/**
 * Media Subtitle Information
 */
typedef struct MEDIA_SUBTITLE_INFO
{
	UINT8			subtitleShow;		/**< Subtitle on/off infomation */
	CHAR			language[10];		/**< Language information */
	CHAR			subtitleURLPath[1024];	/**< Subtitle URL Path */
} MEDIA_SUBTITLE_INFO_T;

/**
 * External subtitle settings
 */
#ifndef LMF_EXT_SUBT_SETTINGS_T
typedef enum
{
	LMF_EXT_SUBT_ENABLE,      // external subtitle on/off setting
	LMF_EXT_SUBT_POSITION,    // subtitle postion setting, Y coordinate offset in step (1step = 10pixels)
	LMF_EXT_SUBT_SYNC,        // subtitle sync setting, sync offset in step (1 step = 0.5 sec)
	LMF_EXT_SUBT_LANGUAGE,     // subtitle language setting, language group (see EMP_LANG_GROUP_T)
	LMF_EXT_SUBT_EXIST		// subtitle exist or not exist
} __LMF_EXT_SUBT_SETTINGS_T;
#define LMF_EXT_SUBT_SETTINGS_T __LMF_EXT_SUBT_SETTINGS_T
#endif //EXT_SUBT_SETTINGS_T


//inyoung.choi
typedef enum
{
	LMF_INT_SUBT_ENABLE ,         // internal subtitle on/off setting
	LMF_INT_SUBT_LANGUAGE,        // internal subtitle language setting - language index
	LMF_INT_SUBT_LANGUAGE_COUNT,   // internal subtitle language count, max number of language
	LMF_INT_SUBT_MKVINTERNAL_SUBT // MKV internal subtitle setting
} LMF_INT_SUBT_SETTINGS_T;

/**
 *	External Subtitle Type
 */
#ifndef LMF_SUBT_FILE_TYPE_T
typedef enum
{
	LMF_FILETYPE_NONE = 0,
	LMF_FILETYPE_SUBVIEWER1 = 1,			// .sub
	LMF_FILETYPE_SUBVIEWER2,			// .sub
	LMF_FILETYPE_MICRODVD,				// .sub
	LMF_FILETYPE_SUBRIP,				// .srt
	LMF_FILETYPE_SAMI,					// .smi
	LMF_FILETYPE_SUBSTATIONALPHA,		// .ssa
	LMF_FILETYPE_ADVANCESUBSTATION,	// .ass
	LMF_FILETYPE_POWERDIVX,			// .psb
	LMF_FILETYPE_TMPLAYER,				// .txt
//#ifdef INCLUDE_BROWSER_SUBTITLE
	LMF_FILETYPE_CINECANVAS,		    // .dcs dongwon
	LMF_FILETYPE_TIMEDTEXT,             // .xml dongwon
//#endif
/*
	LMF_FILETYPE_DVDSS,					// .txt
	LMF_FILETYPE_REALTIME,				// .rt
	LMF_FILETYPE_DKS,					// .dks
	LMF_FILETYPE_MPLAYER2,				// .mpl
	LMF_FILETYPE_VIPLAY,					// .vsf
	LMF_FILETYPE_OVRSCRIPT,				// .ovr
	LMF_FILETYPE_TURBOTITLER,			// .tts
	LMF_FILETYPE_ZEROG,					// .zeg
	LMF_FILETYPE_SPRUCESUBTITLE,    		// .stl
	LMF_FILETYPE_SUBCREATOR,			// .txt
	LMF_FILETYPE_PINNACLEIMP,			// .txt
	LMF_FILETYPE_QUICKTIME,				// .txt
	LMF_FILETYPE_POWERPIXEL,			// .txt
	LMF_FILETYPE_MACDVDSTUDIOPRO,		// .txt
	LMF_FILETYPE_CAPTIONS32,			// .txt
	LMF_FILETYPE_JACOSUB27PLUS,		// .js & .jss
*/
	LMF_FILETYPE_END
} __LMF_SUBT_FILE_TYPE_T;
#define LMF_SUBT_FILE_TYPE_T __LMF_SUBT_FILE_TYPE_T
#endif//LMF_SUBT_FILE_TYPE_T

/**
* SYNCBLOCK_T for subtitle result
*
* @see
*/
#ifndef SYNCBLOCK
typedef struct SYNCBLOCK_T {
	int nSyncStart;
	int nSyncEnd;
	char *text;
} __SYNCBLOCK;
#define SYNCBLOCK __SYNCBLOCK
#endif

/**
* SYNCBLOCK_T2 for bmp subtitle result
* inyoung.choi
* @see
*/
#ifndef SYNCBLOCK2
	typedef struct SYNCBLOCK_T2 {
		int startTime;
		int endTime;
		int bmp_width;
		int bmp_height;
		unsigned char *bmp;
	} __SYNCBLOCK2;
#define SYNCBLOCK2 __SYNCBLOCK2
#endif

/**
 * Media Audio language Information
 */
typedef struct MEDIA_AUDIO_INFO
{
	CHAR			audioLang[10];		/**< Language information */
} MEDIA_AUDIO_INFO_T;

/**
 * This enumeration describes the media play subtitle information
 *
 */
typedef enum HOA_MEDIA_SUBT_PROP_TYPE
{
	HOA_SUBTITLE_SHOW	= 0x0001,	/**< Subtitle on/off */
	HOA_SUBTITLE_LANGUAGE	= 0x0010,	/**< Subtile language */
	HOA_SUBTITLE_URLPATH	= 0x0100,	/**< Subtile URL Path */
	HOA_SUBTITLE_MAX	= 0x4000	/**< Enum end */
} HOA_MEDIA_SUBT_PROP_TYPE_T;

/**
* Media Type Information
*/
typedef struct HOA_MEDIA_TYPE
{
	MEDIA_TRANSPORT_T mediaTransportType;
	MEDIA_FORMAT_T mediaFormatType;
	MEDIA_CODEC_T mediaCodecType;
} HOA_MEDIA_TYPE_T;

/**
 * This enumeration describes the audio sampling rate.
 *
 */
typedef enum HOA_AUDIO_SAMPLERATE{
	HOA_AUDIO_SAMPLERATE_BYPASS = 0,		/**< By pass */
	HOA_AUDIO_SAMPLERATE_48K 	= 1,		/**< 48 kHz */
	HOA_AUDIO_SAMPLERATE_44_1K 	= 2,		/**< 44.1 kHz */
	HOA_AUDIO_SAMPLERATE_32K 	= 3,		/**< 32 kHz */
	HOA_AUDIO_SAMPLERATE_24K 	= 4,		/**< 24 kHz */
	HOA_AUDIO_SAMPLERATE_16K 	= 5,		/**< 16 kHz */
	HOA_AUDIO_SAMPLERATE_12K 	= 6,		/**< 12 kHz */
	HOA_AUDIO_SAMPLERATE_8K 	= 7			/**< 8 kHz */
} HOA_AUDIO_SAMPLERATE_T;

/**
 * This enumeration describes the PCM channel mode.
 *
 */
typedef enum
{
	HOA_AUDIO_PCM_MONO			= 0,		/**< PCM mono */
	HOA_AUDIO_PCM_DUAL_CHANNEL	= 1,		/**< PCM dual channel */
	HOA_AUDIO_PCM_STEREO		= 2,		/**< PCM stereo */
	HOA_AUDIO_PCM_JOINT_STEREO	= 3,		/**< PCM joint stereo */
} HOA_AUDIO_PCM_CHANNEL_MODE_T;

/**
 * This enumeration describes the bit per sample for PCM.
*
*/
typedef enum
{
	HOA_AUDIO_8BIT = 0,		/**< 8 bit per sample */
	HOA_AUDIO_16BIT = 1		/**< 16 bit per sample */
} HOA_AUDIO_PCM_BIT_PER_SAMPLE_T;


typedef struct
{
	/* AAC - instead of ADTS header */
	UINT32 	profile;		// from CP
	UINT32	channels;		// from CP
	HOA_AUDIO_SAMPLERATE_T 	frequency;		// from CP

	/* to support raw audio es(without header) */
	char 	*codec_data;		// codec_data : DSI (Decoding Specific Info)	// from CP
	UINT32 	codec_data_size; 	// from CP
} HOA_AUDIO_AAC_INFO_T;

typedef struct
{
	/* WMA */
	UINT32	wmaVer;
	UINT16	wmaFormatTag;
	UINT16  channels;
	UINT32  samplesPerSec;
	UINT32  avgBytesPerSec;
	UINT16  blockAlign;
	UINT16  bitsPerSample;

	/* to support raw audio es(without header) */
	char 	*codec_data;		// codec_data : DSI (Decoding Specific Info)	// from CP
	UINT32	codec_data_size; 	// from CP

} HOA_AUDIO_WMA_INFO_T;

/**
 * This structure contains the PCM informations
 *
 */
typedef struct HOA_AUDIO_PCM_INFO
{
	HOA_AUDIO_PCM_BIT_PER_SAMPLE_T	bitsPerSample;		/**< PCM bits per sample */
	HOA_AUDIO_SAMPLERATE_T sampleRate;					/**< PCM sampling rate */
	HOA_AUDIO_PCM_CHANNEL_MODE_T channelMode;		/**< PCM channel mode */
} __attribute__((packed)) HOA_AUDIO_PCM_INFO_T;

/**
 * This enumeration describes encryption type of media.
 */
typedef enum MEDIA_SECURITY_TYPE
{
	MEDIA_SECURITY_NONE = 0,	/**< No encryption */
	MEDIA_SECURITY_AES,			/**< AES */
	MEDIA_SECURITY_WMDRM,		/**< WMDRM */
	MEDIA_SECURITY_VERIMATRIX,	/**< Verimatrix DRM */
	MEDIA_SECURITY_NUM
} MEDIA_SECURITY_TYPE_T;


/**
 * This enumeration describes video codec of media.
 *
 */
typedef enum MEDIA_CODEC_VIDEO
{
	MEDIA_VIDEO_NONE	= 0x00,		/**< No Video */
	MEDIA_VIDEO_ANY		= 0x00,		/**< Any Video codec */

	MEDIA_VIDEO_MPEG1	= 0x10,		/**< mpeg1 codec */
	MEDIA_VIDEO_MPEG2	= 0x20,		/**< mpeg2 codec */
	MEDIA_VIDEO_MPEG4	= 0x30,		/**< mpeg4 codec */
	MEDIA_VIDEO_MJPEG	= 0x40,		/**< mjpeg codec */
	MEDIA_VIDEO_H264	= 0x50,		/**< h.264 codec */
	MEDIA_VIDEO_REALVIDEO	= 0x60,	/**< real video codec */
	MEDIA_VIDEO_WMV		= 0x70,		/**< wmv codec */
	MEDIA_VIDEO_YUY2	= 0x80,		/**< YUY2 (YUV422) format */
	MEDIA_VIDEO_VC1		= 0x90,		/**< VC1 codec */
	MEDIA_VIDEO_DIVX	= 0xA0,		/**< Divx codec */
	MEDIA_VIDEO_H263	= 0xe0,		/**< h.263 codec */  // 추후 값 조정 필요.

	MEDIA_VIDEO_NOT_SUPPORTED = 0xb0,

	MEDIA_VIDEO_MASK	= 0xF0		/**< Video codec mask */
} MEDIA_CODEC_VIDEO_T;

/**
 * This enumeration describes audio codec of media.
 *
 */
typedef enum MEDIA_CODEC_AUDIO
{
	MEDIA_AUDIO_NONE	= 0x00,		/**< No Audio */
	MEDIA_AUDIO_ANY		= 0x00,		/**< Any Audio codec */

	MEDIA_AUDIO_MP3		= 0x01,		/**< mp3 codec */
	MEDIA_AUDIO_AC3		= 0x02,		/**< ac3 codec */
	MEDIA_AUDIO_MPEG	= 0x03,		/**< mpeg codec */
	MEDIA_AUDIO_AAC		= 0x04,		/**< aac codec */
	MEDIA_AUDIO_CDDA	= 0x05,		/**< cdda codec */   	//not implemented in LMF
	MEDIA_AUDIO_PCM		= 0x06,		/**< pcm codec */
	MEDIA_AUDIO_LBR		= 0x07,		/**< lbr codec */		//not implemented in LMF
	MEDIA_AUDIO_WMA		= 0x08,		/**< wma codec */
	MEDIA_AUDIO_DTS		= 0x09,		/**< dts codec */
	MEDIA_AUDIO_AC3PLUS	= 0x0A,		/**< ac3 plus codec */
	MEDIA_AUDIO_RA		= 0x0B,		/**< ra  plus codec */
	MEDIA_AUDIO_AMR		= 0x0C,		/**< amr plus codec */
	MEDIA_AUDIO_HEAAC	= 0x0D,								//not implemented in LMF (could not tell from AAC)
	MEDIA_AUDIO_PCMWAV	= 0x0E,								//not implemented in LMF
	MEDIA_AUDIO_WMA_PRO	= 0x0F,								//not implemented in LMF
//	MEDIA_AUDIO_XPCM 	= 0x0F,
	MEDIA_AUDIO_NOT_SUPPORTED = 0xC0, /** Audio not supported */

	MEDIA_AUDIO_MASK	= 0x0F		/**< Audio codec mask */
} MEDIA_CODEC_AUDIO_T;

/**
 * Structure of ASF file options
 */
typedef struct HOA_ASF_OPT
{
	UINT16	audioStreamNum;				/**< Audio stream number (ID) to play */
	UINT16	videoStreamNum;				/**< Video stream number (ID) to play */
	BOOLEAN	bSeperatedStream;			/**< seperated AV  */
	float		playTime;
	float		playRate;
	UINT32	dummyWord;
} __attribute__((packed)) HOA_ASF_OPT_T;


/**
 * Structure of Flash ES options
 */
typedef struct HOA_FLASHES_OPT
{
#if 0 //#ifdef FLASHES_FOR_LMF
           UINT32 audBufMinLevel;
           UINT32 audBufMaxLevel;
           UINT32 vidBufMinLevel;
           UINT32 vidBufMaxLevel;
           UINT32 prerollSizs;
           MEDIA_CODEC_AUDIO_T          aCodec;
           MEDIA_CODEC_VIDEO_T          vCodec;
           AF_BUFFER_HNDL_T              ABuff;
           AF_BUFFER_HNDL_T              VBuff;
           BOOLEAN                   bUseEsSimpleChannelPlay;
           UINT32 bufferMinLevel; // old
           UINT32 bufferMaxLevel; // old
#else
           UINT32 bufferMinLevel;
           UINT32 bufferMaxLevel;
           //AF_BUFFER_HNDL_T handleEsAudio; /* add for flash ES audio case */
           //AF_BUFFER_HNDL_T handleEsVideo; /* add for flash ES video case */
#endif //FLASHES_FOR_LMF
           SINT64 ptsToDecode;
           BOOLEAN pauseAtDecodeTime;
           BOOLEAN bIsAudioOnly;                     /*        Not sure - 20110411 by meeshel         */
} __attribute__((packed)) HOA_FLASHES_OPT_T;

/**
 * Structure of streaming play option
 */
typedef struct MEDIA_STREAMOPT
{
	UINT32				totDataSize;	/**< Total streaming data size. 현재는 Audio에서만 사용. */
	HOA_RECT_T			dispRect;		/**< Display(output) Rect. Video 및 Image에서 사용. */

	HOA_AUDIO_AAC_INFO_T	aacInfo; 		/**< AAC Info for Audio.*/
	HOA_AUDIO_WMA_INFO_T	wmaInfo; 		/**< WMA Info for Audio.*/
	HOA_AUDIO_PCM_INFO_T	pcmInfo;		/**< PCM Info for Audio.*/

	HOA_ASF_OPT_T		asfOption;		/**< ASF option for ASF File (stream) play. Media Format이 ASF인 경우 사용. */
	MEDIA_SECURITY_TYPE_T	securityType;	/**< Stream encrypt type */
	HOA_FLASHES_OPT_T	flashOption;	/**< Flash option */

	SINT64 ptsToDecode;

	MEDIA_VIDEO_ADAPTIVE_INFO_T adaptiveInfo;  /**< to support seamless play for adaptive streaming */

	BOOLEAN	bAdaptiveResolutionStream;			/**< seperated Resolution  */
	BOOLEAN bRestartStreaming;

	UINT32                  preBufferTime;  /**< Transfer time unit required Pre-Buffering */

} __attribute__((packed)) MEDIA_STREAMOPT_T;

/**
 * This enumeration describes stream type.
 */
typedef enum MEDIA_STREAM_TYPE
{
	MEDIA_STREAM_NONE = 0,			/**< don't care */
	MEDIA_STREAM_MULTIPLEXED,	/**< Multiplexed AV */
	MEDIA_STREAM_AUDIO,				/**< AUDIO */
	MEDIA_STREAM_VIDEO				/**< VIDEO */
} MEDIA_STREAM_TYPE_T;

/**
 * Structure of option for feeding stream.
 */
typedef struct MEDIA_FEEDOPT
{
	MEDIA_STREAM_TYPE_T	eStreamType;	/**< stream type(Multi/Audio/Video) */
	unsigned char					bHeaderData;	/**< header or data packet */
	unsigned char					bSendEOS;		/**< whether send EOS */
} MEDIA_FEEDOPT_T;

/**
* MEDIA_CALLBACK : callback function 정보.
*/
typedef struct HOA_MEDIA_CALLBACK
{
	HOA_APP_TYPE_T appType;
	unsigned short int 			appPID;
	MEDIA_PLAY_CB_T pfnPlayCB;				/**< callback for Play End noti */
} HOA_MEDIA_CALLBACK_T;

/**
 * Locale Info Type
 */
typedef enum HOA_LOCALE
{
	HOA_LOCALE_COUNTRY,		/**< Country Info.  TV에 설정되어 있는 국가 정보를 얻어온다.\n
							 * 국가에 대한 code는 ISO 3166-1 alpha-3를 따른다.
							 * ISO 3166-1의 3자리 format(Alpha-3) + NULL이 붙어 UINT32로 반환된다.\n
							 * 예)\n
							 *	 ISO 3166-1 code				반환되는 country code\n
							 * 		KOR							(UINT32)(('K'<<24) | ('O'<<16) | ('R'<<8))
							 */
	HOA_LOCALE_LANGUAGE,	/**< Language Info.  TV에 설정되어 있는 언어를 얻어온다.\n
							 * 설정된 언어에 대한 code는 ISO 639-2를 따른다.
							 * ISO 639의 3자리 format(Alpha-3) + NULL이 붙어 UINT32로 반환된다.\n
							 * 예)\n
							 *	 ISO 639-2 code				반환되는 language code\n
							 * 		kor							(UINT32)(('k'<<24) | ('o'<<16) | ('r'<<8))
							 */
	HOA_LOCALE_GROUP,		/**< Group Info. TV에 설정되어 있는 Group 정보를 얻어온다. Group은 HOA_LOCALE_GROUP_T로 정의되어 있다. */
} HOA_LOCALE_T;


/**
 * MRCU Info Type
 */
typedef enum HOA_MRCU
{
	HOA_MRCU_TYPE,		/**< Magic remote type info: (0: M3, 1: M4, 2: M4CI, 3: Dongle)	 */
	HOA_MRCU_SENSITIVITY,	/**< Magic remote sensitivity for pointing: (0: Normal, 1: Slow, 2: Fast)	 */
	HOA_MRCU_RECENTER,	/**< Magic remote recentering support: (0: no support, 1: support)	 */
} HOA_MRCU_T;


/**
* Black out type
*/
typedef enum HOA_BLACKOUT_TYPE
{
	HOA_NO_SCREEN_SAVER,		/** No Screen Saver */
	HOA_NO_SIGNAL,				/** No Signal */
	HOA_INVALID_FORMAT,			/** Sync ok, but the video format is not valid. */
	HOA_CM_BLOCKED,				/** Channel Block */
	HOA_INPUT_BLOCKED,			/** Input Block */
	HOA_RATING_BLOCKED,			/** Rating Block */
	HOA_AUDIO_ONLY,				/** Audio Only */
	HOA_SCRAMBLED,				/** Scrambled */
	HOA_DATA_ONLY,				/** Data Only */
	HOA_HD_SERVICE,				/** HD_SERVICE */
	HOA_OTA_SERVICE,			/** OTA_SERVICE */
	HOA_INVALID_SERVICE,		/** INVALID_SERVICE */
	HOA_NOT_PROGRAMMED,			/** Not programmed */
	HOA_NOT_CONFIGUED,			/** No Language selection in Setupwizard **/
	HOA_SATELITE_MOTOR_MOVING,	/** satlite motor moving */
	HOA_EMF_DMR_SCREENSAVER,	/** EMF DMR Screen Saver **/
	HOA_BLACKOUT_INFO_MAX,		/** Num of UI_BLACK_OUT_T*/

} HOA_BLACKOUT_TYPE_T;

/**
* TV Source type
* TV Source type 과 Sync 맞출 것
*/
typedef enum HOA_TV_SOURCE_TYPE
{
	TV_SRCTYPE_TV	= 0,
	TV_SRCTYPE_SCART,
	TV_SRCTYPE_COMPOSITE,
	TV_SRCTYPE_AUTOAV,
	TV_SRCTYPE_COMPONENT,
	TV_SRCTYPE_RGB,
	TV_SRCTYPE_HDMI,
	TV_SRCTYPE_USB,
	TV_SRCTYPE_MEDIASHARE,
	TV_SRCTYPE_BT,
	TV_SRCTYPE_PICTUREWIZARD,
	TV_SRCTYPE_SUPPORT,
	TV_SRCTYPE_ADDON,
	TV_SRCTYPE_HDD,
	TV_SRCTYPE_NUMBER,
	TV_SRCTYPE_INVALID = 0xFF
} HOA_TV_SOURCE_TYPE_T;

/**
 * TV UI Media Input Info.
 * 기존 MRE PATH에 정의된 내용을 UI로 가져와서 관리함.
 */
typedef struct HOA_TV_INPUT_INFO
{
	HOA_TV_SOURCE_TYPE_T	type;
	UINT32					id; /*일반 외부입력의 경우는 (0, 1, ...), USB 의 경우는 Device num 으로 사용 - 110604, daesuk.park */
	UINT32					attr;
	UINT8					virtualIndex;
	UINT8					physicalIndex;
} HOA_TV_INPUT_INFO_T;

/**
 * Media Path Index
 *
 */
typedef enum HOA_MEDIA_PATH_INDEX
{
	HOA_MAIN_MEDIA_PATH = 0,
	HOA_SUB_MEDIA_PATH,
	HOA_MAX_MEDIA_PATH
} HOA_MEDIA_PATH_INDEX_T;


/**
 * String structure
 */
typedef struct HOA_STRING
{
	UINT8 *pString;			/**< String. */
	UINT32 stringSize;		/**< String data size. */
} HOA_STRING_T;

/**
 * String structure
 */
typedef struct HOA_BLACKOUT_STRING
{
	UINT8 blackoutString[MAX_BLACKOUT_STRING];			/**< String. */
	UINT32 stringLength;								/**< String data size. */
} HOA_BLACKOUT_STRING_T;

/**
 * String structure
 */
typedef struct HOA_INPUTSOURCE_STRING
{
	UINT8 string[MAX_INPUT_SOURCE_STRING];			/**< String. */
	UINT32 length;								/**< String data size. */
} HOA_INPUTSOURCE_STRING_T;

/**
 * Structure Verimatrix Service Type
 * See VM_SERVICE_TYPE_T in vm_api.h
 */
typedef enum
{
	HOA_MEDIA_SERVICE_IPTV			= 0,
	HOA_MEDIA_SERVICE_INTERNET_TV,
} HOA_MEDIA_SERVICE_TYPE_T;

/**
* 3D Input Mode Type
*/
typedef enum
{
	HOA_3DINPUT_2D				= 0,	/**< Not 3D , 3D off */
	//interim format - half
	HOA_3DINPUT_TOP_BOTTOM,	/**< for T/B, S/S, Checker, Frame Seq*/
	HOA_3DINPUT_SIDE_SIDE_HALF,	/**< for T/B, S/S, Checker, Frame Seq*/
	HOA_3DINPUT_CHECK_BOARD,	/**< for T/B, S/S, Checker, Frame Seq*/
	HOA_3DINPUT_FRAME_SEQUENTIAL,/**< for T/B, S/S, Checker, Frame Seq*/
	HOA_3DINPUT_COLUMN_INTERLEAVE,	/**< for H.264*/
	HOA_3DINPUT_LINE_INTERLEAVE_HALF, /**< for H.264*/
	//Full format
	HOA_3DINPUT_FRAME_PACKING,	/**< Full format*/
	HOA_3DINPUT_FIELD_ALTERNATIVE,	/**< Full format*/
	HOA_3DINPUT_LINE_ALTERNATIVE,	/**< Full format*/
	HOA_3DINPUT_SIDE_SIDE_FULL,	/**< Full format*/
	HOA_3DINPUT_DUAL_STREAM,	/**< Full format*/
	HOA_3DINPUT_2DTO3D,	/**< Full format*/
} HOA_TV_3D_INPUTMODE_TYPE_T;	/**< Full format*/

/**
* 3D hotkey, 3D 버튼 동작위한 property 설정.
* 아래 enum 수정 시 ui_svc_tridtv.h 파일도 같이 추가해야 함.
*/
typedef enum
{
	HOA_3DKEY_ENABLE_DTV				= 0,	/**< DTV Process 에서 동작 */
	HOA_3DKEY_ENABLE_CP_KEEP_3DSTATUS,		/**< CP에서 3D키 동작 가능한 상태이며, 설정된 3D 상태가 계속 유지됨. */
	HOA_3DKEY_ENABLE_CP_RESET_3DSTATUS,		/**< CP에서 3D키 동작 가능한 상태이며, 설정된 3D 상태는 신호 변경 전까지 유효함. */
	HOA_3DKEY_DISABLE_CP,					/**< CP에서 3D키 동작 가능하지 않은 상태 */
} HOA_TV_3DKEY_PROPERTY_T;


/**
* Status Content License Download
*/
typedef struct HOA_DOWNLOAD_STATUSCONTENTLICENSE
{
	UINT8	beginDate[18];
	UINT8	endDate[18];

	/**
	*  expiration after first use.
	*/
	struct EXPIRATION_T{
		UINT16	initialValue;
		UINT8	expirationDate[18];
	}expirationAfterFirstUse;

	/**
	* play count
	*/
	struct PLAYCOUNT_T{
		UINT16	initialValue;
		UINT16	currentValue;
	}playCount;
} HOA_DOWNLOAD_STATUSCONTENTLICENSE_T;

/**
* Content Entty
*/
typedef struct HOA_CONTENT_ENTTY
{
	char	pTitle[256];
	char	pOriginsite[256];
	char	pContentURL[2048];
	char	pTransferType[32];
	char	pMimetype[32];
	char	pSubtitleLanguage[32];
	char	pSubtitleURL[2048];
	char 	contentID[70];

	UINT16	timeMargin;
	UINT32	registerTime;
	UINT32	duration;
	UINT64	size;
} HOA_CONTENT_ENTRY_T;

/**
 * Types for playmode setting: bufferingOnly, playOnly (HTML5 case)
 */
typedef enum MEDIA_PLAYMODE
{
	BUFFERING_AND_PLAY	= 0,
	BUFFERING_ONLY,
	PLAY_ONLY
} MEDIA_PLAYMODE_T;

/**
 * Structure of AD info
 */
typedef struct HOA_AD_INFO
{
	SINT32	appType;
	SINT32	*timeline;
	SINT32	numOfTimeline;
} __attribute__((packed)) HOA_AD_INFO_T;

/**
 * Structure of DLNA info
 */
typedef struct HOA_DLNA_INFO
{
	char	pProtocolInfo[2048];
	UINT64	dContentLength; 	//filesize, in byte
	UINT32	duration;			//in sec
} HOA_DLNA_INFO_T;

/**
 * Structure of  media play options
 */
typedef struct MEDIA_CLIPOPT
{
	UINT32					startPositionMS;		/**< 시작시간 */
	HOA_RECT_T				dispRect;               /**< Display(output) Rect. Video 및 Image에서 사용. */
	HOA_AUDIO_PCM_INFO_T	pcmInfo;                /**< PCM Info for Audio. Audio에서만 사용. */

	/* preload & html5Content will be deleted */
	UINT8					preload;				/**< autoplay mode (none / metadata / auto) */
	UINT8					html5Content;			/**< Html5 Content 확인 */

	/* bufferingOrPlayOnly &  will be used instead */
	MEDIA_PLAYMODE_T		bufferingOrPlayOnly;	/**< buffering&play / bufferingOnly / playOnly */
	UINT8					pauseOnEOS;				/**< don't stop but pause on EOS */
	UINT8 					pauseOnBackwardTrickEnd;     /**< don't start but pause on Backward Trick playback meed position 0. */

	UINT32					inPort; 				/**< widi display 에서 사용 */
	HOA_DLNA_INFO_T			DLNAInfo; 				/**< DLNA 재생시 정보 전달 */

	HOA_AD_INFO_T			adInfo;  				/**< TransType == MEDIA_TRANS_AD 인 경우 사용: 광고용 추가 정보 전달 */

} __attribute__((packed)) MEDIA_CLIPOPT_T;

/**
 * Callback Message of Download play
 */
typedef enum DOWNLOAD_CB_MSG
{
	DOWNLOAD_CB_MSG_NONE			= 0x00,				/**< message 없는 상태 */
	DOWNLOAD_CB_MSG_DOWNLOADING_START,
	DOWNLOAD_CB_MSG_DOWNLOADING_STALLED,
	DOWNLOAD_CB_MSG_DOWNLOADING_END,
	DOWNLOAD_CB_MSG_DOWNLOADING_PAUSED,
	DOWNLOAD_CB_MSG_DOWNLOADING_REMOVED,
	DOWNLOAD_CB_MSG_ERR_DOWNLOADING	= 0xf000,
	DOWNLOAD_CB_MSG_ERR_DISC_FULL,
	DOWNLOAD_CB_MSG_ERR_NO_LONGER_AVAILABLE,
	DOWNLOAD_CB_MSG_REQ_READY_FOR_PLAYBACK,
	DOWNLOAD_CB_MSG_LAST
} DOWNLOAD_CB_MSG_T;


/**
 * Callback Message of Disc
 */
typedef enum DISC_CB_MSG
{
	DISC_CB_MSG_NONE				= 0x00,
	DISC_CB_MSG_FORMATTING_START,
	DISC_CB_MSG_FORMATTING_END,
	DISC_CB_MSG_ERR_FORMATTING		= 0xf000,
	DISC_CB_MSG_ERR_WRITE_PROTECTED,
	DISC_CB_MSG_ERR_BROKEN_MEDIA,
	DISC_CB_MSG_ERR_UNSUPPORTED_DEVICE,
	DISC_CB_MSG_USB_PLUGGED			= 0xff00,
	DISC_CB_MSG_USB_UNPLUGGED,
	DISC_CB_MSG_LAST
/*
	DOWNLOAD_CB_MSG_FORMAT_DONE,
	DOWNLOAD_CB_MSG_PART_STATUS_CHANGE,
	DOWNLOAD_CB_MSG_FORMAT_PROGRESS,
	DOWNLOAD_CB_MSG_DEV_UNLOADED,
	FORMAT_CB_MSG_LAST,
*/
} DISC_CB_MSG_T;

#define HOA_DISC_ID_LENGTH	32

/**
* Disc Format State
*/
typedef enum
{
	HOA_DISC_UNFORMATTED	= 0,
	HOA_DISC_UNDERFORMATTING,
	HOA_DISC_FORMATTED,
	HOA_DISC_ERROR
} HOA_DISC_FORMAT_STATE_T;

/**
* Disc Format Error
*/
typedef enum
{
	HOA_DISC_NOERROR = 0,
	HOA_DISC_UNDER_FORMATTING_ERROR,
	HOA_DISC_WRITE_PROTECTED,
	HOA_DISC_BROKEN_MEDIA,
	HOA_DISC_UNSUPPORTED_DEVICE,
	HOA_DISC_UNDEFINED_ERROR
} HOA_DISC_FORMAT_ERROR_T;

/**
 * Drive format type.
 */
typedef enum	_HOA_IO_DRV_FORMAT
{
	HOA_IO_DRV_DVR			= 0x001,
	HOA_IO_DRV_DB,
	HOA_IO_DRV_VOD,
	HOA_IO_DRV_APP,
	HOA_IO_DRV_CNTV,
	HOA_IO_DRV_NORMAL,
	HOA_IO_DRV_UNKNOWN
} HOA_IO_DRV_FORMAT_T;

/**
 * Drive state.
 */
typedef enum	_HOA_IO_MOUNT_STATUS
{
	HOA_IO_IS_MOUNTING		= 0,
	HOA_IO_MOUNT_OK,
	HOA_IO_MOUNT_NOT_OK,
	HOA_IO_IS_UMOUNTING,
	HOA_IO_UMOUNT_OK,
	HOA_IO_UMOUNT_NOT_OK

} HOA_IO_MOUNT_STATUS_T;

/**
* Download Possible State of Disc
*/
typedef enum
{
	HOA_DISC_SUCESSFUL_TO_DOWNLOAD = 0,
	HOA_DISC_INSUFFICIENT_TO_DOWNLOAD,
	HOA_DISC_NOT_AVAILABLE_TO_DOWNLOAD
} HOA_DISC_DOWNLOAD_POSSIBLE_STATE_T;

/**
* Download State of Disc
*/
typedef enum
{
	HOA_DISC_DOWNLOAD_READY_FOR_PLAY = 0,
	HOA_DISC_DOWNLOAD_COMPLETED		= 1,
	HOA_DISC_DOWNLOAD_IN_PROGRESS	= 2,
	HOA_DISC_DOWNLOAD_PAUSED			= 4,
	HOA_DISC_DOWNLOAD_FAILED			= 8,
	HOA_DISC_DOWNLOAD_NOT_STARTED	= 16,
	HOA_DISC_DOWNLOAD_STALLED		= 32
} HOA_DISC_DOWNLOAD_STATE_T;

/**
* Download Fail Reason of Disc
*/
typedef enum
{
	HOA_DISC_DOWNLOAD_DISC_FULL				= 0,
	HOA_DISC_DOWNLOAD_NOT_PURCHASED			= 1,
	HOA_DISC_DOWNLOAD_NO_LONGER_AVAILABLE	= 2,
	HOA_DISC_DOWNLOAD_INVALID				= 3,
	HOA_DISC_DOWNLOAD_OTHER_REASON			= 4,
	HOA_DISC_DOWNLOAD_NOT_FAIL				= 5
} HOA_DISC_DOWNLOAD_FAIL_REASON_T;

#define IO_USB_MAX_DEVICE_NUM					12
#define IO_USB_INVALID_DEVICE_NUM				IO_USB_MAX_DEVICE_NUM + 1

/**
 *  USB Device Type -- ieeum.lee(10.09.20)
 */
typedef enum HOA_IO_USB_DEV_TYPE
{
	HOA_EXTERNAL_DEV			= 0x01,				/**<LG MFS Format for PICTURE */
	HOA_DVRHDD_DEV,									/**<LG MFS Format for DVR */
	HOA_APPSTORE_DEV,								/**<LG MFS Format for App Store */
	HOA_VOD_DEV,									/**<LG MFS Format for Orange VOD */
	HOA_CNTV_DEV,									/**<LG MFS Format for CNTV */
	HOA_DEV_TYPE_INVALID,							/** Not Connected or Invalid */
} HOA_IO_USB_DEV_TYPE_T;

/**
 *  USB Storaeg Type
 */
typedef enum HOA_IO_USB_STORAGE_TYPE
{
	HOA_STORAGE_UNKNOWN = 0,		/**< for unknown device */
	HOA_STORAGE_FLASH ,				/**< for USB Flash type */
	HOA_STORAGE_HDD					/**< for USB HDD type */
} HOA_IO_USB_STORAGE_TYPE_T;

/**
*  USB device Information
*/
typedef struct HOA_IO_USB_DEV_INFO
{
	UINT16					deviceNum;
	HOA_IO_USB_DEV_TYPE_T	deviceType;
	HOA_IO_USB_STORAGE_TYPE_T	storageType;
	CHAR		mntPath[256];
	CHAR		fsType[10];
	CHAR		productName[128];
	UINT32		bconnectUSB1Port;
	UINT64		physicalSize;
	UINT64		usedSize;
	UINT32		usedRate;
	UINT64		availableSize;
	UINT32		formattingProgress;
	HOA_DISC_FORMAT_STATE_T 	formattingState;
	HOA_DISC_FORMAT_ERROR_T		formattingError;
} HOA_IO_USB_DEV_INFO_T;

/**
*  General USB Drive Information
*/
typedef struct HOA_IO_GENUSB_DRV_INFO
{
	UINT16					driveNum;
	CHAR					mntPath[128];
	CHAR					fsType[10];
	HOA_IO_MOUNT_STATUS_T		mountStatus;
	HOA_IO_DRV_FORMAT_T		drvFormat;
	UINT64		physicalSize;
	UINT64		usedSize;
	UINT32		usedRate;
	UINT64		availableSize;
} HOA_IO_GENUSB_DRV_INFO_T;

/**
*  General USB device Information
*/
typedef struct HOA_IO_GENUSB_DEV_INFO
{
	UINT16					deviceNum;
	HOA_IO_USB_DEV_TYPE_T	deviceType;
	HOA_IO_USB_STORAGE_TYPE_T	storageType;
	UINT32		totalDriveNum;
	HOA_IO_GENUSB_DRV_INFO_T	drvInfo[4];
	CHAR		vendorName[128];
	CHAR		productName[128];
	UINT32		bconnectUSB1Port;
} HOA_IO_GENUSB_DEV_INFO_T;

/*
*  Disc Information
*/
typedef struct HOA_DISC_INFO
{
	UINT8	discId;
	char	fileSystem[64];
	UINT64	physicalSize;
	UINT64	usedSize;
	UINT16	usedRate;
	UINT64	availableSize;
	UINT32	formattingProgress;
	char	storageType[64];
	BOOLEAN	usbPort;
	HOA_DISC_FORMAT_STATE_T formattingState;
	HOA_DISC_FORMAT_ERROR_T	formattingError;
} HOA_DISC_INFO_T;

/**
 *  USB Mounted device list
 */
typedef struct HOA_IO_MOUNT_DEV_LIST
{
	UINT32		usbDevCount;
	UINT32		usbDeviceNum[6];
} HOA_IO_MOUNT_DEV_LIST_T;

/**
* Download Information
*/
typedef struct HOA_DOWNLOAD_INFO
{
	UINT8    id;            // download id
	UINT8    positionInQueue;
	UINT8    state;         // eme_dm_api.h DOWNLOAD_STATE_T 참고

	UINT64   totalSize;
	UINT64   amountDownloaded;

	UINT32   startTime;
	UINT32   timeElapsed;
	UINT32   timeRemaining;
	UINT32   timeRemainingForPlayback;
	UINT32   timeMarginForPlayback;

	UINT32   currentBitrate;
	UINT32   totalDuration;

	char      contentID[70];
	char      name[256];       // vod title

	HOA_DISC_DOWNLOAD_FAIL_REASON_T        reason;
	UINT32   lastPlayPosition;
} HOA_DOWNLOAD_INFO_T;

typedef void (*DOWNLOAD_CB_T)(UINT8 downloadID, DOWNLOAD_CB_MSG_T msg);
typedef void (*DISC_CB_T)(DISC_CB_MSG_T msg);

#if 0
/**
 * Storage List.
 * 각 Storage별로 한 bit씩 할당되어 있음.
 */
typedef enum HOA_STORAGE_TYPE
{
	HOA_INTERNAL_FLASH		= 1,				/**< 내장 Flash */
	HOA_USB_DEV_HDD,							/**< 외장 HDD */
	HOA_USB_DEV_FLASH,							/**< 외장 FLASH */

} HOA_STORAGE_TYPE_T;
#endif

/**
 * TV Support Type.
 *
 */
typedef enum HOA_CTRL_SUPPORT_TYPE
{
	HOA_SUPPORT_BLUETOOTH, 	 	 	/**< Bluetooth 지원 여부 (TRUE/FALSE) */
	HOA_SUPPORT_PHOTOMUSIC, 	 	/**< (EMF 중) Photo/Music 지원 여부 (TRUE/FALSE) */
	HOA_SUPPORT_MOVIE,   		 	/**< (EMF 중) Movie 지원 여부 (TRUE/FALSE) */
	HOA_SUPPORT_CIFS,  		 		/**< CIFS 지원 여부 (TRUE/FALSE) */
	HOA_SUPPORT_DLNA,  		 		/**< DLNA 지원 여부 (TRUE/FALSE) */
	HOA_SUPPORT_MOTIONREMOCON,  	/**< 공간리모컨 지원 여부 (TRUE/FALSE) */
	HOA_SUPPORT_DVRREADY,			/**< DVR READY 여부 (TRUE/FALSE)  */
	HOA_SUPPROT_WIRELESSREADY,		/**< WIRELESS READY 여부 (TRUE/FALSE)  */
	HOA_SUPPORT_LOCALDIMMING,		/**< Local Dimming 지원 여부 (TRUE/FALSE) */
	HOA_SUPPORT_PICTUREWIZARD,		/**< Picture Wizard 지원 여부 (TRUE/FALSE) */
	HOA_SUPPORT_ORANGE,				/**< Orange 지원 여부 (TRUE/FALSE) */
	HOA_SUPPORT_NETCAST,			/**< NetCast 지원 여부 (TRUE/FALSE) */
	HOA_SUPPORT_CHANNELBROWSER,		/**< Channel Browser 지원 여부 (TRUE/FALSE) */
	HOA_SUPPORT_IPTV,				/**< IPTV 지원 여부 */
	HOA_SUPPORT_SKYPE,				/**< SKYPE 지원 여부 */
	HOA_SUPPORT_3D,					/**< Support 3D feature(TRUE/FALSE)(TRUE means that supports 3D feature) */
	HOA_SUPPORT_DUALVIEW,			/**< Dual View 지원 여부(TRUE/FALSE) */
	HOA_SUPPORT_CURSORNAVIGATION	= 0xa000,	/**< Cursor Navigation 지원 여부 */
	HOA_SUPPORT_COMBITYPE 	= 0xa001,	/**< COMBITYPE 지원 여부 */
	HOA_SUPPORT_DTV			= 0xb000, 	/**< Support DTV (TRUE/FALSE) */
	HOA_SUPPORT_CADTV,					/**< Support CADTV (TRUE/FALSE) */
	HOA_SUPPORT_LAST	= 0xffff
} HOA_CTRL_SUPPORT_TYPE_T;

/**
 *  Addon  AppStore Checked Type.
 */
typedef enum HOA_TVAPPS_APPSTORE_CHECK_TYPE
{
	HOA_TVAPPS_APPSTORE_OK				= 0x01,		/**<AppStore Contents OK */
	HOA_TVAPPS_APPSTORE_MOUNTFAIL,					/**<AppStore Mount Failed */
	HOA_TVAPPS_APPSTORE_NOLIST,						/**<AppStore List Do not exists */
	HOA_TVAPPS_APPSTORE_NOT_INIT,					/**<AppStore isn't initialized yet */
	HOA_TVAPPS_APPSTORE_MOUNTING,					/**<AppStore is on Mounting */
} HOA_TVAPPS_APPSTORE_CHECK_TYPE_T;

/**
 * Proc to TV Message
 *
 */
typedef enum HOA_CTRL_MESSAGE_TYPE
{
	HOA_TV_MSG_MR_VCS_LOAD_FINISH, 					/**< vcs load finish */
	HOA_TV_MSG_MR_VCS_CALL_HOLD,					/**< vcs call hold */
	HOA_TV_MSG_MR_VCS_CALL_RESUME, 				 	/**< vcs call resume */
	HOA_TV_MSG_MR_VCS_SHUTDOWN,				  		/**< vcs shutdown */

	HOA_TV_MSG_BROWSER_MSG,						 	/**< Show Browser Message */

} HOA_CTRL_MESSAGE_TYPE_T;

/**
 * MOTION REMOTE POINTER MODE
 *
 */
typedef enum HOA_TV_MOTION_POINT_MODE
{
	MOTION_POINT_MODE_HIDDEN			= 0,	/**< Motion pointer invisible */
	MOTION_POINT_MODE_SELECT,						/**< Motion pointer arrow */
	MOTION_POINT_MODE_BUSY,							/**< Motion pointer hourglass */
	MOTION_POINT_MODE_TEXT,							/**< Motion pointer I-beam */
	MOTION_POINT_MODE_DRAG,							/**< Motion pointer hand */
	MOTION_POINT_MODE_FORBIDDEN,				/**< Motion pointer slashed circle */

	MOTION_POINT_MODE_LAST
} HOA_TV_MOTION_POINT_MODE_T;

/**
 * Popup Type
 */
typedef enum HOA_POPUP_TYPE
{
	HOA_POPUP_SKYPE1,			/**< Skype 1 */
	HOA_POPUP_SKYPE2,			/**< Skype 2 */
	HOA_POPUP_SKYPE3,			/**< Skype 3 */
	HOA_POPUP_SKYPE4,			/**< Skype 4 */
	HOA_POPUP_SKYPE5,			/**< Skype 5 */
	HOA_POPUP_SKYPE6,			/**< Skype 6 */
	HOA_POPUP_SKYPE7,			/**< Skype 7 */
	HOA_POPUP_QUICKMENU,		/**< Quick Menu (AV Setting menu) */
	HOA_POPUP_SWUPDATE,			/**< SW Update Menu(NSU) */
	HOA_POPUP_ASPECTRATIO,		/**< Aspect ration menu */
	HOA_POPUP_3DMENU,			/**< 3D Menu(3D Setting menu)	*/
	HOA_POPUP_LAST = 0xff
} HOA_POPUP_TYPE_T;

/**
 * Popup Window Option
 */
typedef struct HOA_POPUP_OPTION
{
	HOA_POPUP_TYPE_T popupType;	/**< Popup position, size. */
	UINT32 	popupTimeout;		/**< Popup이 사용자 선택을 기다리는 시간. */

	HOA_STRING_T *pTextArr;		/**< Popup에 그려질 text의 array. */
	UINT16	textNum;			/**< text의 갯수 */

	char	**ppImagePathArr;	/**< Image path의 array */
	UINT16	imagePathNum;		/**< Image path의 갯수 */
} HOA_POPUP_OPTION_T;

/**
 * Typedef of callback function to get notice about Popup Timeout.
 */
typedef void (*POPUP_CB_T)(UINT32 handle, UINT8 btnIdx);

/**
 * Running Mode
 */
typedef enum HOA_RUNNINGMODE
{
	HOA_RUNMODE_NONE	= 0,			/**< 설정된 Running Mode가 없을 경우 */
	HOA_RUNMODE_HBBTV	= 1,			/**< HbbTV 모드 */
	HOA_RUNMODE_VCS		= 2,			/**< VCS 모드 */
	HOA_RUNMODE_DISABLE_2DTO3D = 4,		/**< 2Dto3D Disable 모드 */
	HOA_RUNMODE_NUM
} HOA_RUNNINGMODE_T;

#define IS_VIDEO(formatType, codecType) ( \
						(formatType & MEDIA_FORMAT_VIDEO_MASK) ||	\
						(formatType == MEDIA_FORMAT_RAW && 0 != (codecType & MEDIA_VIDEO_MASK)))

/**
 * Display Panel Resolution Type
 */
typedef enum HOA_DISPLAYPANEL_RES
{
	HOA_PANEL_1920X1080P,					/**< 1920x1080 Progressive */
	HOA_PANEL_1920X1080I,					/**< 1920x1080 Interlaced */
	HOA_PANEL_1376X776P,					/**< 1376x776 Progressive */
	HOA_PANEL_1366X768P,					/**< 1366x768 Progressive */
	HOA_PANEL_1365X768P,					/**< 1365x768 Progressive */
	HOA_PANEL_1024X768P,					/**< 1024x768 Progressive */
	HOA_PANEL_1024X720P,					/**< 1024x720 Progressive */
	HOA_PANEL_1280X720P,					/**< 1280x720 Progressive */
	HOA_PANEL_852X480P,						/**< 852x480 Progressive */
	HOA_PANEL_720X480P,						/**< 720x480 Progressive */

	HOA_PANEL_RES_NUMBER
} HOA_DISPLAYPANEL_RES_T;

/**
 * Display Panel Type
 */
typedef enum HOA_DISPLAYPANEL
{
	HOA_PANEL_PLASMA,				/**< PDP */
	HOA_PANEL_LCD,					/**< LCD */
	HOA_PANEL_DLP_PROJECTION,		/**< DLP Projection */
	HOA_PANEL_LCD_PROJECTION,		/**< LCD Projection */
	HOA_PANEL_CRT,					/**< CRT */

	HOA_PANEL_NUMBER
} HOA_DISPLAYPANEL_T;

/**
 * Back Light Type.
 *
 */
typedef enum HOA_TV_BACKLIGHT_TYPE
{
	HOA_BL_CCFL,				/**< CCFL */
	HOA_BL_NOR_LED,				/**< NOR LED */
	HOA_BL_EDGE_LED,			/**< Edge LED */
	HOA_BL_IOP_LED,				/**< IOP LED */
	HOA_BL_LAST
} HOA_TV_BACKLIGHT_TYPE_T;

#ifndef SUPPORT_3D_TYPE_T
/**
 *	Type of 3D Support Type
 */
 typedef enum SUPPORT_3D_TYPE
{
	SUPPORT_2D_ONLY,			/* support 2D only */
	SUPPORT_3D_IN_2D3D,			/* support 3D including 2D to 3D (active galsses 3D)*/
	SUPPORT_3D_MAX,
}__SUPPORT_3D_TYPE_T;
#define SUPPORT_3D_TYPE_T __SUPPORT_3D_TYPE_T
#endif	// SUPPORT_3D_TYPE_T

#ifndef MOTION_REMOCON_TYPE_T
/* MOTION REMOCON TYPE */
typedef enum MOTION_REMOCON_TYPE
{
	MOTION_REMOCON_BUILTIN_M3   	= 0,
	MOTION_REMOCON_BUILTIN_M4		= 1,
	MOTION_REMOCON_BUILTIN_M4CI		= 2,
	MOTION_REMOCON_DONGLE			= 3,
	SUPPORT_MOTION_RC_MAX			= 4,
}__MOTION_REMOCON_TYPE_T;
#define MOTION_REMOCON_TYPE_T __MOTION_REMOCON_TYPE_T
#endif // MOTION_REMOCON_TYPE_T

/**
 * reconfirm login window Type
 */
typedef enum HOA_LOGIN_CONFIRM_TYPE
{
	HOA_RECONFIRM_DELETE 	= 1,
	HOA_RECONFIRM_ADULT,
	HOA_RECONFIRM_PURCHASE,
	HOA_RECONFIRM_PASSWORD,
	HOA_RECONFIRM_MAX,
} HOA_LOGIN_CONFIRM_TYPE_T;

/*
 * add login type
 */
typedef struct HOA_LOGIN_MSG_RSP
{
	char       	usrID[32];
	UINT32      result;
	UINT32  	errCode;
} HOA_LOGIN_MSG_RSP_T;

/*
 * add billing type
 */
#define BILLING_MAX_CHARGE_LEN		16
#define BILLING_MAX_RSPENCDATA_LEN	256

typedef struct HOA_BILLING_PURCHASE_OUT
{
    UINT32        	result;
    UINT32    		errCode;
    char           	chargeNo[BILLING_MAX_CHARGE_LEN];
    char            sResult[BILLING_MAX_RSPENCDATA_LEN]; /* chargeNo + userID */
} HOA_BILLING_PURCHASE_OUT_T;

/*TENNY_NETWORK_HOA */

/**
*  NSU State Value
*/
typedef enum HOA_NSU_STATE
{
	HOA_NSU_STATE_IDLE = 0, 				/**< IDLE state	*/
	HOA_NSU_STATE_CONFIRM_WAIT,  			/**< DSI message arrive */
	HOA_NSU_STATE_PROGRESS,  				/**< conform ok, img file downloading */
	HOA_NSU_STATE_DOWNLOAD_SUSPEND,			/**< donwload stop */
	HOA_NSU_STATE_COMPLETE,					/**< download complete */
	HOA_NSU_STATE_MAX						/**< enum max value */
} HOA_NSU_STATE_T;

/*
* Network Status
 */
typedef enum HOA_NETWORK_STATUS
{
	HOA_NETWORK_LINK_DISCONNECTED,	/**< ethernet cable이 disconnect된 상태 */
	HOA_NETWORK_LINK_CONNECTED,		/**< ethernet cable이 connect된 상태 */
	HOA_NETWORK_DISCONNECTED,		/**< ethernet cable은 connect되어 있으나, 주어진 주소로 ping이 실패한 상태 */
	HOA_NETWORK_CONNECTED,			/**< ethernet cable이 connect되어 있고, internet이 가능한 상태. 또는 주어진 주소로 ping이 성공한 상태 */
	HOA_NETWORK_TRY_TO_CONNECT,		/**< network 연결 시도 중.  */
} HOA_NETWORK_STATUS_T;

/**
 * Network Type
 */
typedef enum HOA_NETWORK_TYPE
{
	HOA_NETWORK_NONE,						/**< None */
	HOA_NETWORK_WIRED_ETHERNET	= 1,		/**< Wired Network*/
	HOA_NETWORK_WIRELESS_WIFI	= (1<<1)	/**< Wireless Network */
} HOA_NETWORK_TYPE_T;

/**
 * Wireless Network Status
 */
typedef struct HOA_WIRELESSNETWORK_STATUS
{
	SINT8	signalStrength;		/**< Signal strength */
} HOA_WIRELESSNETWORK_STATUS_T;

/**
 * Network Configurations
 */
typedef struct HOA_NETCONFIG
{
	UINT32 ipAddress;
	UINT32 subnetMask;
	UINT32 gateway;
	UINT32 DNSServer1;
	UINT32 DNSServer2;
	UINT8 macAddress[6];
	UINT8 macAddressOfAP[6];
	UINT32 DHCPServer;
	BOOLEAN bDHCP;
} HOA_NETCONFIG_T;


#ifndef _SDPIF_CB_TYPE_T
#define _SDPIF_CB_TYPE_T
#define	MAX_SDPIF_CB				10
/**
 * sdpif callback type
 */
typedef enum _SDPIF_CB_TYPE
{
	SDPIF_CB_NONE				= 0,
	SDPIF_CB_MAIN,
	SDPIF_CB_MEMBERSHIP,
	SDPIF_CB_SNSMEMBERSHIP,
	SDPIF_CB_BILLING,
	SDPIF_CB_PKG,
	SDPIF_CB_ADV,
	SDPIF_CB_ADV_VIDEO,
	SDPIF_CB_HOME,

	SDPIF_CB_TYPE_LAST
} SDPIF_CB_TYPE_T;

/**
 * sdpif callback msg type
 */
typedef enum _SDPIF_CB_MSG
{
	SDPIF_SUCCESS_EXEC				= 0x1000,
	SDPIF_SUCCESS_DEVICE_AUTH,
	SDPIF_SUCCESS_CANCEL_DEVICE_AUTH,

	SDPIF_SUCCESS_CHECK_USER_ID,
	SDPIF_SUCCESS_REGISTER_USER,
	SDPIF_SUCCESS_SIGN_IN,
	SDPIF_SUCCESS_SIGN_OUT,
	SDPIF_SUCCESS_USER_LIST,
	SDPIF_SUCCESS_AUTH_USER,
	SDPIF_SUCCESS_EXT_SESSION,
	SDPIF_SUCCESS_DEACTIVATE_USER,
	SDPIF_SUCCESS_CHECK_TERMS,
	SDPIF_SUCCESS_AGREE_TERMS,
	SDPIF_SUCCESS_CHANGE_PASSWD,
	SDPIF_SUCCESS_DELETE_USER,
	SDPIF_SUCCESS_DEACTIVATE_DEVICE,

	SDPIF_SUCCESS_SNS_REGISTER_USER,
	SDPIF_SUCCESS_SNS_DEACTIVATE_USER,
	SDPIF_SUCCESS_SNS_USER_INFO,

	SDPIF_SUCCESS_BILLING,
	SDPIF_SUCCESS_CPN_LIST,

	SDPIF_SUCCESS_AD_INIT,
	SDPIF_SUCCESS_AD_URL,
	SDPIF_SUCCESS_AD_CLICKED,

	SDPIF_SUCCESS_DETECT_COUNTRY,

	SDPIF_SUCCESS_MY_APPS,

	SDPIF_SUCCESS_SEARCH_MEATA,
	SDPIF_SUCCESS_DNLD_CERT,


	SDPIF_ERR_UNKNOWN				= 0x2000,

	SDPIF_ERR_NOT_FOUND_MODEL,			/* A.001.01 */
	SDPIF_ERR_SECRET_FAIL,				/* A.001.02 */
	SDPIF_ERR_NOT_FOUND_MAC,			/* A.001.03 */

	SDPIF_ERR_DUPLICATE_USER_ID,		/* M.001.01 M.002.01 */
	SDPIF_ERR_INVALID_USER_ID,			/* M.001.02 M.002.02 */
	SDPIF_ERR_INVALID_PASSWD,			/* M.002.03 M.011.02 */
	SDPIF_ERR_WRONG_USER_ID,			/* M.003.01 M.004.01 */
	SDPIF_ERR_WRONG_PASSWD,				/* M.003.02 M.004.02 M.008.01 M.011.01 M.012.01 */
	SDPIF_ERR_WRONG_COUNTRY,			/* M.003.03 M.004.03 */
	SDPIF_ERR_EXCESS_DEVICE,			/* M.003.04 M.004.04 */
	SDPIF_ERR_INVALID_USER_RIGHT,		/* M.012.02 */
	SDPIF_ERR_CHECK_USER_ID_DUPLICATE_USER_ID,		/* M.001.01 */
	SDPIF_ERR_CHECK_USER_ID_INVALID_USER_ID,		/* M.001.02 */
	SDPIF_ERR_REGISTER_USER_DUPLICATE_USER_ID,		/* M.002.01 */
	SDPIF_ERR_REGISTER_USER_INVALID_USER_ID,		/* M.002.02 */
	SDPIF_ERR_REGISTER_USER_INVALID_PASSWD,			/* M.002.03 */
	SDPIF_ERR_REGISTER_USER_INVALID_TERMS,			/* M.002.04 */
	SDPIF_ERR_SIGN_IN_WRONG_USER_ID,				/* M.003.01 */
	SDPIF_ERR_SIGN_IN_WRONG_PASSWD,					/* M.003.02 */
	SDPIF_ERR_SIGN_IN_WRONG_COUNTRY,				/* M.003.03 */
	SDPIF_ERR_SIGN_IN_EXCESS_DEVICE,				/* M.003.04 */
	SDPIF_ERR_SIGN_IN_INVALID_TERMS,				/* M.003.05 */
	SDPIF_ERR_CANNOT_DEACTIVATE,					/* M.005.01 */
	SDPIF_ERR_AUTH_USER_WRONG_PASSWD,				/* M.008.01 */
	SDPIF_ERR_AGREE_INVALID_TERMS,					/* M.010.01 */
	SDPIF_ERR_CHANGE_PASSWD_WRONG_PASSWD,			/* M.011.01 */
	SDPIF_ERR_CHANGE_PASSWD_INVALID_PASSWD,			/* M.011.02 */
	SDPIF_ERR_DELETE_USER_WRONG_PASSWD,				/* M.012.01 */
	SDPIF_ERR_DELETE_USER_INVALID_USER_RIGHT,		/* M.012.02 */
	SDPIF_ERR_CHECK_TERMS,

	SDPIF_ERR_BILLING,
	SDPIF_ERR_CPN_LIST,

	SDPIF_ERR_AD_NOT_SUPPORT_COUNTRY,				/* AD.T.001.01 */

	SDPIF_ERR_CANNOT_DETECT_COUNTRY,	/* I.001.01 */

	SDPIF_ERR_MY_APPS,

	SDPIF_ERR_SEARCH_META,
	SDPIF_ERR_DNLD_CERT,

	SDPIF_NOTIFY					= 0x3000,
	SDPIF_NOTIFY_DNLD_HOME_APP,
	SDPIF_NOTIFY_DNLD_HOME_APP_DONE,
	SDPIF_NOTIFY_DNLD_HOME_3D_ZONE,
	SDPIF_NOTIFY_DNLD_HOME_3D_ZONE_DONE,

	SDPIF_CB_MSG_LAST
} SDPIF_CB_MSG_T;

/**
 * sdpif callback func type
 */
typedef void (*SDPIF_CB_T)(SDPIF_CB_MSG_T msg, UINT16 dataSize, UINT8 *pData);

/**
 * sdpif callback mgmt
 */
typedef struct _SDPIF_CB_MGMT
{
	SDPIF_CB_TYPE_T	type;
	SDPIF_CB_T		pfnCallback;
} SDPIF_CB_MGMT_T;
#endif	// _SDPIF_CB_TYPE_H

/**
 *	List 의 각 Item 에 대한 Data Structure.
 *
 *	@see	UI_LMGR_ITEM_INFO_T
 */
typedef struct
{
	UINT32						mediaId;				/**< Uniqe 한 Index	*/
	UINT8						deviceType;				/**< 장치 종류 */
	UINT8						mediaType;				/**< 파일의 Media type */
	BOOLEAN						bIsMarked;				/**< Mark 된 상태 */

	UINT8						fileName[512];			/**< File Name */
	UINT32						lastPlayPos;				/**< Video, Rec.Tv 용 */
} HOA_SMTS_ITEM_INFO_T;


/**
 *	video(movie) data type definition.
 *	@see	SMH_MOVIE_DATA_T
 */
typedef struct
{
	char			*pTitle;		// title
	char			*pDesc;		// describtion
	char			*pGenre;		// genre ( delimeter is , ) ex) 액션, 모험, SF
	char			*pRating;		// rating ( 관람 등급 )
	char			*pDirector;	// director
	char			*pActor;		// actors ( delimeter is , ) ex) 홍길동,
	UINT32		duration;		// unit: sec ( 영화의 원래 시간. 실제 파일이 1분 영상이라도 해당 영화가 2시간 분량이면 2시간으로 나옴 )
	UINT32		lastPlayPos;		// 이어보기 기능을 위한 , 최근 stop 한 위치 ( sec )
} HOA_SMTS_VIDEO_METADATA_T;


/**
 *	photo data type definition.
 *	@see	SMH_PHOTO_DATA_T
*/
typedef struct
{
	UINT32		width;			// photo's width
	UINT32		height;			// photo's height
	UINT32		fileSize;			// File Size
} HOA_SMTS_PHOTO_METADATA_T;


/**
 *	music data type definition.
 *	@see	SMH_MUSIC_DATA_T
*/
typedef struct
{
	UINT32		fileNum;			// Music Tap type 일 때 사용
	UINT32		duration;		// sec
	char			*pTitle;		// 곡명 , song's name
	char			*pSinger;		// 가수명
	char			*pAlbumName;		// album name
	char			*pGenre;		// 장르
	char			*pYear;	// 년도
} HOA_SMTS_MUSIC_METADATA_T;


/**
 *	DVR data type definition.
 *	@see	SMH_DVR_DATA_T
*/
typedef struct
{
	UINT32		programId;

	UINT8		epgType;			// 0: no EPG data 1:KBPS data 2: PSIP data 3: Gemstar data
	UINT8		bIsNew;			// 1 if this av-file is new, 0 otherwise
	UINT8		bAudioOnly;		// 1 if Audio Only, 0 otherwise
	UINT8		bBroken;			// 1 if Broken Image, 0 otherwise
	UINT32		duration;			// in the unit of second
	UINT32		nbThumbnail;		// total number of thumbnails
	UINT32		lastPlayPos;		// 프로그램의 마지막 재생위치
	UINT8		bCopyProtected;	//  0: no copy protected, 1: copy protected
	UINT8		bDeleteProtected;	// 0: no delete protected, 1: delete protected
	UINT32		genre;
	UINT16		recYear;
	UINT8		recMonth;
	UINT8		recDay;
	// 녹화된 채널
	UINT8		sourceIndex;
	UINT16		physicalNum;	/**<  Physical channel Number:  1-135	*/
	UINT16		majorNum;		/**<  Major number(1~9999) : 2bit(TV/Radio/Data flag), 14bit(user number) */
	UINT16		minorNum;		/**<  Minor number of channel : received LCN	*/
} HOA_SMTS_RECTV_METADATA_T;


/**
 *	Playing status 에 대한 Enumeration
 *
*/
typedef enum {
	SMTS_PLAY_STATE_STOPPED,
	SMTS_PLAY_STATE_PAUSED,
	SMTS_PLAY_STATE_PLAYING,
	SMTS_PLAY_STATE_MAX,
} SMTS_PLAY_STATE_T;

/**
 *	Playing status 에 대한 Data structure.
 *
*/
typedef struct {
	SMTS_PLAY_STATE_T		state;
	UINT8					fileName[512];
} HOA_SMTS_PLAY_STATE_T;


typedef struct TAG_LINKED_DEVICE_INFO_T {
	int 					deviceType;
	int 					DataId;
	char					deviceName[200];
	char					eachDeviceName[200];
	BOOLEAN 				bIsLock;
	BOOLEAN 				bConnect;
	char					pDeviceId[200];
	char					rootPath[256];
	char					iconUrl[1024]; //DLNA
	int 					iconType; //PLEX
	int 					inputLabelIndex;
} LINKED_DEVICE_INFO_T;

enum
{
	HOA_REGION_DVB = 0,
	HOA_REGION_ATSC = 1,
};


//#ifdef INCLUDE_VOICE
typedef void (*LGINPUT_VOICE_CB_T)(UINT32 dataSize, UINT8 *pData);
//#endif INCLUDE_VOICE

typedef void (*LGINPUT_VOICE_UI_CB_T)(UINT32 dataSize, UINT8 **pData);
typedef void (*LGINPUT_CB_T)(UINT32 pktCount, UINT32 vPktCount, UINT32 rssiTv, UINT32 rssiDv, UINT32 per);
typedef void (*LGINPUT_BSI_CB_T)(void *data);
typedef void (*LGINPUT_PDP3D_CB_T)(void);

/**
 * SmartShare callback func type
 */
typedef void (*SMTS_CB_T)(UINT32 operation, UINT32 mode[4],int intpParam, char *pParam);

#define MAX_SMTS_LEN_FILE_NAME		129

/**
 *	Smart Share에서 사용하는 Path Tree에 대한 구조체
 *
 */
typedef struct
{
	UINT8		pathDepth;
	UINT8		folderName[MAX_SMTS_LEN_FILE_NAME];
} HOA_SMTS_PATH_INFO_T;

/**
 *	Smart Share에서 사용하는 List Type에 대한 Enumeration
 *
 *	@see	UI_SMTS_LIST_TYPE_T
 */
typedef enum
{
	HOA_SMTS_LIST_TYPE_NONE = 0,
	// Contents List
	HOA_SMTS_LIST_TYPE_ALL = 1,
	HOA_SMTS_LIST_TYPE_VIDEO,
	HOA_SMTS_LIST_TYPE_PHOTO,
	HOA_SMTS_LIST_TYPE_MUSIC,
	HOA_SMTS_LIST_TYPE_RECTV,
	HOA_SMTS_LIST_TYPE_RECENTLY_WATCHED,
	HOA_SMTS_LIST_TYPE_NEWLY_ADDED,
	// Linked Device
	HOA_SMTS_LIST_TYPE_LINKED_DEVICE = 8,
	// Linked Device File List
	HOA_SMTS_LIST_TYPE_DEVICE_USB = 9,
	HOA_SMTS_LIST_TYPE_DEVICE_DVR,
	HOA_SMTS_LIST_TYPE_DEVICE_DLNA,
	HOA_SMTS_LIST_TYPE_DEVICE_PLEX,
	// Smart Share Home
	HOA_SMTS_LIST_TYPE_SMTS_HOME = 13,
	HOA_SMTS_LIST_TYPE_SMTS_HOME_WATCHED,
	HOA_SMTS_LIST_TYPE_SMTS_HOME_ADDED,
	// Home Card
	HOA_SMTS_LIST_TYPE_HOME_CARD = 16,
	HOA_SMTS_LIST_TYPE_HOME_CARD_MAIN,
	HOA_SMTS_LIST_TYPE_HOME_CARD_PHOTO,
	HOA_SMTS_LIST_TYPE_HOME_CARD_MUSIC,
	HOA_SMTS_LIST_TYPE_HOME_CARD_VIDEO,
	HOA_SMTS_LIST_TYPE_HOME_CARD_RECTV,
	// Music Catalog
	HOA_SMTS_LIST_TYPE_MUSIC_SONGS = 22,
	HOA_SMTS_LIST_TYPE_MUSIC_ALBUMS,
	HOA_SMTS_LIST_TYPE_MUSIC_ARTISTS,
	HOA_SMTS_LIST_TYPE_MUSIC_GENERES,
	HOA_SMTS_LIST_TYPE_MAX
} HOA_SMTS_LIST_TYPE_T;

/**
 *	Smart Share에서 사용하는 Sort Type에 대한 Enumeration
 *
 *	@see	UI_SMTS_SORT_TYPE_T
 */
typedef enum
{
	HOA_SMTS_SORT_TYPE_NONE,
	HOA_SMTS_SORT_TYPE_NAME,
	HOA_SMTS_SORT_TYPE_ADDED,
	HOA_SMTS_SORT_TYPE_STOPPED,
	HOA_SMTS_SORT_TYPE_MAX,
} HOA_SMTS_SORT_TYPE_T;

/**
 *	Smart Share에서 사용하는 Sort Type에 대한 Enumeration
 *
 *	@see	UI_SMTS_SORT_TYPE_T
 */
typedef enum
{
	HOA_SMTS_MEDIA_TYPE_UNSUPPORTED,
	HOA_SMTS_MEDIA_TYPE_ALL,
	HOA_SMTS_MEDIA_TYPE_RECTV,
	HOA_SMTS_MEDIA_TYPE_PHOTO,
	HOA_SMTS_MEDIA_TYPE_MUSIC,
	HOA_SMTS_MEDIA_TYPE_VIDEO,
	HOA_SMTS_MEDIA_TYPE_DEMO,
	HOA_SMTS_MEDIA_TYPE_FOLDER,
	HOA_SMTS_MEDIA_TYPE_MUSIC_TAP,
	HOA_SMTS_MEDIA_TYPE_MAX
} HOA_SMTS_MEDIA_TYPE_T;

#ifndef STATIC_STRING_BUFFER_SZ
#define STATIC_STRING_BUFFER_SZ	512
#endif

/**
 *	DVR Free Space Information type definition.
*/
typedef struct
{
	UINT8 storagebarType;
	UINT32 pFreeSpace;
	UINT8 pUsedPercent;
	UINT8 pHDTimeStr[STATIC_STRING_BUFFER_SZ];
	UINT8 pSDTimeStr[STATIC_STRING_BUFFER_SZ];
	UINT16 errStr[STATIC_STRING_BUFFER_SZ];
	UINT8 pFreeSpaceStr[STATIC_STRING_BUFFER_SZ];
} HOA_SMTS_DVR_FREE_SPACE_INFO_T;

typedef enum {
	HOA_DEV_TYPE_NONE 					= 0,
	HOA_DEV_TYPE_TV_ANTENNA				= 1,
	HOA_DEV_TYPE_TV_CABLE				= 2,
	HOA_DEV_TYPE_TV_SATELLITE			= 3,
	HOA_DEV_TYPE_EXT_SCART				= 4,
	HOA_DEV_TYPE_EXT_COMPOSITE			= 5,
	HOA_DEV_TYPE_EXT_AUTOAV				= 6,
	HOA_DEV_TYPE_EXT_COMPONENT			= 7,
	HOA_DEV_TYPE_EXT_RGB				= 8,
	HOA_DEV_TYPE_EXT_HDMI				= 9,
	HOA_DEV_TYPE_EXT_SIMPLINK			= 10,
	HOA_DEV_TYPE_MEDIA_USB				= 11,
	HOA_DEV_TYPE_MEDIA_DLNA				= 12,
	HOA_DEV_TYPE_MEDIA_WIFI_DIRECT		= 13,
	HOA_DEV_TYPE_MEDIA_WIFI_DISPLAY		= 14,
	HOA_DEV_TYPE_MEDIA_DVR				= 15,
	HOA_DEV_TYPE_MEDIA_PLEX				= 16,
	HOA_DEV_TYPE_UTIL_KEYBOARD			= 17,
	HOA_DEV_TYPE_UTIL_MOUSE 			= 18,
	HOA_DEV_TYPE_UTIL_VCS				= 19,
	HOA_DEV_TYPE_UTIL_WIFI_DONGLE 		= 20,
	HOA_DEV_TYPE_UTIL_3G_DONGLE			= 21,
	HOA_DEV_TYPE_UTIL_MOTION_DONGLE 	= 22,
	HOA_DEV_TYPE_UTIL_VOD				= 23,
	HOA_DEV_TYPE_APP_APPSTORE 			= 24,
	HOA_DEV_TYPE_EXT_DIIVA				= 25,
} HOA_LINKED_DEVICE_TYPE_T;



/**
 * Picture ID type
 */
typedef enum HOA_PICTURE_ITEM_ID
{
	PICTURE_ITEM_BACKLIGHT=0,
	PICTURE_ITEM_COLORTEM,
	PICTURE_ITEM_ADV_GAMMA,
	PICTURE_ITEM_TRUMOTION,
	PICTURE_ITEM_TRU_JUDDER,
	PICTURE_ITEM_TRU_BLUR,
	PICTURE_ITEM_DIMMING,
} HOA_PICTURE_ITEM_ID_T;


/**
*  Callback Message of VCS
*/
typedef enum VCS_CB_MSG
{
	VCS_CB_MSG_EVENT		= 0x00,
	VCS_CB_MSG_LAST
} VCS_CB_MSG_T;

/**
 *	날짜, 시간 표시형식에 대한 enumeration type
 */
typedef enum TAG_TIME_OPTION_T
{
	OPT_TIME_MASK	= 0x000000FF,	/**< Caller must not use this. */
	OPT_DATE_MASK	= 0x0000FF00,	/**< Caller must not use this. */

	OPT_DATE_FIRST	= 0x00010000,
	OPT_TIME_FIRST	= 0x00020000,

	/*
	 *	TIME
	 */
	/* Default : 각 국가별 Default */
	OPT_TIME_HM		= 0x00000001,	/**< EU: "13:29",			KO: "오후 1:29",			US: "01:29 PM"			*/

	/* 24시간제 ? 12시간제 */
	OPT_TIME_HHMM_24= 0x00000002,
	OPT_TIME_HHMM_12= 0x00000003,

	/*
	 *	DATE
	 */
	OPT_DATE_YMDW_L	= 0x00000100,	/**< EU: "Mon 10 Mar 2008",	KO/CN: "2008년 3월 10일(월)",	US: "Mon, Mar 10, 2008"	*/
	OPT_DATE_YMDW_S	= 0x00000200,	/**< EU: "(Mon.)10/03/2008",KO/CN: "2008/03/10(월)",		US: "(Mon.)03/10/2008"	*/
									/* KO에 요일추가 by jihyeon@20080517 : reservation 모듈에서만 이 옵션을 사용하는데, 요일이 들어가야 해서 이렇게 수정함. OPT_DATE_MD 처럼... */

	OPT_DATE_MDW	= 0x00000300,	/**< EU: "Mon 10 Mar",		KO/CN: "3월 10일 월요일",		US: "Mon, Mar 10"		*/
	OPT_DATE_MD		= 0x00000400,	/**< EU: "10/Mar",			KO/CN: "3/10(월)",				US: "Mar/10"			*/
	OPT_DATE_MD_N	= 0x00000500,	/**< EU: "10 Mar.",			KO/CN: "3/10(월)",				US: "Mar. 10"			*/
	OPT_DATE_YMD_L	= 0x00000600,	/**< EU: "10 Mar 2008",		KO/CN: "2008년 3월 10일",		US: "Mar 10, 2008"		*/
	OPT_DATE_YMD_S	= 0x00000700,	/**< EU: "10/03/2008",		KO/CN: "2008/03/10",			US: "3/10/2008"		*/
	OPT_DATE_YMD_L_ARAB	= 0x00000800,	/** Arab권 국가에서만 특수하게 사용함.  아랍 문자열 순서 조정을 위해서 "10 Mar 2008" 문자열 마지막에 사용하지 않는 아랍문자 삽입함.*/
	OPT_DATE_YMDW_L_ARAB = 0x00000900,	/** Arab권 국가에서만 특수하게 사용함.  아랍 문자열 순서 조정을 위해서 "Mon 10 Mar 2008" 문자열 마지막에 사용하지 않는 아랍문자 삽입함.*/

} TIME_OPTION_T;


/**
 * VCS callback func type
 */
typedef void (*VCS_CB_T)(VCS_CB_MSG_T msg, UINT32 eventSize, char *pEvent, UINT32 dataSize, char *pData);

#ifndef __MLM_RECENT_TYPE_DEF__
#define __MLM_RECENT_TYPE_DEF__
 /*
  * MLM RECENT Type.
  *   Warning : You must modified mlm_api.h when this enum changed!.
  */
typedef enum
{
	MLM_RECENT_EMPTY = 0,
	MLM_RECENT_TYPE_MOVIE   ,       // 동영상
	MLM_RECENT_TYPE_PHOTO   ,       // 사진
	MLM_RECENT_TYPE_AUDIO   ,       // 음악
	MLM_RECENT_TYPE_RECORDEDTV,     // recorded TV
	MLM_RECENT_TYPE_APP     ,       // App/CP
	MLM_RECENT_TYPE_WEB     ,       // Web
} MLM_RECENT_TYPE_T;
#endif

/**
 * GESTURE callback func type
 */
typedef void (*GESTURE_CB_T)(int gesture_type, int gesture_time, int key_value, int shmid, int buffer_size);


typedef enum GESTURE_CALLBACK_MSG
{
	GESTURE_CALLBACK_REGISTER    	= 0x01,
	GESTURE_CALLBACK_UNREGISTER     = 0x00,
}GESTURE_CALLBACK_MSG_T;


/**
 *	Gesture Game에서 사용하는 Enumeration
 */
typedef enum GESTURE_DATA_TYPE
{
	GESTURE_SKELETON    	,
	GESTURE_DEPTH       	,
	GESTURE_SILHOUETTE  	,
	GESTURE_RGB         	,
	GESTURE_SKELETON_OFF    ,
	GESTURE_DEPTH_OFF   	,
	GESTURE_SILHOUETTE_OFF	,
	GESTURE_RGB_OFF      	,
}GESTURE_DATA_TYPE_T;
/**
 *	Gesture Game에서 사용하는 HOA함수를 위한 Enumeration
 */
typedef enum HOA_GESTURE_MODE_TYPE
{
	HOA_GESTURE_HAND_ON = 0,
	HOA_GESTURE_BODY_ON,
}HOA_GESTURE_MODE_TYPE_T;
/**
 *	Gesture Game에서 사용하는 HOA함수를 위한 Enumeration
 */
typedef enum HOA_GESTURE_DATA_RESOLUTION
{
	HOA_GESTURE_RESOLUTION_OFF,			//for All data
	HOA_GESTURE_RESOLUTION_1BIT_QVGA,	//for Silhouette data
	HOA_GESTURE_RESOLUTION_8BIT_VGA,	//for Depth and RGB data
	HOA_GESTURE_RESOLUTION_8BIT_QVGA,	//for Depth and RGB data
	HOA_GESTURE_RESOLUTION_8BIT_QQVGA,	//for Depth and RGB data
	HOA_GESTURE_RESOLUTION_16BIT_VGA,	//for Depth and RGB data
	HOA_GESTURE_RESOLUTION_16BIT_QVGA,	//for Depth and RGB data
	HOA_GESTURE_RESOLUTION_16BIT_QQVGA,	//for Depth and RGB data
}HOA_GESTURE_DATA_RESOLUTION_T;
/**
 *	Gesture Game에서 사용하는 HOA함수를 위한 Enumeration
 */
typedef enum HOA_GESTURE_REQUEST_DATA
{
	HOA_GESTURE_REQUEST_DEPTH = 0x01,
	HOA_GESTURE_REQUEST_SILHOUETTE,
	HOA_GESTURE_REQUEST_RGB,
}HOA_GESTURE_REQUEST_DATA_T;

typedef struct RECEVIED_GESTURE_HAND_DATA
{
	int gestureName;
	int gestureType;
	int grip;
	float x;
	float y;
	float z;
}RECEVIED_GESTURE_HAND_DATA_T;

typedef struct RECEVIED_GESTURE_BODY_JOINT_DATA
{
	float x;
	float y;
	float z;
	float confidence;
	float rotationMatrix[9];
} RECEVIED_GESTURE_BODY_JOINT_DATA_T;

typedef struct RECEVIED_GESTURE_BODY_DATA
{
	int gesture1;
	int gesture2;
	int gesture3;
	int gesture4;
	int gesture5;
	struct RECEVIED_GESTURE_BODY_JOINT_DATA jointData[15];

} RECEVIED_GESTURE_BODY_DATA_T;

typedef struct RECEVIED_GESTURE_IMAGE_DATA
{
	int resolution;
	int last;
	unsigned char *data;
} RECEVIED_GESTURE_IMAGE_DATA_T;



//////////////////////////////////////////////////////////////////////////////////
// Types for MemoCast(PDP Only)
// Start
//////////////////////////////////////////////////////////////////////////////////

/**
 * MemoCast Mode.
 */
typedef enum HOA_MCAST_MODE
{
	HOA_MCAST_MEMO = 1,
	HOA_MCAST_PR,
} HOA_MCAST_MODE_T;


/**
 * MemoCast Command Set.
 */
typedef enum HOA_MCAST_CMD
{
	HOA_MCAST_BCMD_DEL = 0,
	HOA_MCAST_BCMD_DELALL,
	HOA_MCAST_BCMD_PLAY,
	HOA_MCAST_BCMD_STOP,
	HOA_MCAST_BCMD_PAUSE,

	HOA_MCAST_FCMD_FILENAME,
	HOA_MCAST_FCMD_OPENFILE,
	HOA_MCAST_FCMD_RENAME,
	HOA_MCAST_FCMD_PREVIEW_DELFILE,
	HOA_MCAST_FCMD_OPEN_DELFILE,

	HOA_MCAST_SCMD_OSD_CLEAR,
	HOA_MCAST_SCMD_MEMO_EXIT,
	HOA_MCAST_SCMD_CREATEJPGLIST,
} HOA_MCAST_CMD_T;

/**
*  Callback Message of FXUI
*/
typedef enum FXUI_CB_MSG
{
	FXUI_CB_MSG_NONE 	= 0x00,
	FXUI_CB_MSG_AGREETERM,
	FXUI_CB_MSG_LAST
} FXUI_CB_MSG_T;


/**
 * FXUI callback func type
 */
typedef void (*FXUI_CB_T)(FXUI_CB_MSG_T msg, UINT32 dataSize, char *pData);

typedef struct _FX_STRING_T
{
	UINT16 *str;
	UINT32  length;
} FX_STRING_T;


/**
 * Structure of MemoCast Flash Setting Info.
 */
typedef struct HOA_MCAST_FLASH_SET_INFO
{
	HOA_MCAST_MODE_T		eMCastMode;			/**< MemoCast Mode*/
	UINT8					uId;				/**< Memo or PR ID*/
	TIME_T					stStartTime;		/**< Start Time*/
	TIME_T					stEndTime;			/**< End Time*/
	UINT8					uRepType;			/**< Repeat Type*/
	UINT8					uRepCount;			/**< Repeat Counter*/
	BOOLEAN					bIsChecked;			/**< Checked Or Not*/
} HOA_MCAST_FLASH_SET_INFO_T;

/**
 * MemoCast Result Val enum.
 */
typedef enum HOA_MCAST_RET_VAL
{
	HOA_MCAST_RET_NOK = -1,
	HOA_MCAST_RET_OK = 0,
	HOA_MCAST_RET_USB_DIS,
	HOA_MCAST_RET_USB_NOFOLDER,
	HOA_MCAST_RET_USB_NOIMG,
	HOA_MCAST_RET_USB_OK,
} HOA_MCAST_RET_VAL_T;

/**
 * Av Setting / EasySetting.
 */
typedef enum HOA_EASYSETTING_T
{
	HOA_NATIVE_EASYSETTING_NONE,
	HOA_NATIVE_EASYSETTING_MOVIE,		/**< MOVIE */
	HOA_NATIVE_EASYSETTING_PHOTO,		/**< PHOTO */
	HOA_NATIVE_EASYSETTING_MUSIC,		/**< MUSIC */
	HOA_NATIVE_EASYSETTING_IDLE,		/**< IDLE */
	HOA_NATIVE_EASYSETTING_AUDIOMENU,	/**< AUDIOMENU */
	HOA_NATIVE_EASYSETTING_MOVIE_ASPECTRATIO,	/**< ASPECT RATIO */
	HOA_NATIVE_EASYSETTING_IDLE_ASPECTRATIO,	/**< ASPECT RATIO */
	HOA_NATIVE_EASYSETTING_NOT_USE, 	/**< CP에서 사용하지 않는 경우 */
	HOA_EASYSETTING_MAX,
} HOA_EASYSETTING_T;

/*
	HOA Caption TYPE
*/
typedef enum HOA_CAPTION_T
{
	HOA_NATIVE_CAPTION_NONE,
	HOA_NATIVE_CAPTION_STOP,
	HOA_NATIVE_CAPTION_MAX,
} HOA_CAPTION_T;


/**
 * device connect/disonnect msg box type.
 */
typedef enum HOA_MSGBOX_T
{
	/** param[0] = type */
	HOA_MSGBOX_HID_CONNECT = 0,		/**< HID device Connect/Disconnect msg , param[1] = MSG_MFS2UI_DEV_ATTACHED or MSG_MFS2UI_DEV_DETACHED, param[2] = devNum*/
	HOA_MSGBOX_LAN_CONNECT = 1,		/**< Lan plug-in/plug-out msg, param[1] = EVENT_ETHERNET_PLUGGED or EVENT_ETHERNET_UNPLUGGED */
	HOA_MSGBOX_WIFI_DONGLE_CONNECT = 2,
	HOA_MSGBOX_MAX,
} HOA_MSGBOX_T;

/**
* home dash board status setting for screen saver(PDP only).
*/
typedef enum HOME_STATUS_T
{
	HOME_STATUS_NONE 	= 0,
	HOME_STATUS_NONE_TV = 1,
	HOME_STATUS_SHOW_TV = 2
}HOME_STATUS_T;

typedef enum HOA_DRAG_MODE_T{
	DRAG_MODE_NONE = 0,
	DRAG_MODE_HORIZONTAL = 1,
	DRAG_MODE_VERTICAL = 2,
}HOA_DRAG_MODE_T;
/**
 * Dimming 상태를 나타냄.
 */
typedef enum
{
	DIMMING_OFF 	= 	0,	/* Dimming Off  : 강제로 백라치트 100 세팅됨. (최대밝기)*/
	DIMMING_LOW 	= 	1,	/* Dimming Low : 강제로 어둡게. */
	DIMMING_HIGH 	= 	2,	/* Dimming High : 사용자가 선택한 값대로. (백라이트)*/

} HOA_DIMMING_STATE_T;


/**
 * DRM Send Message result enumeration for onDRMMessageResult(), specified by OIPF
 */
typedef enum HOA_DRM_MSG_RESULT_CODE {
	HOA_DRM_MSG_RESULT_NONE                   = -1,/**< NONE value */
	HOA_DRM_MSG_RESULT_SUCCESSFUL             = 0, /**< The action(s) requeseted by SendDRMMessage() completed successfully. */
	HOA_DRM_MSG_RESULT_UNKNOWN_ERROR          = 1, /**< SendDRMMessage() failed because an unspecified error occurred. */
	HOA_DRM_MSG_RESULT_CANNOT_PROCESS_REQUEST = 2, /**< SendDRMMessage() failed because the DRM agent was unable to complete the request. */
	HOA_DRM_MSG_RESULT_UNKNOWN_MIMETYPE       = 3, /**< SendDRMMessage() failed because the specified Mime Type is unknown for the specified DRM system indicated in MIME type */
	HOA_DRM_MSG_RESULT_USER_CONSENT_NEEDED    = 4, /**< SendDRMMessage() failed because user consent is needed for that action. */
	HOA_DRM_MSG_RESULT_MAX                         /**< MAX value */
} HOA_DRM_MSG_RESULT_CODE_T;

/**
 * DRM Callback type for onDRMMessageResult(), specified by OIPF
 */
typedef void (*HOA_DRM_MSG_RESULT_CB_T) (char* pszMsgID, char* pszResultMsg, HOA_DRM_MSG_RESULT_CODE_T eResultCode);

/**
 * DRM Rights error enumeration for onDRMRightsError(), specified by OIPF
 */
typedef enum HOA_DRM_RIGHTS_ERR_STATE {
	HOA_DRM_RIGHTS_ERR_NONE            = -1,/**< NONE value */
	HOA_DRM_RIGHTS_ERR_NO_LICENSE      = 0, /**< no license */
	HOA_DRM_RIGHTS_ERR_INVALID_LICENSE = 1, /**< invalid license */
	HOA_DRM_RIGHTS_ERR_MAX                  /**< MAX value */
} HOA_DRM_RIGHTS_ERR_STATE_T;

/**
 * DRM Callback type for onDRMRightsError(), specified by OIPF
 */
typedef void (*HOA_DRM_RIGHTS_ERR_CB_T) (HOA_DRM_RIGHTS_ERR_STATE_T eErrState, char* pszConTentID, char* pszDRMSystemID, char* pszRightsIssureURL);


//////////////////////////////////////////////////////////////////////////////////
// Types for MemoCast(PDP Only)
// End
//////////////////////////////////////////////////////////////////////////////////

/**
 * Eanbled Display callback func type
 */
typedef void (*ENABLED_DISPLAY_CB_T)(SINT32 *pDisplayID);


/**
 * Capture output image format
 */
typedef enum HOA_CAPTURE_FORMAT {
	HOA_CAPTURE_BMP		= 1,
	HOA_CAPTURE_JPEG	= 2,
	HOA_CAPTURE_PNG		= 3,
} HOA_CAPTURE_FORMAT_T;

#ifdef __cplusplus
}
#endif
#endif //_APPFRWK_OPENAPI_TYPES_H_

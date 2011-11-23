/******************************************************************************
 *   DTV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2006 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/

/** @file sdpif_openapi.h
 *
 *  functions list to use libsdpifopenapi.so
 *
 *  @author KyungMee Lee (kyungmee@lge.com)
 *  @version	0.1
 *  @date		created    2011.07.
 */
#ifndef _SDPIF_OPENAPI_H_
#define _SDPIF_OPENAPI_H_

#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************
	File Inclusions
******************************************************************************/
#include <dbus/dbus.h>
#include "appfrwk_openapi_types.h"

/******************************************************************************
	Macro Definitions
******************************************************************************/
#define	MAX_APPS_TYPE	2
#define	PKG_VER_LENGTH	10
#define SI_DEBUG_ERROR(fmt, args...)	AF_DEBUG_ERRTR(fmt, ##args)

/******************************************************************************
	Extern Variables & Function Prototype Declarations
******************************************************************************/

/******************************************************************************
	Global Type Definitions
******************************************************************************/
/**
 * enum list
 */
enum {
	USER_LIST_XML_FMT		= 1,
	USER_LIST_STRUCT_FMT	= 2,

	COUNTRY_FROM_TV			= 3,
	COUNTRY_FROM_SMARTTV	= 4,

	SDPIF_APPS_TYPE_HOT		= 5,
	SDPIF_APPS_TYPE_NEW		= 6,

	APP_TYPE_UNKNOWN		= 10,
	APP_TYPE_NEW,
	APP_TYPE_HOT,

	ACTION_TYPE_UNKNOWN		= 20,
	ACTION_TYPE_CP,
	ACTION_TYPE_APP,
	ACTION_TYPE_FBROWSER,

	NOTICE_TYPE_UNKNOWN		= 30,
	NOTICE_TYPE_GENERAL,
	NOTICE_TYPE_EVENT,

	NOTICE_CONTENT_UNKNOWN	= 40,
	NOTICE_CONTENT_IMG_TXT,
	NOTICE_CONTENT_TXT,
	NOTICE_CONTENT_IMG,
};

/**
 * path type
 */
typedef enum {
	SDPIF_CONFIG_PATH = 0x1,
	SDPIF_BROWSER_CONFIG_PATH,
	SDPIF_CMNDATA_PATH,
	SDPIF_MAINPAGE_PATH,
	SDPIF_NOTICE_PATH,
	SDPIF_HOME_CONFIG_PATH,
} HOA_SDPIF_PATH_T;

/**
 * premium card info
 */
typedef struct _CARD_PREMIUM_ITEM
{
	char	*pCpId;
	char	*pCpName;
	char	*pIconPath;
} HOA_SDPIF_CARD_PREMIUM_ITEM_T;

/**
 * premium card item list
 */
typedef struct _CARD_PREMIUM_INFO
{
	UINT32							numOfItems;
	HOA_SDPIF_CARD_PREMIUM_ITEM_T	*pItems;
} HOA_SDPIF_CARD_PREMIUM_INFO_T;

/**
 * app card info
 */
typedef struct _CARD_APP_ITEM
{
	char	*pIconPath;
	char	*pAppName;
	char	*pAppId;
} HOA_SDPIF_CARD_APPS_ITEM_T;

/**
 * app card type
 */
typedef struct _CARD_APPS
{
	int							type;
	UINT32						numOfItems;
	HOA_SDPIF_CARD_APPS_ITEM_T	*pItems;
} HOA_SDPIF_CARD_APPS_T;

/**
 * apps card list
 */
typedef struct _CARD_APPS_INFO_T
{
	UINT32					numOfTypes;
	HOA_SDPIF_CARD_APPS_T	*pTypes;
} HOA_SDPIF_CARD_APPS_INFO_T;

/**
 * app card info
 */
typedef struct _CARD_APP_INFO
{
	UINT32						numOfItems;
	HOA_SDPIF_CARD_APPS_ITEM_T	*pItems;
} HOA_SDPIF_CARD_APP_INFO_T;

/**
 * user info
 */
typedef struct _USER_INFO
{
	char	*pId;
	char	*pName;
	char	*pGender;
	char	*pBirthDate;
	char	*pEmail;
	char	*pCountryName;
} HOA_SDPIF_USER_INFO_T;

/**
 * from SA libraries
 */
typedef struct _SECRET_INFO
{
	char	*pModelSecret;
	char	*pDevSecret;
} HOA_SDPIF_SECRET_INFO_T;

/**
 * notice
 */
typedef struct _NOTICE_ITEM
{
	char	*pId;
	char	*pTitle;
	char	*pContent;
	char	*pLang;
} HOA_SDPIF_NOTICE_ITEM_T;

/**
 * home dashboard notice list
 */
typedef struct _NOTICE_LIST
{
	UINT32					numOfItems;
	HOA_SDPIF_NOTICE_ITEM_T	*pItems;
} HOA_SDPIF_NOTICE_LIST_T;

#define	MAX_SERVER_NAME	32
#define	MAX_SERVER		10

/**
 * server list
 */
typedef struct _SERVER_LIST
{
	UINT32				numOfServers;
/**
 * server
 */
	struct
	{
		UINT32	index;
		char	serverName[MAX_SERVER_NAME];
	} server[MAX_SERVER];

} HOA_SDPIF_SERVER_LIST_T;

#define	CUR_FLAG	0x80
#define NUM_NETLOGS	100
/**
 * log module index
 */
enum {
	LOGMOD_INVALID		= 0,
	LOGMOD_SDPIF		= 11,
	LOGMOD_APPMANAGER	= 33,
	LOGMOD_APPCLIENT	= 77,
};

/**
 * net log
 */
typedef struct _NETLOG
{
	char	*pModule;
	long	result;
	char	*pErrCode;
} HOA_SDPIF_NETLOG_T;

/**
 * net log list
 */
typedef struct _NETLOG_LIST
{
	UINT32				numOfLogs;
	HOA_SDPIF_NETLOG_T	netLog[NUM_NETLOGS];
} HOA_SDPIF_NETLOG_LIST_T;

/**
 * home card option
 */
typedef struct _SVC_OPT
{
	UINT32	bSearch			:1;
	UINT32	bApps			:1;
	UINT32	bMediaLink		:1;
	UINT32	bSmartMap		:1;
	UINT32	bSocialCenter	:1;
	UINT32	b3dZone			:1;
	UINT32	bChBrowser		:1;
} HOA_SDPIF_SVC_OPT_T;

/**
 * result of purchase
 */
typedef struct _SDPIF_PURCHASE_RESULT
{
	UINT32	retCode;
	char	*pChargeNo;
	char	*pResult;
} HOA_SDPIF_PURCHASE_RESULT_T;

/**
 * purchase type
 */
typedef enum	_PUR_TYPE {
	APP_PURCHASE		= 1,
	IN_APP_PURCHASE		= 2,
} HOA_SDPIF_PUR_TYPE_T;

#define	PRDT_ID_LEN		256
#define	PRDT_NAME_LEN	256
#define	REAL_PUR_LEN	16
#define	CURR_CODE_LEN	4
/**
 * purchase args
 */
typedef struct _PURCHASE
{
	HOA_SDPIF_PUR_TYPE_T		type;			// PURHCASE_APP, PURCHASE_IN_APP
	char						prdtId[PRDT_ID_LEN];
	char						prdtName[PRDT_NAME_LEN];
	char						realPur[REAL_PUR_LEN];
	char						currCode[CURR_CODE_LEN];
	UINT32						purCnt;
	char						*pTheRest;
	double						payAmt;
} HOA_SDPIF_PURCHASE_T;

/**
 * request coupon
 */
typedef struct _REQ_CPN_LIST {
	HOA_SDPIF_PUR_TYPE_T	purType;
	char					*pAppId;
	double					realPurAmt;
	char					*pCurrCode;
} HOA_SDPIF_REQ_CPN_LIST_T;

/**
 * coupon
 */
typedef struct _COUPON {
	char	*pName;
	char	*pNo;
	char	*pType;
	char	*pTypeVal;
	double	dcAmt;
	char	*pDisplayDcAmt;
	double	realPurAmt;
	char	*pDisplayRealPurAmt;
	double	payAmt;
	char	*pDisplayPayAmt;
	UINT32	flag;
} HOA_SDPIF_COUPON_T;

/**
 * coupon list
 */
typedef struct _COUPON_LIST {
	double	realPurAmt;
	char	*pDisplayRealPurAmt;
	double	resCashAmt;
	char	*pDisplayResCashAmt;
	double	noCpnPayAmt;
	char	*pDisplayNoCpnPayAmt;
	double	minAmt;
	char	*pDisplayMinAmt;
	int		noCpnPurFlag;
	UINT32	paymentType;

	UINT32				numOfCoupons;
	HOA_SDPIF_COUPON_T	*pCoupons;
} HOA_SDPIF_COUPON_LIST_T;

/**
 * applied coupon
 */
typedef struct _APPLIED_COUPON {
	char	*pNo;
	double	applyAmt;
} HOA_SDPIF_APPLIED_COUPON_T;

/**
 * err code for billing
 */
typedef enum HOA_SDPIF_PURCHASE_ERRCODE
{
	BILLING_UNKNOWN_ERR		= -1,
	BILLING_INPUT_PARAM_ERR	= 200,
	BILLING_INTERNAL_ERR	= 800,

	SDPIF_PURCHASE_UNKNOWN_ERR	= -1,
	SDPIF_PURCHASE_INVALID_APP_ID	= 401,
	SDPIF_PURCHASE_INVALID_CP_ID	= 402,
	SDPIF_PURCHASE_NOT_FOUND_APP	= 403,
	SDPIF_PURCHASE_BLACK_USER		= 404,
	SDPIF_PURCHASE_ALREADY		= 405,
	SDPIF_PURCHASE_NOT_SUPPORT_HW	= 426,
	SDPIF_PURCHASE_NOT_SUPPORT_SW	= 427,
	SDPIF_PURCHASE_NSU_REQUIRED	= 428,
	SDPIF_LOGIN_BLACKLIST			= 499,
	SDPIF_PURCHASE_USER_NOT_FOUND	= 500,
	SDPIF_PURCHASE_USER_SECEDED	= 501,
	SDPIF_PURCHASE_NOT_FOUND		= 502,
	SDPIF_PURCHASE_CANCELED		= 503,
	SDPIF_PURCHASE_PAY_NOT_FOUND	= 504,
	SDPIF_PURCHASE_PAY_CANCLED	= 505,
	SDPIF_PURCHASE_NOT_REGISTERED	= 506,
	SDPIF_PURCHASE_ALREADY_REGISTERED	= 507,
	SDPIF_PURCHASE_NO_RIGHT		= 508,
	SDPIF_PURCHASE_ALREADY_PAID	= 510,
	SDPIF_PURCHASE_UNDER_LIMIT	= 600,
	SDPIF_PURCHASE_FAIL_REGISTER	= 601,
	SDPIF_PURCHASE_FAIL_REPLACE	= 602,
	SDPIF_PURCHASE_FAIL_DELETE	= 603,
	SDPIF_PURCHASE_FAIL_INQUIRY	= 604,
	SDPIF_PURCHASE_ERR_PAYMENT	= 605,
	SDPIF_PURCHASE_ERR_CANCEL		= 606,
	SDPIF_PURCHASE_EXCEED_MONTH_LIMIT	= 607,
	SDPIF_PURCHASE_EXCEED_1_LIMIT	= 620,
	SDPIF_PURCHASE_NOT_AVAIL_CARD	= 621,
	SDPIF_PURCHASE_INVALID_CARD	= 622,
	SDPIF_PURCHASE_UNREIGISTERD_CARD	= 623,
	SDPIF_PURCHASE_EXCEED_PASSWD	= 624,
	SDPIF_PURCHASE_DISABLE_CARD	= 625,
	SDPIF_PURCHASE_EXPIRED_CARD	= 626,
	SDPIF_PURCHASE_INSUFFICIENT	= 627,
	SDPIF_PURCHASE_EXCEED_LIMIT	= 628,
	SDPIF_PURCHASE_CANCELED_CARD	= 629,
} HOA_SDPIF_PURCHASE_ERRCODE_T;

/**
 * user id list
 */
typedef struct _USER_ID_LIST
{
	UINT32	numOfIds;
	char	**ppUserIdList;
} HOA_SDPIF_USER_ID_LIST_T;

/**
 * result of auth user
 */
typedef struct _SDPIF_AUTH_USER_RESULT
{
	UINT8	age;
	BOOLEAN	bRegular;
} HOA_SDPIF_AUTH_USER_RESULT_T;

#define ADVS_SERVER_URL_LEN			128
#define ADVS_DOMAIN_NAME_LEN		32
#define ADVS_MEMBERSHIP_TARGET_LEN	128
#define ADVS_DEVICE_INFO_LEN		1024
#define ADVS_IAB_CATEGORY_LEN		128
#define ADVS_KVP_LEN				512
#define ADVS_PARAM_LEN			2048

/**
 * adv domain type
 */
typedef enum _HOA_SDPIF_ADVS_DOMAIN_TYPE
{
	ADVS_DOMAIN_UNKNOWN	= -1,

#if 0
	ADVS_DOMAIN_LOADING	= 0,
	ADVS_DOMAIN_LGAPPS,
	ADVS_DOMAIN_SEARCH,
	ADVS_DOMAIN_SEARCH_RESULT,
	ADVS_DOMAIN_INAPP_FLASH_728x90,
	ADVS_DOMAIN_INAPP_FLASH_300x250,
	ADVS_DOMAIN_INAPP_BROWSER,
	ADVS_DOMAIN_INAPP_PLEX,
	ADVS_DOMAIN_VIDEO_FLASH,
	ADVS_DOMAIN_VIDEO_BROWSER,
	ADVS_DOMAIN_VIDEO_PLEX,
	ADVS_DOMAIN_HOME,
	ADVS_DOMAIN_MYAPPS,
	ADVS_DOMAIN_PREMIUM,
#endif

	// portal AD
	ADVS_DOMAIN_LOADING	= 0,
	ADVS_DOMAIN_HOMELIVECARD,
	ADVS_DOMAIN_MYAPPS,
	ADVS_DOMAIN_LGAPPS,
	ADVS_DOMAIN_PREMIUM,
	ADVS_DOMAIN_SEARCH,
	ADVS_DOMAIN_SEARCH_RESULT,

	// inApp AD
	ADVS_DOMAIN_INAPP_FLASH_BANNER,
	ADVS_DOMAIN_INAPP_BROWSER_BANNER,
	ADVS_DOMAIN_INAPP_PLEX_BANNER,
	ADVS_DOMAIN_INAPP_FLASH_PREROLL,
	ADVS_DOMAIN_INAPP_BROWSER_PREROLL,
	ADVS_DOMAIN_INAPP_PLEX_PREROLL,
	ADVS_DOMAIN_INAPP_FLASH_POSTROLL,
	ADVS_DOMAIN_INAPP_BROWSER_POSTROLL,
	ADVS_DOMAIN_INAPP_PLEX_POSTROLL,

	ADVS_DOMAIN_MAX,
} HOA_SDPIF_ADVS_DOMAIN_TYPE_T;

/**
 * advs info
 */
typedef struct HOA_SDPIF_ADVS_INFO
{
	char	serverURL[ADVS_SERVER_URL_LEN];
	char	domainName[ADVS_DOMAIN_NAME_LEN];
	char	membershipTarget[ADVS_MEMBERSHIP_TARGET_LEN];
	char	deviceInfo[ADVS_DEVICE_INFO_LEN];

	BOOLEAN	bPlexBannerEnable;
	BOOLEAN	bPlexPrerollEnable;
	BOOLEAN	bPlexPostrollEnable;

	char	IABCategory[ADVS_IAB_CATEGORY_LEN];
	char	KVPStr[ADVS_KVP_LEN];
} HOA_SDPIF_ADVS_INFO_T;

typedef struct HOA_AD_BANNER_URL_OUT
{
    UINT32        	result;
    SINT32        	errCode;
    UINT32        	apptype;
    UINT32        	imagesCount;
    UINT32        	bannersCount;
    UINT32        	timelineEventsCount;
    UINT32        	timelineEventType;
    UINT32        	*pTimelineArray;
    UINT32        	eventId;
    UINT32        	leaveUpLastFrame;
    UINT32        	clickType;
    char			*pClickTarget;
    char			*pClickValue;
    char           	*pUrl;	// same as pClickTag
    char           	*pClickUrl;
} HOA_AD_BANNER_URL_OUT_T;

/**
 * terms type
 */
typedef enum _TERMS_TYPE {
	TEEMS_TYPE_INVALID,

	APP_SVC_TERMS,
	APP_PRV_TERMS,
	SMART_SVC_TERMS,

	TEEMS_TYPE_LAST
} HOA_SDPIF_TERMS_TYPE_T;

/**
 * banner notice
 */
typedef struct _BANNER_ITEM
{
	BOOLEAN	bEnable;
	int		type;
	char	*pId;
	char	*pTitle;
	char	*pDate;
	char	*pLang;
	int		action;
	char	*pActionExec;
} HOA_SDPIF_BANNER_ITEM_T;

/**
 * home dashboard banner notice list
 */
typedef struct _BANNER_LIST
{
	UINT32					numOfItems;
	HOA_SDPIF_BANNER_ITEM_T	*pItems;
} HOA_SDPIF_BANNER_LIST_T;

/**
 * detail notice
 */
typedef struct _DETAIL_NOTICE_INFO
{
	char	*pTitle;
	char	*pDate;
	char	*pLang;
	int		type;
	char	*pContent;
	char	*pImgPath;
	int		action;
	char	*pActionExec;
} HOA_SDPIF_NOTICE_INFO_T;

/**
 * category
 */
typedef struct _APP_CATEGORY
{
	int		id;
	char	*pName;
} HOA_SDPIF_APP_CATEGORY_T;

/**
 * recommend category list
 */
typedef struct _APP_CATEGORY_LIST
{
	UINT32						numOfCategorys;
	HOA_SDPIF_APP_CATEGORY_T	*pCategorys;
} HOA_SDPIF_APP_CATEGORY_LIST_T;

/******************************************************************************
	Static Variables & Function Prototypes Declarations
******************************************************************************/

/******************************************************************************
	Global Variables & Function Prototypes Declarations
******************************************************************************/
/* - env - */
extern HOA_STATUS_T	HOA_SDPIF_TestAlive(void);
extern HOA_STATUS_T	HOA_SDPIF_PreInitialize(void);
extern HOA_STATUS_T	HOA_SDPIF_Initialize(void);
extern HOA_STATUS_T	HOA_SDPIF_NotifyNetworkReady(void);
extern HOA_STATUS_T	HOA_SDPIF_NotifyNetworkError(void);
extern HOA_STATUS_T	HOA_SDPIF_ClearData(void);

/* - premium & home dashboard - */
extern HOA_STATUS_T	HOA_SDPIF_CheckPkgVersion(void *pfnCallback);
extern HOA_STATUS_T	HOA_SDPIF_CheckPremium(void *pfnCallback);
extern HOA_STATUS_T	HOA_SDPIF_CheckHomeDashboard(void *pfnCallback);
extern HOA_STATUS_T	HOA_SDPIF_SyncServer(void *pfnCallback);
extern HOA_STATUS_T	HOA_SDPIF_GetCurrentPath(HOA_SDPIF_PATH_T type, char **ppPath );
extern HOA_STATUS_T	HOA_SDPIF_GetPremiumCardInfo(HOA_SDPIF_CARD_PREMIUM_INFO_T *pCard);
extern HOA_STATUS_T	HOA_SDPIF_DestroyPremiumCardInfo(HOA_SDPIF_CARD_PREMIUM_INFO_T *pCard);
extern HOA_STATUS_T	HOA_SDPIF_GetAppsCardInfo(HOA_SDPIF_CARD_APPS_INFO_T *pCard);
extern HOA_STATUS_T	HOA_SDPIF_DestroyAppsCardInfo(HOA_SDPIF_CARD_APPS_INFO_T *pCard);
extern HOA_STATUS_T	HOA_SDPIF_GetVersion(char *pCpId, char **ppCpVer, char **ppPlatformVer);
extern char * 		HOA_SDPIF_GetPackageVer(void);
extern HOA_STATUS_T HOA_SDPIF_RequestPkgsWithVer(char *pVer, void *pfnCallback);
extern HOA_STATUS_T	HOA_SDPIF_GetPremiumList(HOA_SDPIF_CARD_PREMIUM_INFO_T *pInfo);
extern HOA_STATUS_T	HOA_SDPIF_GetHomeIconPath(char *pCpId, char **ppIconPath);
extern HOA_STATUS_T	HOA_SDPIF_RequestResetCp(char *pCpId, void *pfnCallback);
extern HOA_STATUS_T	HOA_SDPIF_RequestRefreshAppIcon(char  *pAppId, void  *pfnCallback);
extern HOA_STATUS_T HOA_SDPIF_GetUrl(char *pCpId, char **ppUrl);
extern BOOLEAN 		HOA_SDPIF_CheckUpdateStatus(void );
extern HOA_STATUS_T	HOA_SDPIF_GetCurrentCpList(char **ppList);
extern HOA_STATUS_T	HOA_SDPIF_GetRollbackPath(HOA_SDPIF_PATH_T type, char **ppPath);
extern HOA_STATUS_T	HOA_SDPIF_GetNoticeList(HOA_SDPIF_NOTICE_LIST_T *pList);
extern HOA_STATUS_T	HOA_SDPIF_DestroyNoticeList(HOA_SDPIF_NOTICE_LIST_T *pList);
extern HOA_STATUS_T	HOA_SDPIF_GetServiceOption(HOA_SDPIF_SVC_OPT_T	*pOpt);
extern HOA_STATUS_T	HOA_SDPIF_CheckMyApps(void *pfnCallback);
extern HOA_STATUS_T	HOA_SDPIF_GetAppCardInfo(int type, int fromIndex, int count, HOA_SDPIF_CARD_APP_INFO_T	*pInfo);
extern HOA_STATUS_T	HOA_SDPIF_DestroyAppCardInfo(HOA_SDPIF_CARD_APP_INFO_T *pCard);
extern HOA_STATUS_T	HOA_SDPIF_Convert2AppIndex(char	*pData, int	*pType, int	*pIndex);
extern HOA_STATUS_T	HOA_SDPIF_RequestAddableCardList(void *pfnCallback);
extern HOA_STATUS_T	HOA_SDPIF_RequestDetailNotice(void *pfnCallback);
extern HOA_STATUS_T	HOA_SDPIF_GetBannerList(HOA_SDPIF_BANNER_LIST_T *pList);

/* - membership - */
extern HOA_STATUS_T	HOA_SDPIF_RequestCheckUserId(char *pUserId, void  *pfnCallback);
extern HOA_STATUS_T HOA_SDPIF_RequestRegisterUser(char *pUserId, char *pPasswd, void *pfnCallback);
extern HOA_STATUS_T HOA_SDPIF_RequestSignIn(char *pUserId, char *pPasswd, BOOLEAN bAuto, void *pfnCallback);
extern HOA_STATUS_T	HOA_SDPIF_RequestSignOut(void *pfnCallback);
extern HOA_STATUS_T HOA_SDPIF_GetCurrentUserInfo(HOA_SDPIF_USER_INFO_T *pInfo);
extern HOA_STATUS_T	HOA_SDPIF_FreeUserInfo(HOA_SDPIF_USER_INFO_T *pInfo);
extern HOA_STATUS_T	HOA_SDPIF_GetUserSession(char **ppSession);
extern HOA_STATUS_T HOA_SDPIF_RequestUserList(UINT32 format, void *pfnCallback);
extern HOA_STATUS_T HOA_SDPIF_RequestDeactivateUser(char *pUserId, void *pfnCallback);
extern BOOLEAN		HOA_SDPIF_IsSignedIn(void);
extern HOA_STATUS_T HOA_SDPIF_RequestAuthUser(char *pUserId, char *pPasswd, void *pfnCallback);
extern HOA_STATUS_T HOA_SDPIF_RequestExtendUserSession(void * pfnCallback);
extern HOA_STATUS_T	HOA_SDPIF_CheckTerms(void *pfnCallback);
extern HOA_STATUS_T	HOA_SDPIF_AgreeTerms(HOA_SDPIF_TERMS_TYPE_T type, void *pfnCallback);
extern BOOLEAN		HOA_SDPIF_IsAgreed(HOA_SDPIF_TERMS_TYPE_T type);
extern HOA_STATUS_T HOA_SDPIF_GetCurrentTerms(HOA_SDPIF_TERMS_TYPE_T type, char **ppPath);
extern HOA_STATUS_T	HOA_SDPIF_GetUserIdList(HOA_SDPIF_USER_ID_LIST_T *pList);
extern HOA_STATUS_T HOA_SDPIF_GetCurrentUserId(char	*pUserId, int size);
extern HOA_STATUS_T	HOA_SDPIF_Convert2AuthResult(char *pData, HOA_SDPIF_AUTH_USER_RESULT_T *pResult);
extern HOA_STATUS_T HOA_SDPIF_RequestChangePasswd(char *pOldPasswd, char *pNewPasswd, void *pfnCallback);
extern HOA_STATUS_T HOA_SDPIF_RequestDeleteUser(char *pPasswd, void *pfnCallback);
extern BOOLEAN		HOA_SDPIF_IsRegularMember(void);
extern int			HOA_SDPIF_GetAge(void);

/* - setting (country & language) - */
extern HOA_STATUS_T	HOA_SDPIF_RequestDetectCountry(void *pfnCallback);
extern HOA_STATUS_T	HOA_SDPIF_GetCurrentCountryWith2Ciphers(char **ppCode);
extern HOA_STATUS_T	HOA_SDPIF_GetCurrentCountryWith3Ciphers(char **ppCode);
extern HOA_STATUS_T	HOA_SDPIF_NotifyCountryChanged(int type, char *pCode2, char *pCode3);
extern HOA_STATUS_T	HOA_SDPIF_NotifyLangChanged(UINT32	code);

/* - device auth & request header - */
extern HOA_STATUS_T	HOA_SDPIF_RequestDeviceAuth(void *pfnCallback);
extern HOA_STATUS_T	HOA_SDPIF_RequestCancelDeviceAuth(void *pfnCallback);
extern HOA_STATUS_T	HOA_SDPIF_GetSecretInfo(HOA_SDPIF_SECRET_INFO_T *pInfo);

extern HOA_STATUS_T	HOA_SDPIF_GetHttpRequestHeaderVariablePart(char **ppHeader);
extern HOA_STATUS_T	HOA_SDPIF_GetHttpRequestHeaderFixedPart(char **ppHeader);
extern HOA_STATUS_T	HOA_SDPIF_GetHttpRequestHeader(char **ppHeader);

/* - server - */
extern HOA_STATUS_T	HOA_SDPIF_ChangeServer(UINT32 index);
extern HOA_STATUS_T HOA_SDPIF_GetCurrentServerUrl(char **ppServerUrl);
extern UINT32		HOA_SDPIF_GetCurrentServerIndex(void);
extern HOA_STATUS_T	HOA_SDPIF_GetServerList(HOA_SDPIF_SERVER_LIST_T *pList);
extern HOA_STATUS_T	HOA_SDPIF_SetPublishFlag(BOOLEAN bFlag);
extern HOA_STATUS_T	HOA_SDPIF_GetPublishFlag(BOOLEAN *pbFlag);
extern HOA_STATUS_T	HOA_SDPIF_SetAppPublishFlag(BOOLEAN	bFlag);
extern HOA_STATUS_T	HOA_SDPIF_GetAppPublishFlag(BOOLEAN	*pbFlag);

/* - error log  - */
extern HOA_STATUS_T	HOA_SDPIF_GetNetLogs(HOA_SDPIF_NETLOG_LIST_T *pList);
extern HOA_STATUS_T	HOA_SDPIF_UpdateErrLog(int module, long result, char *pErrResult);

/* - SNS - */
extern HOA_STATUS_T HOA_SDPIF_RemoveDeactivateUserSNS(	char *pSNSType, char *pSNSID, void *pfnCallback);
extern HOA_STATUS_T HOA_SDPIF_RequestUserSNSInfo(char *pLGID, char *pPasswd, void *pfnCallback);
extern int 			HOA_SDPIF_IsAutoSNSLogin(char *pSNSType, char * pSNSID);
extern HOA_STATUS_T HOA_SDPIF_RequestRegisterSNSUser(char *pSNSType, char *pSNSID, int SNSAuto, char *pToken, void  *pfnCallback);
extern int 			HOA_SDPIF_IsExistSNSUser(char* pSNSType, char * pSNSID);

/* - billing - */
extern HOA_STATUS_T	HOA_SDPIF_GetBillingDeviceId(char **ppDeviceId);
extern HOA_STATUS_T	HOA_SDPIF_RequestPurchase(HOA_SDPIF_PURCHASE_T *pPurchase, HOA_SDPIF_APPLIED_COUPON_T *pCoupon, void *pfnCallback );
extern HOA_STATUS_T	HOA_SDPIF_RequestCouponList(HOA_SDPIF_REQ_CPN_LIST_T *pReq, void *pfnCallback);
extern HOA_STATUS_T	HOA_SDPIF_GetCouponList(HOA_SDPIF_COUPON_LIST_T *pList);
extern HOA_STATUS_T	HOA_SDPIF_FreeCouponList(HOA_SDPIF_COUPON_LIST_T *pList);
extern HOA_STATUS_T	HOA_SDPIF_Convert2PurResult(char*pData, HOA_SDPIF_PURCHASE_RESULT_T	*pResult);
extern HOA_STATUS_T	HOA_SDPIF_FreePurchaseResult(HOA_SDPIF_PURCHASE_RESULT_T *pResult);

/* - Advertisement - */
extern HOA_STATUS_T HOA_SDPIF_RequestADUrl(int apptype,char *pAddparam,int isCached, int adType, int duration, int midrollNumber, void *pfnCallback);	// roll_position : pre, mid, post
extern HOA_STATUS_T HOA_SDPIF_NotifyADBannerClicked(int apptype, void *pfnCallback);
extern HOA_STATUS_T HOA_SDPIF_NotifyADPlaybackFinished(int apptype);
extern HOA_STATUS_T HOA_SDPIF_NotifyADTimelineEvent(int apptype, int timeline);
extern HOA_STATUS_T HOA_SDPIF_NotifyADEnded(int apptype);
#if 0
extern HOA_STATUS_T HOA_SDPIF_RequestADVideoUrl(int apptype,int position, int duration, void *pfnCallback);
#endif

/* - App Store - */
extern HOA_STATUS_T	HOA_SDPIF_ProvisionDevice(void);
extern HOA_STATUS_T	HOA_SDPIF_IsPaid(void);
extern HOA_STATUS_T	HOA_SDPIF_GetRecommCategoryList(HOA_SDPIF_APP_CATEGORY_LIST_T *pList);
extern HOA_STATUS_T	HOA_SDPIF_FreeCategoryList(HOA_SDPIF_APP_CATEGORY_LIST_T *pList);

/* - etc - */
extern HOA_STATUS_T HOA_SDPIF_RequestDeactivateDevice(void *pfnCallback);
extern HOA_STATUS_T	HOA_SDPIF_FreeMemory(void **ppMem);
extern HOA_STATUS_T	HOA_SDPIF_RegisterCallback(SDPIF_CB_TYPE_T type, SDPIF_CB_T pfnCallback);
extern HOA_STATUS_T	HOA_SDPIF_GetMacAddr(char *pBUf, int size);
extern HOA_STATUS_T	HOA_SDPIF_RequestMetaData(char *pQuery, int  *pIndex, void *pfnCallback);
#ifdef __cplusplus
}
#endif

#endif	//ifndef _SDPIF_OPENAPI_H_

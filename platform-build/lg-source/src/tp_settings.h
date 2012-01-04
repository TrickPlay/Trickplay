#ifndef __TP_SETTINGS_H__
#define __TP_SETTINGS_H__

//#define SUPPORT_FULLHD_RES 1
/* width and height of graphics plane. */
//#if SUPPORT_FULLHD_RES
#define TRICKPLAY_SCREEN_WIDTH				1920
#define TRICKPLAY_SCREEN_HEIGHT				1080
//#else
//#define TRICKPLAY_SCREEN_WIDTH				1280
//#define TRICKPLAY_SCREEN_HEIGHT				720
//#endif

/* whether the display is stretched to full screen size. */
#define TRICKPLAY_STRETCH_TO_SCREEN			1

/* path settings */
#define TRICKPLAY_DRM_DECRYPTED_BASE_PATH	"/tmp/trickplay"
#define TRICKPLAY_FONTS_PATH				"/mnt/lgfont"
#define TRICKPLAY_DATA_PATH					"/mnt/lg/cmn_data"

/* This is used when we want to show list of apps on TrickPlay launcher */
#define TRICKPLAY_SCAN_APP_SOURCES			"TRUE"

#endif


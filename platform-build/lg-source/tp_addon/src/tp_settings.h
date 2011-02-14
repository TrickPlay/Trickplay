#ifndef __TP_SETTINGS_H__
#define __TP_SETTINGS_H__

// minimum requirement for system memory
#define TRICKPLAY_REQUIRED_SYSTEM_MEMORY	(50 * 1024 * 1024)	// 50MB
// minimum requirement for graphics memory
#define TRICKPLAY_REQUIRED_GRAPHIC_MEMORY	(50 * 1024 * 1024)	// 50MB

// maximum width of graphics plane.
#define TRICKPLAY_SCREEN_WIDTH				960
// maximum height of graphics plane.
#define TRICKPLAY_SCREEN_HEIGHT				540
// whether the display is stretched to full screen size.
#define TRICKPLAY_STRETCH_TO_SCREEN			1

// path settings
#define TRICKPLAY_DRM_DECRYPTED_BASE_PATH	"/tmp/trickplay"
#define TRICKPLAY_FONTS_PATH				"/mnt/lgfont"
#define TRICKPLAY_DATA_PATH					"/mnt/lg/cmn_data"

// This is used when we want to show list of apps on TrickPlay launcher
#define TRICKPLAY_SCAN_APP_SOURCES			"FALSE"

#endif


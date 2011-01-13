#ifndef __TP_SETTINGS_H__
#define __TP_SETTINGS_H__

// minimum requirement for system memory
#define TRICKPLAY_REQUIRED_SYSTEM_MEMORY	(45 * 1024 * 1024)	// 45MB
// minimum requirement for graphics memory
#define TRICKPLAY_REQUIRED_GRAPHIC_MEMORY	(50 * 1024 * 1024)	// 45MB

// DRM 복호화 한 app을 임시로 생성할 디렉토리
#define TRICKPLAY_DRM_DECRYPTED_PATH		"/tmp/trickplay"
// 사용할 font가 위치한 디렉토리
#define TRICKPLAY_FONTS_PATH				"/mnt/lgfont"
// 설정값 등의 데이터가 저장될 경로 (해당 디렉토리에 'trickplay' 서브 디렉토리 생성)
#define TRICKPLAY_DATA_PATH					"/mnt/lg/cmn_data"
// TRICKPLAY_APP_SOURCES에 지정된 디렉토리에서 app들을 검색할 것인지 여부
#define TRICKPLAY_SCAN_APP_SOURCES			"0"

// 스크린 너비. maximum width of graphics plane.
#define TRICKPLAY_SCREEN_WIDTH				960
// 스크린 높이. maximum height of graphics plane.
#define TRICKPLAY_SCREEN_HEIGHT				540
// 화면 사이즈로 확대 여부. (0: not stretch to fit, 1: stretch to full screen)
#define TRICKPLAY_STRETCH_TO_SCREEN			1

#endif


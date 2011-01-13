#ifndef __TP_SETTINGS_H__
#define __TP_SETTINGS_H__

// minimum requirement for system memory
#define TRICKPLAY_REQUIRED_SYSTEM_MEMORY	(45 * 1024 * 1024)	// 45MB
// minimum requirement for graphics memory
#define TRICKPLAY_REQUIRED_GRAPHIC_MEMORY	(50 * 1024 * 1024)	// 45MB

// DRM ��ȣȭ �� app�� �ӽ÷� ������ ���丮
#define TRICKPLAY_DRM_DECRYPTED_PATH		"/tmp/trickplay"
// ����� font�� ��ġ�� ���丮
#define TRICKPLAY_FONTS_PATH				"/mnt/lgfont"
// ������ ���� �����Ͱ� ����� ��� (�ش� ���丮�� 'trickplay' ���� ���丮 ����)
#define TRICKPLAY_DATA_PATH					"/mnt/lg/cmn_data"
// TRICKPLAY_APP_SOURCES�� ������ ���丮���� app���� �˻��� ������ ����
#define TRICKPLAY_SCAN_APP_SOURCES			"0"

// ��ũ�� �ʺ�. maximum width of graphics plane.
#define TRICKPLAY_SCREEN_WIDTH				960
// ��ũ�� ����. maximum height of graphics plane.
#define TRICKPLAY_SCREEN_HEIGHT				540
// ȭ�� ������� Ȯ�� ����. (0: not stretch to fit, 1: stretch to full screen)
#define TRICKPLAY_STRETCH_TO_SCREEN			1

#endif


/******************************************************************************
 *   Software Center, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 1999 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/

/** @file addon_hoa.h
 *
 *  HOA function & related data definition
 *
 *  @author     Meekyung Lim(mimir@lge.com)
 *  @version    1.0
 *  @date       2008.12.29
 *  @note		Please refer to SGP_TD_HOA_K0-(V.1.0).doc for further information
 *  @see
 */

#ifndef __ADDON_HOA_H__
#define __ADDON_HOA_H__

#include "addon_ver.h"

#ifdef __cplusplus
extern "C" {
#endif

#ifndef MAXFILENAME
#define MAXFILENAME (256)
#endif

#ifndef MAXCHANNELNAME
#define MAXCHANNELNAME	64
#endif //MAXCHANNELNAME

#define MAXSFFILTERLEN	0x09

#define HOA_SDPVERSION_LEN 32

#define HOA_BSIPRINT_MAXLEN 4096

/**
 * HOA API의 Return type.
 *
 */
typedef enum {
	HOA_OK					= 0,	/**< HOA 함수가 성공적으로 수행 */
	HOA_HANDLED				= 0,	/**< 주어진 요청사항에 대한 처리를 완료함 */
	HOA_ERROR				= -1,	/**< 함수 수행 중 에러 발생 */
	HOA_NOT_HANDLED			= -1,	/**< 주어진 요청사항에 대한 처리를 하지 않음 */
	HOA_BLOCKED				= -2,	/**< 다른 App.가 HOA를 독점적으로 사용하고 있어 수행되지 않음 */
	HOA_INVALID_PARAMS		= -3,	/**< 함수 인자에 잘못된 값이 들어있음 */
	HOA_NOT_ENOUGH_MEMORY	= -4,	/**< 메모리가 함수를 수행할 수 있을 만큼 충분하지 않음 */
	HOA_TIMEOUT				= -5,	/**< 함수 수행 요청 후 일정 시간 내에 답이 오지 않음 */
	HOA_NOT_SUPPORTED		= -6,	/**< 버전 차이 등으로 인해 지원되지 않는 함수임 */
	HOA_BUFFER_FULL			= -7,	/**< 버퍼에 데이터가 가득 차있어 함수가 수행되지 않음  */
	HOA_HOST_NOT_CONNECTED	= -8,	/**< Host가 연결되어 있지 않아 함수가 수행되지 않음  */
	HOA_VERSION_MISMATCH	= -9,	/**< App.와 library간에 버전이 맞지 않아 수행되지 않음 */
	HOA_ALREADY_REGISTERED	= -10,	/**< App.가 이미 Manager에 등록되어 있음 */
	HOA_LAST
} HOA_STATUS_T;

/**
 * Update Controller의 Return type.
 *
 */
typedef enum {
	HOA_UC_OK					= 0,	/**< HOA 함수가 성공적으로 수행 */
	HOA_UC_HANDLED				= 0,	/**< 주어진 요청사항에 대한 처리를 완료함 */
	HOA_UC_ERROR				= -1,	/**< 함수 수행 중 에러 발생 */
	HOA_UC_NOT_HANDLED			= -1,	/**< 주어진 요청사항에 대한 처리를 하지 않음 */
	HOA_UC_BLOCKED				= -2,	/**< 다른 App.가 HOA를 독점적으로 사용하고 있어 수행되지 않음 */
	HOA_UC_INVALID_PARAMS		= -3,	/**< 함수 인자에 잘못된 값이 들어있음 */
	HOA_UC_NOT_ENOUGH_MEMORY	= -4,	/**< 메모리가 함수를 수행할 수 있을 만큼 충분하지 않음 */
	HOA_UC_TIMEOUT				= -5,	/**< 함수 수행 요청 후 일정 시간 내에 답이 오지 않음 */
	HOA_UC_NOT_SUPPORTED		= -6,	/**< 버전 차이 등으로 인해 지원되지 않는 함수임 */
	HOA_UC_BUFFER_FULL			= -7,	/**< 버퍼에 데이터가 가득 차있어 함수가 수행되지 않음  */
	HOA_UC_HOST_NOT_CONNECTED	= -8,	/**< Host가 연결되어 있지 않아 함수가 수행되지 않음  */
	HOA_UC_VERSION_MISMATCH	= -9,	/**< App.와 library간에 버전이 맞지 않아 수행되지 않음 */
	HOA_UC_ALREADY_REGISTERED	= -10,	/**< App.가 이미 Manager에 등록되어 있음 */
	HOA_UC_LAST
} HOA_UC_STATUS_T;


/**
 * Message의 종류
 */
typedef enum MSG_TYPE
{
	HOA_MSG_NONE,					/**< 메세지 없음 */
	HOA_MSG_FOCUS_IN,				/**< Focus in.\n
											submsg : 0,\n
											pData : NULL,\n
											dataSize : 0.
									*/
	HOA_MSG_FOCUS_OUT,				/**< Focus out.\n
											submsg : 0,\n
											pData : NULL,\n
											dataSize : 0.
									*/
	HOA_MSG_EXECUTE,				/**< 이미 실행중인 프로그램에 대해 다시 한번 실행 요청이 올 경우 실행 파라메터를 전달해 준다.\n
											submsg : 0,\n
											pData : 실행 argument. NULL로 끝나도록 처리되어 있음,\n
											dataSize : string length of argument.
									*/
	HOA_MSG_TERMINATE,				/**< Application 종료 요청.\n
											submsg : 0,\n
											pData : NULL,\n
											dataSize : 0.
									*/
	HOA_MSG_HOST_EVENT,				/**< Host에서 보낸 Event 알림.\n
											submsg : ADDON_HOST_EVENT_T,\n
											pData : UINT32 size의 data,\n
											dataSize : sizeof(UINT32).
									*/
	HOA_MSG_USER,					/**< Host에서 특정 Add-on App.로 보내는 custom message.\n
											submsg : customized message ID,\n
											pData : customized Data,\n
											dataSize : size of customized Data.
									*/
	HOA_MSG_OTHERAPPSTATUSCHANGED,	/**< 프로그램이 실행을 요청한 다른 프로그램의 상태가 변경될 경우 알림.\n
											submsg : 0, \n
											pData : pointer of HOA_APP_PID_STATUS_T,\n
											dataSize : size of (HOA_APP_PID_STATUS_T)
									*/
	HOA_MSG_STOPLOADING,			/**< 프로그램이 로딩중일 때, 로딩을 멈추도록 함.\n
											submsg : 0,\n
											pData : NULL,\n
											dataSize : 0.
									*/
	//sophia
	HOA_MSG_UC_EVENT,				/**< Update Contoller에서 보낸 Event 및 Progress Rate 알림.\n
											submsg : 0, \n
											pData : pointer of HOA_UC_EVENT_T,\n
											dataSize : size of (HOA_UC_EVENT_T)
									*/
	HOA_MSG_APP_EXITCODE,			/**< App.이 ExitCode를 주고 종료시, App.의 수행을 요청한 App.에게 ExitCode를 전달 \n
											submsg : 0, \n
											pData : pointer of ADDON_EXITCODE_T,\n
											dataSize : size of (ADDON_EXITCODE_T)
									*/
	HOA_MSG_LAST
} HOA_MSG_TYPE_T;

typedef ADDON_RESOURCE_TYPE_T	HOA_RESOURCE_TYPE_T;
typedef ADDON_APP_STATE_T		HOA_APP_STATE_T;

//sophia
typedef ADDON_UC_EVENT_T		HOA_UC_EVENT_T;
typedef ADDON_UC_EVENT_TYPE_T	HOA_UC_EVENT_TYPE_T;
typedef ADDON_HOST_INFO_T		HOA_HOST_INFO_T;


/**
 * To Mask APP DEBUG MSG
 */
typedef enum HOA_APP_DEBUG_MASK
{
	HOA_DEBUG_MASK_APP1,		/**< APP1 BIT INDEX */
	HOA_DEBUG_MASK_APP2,		/**< APP2 BIT INDEX */
	HOA_DEBUG_MASK_APP3,		/**< APP3 BIT INDEX */
	HOA_DEBUG_MASK_APP4,		/**< APP4 BIT INDEX */
	HOA_DEBUG_MASK_APP5,		/**< APP5 BIT INDEX */
	HOA_DEBUG_MASK_APP6,		/**< APP6 BIT INDEX */
	HOA_DEBUG_MASK_APP7,		/**< APP7 BIT INDEX */
	HOA_DEBUG_MASK_APP8,		/**< APP8 BIT INDEX */
	HOA_DEBUG_MASK_APP9,		/**< APP9 BIT INDEX */
	HOA_DEBUG_MASK_APP10,		/**< APP10 BIT INDEX */
	HOA_DEBUG_MASK_APP11,		/**< APP11 BIT INDEX */
	HOA_DEBUG_MASK_APP12,		/**< APP12 BIT INDEX */
	HOA_DEBUG_MASK_APP13,		/**< APP13 BIT INDEX */
	HOA_DEBUG_MASK_APP14,		/**< APP14 BIT INDEX */
	HOA_DEBUG_MASK_APP15,		/**< APP15 BIT INDEX */
	HOA_DEBUG_MASK_APP16,		/**< APP16 BIT INDEX */

	HOA_DEBUG_MASK_APP_LAST
}HOA_DEBUG_MASK_T;

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
}HOA_AUDIO_SAMPLERATE_T;

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
	MEDIA_AUDIO_CDDA	= 0x05,		/**< cdda codec */
	MEDIA_AUDIO_PCM		= 0x06,		/**< pcm codec */
	MEDIA_AUDIO_LBR		= 0x07,		/**< lbr codec */
	MEDIA_AUDIO_WMA		= 0x08,		/**< wma codec */
	MEDIA_AUDIO_DTS		= 0x09,		/**< dts codec */
	MEDIA_AUDIO_AC3PLUS	= 0x0A,		/**< ac3 plus codec */

	MEDIA_AUDIO_MASK	= 0x0F		/**< Audio codec mask */
} MEDIA_CODEC_AUDIO_T;

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

	MEDIA_VIDEO_MASK	= 0xF0		/**< Video codec mask */
} MEDIA_CODEC_VIDEO_T;

/**
 * This enumeration describes image codec of media.
 *
 */
typedef enum MEDIA_CODEC_IMAGE
{
	MEDIA_IMAGE_NONE	= 0x00,		/**< No Image */
	MEDIA_IMAGE_ANY		= 0x00,		/**< Any Image codec */

	MEDIA_IMAGE_JPEG	= (0x01<<8),	/**< jpeg codec */
	MEDIA_IMAGE_PNG		= (0x02<<8),	/**< png codec */

	MEDIA_IMAGE_MASK	= (0x0F<<8)		/**< Image codec mask */
} MEDIA_CODEC_IMAGE_T;

/**
 * Type definition of Media Codec.
 * MEDIA_CODEC_T는 MEDIA_CODEC_AUDIO_T, MEDIA_CODEC_VIDEO_T, MEDIA_CODEC_IMAGE_T의 ORing을 통해 나타낸다.
 *
 */
typedef UINT32 	MEDIA_CODEC_T;

/**
 * This enumeration describes transport types of media.
 * 전송 방식에 대한 정의이다.
 * 크게 Media Buffer를 사용하는 경우와 그 외의 경우 둘로 나누어지며
 * Media Buffer를 사용할 경우에는 MEDIA_TRANS_BUFFER를,
 * 그 외의 경우에는 전송 방식에 따라 MEDIA_TRANS_FILE, MEDIA_TRANS_DLNA, MEDIA_TRANS_YOUTUBE를 선택한다.
 *
 */
typedef enum MEDIA_TRANSPORT
{
	MEDIA_TRANS_FILE	= 0x01,		/**< File. File Play시 선택. */
	MEDIA_TRANS_DLNA	= 0x02,		/**< DLNA. File Play시 선택. */
	MEDIA_TRANS_YOUTUBE	= 0x03,		/**< YouTube. File Play시 선택. */
	MEDIA_TRANS_YAHOO	= 0x04,		/**< Yahoo Video. File Play시 선택. */
	MEDIA_TRANS_HTTP_DOWNLOAD	= 0x05,		/**< HTTP Progressive download play시 선택. */
	MEDIA_TRANS_MSDL	= 0x06,		/**< MSDL을 이용한 play시 선택. */
	MEDIA_TRANS_MSDL_ONESHOT	= 0x07,		/**< MSDL OneShot URL을 이용한 play시 선택. */
	MEDIA_TRANS_MSDL_LOCAL_MEDIA	= 0x08,		/**< Media Link, DLNA등 Local 망의 미디어를 play시 선택. */
	MEDIA_TRANS_BUFFERCLIP		= 0x10,		/**< Clip Buffer Play시 선택. */
	MEDIA_TRANS_BUFFERSTREAM	= 0x11,		/**< Stream Play시 선택. */
	MEDIA_TRANS_SKYPE			= 0x12,		/**< Skype용 Stream Play시 선택. */
	MEDIA_TRANS_WIDEVINE			= 0x13,		/**< Widevine Stream Play시 선택. */
} MEDIA_TRANSPORT_T;

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
 * This enumeration describes encryption type of media.
 */
typedef enum MEDIA_SECURITY_TYPE
{
	MEDIA_SECURITY_NONE = 0,	/**< No encryption */
	MEDIA_SECURITY_AES,			/**< AES */
	MEDIA_SECURITY_WMDRM,		/**< WMDRM */
	MEDIA_SECURITY_NUM
} MEDIA_SECURITY_TYPE_T;

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
 * This enumeration describes stream type.
 */
typedef enum MEDIA_STREAM_TYPE
{
	MEDIA_STREAM_NONE = 0,			/**< don't care */
	MEDIA_STREAM_MULTIPLEXED,	/**< Multiplexed AV */
	MEDIA_STREAM_AUDIO,				/**< AUDIO */
	MEDIA_STREAM_VIDEO				/**< VIDEO */
} MEDIA_STREAM_TYPE_T;

//#define MEDIA_BUFFER_HANDLE_T (void *)

#ifndef INCLUDE_ADDON_HOST
/**
 * Channel Map Type.
 */
typedef	enum	API_CHANNEL_MAP
{
	MAP_CUSTOMIZED		= 1,		/**< 실제로 스캔을 하면 잡히는 채널 */
	MAP_FAVORITE		= 2,		/**< 선호 채널로 설정한 채널 */
	MAP_NONE			= 3			/**< 모든 채널 */

} API_CHANNEL_MAP_T;


/**
 * 채널 정보를 얻을때 요청할 Attribute
 */
enum API_CHANNEL_ATTR_TYPE_T
{
	ATTR_INCLUDE_BLOCK			= 0x00000100,	/**< Blocking 속성 포함 */
	ATTR_EXCLUDE_BLOCK			= 0x00000200,	/**< Blocking 속성 제외 */
	ATTR_INCLUDE_SKIPHIDDEN		= 0x00000400,	/**< Skip, Hidden된 채널 속성 포함 */
	ATTR_EXCLUDE_SKIPHIDDEN		= 0x00000800,	/**< Skip, Hidden된 채널 속성 제외 */
	ATTR_INCLUDE_SCRAMBLE		= 0x00004000,	/**< 스크램블 된 채널 속성 포함 */
	ATTR_EXCLUDE_SCRAMBLE		= 0x00008000,	/**< 스크램블 된 채널 속성 제외 */
	ATTR_INCLUDE_INVISIBLE		= 0x00010000,	/**< 보이지 않는 채널 속성 포함 */
	ATTR_EXCLUDE_INVISIBLE 		= 0x00020000,	/**< 보이지 않는 채널 속성 제외 */
	ATTR_INCLUDE_INACTIVE		= 0x00040000,	/**< 비활성화된 채널 속성 포함 */
	ATTR_EXCLUDE_INACTIVE 		= 0x00080000,	/**< 비활성화된 채널 속성 제외 */

	ATTR_TV_ONLY				= 0x01000000,	/**< TV속성 */
	ATTR_RADIO_ONLY				= 0x02000000,	/**< 라디오 속성 */
	ATTR_MAIN_CH				= 0x10000000,	/**< 메인 채널 속성 */
	ATTR_SUB_CH					= 0x20000000,	/**< 서브 채널 속성 */
	ATTR_UNUSED_CH				= 0x40000000	/**< 사용되지 않는 채널 속성 */
};

/**
 * TV Input (source type)
 */
typedef enum TV_INPUT_TYPE
{
	CM_ANTENNA_ANALOG_INPUT = 0,	/**<   Antenna신호로 잡힌 NTSC입력 */
	CM_ANTENNA_DIGITAL_INPUT,		/**<   Antenna신호로 잡힌 VSB입력 */
	CM_CABLE_ANALOG_INPUT,			/**<   Cable신호로 잡힌 NTSC입력 */
	CM_CABLE_DIGITAL_INPUT,			/**<   Cable신호로 잡힌 Digital(QAM or VSB)입력 */
	CM_CABLE_UNDEFINED_INPUT,		/**<   Cable신호로 잡힌 Undefined 입력 -> CM_CABLE_UNDEFINED_INPUT */
	CM_OCABLE_ANALOG_INPUT,			/**<   OpenCable신호로 잡힌 ANALOG입력 */
	CM_OCABLE_DIGITAL_INPUT,		/**<   OpenCable신호로 잡힌 DIGITAL입력 */
	CM_1394_TV_INPUT,				/**<   1394 입력 */
#ifdef EXT_BOX_SUPPORT
	CM_CABLE_BOX,					/**<   Cable box 입력 */
#endif
	CM_UNDEFINED_TV_INPUT,	 		/**<   정의되지 않은 입력 */
} TV_INPUT_TYPE_T;

#endif //INCLUDE_ADDON_HOST

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
	SCHEDULE_REPEAT_MAX			/**< number of repeat types */ // position is important
} SCHEDULE_REPEAT_T;


/**
 * Application Type
 */
typedef enum HOA_APP_TYPE
{
	HOA_APP_ALL		= 0,	/**< All application */
	HOA_APP_HOST		= (1<<1),			/**< Host application */
	HOA_APP_ADDON		= (1<<2),			/**< Add-on application */
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
 * Audio Mode
 */
typedef enum HOA_AUDIO_MODE
{
	HOA_AUDIO_MODE_NORMAL,						/**< H/W setting그대로 */
	HOA_AUDIO_MODE_MONO,						/**< Mono */
	HOA_AUDIO_MODE_STEREO						/**< Stereo */
} HOA_AUDIO_MODE_T;

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
typedef ADDON_DISPLAYMODE_T HOA_DISPLAYMODE_T;

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
 * Group Type
 */
typedef enum HOA_LOCALE_GROUP
{
	HOA_GROUP_KR = 0x01,	/**< Korea */
	HOA_GROUP_US,			/**< United States */
	HOA_GROUP_BR,			/**< Brazil */
	HOA_GROUP_EU,			/**< EU */
	HOA_GROUP_CN,			/**< China (Mainland) */
	HOA_GROUP_AU,			/**< Australia */
	HOA_GROUP_SG,			/**< Singapore */
	HOA_GROUP_ZA,			/**< South Africa */
	HOA_GROUP_VN,			/**< Vietnam */
	HOA_GROUP_TW,			/**< Taiwan */
	HOA_GROUP_XA,			/**< 중남미 아날로그 국가, NTSC */
	HOA_GROUP_XB,			/**< 중아, 아주 아날로그 국가, PAL */
	HOA_GROUP_IL,			/**< 이스라엘 */
	HOA_GROUP_ID,			/**< 인도네시아 */
	HOA_GROUP_MY,			/**< 말레이시아 */
	HOA_GROUP_IR,			/**< 이란 */
	HOA_GROUP_HK,			/**< China (Hongkong) */
	HOA_GROUP_ZZ			/**< not defined */
} HOA_LOCALE_GROUP_T;

/**
 * TV Support Type.
 *
 */
typedef enum HOA_TV_SUPPORT_TYPE
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
	HOA_SUPPORT_3D,				/**< Support 3D feature(TRUE/FALSE)(TRUE means that supports 3D feature) */
	HOA_SUPPORT_LAST	= 0xffff
} HOA_TV_SUPPORT_TYPE_T;

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
}HOA_TV_PANEL_ATTRIBUTE_TYPE_T;

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

/**
 * OSD Type
 */
typedef enum HOA_TV_OSD_TYPE
{
	HOA_OSD_NONE = -1,			/**< None */
	HOA_OSD_MAIN = 0,			/**< Main OSD */
	HOA_OSD_SUB = 1,			/**< Sub OSD */
	HOA_OSD_SUB_2 = 2,			/**< Sub2 OSD */
	HOA_OSD_SUB_3 = 3,			/**< Sub3 OSD */
	HOA_OSD_NUM
} HOA_TV_OSD_TYPE_T;

/**
 * OSD Update Type
 */
typedef enum HOA_TV_OSD_UPDATE_TYPE
{
	HOA_OSD_UPDATE_NORMAL = 0,		/**< Normal Update */
	HOA_OSD_UPDATE_FLIPONLY,		/**< Flip only Update */
	HOA_OSD_UPDATE_NUM
} HOA_TV_OSD_UPDATE_TYPE_T;

/**
 * Overlay Control Pad Type
 */
typedef enum HOA_OVERLAY_CONTROLPAD
{
	HOA_OVERLAY_CONTROLPAD_NORMAL = 0,		/**< Default Control Pad */
	HOA_OVERLAY_CONTROLPAD_LAST
} HOA_OVERLAY_CONTROLPAD_T;

/**
 * Storage List.
 * 각 Storage별로 한 bit씩 할당되어 있음.
 */
typedef enum HOA_STORAGE_TYPE
{
	HOA_INTERNAL_FLASH		= 1,				/**< 내장 Flash */
	HOA_INTERNAL_HDD		= (1<<1),			/**< 내장 HDD */

	HOA_EXTERNAL_USB1_DRV1	= (1<<4),			/**< 외장 USB Port 1 Drive 1 */
	HOA_EXTERNAL_USB1_DRV2	= (1<<5),			/**< 외장 USB Port 1 Drive 2 */
	HOA_EXTERNAL_USB1_DRV3	= (1<<6),			/**< 외장 USB Port 1 Drive 3 */
	HOA_EXTERNAL_USB1_DRV4	= (1<<7),			/**< 외장 USB Port 1 Drive 4 */
	HOA_EXTERNAL_USB2_DRV1	= (1<<8),			/**< 외장 USB Port 2 Drive 1 */
	HOA_EXTERNAL_USB2_DRV2	= (1<<9),			/**< 외장 USB Port 2 Drive 2 */
	HOA_EXTERNAL_USB2_DRV3	= (1<<10),			/**< 외장 USB Port 2 Drive 3 */
	HOA_EXTERNAL_USB2_DRV4	= (1<<11),			/**< 외장 USB Port 2 Drive 4 */
} HOA_STORAGE_TYPE_T;


/**
 *  USB Device Type -- ieeum.lee(10.09.20)
 */
typedef enum HOA_USB_DEV_TYPE
{
	HOA_INTERNAL_DEV			= 0x01,				/**<LG MFS Format for AV */
	HOA_EXTERNAL_DEV			= 0x02,				/**<LG MFS Format for PICTURE */
	HOA_EXTERNAL1_DEV		= 0x02,				/**<LG MFS Format for PICTURE at port1 */
	HOA_EXTERNAL2_DEV		= 0x04,				/**<LG MFS Format for PICTURE at port2 */	
	HOA_DVRHDD_DEV			= 0x08,				/**<LG MFS Format for DVR */	
	HOA_BACKUP_DEV			= 0x10,				/**<LG MFS Format for Backup HDD */	
	HOA_APPSTORE_DEV			= 0x20,				/**<LG MFS Format for App Store */	
	HOA_DETACHABLE_DEV		= 0x40,				/**<LG Detachable  */	
	HOA_DEV_TYPE_INVALID		= 0x80,				/** Not Connected or Invalid */		
} HOA_USB_DEV_TYPE_T;

/**
 *  Addon  Storage Device Type for TV Apps. 
 * (This enum should be synchronized with ADDON_STORAGE_TYPE_T)
 */
typedef enum HOA_TVAPPS_STORAGE_TYPE
{
	HOA_TVAPPS_FLASH_DEV			= 0x01,				/**<TV Apps Flash Storage */
	HOA_TVAPPS_USB_DEV			= 0x02,				/**<TV Apps USB Storage */
	HOA_TVAPPS_TYPE_INVALID		= 0x80,				/** Unknown or Invalid Type*/		
} HOA_TVAPPS_STORAGE_TYPE_T;


/**
 *  Addon  App List Type  for TV Apps. 
 * (This enum should be synchronized with ADDON_STORAGE_TYPE_T)
 */
typedef enum HOA_TVAPPS_APPLIST_TYPE
{
	HOA_TVAPPS_APPLIST_SYSTEM		= 0x01,				/**<Apps List - System */
	HOA_TVAPPS_APPLIST_LAUNCHER		= 0x02,				/**<Apps List - LauncherBar */
	HOA_TVAPPS_APPLIST_FLASH			= 0x03,				/**<Apps List - Flash */
	HOA_TVAPPS_APPLIST_USB			= 0x04,				/**<Apps List - USB  */
	HOA_TVAPPS_APPLIST_INVALID		= 0x80,				/**<Apps List - Invalid */	
} HOA_TVAPPS_APPLIST_TYPE_T;


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
	HOA_NETWORK_WIRELESS_WIFI	= (1<<1),	/**< Wireless Network */
	HOA_NETWORK_WIRELESS_3G		= (1<<2)	/**< 3G Network */
} HOA_NETWORK_TYPE_T;

/**
 * IPTV_MODE_TYPE_T
 */
typedef enum
{
	HOA_IPTV_TYPE_NONE	= 0,				/**< NONE */
	HOA_IPTV_TYPE_KT 	= 1,				/**< KT Qook */
	HOA_IPTV_TYPE_LGD	= 2,				/**< LG MyLGTV */
	HOA_IPTV_TYPE_SKB	= 3					/**< SK Broadband */
}HOA_IPTV_TYPE_T;

/**
 * Audio/Video Mode for IPTV
 */
typedef enum
{
	HOA_IPTV_AV_AUDIO_VIDEO,		/**< A/V Both */
	HOA_IPTV_AV_VIDEO_ONLY,			/**< Video Only */
	HOA_IPTV_AV_AUDIO_ONLY			/**< Audio Only */
} HOA_IPTV_AV_MODE_T;

/**
 * Audio Play Mode for IPTV
 */
typedef enum
{
	HOA_IPTV_AUDIO_NORMAL,			/**< Normal */
	HOA_IPTV_AUDIO_LEFT_MONO,		/**< Mono (from Left channel) */
	HOA_IPTV_AUDIO_RIGHT_MONO,		/**< Mono (from Right channel) */
	HOA_IPTV_AUDIO_AC3				/**< AC3 */
} HOA_IPTV_AUDIO_T;

/**
 * Tuner Type
 */
typedef enum
{
	HOA_TUNER_SATELLITE,			/**< Satellite (위성방송) */
	HOA_TUNER_TERRESTRIAL,			/**< Terrestrial (지상파) */
	HOA_TUNER_CABLE,				/**< Cable */
	HOA_TUNER_IP,					/**< IP */
	HOA_TUNER_FILE					/**< FILE */
} HOA_TUNER_TYPE_T;

/**
 * IP Version
 */
typedef enum
{
	HOA_IP_V4,					/**< IPv4 */
	HOA_IP_V6					/**< IPv6 */
} HOA_IP_TYPE_T;

/**
 * IP Transport Type
 */
typedef enum
{
	HOA_IPTV_TRANS_UDP,				/**< UDP */
	HOA_IPTV_TRANS_UDP_RTP,			/**< UDP with RTP */
	HOA_IPTV_TRANS_TCP,				/**< TCP */
	HOA_IPTV_TRANS_TCP_RTP,			/**< TCP with RTP */
	HOA_IPTV_TRANS_PRIVATE_BASE,
	HOA_IPTV_TRANS_PRIVATE0,		/**< Private 0 */
	HOA_IPTV_TRANS_PRIVATE1,		/**< Private 1 */
	HOA_IPTV_TRANS_PRIVATE2			/**< Private 2 */
} HOA_IPTV_TRANSPORT_T;

/**
 * HOA_IPTV_FWDN_REQ_TYPE_T
 */
typedef enum HOA_IPTV_FWDN_REQ_TYPE
{
	HOA_IPTV_FWDN_USER_SETTING,	/**< = AC_FWDN_REQTYPE_SYS_SETTING */
	HOA_IPTV_FWDN_HIDDEN_MENU	/**< = AC_FWDN_REQTYPE_HIDDEN_MENU */
} HOA_IPTV_FWDN_REQ_TYPE_T;

/**
 * HOA_IPTV_FWDN_TYPE_T
 */
typedef enum HOA_IPTV_FWDN_TYPE
{
	HOA_IPTV_FWDN_START,		/**< = AC_FWDN_ANSWER_OK */
	HOA_IPTV_FWDN_CANCEL,		/**< = AC_FWDN_ANSWER_CANCEL */
	HOA_IPTV_FWDN_INVOD			/**< = AC_FWDN_ANSWER_INVOD */
} HOA_IPTV_FWDN_TYPE_T;

/**
 * NDS CALLBACK FUNCTION LIST.
 *
 */
typedef enum NDSCB_FUNCTION_ID
{
	FN_X_SENDAPPLICATIONEVENT,
	FN_X_GETHANDLEPROPERTIES,
	FN_X_SETCCIDATA,
	FN_X_SETCLEARMODEPERMISSION,
	FN_X_DATATOIRD,
	FN_X_SETMAXNUMCOMPONENTS,
	FN_X_GETCURRENTGMTDATETIME,
	FN_X_COMPARESERVICEREF,
	FN_X_SETCASID,
	FN_NDS_MDSTATUS,
	FN_NDS_VERIFIERNOTIFICATION,
	FN_NDS_SENDCOMPONENTSTATUS,
} NDSCB_FUNCTION_ID_T;

/**
 * MOTION REMOT CONTROL MSG LIST.
 *
 */
typedef enum HOA_TV_MESSAGE_TYPE
{
	HOA_TV_MSG_MR_GESTURE_NORMAL,   	/**< Motion Remocon Ready to gesture message (MSG_GAME2UI_READY_TO_GESTURE) */
	HOA_TV_MSG_MR_GESTURE_SWING,   	/**< Motion Remocon Ready to swing message (MSG_GAME2UI_READY_TO_SWING) */
	HOA_TV_MSG_MR_GESTURE_SWING_END,	/**< Motion Remocon End swing message (MSG_GAME2UI_END_SWING) */
	HOA_TV_MSG_MR_GESTURE_SPACE_SENSING, /**< Motion Remocon Space sensing message (MSG_GAME2UI_SET_SPACE_SENSING) */
	HOA_TV_MSG_MR_GESTURE_JUMP,    	/**< Motion Remocon Ready to jump message (MSG_GAME2UI_READY_TO_JUMP) */
	HOA_TV_MSG_MR_GESTURE_THROW,   	/**< Motion Remocon Ready to throw message (MSG_GAME2UI_READY_TO_THROW) */
	HOA_TV_MSG_MR_GESTURE_FISHING,		/**< Motion Remocon Ready to fishing message (MSG_GAME2UI_READY_TO_FISHING) */
	HOA_TV_MSG_MR_GESTURE_END,    		/**< Motion Remocon End gesture recognition message (MSG_GAME2UI_ENTER_TITLE) */
	HOA_TV_MSG_MR_SETFEEDBACK,			/**< Motion Remocon Feedback */
	HOA_TV_MSG_MR_REMOVECURSOR,		/**< Motion Remocon Remove E-Manual MR pointer*/
	HOA_TV_MSG_MR_DISABLE_REMOVECURSOR,	/**< Disable Motion Remocon Remove E-Manual MR pointer*/
	HOA_TV_MSG_MR_MOTION_ON,			/** disable motion remocon event if motion remocon input is received */
	HOA_TV_MSG_MR_MOTION_OFF,			/** enable motion remocon */
	 
	//HOA_TV_MSG_MR_MOTION_POINTER_MODE,			/** Motion pointer mode for VUDU */
	
	HOA_TV_MSG_MOTION_POINT_MODE_HIDDEN,			/**< Motion pointer invisible */
	HOA_TV_MSG_MOTION_POINT_MODE_SELECT,			/**< Motion pointer arrow */
	HOA_TV_MSG_MOTION_POINT_MODE_BUSY,				/**< Motion pointer hourglass */
	HOA_TV_MSG_MOTION_POINT_MODE_TEXT,				/**< Motion pointer I-beam */
	HOA_TV_MSG_MOTION_POINT_MODE_DRAG,				/**< Motion pointer hand */
	HOA_TV_MSG_MOTION_POINT_MODE_FORBIDDEN,		/**< Motion pointer slashed circle */
	HOA_TV_MSG_MOTION_POINT_MODE_PREV,				/**< Motion pointer previous style */

#ifdef INCLUDE_VCS
	HOA_TV_MSG_MR_RAC_ON,							/**< rac on */
	HOA_TV_MSG_MR_RAC_OFF,							/**< rac off */
	HOA_TV_MSG_MR_VCS_LOAD_FINISH,					/**< vcs load finish */
#endif
	
	HOA_TV_MSG_END = 0xff,
} HOA_TV_MESSAGE_TYPE_T;

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
 * MOTION REMOTE POINTER TYPE
 *
 */
typedef enum HOA_TV_GESTURE_POINT_TYPE
{
	HOA_TV_GESTURE_POINT_TYPE_A			= 0,		/**< 화살표 */
	HOA_TV_GESTURE_POINT_TYPE_B,						/**< 비행기 */
	HOA_TV_GESTURE_POINT_TYPE_C,						/**< 동그라미 */
	HOA_TV_GESTURE_POINT_TYPE_D,						/**< 크로스바 */
	HOA_TV_GESTURE_POINT_TYPE_DRAG,					/**< DRAG 손바닥 */
	
	HOA_TV_GESTURE_POINT_TYPE_LAST					/**< 이전 모양 */
} HOA_TV_GESTURE_POINT_TYPE_T;

/**
 * MEDIA LINK STATE
 *
 */
typedef enum HOA_MEDIALINK_STATE
{
    HOA_MEDIALINK_STATE_NONE            = 0,
    HOA_MEDIALINK_STATE_IDLE            = 1,
    HOA_MEDIALINK_STATE_PLAY_FULL_VIDEO = 2,
    HOA_MEDIALINK_STATE_PLAY_AUDIO      = 3,
    HOA_MEDIALINK_STATE_PLAY_PICTURE    = 4,
    
    HOA_MEDIALINK_STATE_NUM,
    HOA_MEDIALINK_STATE_MAX				= HOA_MEDIALINK_STATE_NUM  - 1
} HOA_MEDIA_LINK_STATE_T;

/**
 * Add-on Application이 Agent에 등록해야 하는 Callback들 .
 */
typedef struct APP_CALLBACKS
{
	/* Message handler. Add-on Agent에서 Add-on App.으로 전하는 메세지를 처리하는 함수. */
	HOA_STATUS_T (*pfnMsgHandler)(HOA_MSG_TYPE_T msg, UINT32 submsg,
									UINT8 *pData, UINT16 dataSize);
	/* Key event callback. Key를 사용하였으면 TRUE를 리턴하고 사용하지 않았으면 FALSE를 리턴한다. */
	BOOLEAN (*pfnKeyEventCallback)(UINT32 key, ADDON_KEY_COND_T keyCond);
	/* Mouse event callback. Mouse를 사용하였으면 TRUE를 리턴하고 사용하지 않았으면 FALSE를 리턴한다. */
	BOOLEAN (*pfnMouseEventCallback)(SINT32 posX, SINT32 posY, UINT32 keyCode, ADDON_KEY_COND_T keyCond);
} APP_CALLBACKS_T;

/**
 * Add-on Application의 PID와 Status.
 * (HOA_MSG_OTHERAPPSTATUSCHANGED의 pData)
 */
typedef struct HOA_APP_PID_STATUS
{
	UINT16	pid;				/**< Process ID of Executed Application */
	ADDON_APP_STATE_T status;	/**< Status of Executed Application */
} HOA_APP_PID_STATUS_T;

typedef UINT16 HOA_APP_PIDLIST_T[ADDON_MAX_PROC_NUM];

#ifndef INCLUDE_ADDON_HOST
/**
 *	Time structure.
 */
typedef	struct
{
	UINT16		year;		/**< year		: 1970 ~ 65535 */
	UINT8		month;		/**< month		: 1 ~ 12       */
	UINT8 		day;		/**< day		: 1 ~ 31       */
	UINT8 		hour;		/**< hour		: 0 ~ 23       */
	UINT8 		minute;		/**< minute		: 0 ~ 59       */
	UINT8 		second;		/**< second		: 0 ~ 59       */
}	TIME_T;
#endif //INCLUDE_ADDON_HOST

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
	UINT32 bufferMinLevel;
	UINT32 bufferMaxLevel;
	SINT64 ptsToDecode;
	BOOLEAN pauseAtDecodeTime;
} __attribute__((packed)) HOA_FLASHES_OPT_T;


/**
 * Structure of streaming play option
 */
typedef struct MEDIA_STREAMOPT
{
	UINT32				totDataSize;	/**< Total streaming data size. 현재는 Audio에서만 사용. */
	HOA_RECT_T			dispRect;		/**< Display(output) Rect. Video 및 Image에서 사용. */
	HOA_AUDIO_PCM_INFO_T	pcmInfo;		/**< PCM Info for Audio. Audio에서만 사용. */
	HOA_ASF_OPT_T		asfOption;		/**< ASF option for ASF File (stream) play. Media Format이 ASF인 경우 사용. */
	MEDIA_SECURITY_TYPE_T	securityType;	/**< Stream encrypt type */
	HOA_FLASHES_OPT_T	flashOption;	/**< Flash option */
	
	BOOLEAN	bAdaptiveResolutionStream;			/**< seperated Resolution  */	

	UINT32                  preBufferTime;  /**< Transfer time unit required Pre-Buffering */
} __attribute__((packed)) MEDIA_STREAMOPT_T;

/**
 * Structure of option for feeding stream.
 */
typedef struct MEDIA_FEEDOPT
{
	MEDIA_STREAM_TYPE_T	streamType;		/**< stream type(Multi/Audio/Video) */
	BOOLEAN				bHeader;		/**< header or data packet */
	BOOLEAN				bSendEOS;		/**< whether send EOS */
} MEDIA_FEEDOPT_T;
#define STREAM_DATA_INFINITE		0

/**
 * Structure widevine credentials
 * See API_WV_CREDENTIALS in eme_api.h
 */
typedef struct MEDIA_CREDENTIALS
{
	CHAR deviceID[256];					/**< unique player device ID from CinemaNow */
	CHAR streamID[256];					/**< unique streamID from CinemaNow */
	CHAR clientIP[256];					/**< IP address of client */
	CHAR drmServerURL[1024];		/**< URL for DRM server */
	CHAR userData[256]; 				/**< Additional optional user data, TBD */	
	CHAR portal[256];						/**< Identifies the operator */
	CHAR storefront[256];				/**< Identifies store run by operator */
	CHAR drmAckServerURL[1024];	/**< URL for server that receives entitlement confirmations */
	
	CHAR heartbeatURL[1024];		/**< URL to receive client heartbeats */
	UINT32 heartbeatPeriod;			/**< Duration between consecutive heartbeats in
																		seconds. 0 indicates no heartbeats requested */
	
	UINT32 cnDeviceType;				/**< device type identifier defined by CinemaNow */
} MEDIA_CREDENTIALS_T;

/**
 * This structure contains the media play informations
 *
 */
typedef struct MEDIA_PLAY_INFO
{
	MEDIA_PLAY_STATE_T 	playState;		/**< Media play state */
	UINT32 				elapsedMS;		/**< Elapsed time in millisecond */
	UINT32				durationMS;		/**< Total duration in millisecond */

	UINT32				bufBeginSec;	/**< Buffering된 stream의 가장 앞 부분. (MEDIA_TRANS_DLNA, MEDIA_TRANS_YOUTUBE, MEDIA_TRANS_YAHOO일 경우에만 유효) */
	UINT32				bufEndSec;		/**< Buffering된 stream의 가장 뒷 부분. (MEDIA_TRANS_DLNA, MEDIA_TRANS_YOUTUBE, MEDIA_TRANS_YAHOO일 경우에만 유효) */
	SINT32				bufRemainSec;	/**< Buffering된 stream의 남은 부분. (MEDIA_TRANS_DLNA, MEDIA_TRANS_YOUTUBE, MEDIA_TRANS_YAHOO일 경우에만 유효) */

	SINT32				instantBps;		/**< 현재의 Stream 전송 속도. (MEDIA_TRANS_DLNA, MEDIA_TRANS_YOUTUBE, MEDIA_TRANS_YAHOO일 경우에만 유효) */
	SINT32				totalBps;		/**< 전체 Stream 전송 속도. (MEDIA_TRANS_DLNA, MEDIA_TRANS_YOUTUBE, MEDIA_TRANS_YAHOO일 경우에만 유효) */
	UINT32				streamBitRate;
	UINT32				numOfRates;
	UINT32				curIndexOfRate;
	MEDIA_CB_MSG_T		lastCBMsg;		/**< 가장 최근에 불린 Callback Message */

	UINT32 playErrorNum;					/**< 가장 최근에 발생한 Cinemanow play error number */
} MEDIA_PLAY_INFO_T;

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
 * Media Subtitle Information
 */
typedef struct MEDIA_SUBTITLE_INFO
{
	UINT8			subtitleShow;		/**< Subtitle on/off infomation */
	CHAR			language[10];		/**< Language information */
	CHAR			subtitleURLPath[1024];	/**< Subtitle URL Path */
} MEDIA_SUBTITLE_INFO_T;

/**
 * Media Audio language Information
 */
typedef struct MEDIA_AUDIO_INFO
{
	CHAR			audioLang[10];		/**< Language information */
} MEDIA_AUDIO_INFO_T;

/**
* Media Type Information
*/
typedef struct HOA_MEDIA_TYPE
{
	MEDIA_TRANSPORT_T mediaTransportType;
	MEDIA_FORMAT_T mediaFormatType;
	MEDIA_CODEC_T mediaCodecType;
} HOA_MEDIA_TYPE_T;


#ifndef INCLUDE_ADDON_HOST
#ifndef	 API_CHANNEL_NUM_T

/**
 * Channel Num Information.
 */
typedef		struct	API_CHANNEL_NUM
{
	UINT8		sourceIndex;	/**<   Source of channel : TV_INPUT_TYPE_T	*/
	UINT16		physicalNum;	/**<   Physical channel Number:  1-135	*/
	UINT16		majorNum;		/**<  Major number(1~9999) : 2bit(TV/Radio/Data flag), 14bit(user number) */
	UINT16		minorNum;		/**<  Minor number of channel : received LCN	*/
} __API_CHANNEL_NUM_T;

#define API_CHANNEL_NUM_T	__API_CHANNEL_NUM_T
#endif //API_CHANNEL_NUM_T
#endif //INCLUDE_ADDON_HOST

/**
 *	HOA_CHANNEL_INFO structure.
 */
typedef struct HOA_CHANNEL_INFO
{
	API_CHANNEL_NUM_T	channelNum;		/**< Channel */
	char				channelName[MAXCHANNELNAME];	/**< Channel Name */
} HOA_CHANNEL_INFO_T;

/**
 *	HOA_CHANNEL_LIST structure.
 */
typedef struct HOA_CHANNEL_LIST
{
	UINT16				channelNum;			/**< Channel의 갯수 */
	HOA_CHANNEL_INFO_T	*pChannelList;		/**< Channel의 array (channelNum 만큼) */
} HOA_CHANNEL_LIST_T;

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
	ATSC_DIMENSION_L_T 	*pRatingValue;		/**<  0x02: rating value */
										/**<  0x06: 8 bytes */
} ATSC_REGION_LIST_T;

/**
 * Rating list - type structure
 * used for rating information.
 */
typedef struct ATSC_RATING_LIST
{
	UINT8			numOfRegions;		/**<  0x00: number of rating regions */
	ATSC_REGION_LIST_T 	*pRegionList; 		/**<  0x01: rating region list */
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

	UINT8				*pGenre;		/**< Genre Information */

	char				*pName;		/**< Event Name (PSIP:multistring->string) */
	char				*pDesc;		/**< Event Description (SI:description, PSIP(evContents):multistring->string) */
	char				*pExtDesc;	/**< Event Extended Description (SI:extended description) */

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
	UINT16				eventInfoNum;		/**< Event Info의 갯수 */
	HOA_EVENT_INFO_T		*pEventInfoList;	/**< Array of Event Info (eventInfoNum 만큼) */
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
 * TV General Info.
 */
typedef struct HOA_TV_INFO
{
	char	projectName[32];	/**< Project Name, OSA_MD_GetProjectName() */
	char	modelName[32];		/**< Model Name, OSA_MD_GetModelName() */
	char	hwVer[32];			/**< Hardware Version, OSA_MD_GetEventBoardType(), tv_system.c 참조 */
	char	swVer[32];			/**< Software Version, G_FIRMWARE_VERSION */
	char	ESN[32];			/**< ESN, API_NSU_GetESN() */
	char	toolTypeName[32];	/**< Tool type name, OSA_MD_GetToolType(), toolitem.h */
	char	serialNumber[32];
	char modelInch[8];		/** model inch from UI_SUMODE_GetInchTypeString() */
	char countryGroup[8];	/** countryGroup from UI_SUMODE_GetCountryGroupString*/
} HOA_TV_INFO_T;

/**
 * Network Configurations
 */
typedef struct HOA_NETCONFIG
{
	UINT32 ipAddress;			/**< IP address. Address가 "A.B.C.D" 이면 ((D<<24)|(C<<16)|(B<<8)|A)의 값을 갖는다. */
	UINT32 subnetMask;			/**< Subnet mask.  Address가 "A.B.C.D" 이면 ((D<<24)|(C<<16)|(B<<8)|A)의 값을 갖는다. */
	UINT32 gateway;				/**< Gateway.  Address가 "A.B.C.D" 이면 ((D<<24)|(C<<16)|(B<<8)|A)의 값을 갖는다. */
	UINT32 DNSServer1;			/**< DNS server 1.  Address가 "A.B.C.D" 이면 ((D<<24)|(C<<16)|(B<<8)|A)의 값을 갖는다. */
	UINT32 DNSServer2;			/**< DNS server 2.  Address가 "A.B.C.D" 이면 ((D<<24)|(C<<16)|(B<<8)|A)의 값을 갖는다. */
	UINT8 macAddress[6];		/**< MAC address */
	UINT32 DHCPServer;			/**< DHCP Server address.  Address가 "A.B.C.D" 이면 ((D<<24)|(C<<16)|(B<<8)|A)의 값을 갖는다. */
	BOOLEAN bDHCP;				/**< Is DHCP Enabled (1) or Not (0) */
	UINT8 macAddressOfAP[6];		/**< MAC address of  Wiress AP*/	
} HOA_NETCONFIG_T;

/**
 * Wireless Network Status
 */
typedef struct HOA_WIRELESSNETWORK_STATUS
{
	SINT8	signalStrength;		/**< Signal strength */
} HOA_WIRELESSNETWORK_STATUS_T;

/**
 * Tuner List for IPTV
 */
typedef struct HOA_TUNER_LIST
{
	UINT32 tunerNum;					/**< Number of Tuner */
	HOA_TUNER_TYPE_T *pTunerTypeList;	/**< List of Tuner */
} HOA_TUNER_LIST_T;

/**
 * Section filter options
 */
typedef struct
{
 	UINT32	  transaction_id;					/**< Transaction ID */
	UINT16	  pid;								/**< PID filter value */
	UINT8	  table_id;							/**< Table ID value */
 	UINT8	  section_syntax_indicator;			/**< Section Syntax Indicator value */
	UINT16	  table_id_extension;				/**< Table ID Extension value */
	UINT8	  version_number;					/**< Version Number value */
	UINT8	  current_next_indicator;			/**< Current Next Indicator value */
	UINT8	  last_section_number;				/**< Last section number value */
	UINT8	  protocol_version;					/**< Protocol Version value */

 	UINT8	  table_id_filter_mask;				/**< Table ID filter bit mask (8 bits) */
	UINT16	  table_id_extension_filter_mask;	/**< Table ID extension filter bit mask (16 bits) */

 	UINT8
			  section_syntax_indicator_filter	: 1,	/**< Section syntax indicator filter ON/OFF */
			  version_number_filter				: 1,	/**< Version number filter ON/OFF */
			  not_version_number_filter			: 1,	/**< Not version number filter ON/OFF */
			  current_next_indicator_filter		: 1,	/**< Current next indicator filter ON/OFF */
			  last_section_number_filter		: 1,	/**< Last section number filter ON/OFF */
			  protocol_version_filter			: 1,	/**< Protocol version filter ON/OFF */
			  reserved_filter					: 2;	/**< reserved */

 	UINT8
	 		  once_flag							: 1,	/**< Once flag ON/OFF */
		 	  crc_chksum						: 2, 	/**< 0 : No CRC & Checksum, 1 : CRC, 2 : CheckSum */
			  bNegativeTableId					: 1,	/**< 0 = Positive match, 1 = Negative Match for IPTV */
	 		  reserved							: 4;	/**< reserved */

	UINT8	  match[MAXSFFILTERLEN];
	UINT8	  match_mask[MAXSFFILTERLEN];
	UINT8	  negate[MAXSFFILTERLEN];
	UINT8	  negate_mask[MAXSFFILTERLEN];

	UINT32	  timeOut;
} HOA_SECTION_FILTER_T;

/**
 * To Send Section Data To PSIP/SI
 */
typedef struct
{
	UINT32		msgId;			///< 0x00: message id
	UINT32		channel;		///< 0x04: port id
	UINT8		filterId;		///< 0x05: filter id
	UINT16		pid;			///< 0x06: pid
	UINT8		*pData;			///< 0x08: pointer to section data
	UINT16		tableType;		///< 0x0C: table type
	UINT32		dataLen;		///< 0x0E: section data length
	UINT32		transactionId;	///< 0x10: transaction id
	SINT32		entryId;		///< 0x14: entry id

	UINT32		delay;
} HOA_SF_CB_MSG_T;

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
	HOA_POPUP_SWUPDATE,		/**< SW Update Menu(NSU) */	
	HOA_POPUP_ASPECTRATIO,			/**< Aspect ration menu */	
	HOA_POPUP_3DMENU,			/**< 3D Menu(3D Setting menu)	*/	
	HOA_POPUP_LAST = 0xff
} HOA_POPUP_TYPE_T;

/**
 * String structure
 */
typedef struct HOA_STRING
{
	UINT8 *pString;			/**< String. */
	UINT32 stringSize;		/**< String data size. */
} HOA_STRING_T;


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

/** * Browser App Type */
typedef enum HOA_BROWSER_APP_TYPE
{
	HOA_NONE = 0,				/**< NONE */ 
	HOA_PREMIUM_MASTER = 1,		/**< Premium Master */
	HOA_STORE_MASTER = 2,		/**< Store Master */
} HOA_BROWSER_APP_TYPE_T;

/** * SDP Update Path */
typedef enum HOA_SDP_UPDATE_PATH
{	HOA_SDP_MAIN_PATH,	
	HOA_SDP_AD_PATH,	
	HOA_SDP_FULL_AD_PATH,	
	HOA_SDP_NOTICE_PATH,	
	HOA_SDP_CP_PATH,
} HOA_SDP_UPDATE_PATH_T;

/** * SDP Path */
typedef enum HOA_SDP_PATH_TYPE
{	
  HOA_SDP_PATH_CONFIG			= 0x1,
  HOA_SDP_PATH_BROWSER_CONFIG,
  HOA_SDP_PATH_NETCAST,
  HOA_SDP_PATH_MASTER,
  HOA_SDP_PATH_COMMON,
  HOA_SDP_PATH_LANG,
  HOA_SDP_PATH_BACKGROUND,
  HOA_SDP_PATH_MAINPAGE,
  HOA_SDP_PATH_NOTICE,
  HOA_SDP_PATH_LAST
} HOA_SDP_PATH_TYPE_T;

typedef enum HOA_BLACKOUT_TYPE
{
	HOA_NO_SCREEN_SAVER,
	HOA_NO_SIGNAL,
	HOA_INVALID_FORMAT,
	HOA_CM_BLOCKED,
	HOA_INPUT_BLOCKED,
	HOA_RATING_BLOCKED,
	HOA_AUDIO_ONLY,
	HOA_SCRAMBLED,
	HOA_DATA_ONLY,
	HOA_HD_SERVICE,
	HOA_OTA_SERVICE,
	HOA_INVALID_SERVICE,
	HOA_NOT_PROGRAMMED,
	HOA_NOT_CONFIGUED,
	HOA_SATELITE_MOTOR_MOVING,
	HOA_EMF_DMR_SCREENSAVER,
	HOA_BLACKOUT_INFO_MAX,

} HOA_BLACKOUT_TYPE_T;

typedef enum
{
	HOA_3DINPUT_TOP_BOTTOM       =0,
	HOA_3DINPUT_SIDE_SIDE,
	HOA_3DINPUT_CHECK_BOARD,
	HOA_3DINPUT_FULL_HD,
	HOA_3DINPUT_2D_3D,
	HOA_3DINPUT_LAST
} HOA_TV_3D_INPUTMODE_TYPE_T;

typedef enum
{
	HOA_GROUP_DVB       =0,
	HOA_GROUP_ATSC
} HOA_TV_GROUP_TYPE_T;

/** SDP Version */
typedef struct HOA_SDP_VER
{
	char cpVer[10];
	char platformVer[20];
} HOA_SDP_VER_T;


// SDP I/F HOA Data Type by esca 10/08/11
/**
 * SDP I/F(App. Store client) Data Type Definition
 * App. Store login information
 */

typedef struct HOA_SDPIF_LOGIN_INFO
{
	CHAR usrID[24];
	CHAR passWD[13];
	BOOLEAN autoSignin;
} HOA_SDPIF_LOGIN_INFO_T;

typedef struct HOA_SDPIF_SES_INFO
{
	CHAR usrID[24];
	CHAR passWD[13];
	CHAR tokenKey[512];
} HOA_SDPIF_SES_INFO_T;

/**
 * SDP I/F(App. Store client) Data Type Definition
 * App. Store User information
 */
typedef struct HOA_SDPIF_USER_INFO
{
	CHAR usrID[24];
	CHAR gender[2];
	CHAR usrName[100];
	CHAR birthdate[16];
	CHAR email[40];
	CHAR country[8];
} HOA_SDPIF_USER_INFO_T;

/**
 * SDP I/F(App. Store client) Data Type Definition
 * App. Store Secret(Model/Device) information
 */
typedef struct HOA_SDPIF_SECRET_INFO
{
	CHAR modelSecret[256];
	UINT16 modelLength;
	CHAR deviceSecret[256];
	UINT16 deviceLength;
} HOA_SDPIF_SECRET_INFO_T;

/**
 * SDP I/F(App. Store client) Data Type Definition
 * SDP server data option information
 */
typedef struct HOA_SDPIF_SDPOPTION_INFO
{
	BOOLEAN bAppCard;
	BOOLEAN bSearch;
	BOOLEAN bBrowser;
	BOOLEAN bMedaiLink;
	UINT32 bValid;
} HOA_SDPIF_SDPOPTION_INFO_T;

/**
 * Device Feature Info.
 */
typedef struct HOA_DEVICE_FEATURE_INFO
{
	char	modelName[14];
	char	flashMemorySize[5];
	char	dramSize[5];
	char support3D[5];
	char localeInfoGroup[3];
	char localeInfoCountry[4];
	char videoResolution[5];
	char osdResolution[10];
	char wifiReady[4];
	char gpuSpec[9];
	char openGLVersion[4];
	char flashEngineVersion[15];
	char browserVersion[15];
	char lgSDKVersion[10];
	char tvFirmwareVersion[9];
	char netcastPlatformVersion[15];
	char otaID[33];	
} HOA_DEVICE_FEATURE_INFO_T;

/**
 * InStart System Information.
 */
typedef struct HOA_INSTART_SYSTEM_INFO
{
	UINT8	modelName[32];
	UINT8	serialnumber[32];
	UINT32	swversion;
	UINT8 	hwversion;
	UINT32 	motionremocononoff;
	UINT8 	macaddress[6];
	HOA_TV_GROUP_TYPE_T	batsc_dvb;
} HOA_INSTART_SYSTEM_INFO_T;

/**
 * Typedef of callback function to get notice about Popup Timeout.
 */
typedef void (*POPUP_CB_T)(UINT32 handle, UINT8 btnIdx);

/**
 * Typedef of callback function to get notice about playback end.
 */
typedef void (*MEDIA_PLAY_CB_T)(MEDIA_CHANNEL_T ch, MEDIA_CB_MSG_T msg);
/**
 * Typedef of callback function to get notice from section filter.
 */
typedef HOA_STATUS_T (*IPTV_SECTION_FILTER_CB_T)(HOA_SF_CB_MSG_T *pMsg);

/**
 * Typedef of callback function to SDP I/F
 */
typedef HOA_STATUS_T (*SDPIF_CB_T)(UINT16 PID, UINT32 usermsg, UINT8 *pData, UINT16 dataSize);

/**
 * Typedef of callback function to get notice about PLEX Media Server List Changing.
 */
typedef void (*PMS_CB_T)(MEDIA_CHANNEL_T ch, PMS_CB_MSG_T msg); 	//added 10.08.12

#ifndef INCLUDE_ADDON_HOST
#define HOA_APP_RegisterToMgr(pCallbacks) 	HOA_APP_RegisterToMgrEx(_ADDON_VER_MAJOR, _ADDON_VER_MINOR, ADDONTYPE_ADDON, pCallbacks)
#define HOA_APP_RegisterBrowserToMgr(pCallbacks) 	HOA_APP_RegisterToMgrEx(_ADDON_VER_MAJOR, _ADDON_VER_MINOR, ADDONTYPE_BROWSER, pCallbacks)

HOA_STATUS_T HOA_APP_RegisterToMgrEx(UINT8 verMajor, UINT8 verMinor, ADDON_APP_TYPE_T appType, APP_CALLBACKS_T *pCallbacks);
HOA_STATUS_T HOA_APP_RegisterToUpCtrl(void);
HOA_STATUS_T HOA_APP_DeregisterFromMgr(ADDON_EXITCODE_T exitCode);
HOA_STATUS_T HOA_APP_DeregisterFromUpCtrl(void);

HOA_STATUS_T HOA_APP_SetReady(void);
HOA_STATUS_T HOA_APP_SetLoading(void);
HOA_STATUS_T HOA_APP_SetTerminate(void);

HOA_STATUS_T HOA_APP_RequestFocus(void);
HOA_STATUS_T HOA_APP_ReleaseFocus(ADDON_EXITCODE_T exitCode);
HOA_STATUS_T HOA_APP_LockResource(HOA_RESOURCE_TYPE_T resourceType, BOOLEAN bWait);
HOA_STATUS_T HOA_APP_UnlockResource(HOA_RESOURCE_TYPE_T resourceType);
HOA_STATUS_T HOA_APP_GetRunningAddonAppNum(UINT16 *pAddonAppNum);

HOA_STATUS_T HOA_APP_ExecuteAddonApp(char *pszAppPath, UINT16 appPathSize,
										char *pszArgument, UINT16 argumentSize ,
										BOOLEAN bSingle,
										UINT16 *pPID);
//[sophia 10-06-18] add
HOA_STATUS_T HOA_APP_ExecuteStoreMaster(char *pszParam, UINT16 paramSize);	//sophia
HOA_STATUS_T HOA_APP_GetExecuteArgument(UINT16 PID, char *pszArgument, UINT16 argumentSize); //sophia
HOA_STATUS_T HOA_APP_GetFocusedAddonAppPID(UINT16 *pPID);
HOA_STATUS_T HOA_APP_GetAddonAppState(UINT16 PID, HOA_APP_STATE_T *pState);

HOA_STATUS_T HOA_APP_GetRemoconTypeInformation(UINT8 *pRemoconType);

HOA_STATUS_T HOA_APP_TerminateAddonApp(UINT16 PID, BOOLEAN bRespawn);

HOA_STATUS_T HOA_APP_TerminateAllAddonApp(BOOLEAN bRespawn);

HOA_STATUS_T HOA_APP_TerminateAppBrowser(BOOLEAN bRespawn);

HOA_STATUS_T HOA_APP_GetAddonAppBinaryPIDList(char *pszAppPath, UINT16 appPathSize, char *pszArgument, UINT16 argumentSize, UINT16 *pPidNum, UINT16 *pPidList);

HOA_STATUS_T HOA_APP_DebugPrint(HOA_DEBUG_MASK_T appNo, DEBUG_LEVEL_T level, const char *pLogText,...);
	#ifdef INCLUDE_ADDON_DEBUG_VPRINT
HOA_STATUS_T HOA_APP_DebugVPrint(HOA_DEBUG_MASK_T appNo, DEBUG_LEVEL_T level, const char *pLogText, va_list vArgs);
	#endif //INCLUDE_ADDON_DEBUG_VPRINT
HOA_STATUS_T HOA_APP_GetDebugPrintStatus(HOA_DEBUG_MASK_T appNo, DEBUG_LEVEL_T *pLevel, BOOLEAN *pbOnOff);

HOA_STATUS_T HOA_APP_StopAddonAppLoading(UINT16 PID);

HOA_STATUS_T HOA_APP_ClearBatchList(void);
HOA_STATUS_T HOA_APP_RunBatchList(void);

HOA_STATUS_T HOA_APP_GetStoreMasterExecuteStatus(BOOLEAN *pStoreMasterEnable);

HOA_STATUS_T HOA_APP_SendMsgNoti(UINT16 destPId, ADDON_SUBMSG_TYPE_T usrMsg, UINT8 *pData, UINT16 dataSize);


//[sophia 10-06-18] add
HOA_UC_STATUS_T HOA_UC_GetInstalledAppListSize(UINT32 *pInstalledAppListSize,
													HOA_TVAPPS_APPLIST_TYPE_T  appListType);
HOA_UC_STATUS_T HOA_UC_GetInstalledAppList(char *pInstalledAppList,
													HOA_TVAPPS_APPLIST_TYPE_T  appListType);
HOA_UC_STATUS_T HOA_UC_GetInstalledAppListEx(char **pInstalledAppList,
													UINT32 startAppNumber,
													UINT32 numApps,
													HOA_TVAPPS_APPLIST_TYPE_T  appListType);
HOA_UC_STATUS_T HOA_UC_GetNumInstalledApps(UINT32 *numInstalledApps,
													HOA_TVAPPS_APPLIST_TYPE_T  appListType);

HOA_UC_STATUS_T HOA_UC_GetInstalledAppInfoSize(UINT32 appID, 
													UINT32 *pInstalledAppInfoSize,
													HOA_TVAPPS_APPLIST_TYPE_T  appListType);
HOA_UC_STATUS_T HOA_UC_GetInstalledAppInfo(UINT32 appID, 
													char *pInstalledAppInfo,
													HOA_TVAPPS_APPLIST_TYPE_T  appListType);


HOA_UC_STATUS_T HOA_UC_GetInstalledTestAppInfo(char **pInstalledAppInfo);


HOA_UC_STATUS_T HOA_UC_IsInstalledApp(UINT32 appID, 
													BOOLEAN *bInstalled,
													HOA_TVAPPS_APPLIST_TYPE_T appListType);
HOA_UC_STATUS_T HOA_UC_InstallApp(UINT32 appID, HOA_TVAPPS_APPLIST_TYPE_T  appListType);
HOA_UC_STATUS_T HOA_UC_CancelInstallApp(UINT32 appID, HOA_TVAPPS_APPLIST_TYPE_T  appListType);
HOA_UC_STATUS_T HOA_UC_UninstallApp(UINT32 appID, HOA_TVAPPS_APPLIST_TYPE_T  appListType);
HOA_UC_STATUS_T HOA_UC_CheckAppUpdate(UINT32 appID, 
													char **ppAppListToUpdate, 
													int *pAppListSize,
													HOA_TVAPPS_APPLIST_TYPE_T  appListType);
HOA_UC_STATUS_T HOA_UC_UpdateApp(UINT32 appID, HOA_TVAPPS_APPLIST_TYPE_T  appListType);

HOA_UC_STATUS_T HOA_UC_ChangeAppOrder(UINT32 appID, 
													UINT16 absOrderIndex,
													HOA_TVAPPS_APPLIST_TYPE_T  appListTypeFrom,
													HOA_TVAPPS_APPLIST_TYPE_T  appListTypeTo );
HOA_UC_STATUS_T HOA_UC_CheckAppListExist(BOOLEAN *bAppListExist, 
													HOA_TVAPPS_APPLIST_TYPE_T  appListType);

HOA_UC_STATUS_T HOA_UC_GetStorageSize(char *pAbsPath, UINT64 *pAvailableSize, UINT64 *pTotalSize);

HOA_UC_STATUS_T HOA_UC_SetInstalledAppsSync(HOA_TVAPPS_STORAGE_TYPE_T tvAppStorage);

HOA_UC_STATUS_T HOA_UC_SetAppListSync(HOA_TVAPPS_APPLIST_TYPE_T appListType1 ,
											HOA_TVAPPS_APPLIST_TYPE_T appListType2);


HOA_UC_STATUS_T HOA_UC_GetXAuthentication(char* xAuth);
HOA_UC_STATUS_T HOA_UC_GetDeviceID(char* deviceID);
HOA_UC_STATUS_T HOA_UC_GetEncPasswd(char* encPasswd);
HOA_UC_STATUS_T HOA_UC_GetPasswdHash(char* passwdHash);
HOA_UC_STATUS_T HOA_UC_GetAuthenticationInfo(/*out*/char **ppAuthenticaionInfo);
HOA_UC_STATUS_T HOA_UC_GetHostInfo(/*out*/HOA_HOST_INFO_T *pHostInfo);
HOA_UC_STATUS_T HOA_UC_GetDeviceFeatureInfo(/*out*/HOA_DEVICE_FEATURE_INFO_T *pDeviceFeatureInfo);


#endif //INCLUDE_ADDON_HOST

HOA_STATUS_T HOA_MEDIA_MakeMediaBuffer(MEDIA_BUFFER_HANDLE_T **ppHandle, UINT32 bufferSize);
HOA_STATUS_T HOA_MEDIA_GetMediaBufferAddress(MEDIA_BUFFER_HANDLE_T *pHandle, char **pBuffer);
HOA_STATUS_T HOA_MEDIA_DeleteMediaBuffer(MEDIA_BUFFER_HANDLE_T *pHandle);
HOA_STATUS_T HOA_MEDIA_GetPlayInfo(MEDIA_CHANNEL_T ch, MEDIA_PLAY_INFO_T *pPlayInfo);

HOA_STATUS_T HOA_MEDIA_Initialize(void);
HOA_STATUS_T HOA_MEDIA_Finalize(void);
HOA_STATUS_T HOA_MEDIA_StartChannel(MEDIA_CHANNEL_T ch,
											MEDIA_TRANSPORT_T mediaTransportType,
											MEDIA_FORMAT_T mediaFormatType,
											MEDIA_CODEC_T mediaCodecType);
HOA_STATUS_T HOA_MEDIA_EndChannel(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_PlayClipBuffer(MEDIA_CHANNEL_T ch,
											MEDIA_BUFFER_HANDLE_T *pHandle,
											UINT32 repeatNumber,
											MEDIA_TRANSPORT_T mediaTransportType,
											MEDIA_FORMAT_T mediaFormatType,
											MEDIA_CODEC_T mediaCodecType,
											UINT8 *pPlayOption, UINT16 playOptionSize);
HOA_STATUS_T HOA_MEDIA_PlayClipFile(MEDIA_CHANNEL_T ch,
											char *pFileName,
											UINT32 repeatNumber,
											MEDIA_TRANSPORT_T mediaTransportType,
											MEDIA_FORMAT_T mediaFormatType,
											MEDIA_CODEC_T mediaCodecType,
											UINT8 *pPlayOption, UINT16 playOptionSize);
HOA_STATUS_T HOA_MEDIA_PauseClip(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_ResumeClip(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_SeekClip(MEDIA_CHANNEL_T ch, UINT32 playPositionMs);
HOA_STATUS_T HOA_MEDIA_StopClip(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_PlayStream(MEDIA_CHANNEL_T ch,
											MEDIA_BUFFER_HANDLE_T *pHandle,
											MEDIA_TRANSPORT_T mediaTransportType,
											MEDIA_FORMAT_T mediaFormatType,
											MEDIA_CODEC_T mediaCodecType,
											UINT8 *pPlayOption, UINT16 playOptionSize);
HOA_STATUS_T HOA_MEDIA_SendStream(MEDIA_CHANNEL_T ch, UINT32 dataSize, UINT8 *pFeedOption, UINT16 feedOptionSize);
HOA_STATUS_T HOA_MEDIA_PauseStream(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_ResumeStream(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_StopStream(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_FlushStream(MEDIA_CHANNEL_T ch);

HOA_STATUS_T HOA_MEDIA_OpenStream(MEDIA_CHANNEL_T ch,
											char *pFileName,
											MEDIA_TRANSPORT_T mediaTransportType,
											MEDIA_FORMAT_T mediaFormatType,
											MEDIA_CODEC_T mediaCodecType,
											UINT8 *pOpenOption, UINT16 openOptionSize);
HOA_STATUS_T HOA_MEDIA_CloseStream(MEDIA_CHANNEL_T ch);

HOA_STATUS_T HOA_MEDIA_RegisterPlayCallback(MEDIA_CHANNEL_T ch, MEDIA_PLAY_CB_T pfnPlayCB);
HOA_STATUS_T HOA_MEDIA_SendStreamRaw(MEDIA_CHANNEL_T ch, UINT32 dataSize, MEDIA_CODEC_T codecType, UINT64 pts);

HOA_STATUS_T HOA_MEDIA_GetCapturedImage(MEDIA_CHANNEL_T ch, MEDIA_FORMAT_T format, MEDIA_CAPTURED_IMAGE_T *pCapturedImage);
HOA_STATUS_T HOA_MEDIA_FreeCapturedImage(MEDIA_CHANNEL_T ch, MEDIA_CAPTURED_IMAGE_T *pCapturedImage);
HOA_STATUS_T HOA_MEDIA_SetPlaySpeed(MEDIA_CHANNEL_T ch, BOOLEAN bForward, UINT8 speedInt, UINT8 speedFrac);
HOA_STATUS_T HOA_MEDIA_GetSourceInfo(MEDIA_CHANNEL_T ch, MEDIA_SOURCE_INFO_T *pSourceInfo);
HOA_STATUS_T HOA_MEDIA_GetSubtitleProperty(MEDIA_CHANNEL_T ch, HOA_MEDIA_SUBT_PROP_TYPE_T subtitleProperty, MEDIA_SUBTITLE_INFO_T *pSubtitleInfo);
HOA_STATUS_T HOA_MEDIA_SetSubtitleProperty(MEDIA_CHANNEL_T ch, HOA_MEDIA_SUBT_PROP_TYPE_T subtitleProperty, MEDIA_SUBTITLE_INFO_T subtitleInfo);
HOA_STATUS_T HOA_MEDIA_GetAudioProperty(MEDIA_CHANNEL_T ch, HOA_MEDIA_AUDIO_PROP_TYPE_T audioProperty, MEDIA_AUDIO_INFO_T *pAudioInfo);
HOA_STATUS_T HOA_MEDIA_SetAudioProperty(MEDIA_CHANNEL_T ch, HOA_MEDIA_AUDIO_PROP_TYPE_T audioProperty, MEDIA_AUDIO_INFO_T audioInfo);
HOA_STATUS_T HOA_MEDIA_SetHttpHeader(MEDIA_CHANNEL_T ch, UINT8* pData, UINT16 dataSize);
HOA_STATUS_T HOA_MEDIA_GetMediaServerList(MEDIA_CHANNEL_T ch, MEDIA_SERVER_LIST_T *pServerList);
HOA_STATUS_T HOA_MEDIA_SetCurrentMediaServer(MEDIA_CHANNEL_T ch, MEDIA_SERVER_INFO_T *pServerInfo);
HOA_STATUS_T HOA_MEDIA_GetCurrentMediaServer(MEDIA_CHANNEL_T ch, MEDIA_SERVER_INFO_T *pServerInfo);
HOA_STATUS_T HOA_MEDIA_RegisterPMSCallback(MEDIA_CHANNEL_T ch, PMS_CB_T pfnPMSCB);
HOA_STATUS_T HOA_MEDIA_GetMediaServerCount(MEDIA_CHANNEL_T ch, UINT32 *pServerCount);
HOA_STATUS_T HOA_MEDIA_GetMediaType(MEDIA_CHANNEL_T ch, HOA_MEDIA_TYPE_T *pMediaType);

HOA_STATUS_T HOA_MEDIA_GetWVDeviceID(MEDIA_CHANNEL_T ch, CHAR *pWVDeviceID, UINT16 *pDeviceIDSize);

HOA_STATUS_T HOA_TV_ChannelUp(BOOLEAN bShowBanner, API_CHANNEL_NUM_T *pChannelNum);
HOA_STATUS_T HOA_TV_ChannelDown(BOOLEAN bShowBanner, API_CHANNEL_NUM_T *pChannelNum);
HOA_STATUS_T HOA_TV_SetChannel(BOOLEAN bShowBanner, API_CHANNEL_NUM_T *pChannelNum);
HOA_STATUS_T HOA_TV_GetCurrentChannel(HOA_CHANNEL_INFO_T *pChannelInfo);
HOA_STATUS_T HOA_TV_SetVolume(BOOLEAN bShowVolumebar, HOA_APP_TYPE_T appType, BOOLEAN bRelative, SINT8 volumeIn, UINT8 *pVolumeOut);
HOA_STATUS_T HOA_TV_GetCurrentVolume(HOA_APP_TYPE_T appType, SINT8 *pVolume);
HOA_STATUS_T HOA_TV_SetMute(BOOLEAN bShowVolumebar, BOOLEAN bMute);
HOA_STATUS_T HOA_TV_GetMute(BOOLEAN *pbMute);

HOA_STATUS_T HOA_TV_SetAVBlock(BOOLEAN bBlockAudio, BOOLEAN bBlockVideo);
HOA_STATUS_T HOA_TV_ResetAVBlock(void);

HOA_STATUS_T HOA_TV_SetAspectRatio(HOA_ASPECT_RATIO_T ratio);
HOA_STATUS_T HOA_TV_ResetAspectRatio(void);
HOA_STATUS_T HOA_TV_SetDefaultPQ(void);
HOA_STATUS_T HOA_TV_SetLocalDimmingOFF(void);
HOA_STATUS_T HOA_TV_GetDisplayResolution(UINT32 *pWidth, UINT32 *pHeight);
HOA_STATUS_T HOA_TV_SetDisplayArea(HOA_RECT_T *pInRect, HOA_RECT_T *pOutRect);
HOA_STATUS_T HOA_TV_SetDisplayAreaEx(HOA_RECT_T *pInRect, HOA_RECT_T *pOutRect);
HOA_STATUS_T HOA_TV_ResetDisplayArea(void);

HOA_STATUS_T HOA_TV_GetCurrentTime(TIME_T *pTime);

HOA_STATUS_T HOA_TV_GetChannelList(UINT32 attribute, HOA_CHANNEL_LIST_T *pChannelList);
HOA_STATUS_T HOA_TV_FreeChannelList(HOA_CHANNEL_LIST_T *pChannelList);
HOA_STATUS_T HOA_TV_GetEventInfoList(API_CHANNEL_NUM_T *pChannelNum, TIME_T *pStartTime, TIME_T *pEndTime,
							HOA_EVENT_INFO_LIST_T *pEventInfoList);
HOA_STATUS_T HOA_TV_FreeEventInfoList(HOA_EVENT_INFO_LIST_T *pEventInfoList);
HOA_STATUS_T HOA_TV_GetScheduleList(HOA_SCHEDULE_INFO_LIST_T *pScheduleInfoList);
HOA_STATUS_T HOA_TV_FreeScheduleList(HOA_SCHEDULE_INFO_LIST_T *pScheduleInfoList);
HOA_STATUS_T HOA_TV_AddSchedule(char *szScheduleName, UINT16 scheduleNameLen, SCHEDULE_TYPE_T scheduleType,
									API_CHANNEL_NUM_T *pChannelNum, TIME_T *pStartTime, TIME_T *pEndTime);
HOA_STATUS_T HOA_TV_DelSchedule(UINT32 scheduleID);

HOA_STATUS_T HOA_TV_SetAudioMode(HOA_AUDIO_MODE_T audioMode);
HOA_STATUS_T HOA_TV_GetAudioMode(HOA_AUDIO_MODE_T *pAudioMode);

HOA_STATUS_T HOA_TV_GetCurrentAVBlock(BOOLEAN *pbBlockAudio, BOOLEAN *pbBlockVideo);
HOA_STATUS_T HOA_TV_GetCurrentAspectRatio(HOA_ASPECT_RATIO_T *pRatio);
HOA_STATUS_T HOA_TV_GetCurrentDisplayArea(HOA_RECT_T *pInRect, HOA_RECT_T *pOutRect);

HOA_STATUS_T HOA_TV_GetDisplayPanelType(HOA_TV_PANEL_ATTRIBUTE_TYPE_T panelAttribType, UINT32 *pType);
HOA_STATUS_T HOA_TV_GetSystemInfo(HOA_TV_INFO_T *pTVInfo);

HOA_STATUS_T HOA_TV_GetParentalLockOnOff(BOOLEAN *pbOn);
HOA_STATUS_T HOA_TV_GetParentalGuidanceSettings(HOA_RATING_TYPE_T ratingType, UINT8 settingsSize, UINT8 *pSettings);
HOA_STATUS_T HOA_TV_CheckPassword(UINT8 *pPassword, BOOLEAN *pMatched);

HOA_STATUS_T HOA_TV_SetDisplayMode(HOA_DISPLAYMODE_T displayMode);
HOA_STATUS_T HOA_TV_GetDisplayMode(HOA_DISPLAYMODE_T *pDisplayMode);

HOA_STATUS_T HOA_TV_GetBSIOnOff(BOOLEAN *pbBSIOn);
HOA_STATUS_T HOA_TV_PrintBSI(const char * pcBSIMsg, ...);

HOA_STATUS_T HOA_TV_SetDimmingOff(BOOLEAN bOff);

HOA_STATUS_T HOA_TV_GetLocaleInfo(HOA_LOCALE_T localeType, UINT32 *pLocaleInfo);
HOA_STATUS_T HOA_TV_GetSWUpdateExist(BOOLEAN *pbExist);

HOA_STATUS_T HOA_TV_GetCapability(HOA_TV_SUPPORT_TYPE_T supportType, UINT32 *pSupport);

HOA_STATUS_T HOA_TV_CreatePopup(HOA_POPUP_OPTION_T *pPopupOption, POPUP_CB_T pfnPopupCB, UINT32 *pPopupHandle);
HOA_STATUS_T HOA_TV_UpdatePopup(UINT32 popupHandle, HOA_POPUP_OPTION_T *pPopupOption);
HOA_STATUS_T HOA_TV_DestroyPopup(UINT32 popupHandle);

HOA_STATUS_T HOA_TV_SwitchToOSD(HOA_TV_OSD_TYPE_T osdType, HOA_TV_OSD_UPDATE_TYPE_T updateType);

HOA_STATUS_T HOA_TV_GetLocalTimeOffset(BOOLEAN *pbPlus, UINT8 *pOffsetHour, UINT8 *pOffsetMin);
HOA_STATUS_T HOA_TV_GetMotionRemoconOnOff(BOOLEAN *bOn);
HOA_STATUS_T HOA_TV_SendMessage(HOA_TV_MESSAGE_TYPE_T message, UINT32 param);
HOA_STATUS_T HOA_TV_SetWebcamDisplaySettings(BOOLEAN bOn, HOA_RECT_T *pOutRect);
HOA_STATUS_T HOA_TV_SetScreensaverOff(BOOLEAN bOff);
HOA_STATUS_T HOA_TV_SetMotionRemoconSupport(ADDON_MOTION_SUPPORT_T motionSupport);
HOA_STATUS_T HOA_TV_SmartTextSupport(ADDON_HOST_USER_SMART_MSG_T showSelect, ADDON_SMART_TEXT_T smartText);
HOA_STATUS_T HOA_TV_GetWebcamOnOff(BOOLEAN *pbOn);
HOA_STATUS_T HOA_TV_GetNSUVersion(UINT32 *pVersion);
HOA_STATUS_T HOA_IO_GetSDPUpdatePath(HOA_SDP_UPDATE_PATH_T type, UINT16 *pPathSize, char *pszPath);
HOA_STATUS_T HOA_IO_CheckSDPForceUpdate(void);
HOA_STATUS_T HOA_TV_GetSecureSerialNumber(UINT8 serial[256]);
HOA_STATUS_T HOA_TV_GetNetcastPlatformVersion(CHAR *pNetcastPltVer);
HOA_STATUS_T HOA_TV_SetNSUMenu(void);
HOA_STATUS_T HOA_TV_GetBlackOutType(HOA_BLACKOUT_TYPE_T *blackOutInfo, HOA_STRING_T* strBOType);
HOA_STATUS_T HOA_TV_FreeBlackOutType(HOA_STRING_T* sBlackOut);
HOA_STATUS_T HOA_TV_GetRemoconTypeInformation(UINT8 *pRemoconType);
// added 2010.11.8 by jaeguk.lee
HOA_STATUS_T HOA_TV_DMEM_GetMemInfo(UINT32* totalSize, UINT32* allocSize, UINT32* freeSize);

HOA_STATUS_T HOA_TV_SetMotionRCControlPad(HOA_OVERLAY_CONTROLPAD_T controlPad, BOOLEAN bDisplayOn, ADDON_MOTION_SUPPORT_T transient, UINT32 timeOut);
HOA_STATUS_T HOA_TV_SetMotionRCPosition(HOA_TV_MOTION_POINT_MODE_T MRCPointerMode, UINT32 xAxis, UINT32 yAxis, UINT32 zAxis);
HOA_STATUS_T HOA_TV_SetMotionRCCursorOn(BOOLEAN bCursorOn, UINT32 timeout);
HOA_STATUS_T HOA_TV_CreateAppsInitMsgBox(void);
HOA_STATUS_T HOA_TV_CreateMuteOSD(void);
HOA_STATUS_T HOA_TV_SetPlayState(MEDIA_PLAY_STATE_T playState);
HOA_STATUS_T HOA_TV_GetPlayState(MEDIA_PLAY_STATE_T *playState);
HOA_STATUS_T HOA_TV_SetAVBlockEx(BOOLEAN bBlockAudio, BOOLEAN bBlockVideo);
HOA_STATUS_T HOA_TV_SetTriDModeOn (HOA_TV_3D_INPUTMODE_TYPE_T TriDInputMode, BOOLEAN bLRBalance);
HOA_STATUS_T HOA_TV_SetTriDModeOff (void);
HOA_STATUS_T HOA_TV_GetInstartSystemInformation(HOA_INSTART_SYSTEM_INFO_T *pInstartsysteminfo);
HOA_STATUS_T HOA_TV_SetMediaLinkState(UINT32 mediaLinkState);
HOA_STATUS_T HOA_TV_SetMotionRCDisplayTime(UINT32 timeOut);
HOA_STATUS_T HOA_TV_SelCursorType(HOA_TV_GESTURE_POINT_TYPE_T cursorType);

HOA_STATUS_T HOA_IO_GetAvailableStorage(HOA_STORAGE_TYPE_T *pAvailableStorage);
HOA_STATUS_T HOA_IO_GetUSBDevType(HOA_USB_DEV_TYPE_T *pDevType);
HOA_STATUS_T HOA_IO_SetUSBFormat(CHAR *pDevName, HOA_USB_DEV_TYPE_T deviceType);
HOA_STATUS_T HOA_IO_GetStoragePath(HOA_STORAGE_TYPE_T storageType, UINT16 *pPathSize, char *pszPath);


HOA_STATUS_T HOA_IO_CheckAppStoreInternal(HOA_TVAPPS_APPSTORE_CHECK_TYPE_T *pCheckAppStore);
HOA_STATUS_T HOA_IO_SetAppStoreInternalFormat(HOA_TVAPPS_APPSTORE_CHECK_TYPE_T CheckAppStore);


HOA_STATUS_T HOA_IO_CopyFile(char *pszPathSrc, char *pszPathDest);
HOA_STATUS_T HOA_IO_MoveFile(char *pszPathSrc, char *pszPathDest);
HOA_STATUS_T HOA_IO_DeleteFile(char *pszPath, BOOLEAN bRecursive);
HOA_STATUS_T HOA_IO_GetNetworkStatus(char *pszIpAddress, HOA_NETWORK_TYPE_T *pActivatedNetwork, HOA_NETWORK_STATUS_T *pStatus);

HOA_STATUS_T HOA_IO_GetNetworkSettings(HOA_NETWORK_TYPE_T networkType, HOA_NETCONFIG_T *pNetworkSettings);
HOA_STATUS_T HOA_IO_SetNetworkSettings(HOA_NETWORK_TYPE_T networkType, HOA_NETCONFIG_T *pNetworkSettings);

HOA_STATUS_T HOA_IO_GetWirelessNetworkStatus(HOA_WIRELESSNETWORK_STATUS_T *pStatus);

HOA_STATUS_T HOA_IO_GetSDPCurrentPath(HOA_SDP_PATH_TYPE_T pathType, UINT16 *pPathSize, CHAR *pSDPPath);
HOA_STATUS_T HOA_IO_GetSDPRollbackPath(HOA_SDP_PATH_TYPE_T pathType, UINT16 *pPathSize, CHAR *pSDPPath);
HOA_STATUS_T HOA_IO_GetSDPCPVersion(CHAR *pCpID, HOA_SDP_VER_T *pCpVersion);

// added 2010.08.28 by ieeum.lee
HOA_STATUS_T HOA_IO_GetAvailableStorage(HOA_STORAGE_TYPE_T *pAvailableStorage); 
HOA_STATUS_T HOA_IO_GetUSBDevType(HOA_USB_DEV_TYPE_T *pDevType);
HOA_STATUS_T HOA_IO_SetUSBFormat(CHAR *pDevName, HOA_USB_DEV_TYPE_T deviceType);
HOA_STATUS_T HOA_IO_GetUSBPortCount(UINT8 *pUSBportCount);
HOA_STATUS_T HOA_IO_CheckCPBox(BOOLEAN *pbCPBox);



HOA_STATUS_T HOA_IO_GetSDPUpdateInformation(BOOLEAN *pSDPUpdateInfo);
HOA_STATUS_T HOA_IO_SetSDPUpdateInformation(BOOLEAN SDPUpdateInfo);

void HOA_IPTV_Init(void);	/* need to be redesigned */
void HOA_IPTV_Final(void);	/* need to be redesigned */
HOA_STATUS_T HOA_IPTV_GetTunerInfoList(HOA_TUNER_LIST_T *pTunerList);
HOA_STATUS_T HOA_IPTV_FreeTunerInfoList(HOA_TUNER_LIST_T *pTunerList);
HOA_STATUS_T HOA_IPTV_TuneIP(UINT32 channel,
								HOA_IP_TYPE_T networkType,
								UINT8 address[16],
								HOA_IPTV_TRANSPORT_T transportType,
								UINT16 port,
								void *extension,
								UINT32 extensionLen);
HOA_STATUS_T HOA_IPTV_TuneFile(UINT32 channel, UINT8 *url, UINT32 urlLen, UINT64 position,  UINT64 duration);
HOA_STATUS_T HOA_IPTV_ReleaseTuner(UINT32 channel);
HOA_STATUS_T HOA_IPTV_SelectService(HOA_IPTV_AV_MODE_T mode, UINT32 pcrPID,
										UINT32 videoPID, UINT32 vType,
										UINT32 audioPID, UINT32 aType,
										HOA_IPTV_AUDIO_T audioMode);
HOA_STATUS_T HOA_IPTV_Play(HOA_IPTV_AV_MODE_T avMode);
HOA_STATUS_T HOA_IPTV_Stop(HOA_IPTV_AV_MODE_T avMode);
HOA_STATUS_T HOA_IPTV_RequestSection(UINT32 channel, UINT32 pid,
										HOA_SECTION_FILTER_T sectionFilter,
										UINT32 buffSize,
										IPTV_SECTION_FILTER_CB_T callbackFunc,
										UINT8 *pFilterId);
HOA_STATUS_T HOA_IPTV_GetSectionFilterNum(UINT32 channel, UINT32 *pSfNum);
HOA_STATUS_T HOA_IPTV_CancelSection(UINT32 channel, UINT8 filterId);

HOA_STATUS_T HOA_IPTV_GetNVMNumOfBlocks(UINT32 *pBlockNum);
HOA_STATUS_T HOA_IPTV_GetNVMSize(UINT32 nvmBlockIdx, UINT32 *pSize);
HOA_STATUS_T HOA_IPTV_ReadNVM(UINT32 nvmBlockIdx, UINT32 offset, UINT32 dataSize, UINT8 *pData);
HOA_STATUS_T HOA_IPTV_WriteNVM(UINT32 nvmBlockIdx, UINT32 offset, UINT32 dataSize, UINT8 *pData);

HOA_STATUS_T HOA_IPTV_GetBackgroundResolution(UINT32 *pWidth, UINT32 *pHeight);
HOA_STATUS_T HOA_IPTV_DrawBackgroundImage(UINT16 x, UINT16 y, UINT16 width, UINT16 height, UINT32 dataSize, UINT8 *pData);
HOA_STATUS_T HOA_IPTV_FillBackgroundRect(UINT16 x, UINT16 y, UINT16 width, UINT16 height, UINT32 color);
HOA_STATUS_T HOA_IPTV_UpdateBackground(UINT16 x, UINT16 y, UINT16 width, UINT16 height);

HOA_STATUS_T HOA_IPTV_GetMikeCapability(BOOLEAN *pbMikeSupported, BOOLEAN *pbEchoSupported);
HOA_STATUS_T HOA_IPTV_SetMikeOnOff(BOOLEAN bOn);
HOA_STATUS_T HOA_IPTV_GetMikeOnOff(BOOLEAN *pbOn);
HOA_STATUS_T HOA_IPTV_SetMikeEchoOnOff(BOOLEAN bOn);
HOA_STATUS_T HOA_IPTV_GetMikeEchoOnOff(BOOLEAN *pbOn);
HOA_STATUS_T HOA_IPTV_SetMikeVolume(SINT8 volume);
HOA_STATUS_T HOA_IPTV_GetMikeVolume(SINT8 *pVolume);

HOA_STATUS_T HOA_IPTV_RequestToCheckNewFirmware(HOA_IPTV_FWDN_REQ_TYPE_T reqType);
HOA_STATUS_T HOA_IPTV_UpgradeFirmware(HOA_IPTV_FWDN_TYPE_T upgradeType);

HOA_STATUS_T NDSCB_SetNdsCB(NDSCB_FUNCTION_ID_T func_id, void *fnAddr);
HOA_STATUS_T HOA_NDS_SetPlayPosition(UINT32 x_connection, UINT32 pos, SINT32 speed);


// SDP I/F HOA Function by esca 10/08/11
HOA_STATUS_T HOA_SDPIF_RequestUserInfo(HOA_SDPIF_USER_INFO_T *pUserInfo);
HOA_STATUS_T HOA_SDPIF_RequestLogin(HOA_SDPIF_LOGIN_INFO_T logInInfo);
HOA_STATUS_T HOA_SDPIF_RequestLogout(void);
HOA_STATUS_T HOA_SDPIF_RequestSession(HOA_SDPIF_SES_INFO_T *pSessionInfo);

HOA_STATUS_T HOA_SDPIF_RequestCheckDuplicateID(CHAR *pUsrID);
HOA_STATUS_T HOA_SDPIF_RequestRegister(HOA_SDPIF_LOGIN_INFO_T logInInfo);

HOA_STATUS_T HOA_SDPIF_RequestUserList(void);
HOA_STATUS_T HOA_SDPIF_RequestUserDeactivation(CHAR *pUsrID);

HOA_STATUS_T HOA_SDPIF_RequestDeviceDeactivation(void);

HOA_STATUS_T HOA_SDPIF_NotifyChangedCountry(UINT32 countryCode, UINT32 countryCodeEx);
HOA_STATUS_T HOA_SDPIF_RequestCandidateCountry (void);
HOA_STATUS_T HOA_SDPIF_RequestCPList(CHAR *pCpList, UINT16 *pCpListSize);
HOA_STATUS_T HOA_SDPIF_RequestSecretInformation(HOA_SDPIF_SECRET_INFO_T *pSecretInfo);

// SDP I/F HOA Function by sophia 10/09/13
HOA_STATUS_T HOA_SDPIF_RequestDeviceAuth(void);
HOA_STATUS_T HOA_SDPIF_RequestCancelDeviceAuth(void);
HOA_STATUS_T HOA_SDPIF_GetHttpRequestHeaderVariablePart(CHAR **pReqHeader);
HOA_STATUS_T HOA_SDPIF_GetHttpRequestHeaderFixedPart(CHAR **pReqHeader);

HOA_STATUS_T HOA_SDPIF_RequestCurrentCountry (UINT32 *pCountryCode);
HOA_STATUS_T HOA_SDPIF_RequestSearchEnable (BOOLEAN *pSDPSearchEnable);
HOA_STATUS_T HOA_SDPIF_RequestNordicCountryInformation (BOOLEAN *pNordicCountryInfo);
HOA_STATUS_T HOA_SDPIF_GetCurrentServerUrl(CHAR **pServerUrl);
HOA_STATUS_T HOA_SDPIF_RequestDeleteDevice(void);
HOA_STATUS_T HOA_SDPIF_RequestAppStoreEnable (BOOLEAN *pAppStoreEnable);
HOA_STATUS_T HOA_SDPIF_RequestUserAuthentication(CHAR *pUsrID, CHAR *pPassWD);
HOA_STATUS_T HOA_SDPIF_RequestUpdateErrorLog(UINT32 moduleIdx, SLONG responseResult, CHAR *pErrorResult);
HOA_STATUS_T HOA_SDPIF_RequestValidOption (UINT32 *pValidOption);
HOA_STATUS_T HOA_SDPIF_RequestSDPOption(HOA_SDPIF_SDPOPTION_INFO_T *pSDPOption);
HOA_STATUS_T HOA_SDPIF_RequestExtUserSession(void);
HOA_STATUS_T HOA_SDPIF_GetNetcastVer(CHAR **pSDPVer);
HOA_STATUS_T HOA_SDPIF_NotifyCountryAuto(BOOLEAN bAutoCountry);
HOA_STATUS_T HOA_SDPIF_GetShowSelectCountry (BOOLEAN *bIsShow);
HOA_STATUS_T HOA_SDPIF_SetShowSelectCountry(BOOLEAN bIsShow);
/* HOA CEK 최적화 */
typedef struct APPCEK
{
	UINT32 	appID; 
	UINT8 	bszCEK[32];
} APPCEK_T;

HOA_UC_STATUS_T HOA_SECCHK_GetCEK(UINT32 appID, CHAR *filename, UINT8 *bszCEK);

#ifndef INCLUDE_ADDON_HOST
#ifdef INCLUDE_HOA_OSD
/**
 * pixel format.
 * ARGB888, ARGB4444, 8bpp palette ..etc .
*/
typedef enum {
	OSD_ARGB8888 = 0,		/**< ARGB8888 format */
	OSD_ARGB4444 = 1,		/**< ARGB4444 format */
	OSD_ARGB1555 = 2,		/**< ARGB1555 Pallette format */
	OSD_8BPP_PAL = 3,		/**< 8bit Pallette format */
} OSD_FORMAT_T;

/**
 * pixel depth.
 * 8bpp, 16bpp, 32bpp.
*/
typedef enum {
	OSD_8BPP 	= 0,			/**< 8 bit per pixel */
	OSD_16BPP 	= 1,			/**< 16 bit per pixel */
	OSD_32BPP 	= 2,			/**< 32 bit per pixel */
} OSD_PIXELDEPTH_T;

/** Frame Info */
typedef struct {
	UINT16					x;			/**< x */
	UINT16					y;			/**< y */
	UINT16					width;		/**< width */
	UINT16					height;		/**< height */

	OSD_FORMAT_T			format;		/**< available when pAddr!=NULL */
	OSD_PIXELDEPTH_T		pxlDepth; 	/**< available when pAddr!=NULL */
} OSD_FRAME_T;

HOA_STATUS_T HOA_OSD_GetResolution(UINT32 *pWidth, UINT32 *pHeight);
HOA_STATUS_T HOA_OSD_CreateFrameBuffer(UINT32 x, UINT32 y, UINT32 width, UINT32 height, UINT32 *pFrameBufferID);
HOA_STATUS_T HOA_OSD_DestroyFrameBuffer(UINT32 frameBufferID);
HOA_STATUS_T HOA_OSD_GetFrameBufferInfo(UINT32 frameBufferID, OSD_FRAME_T *pFrameInfo);
HOA_STATUS_T HOA_OSD_LockFrameBuffer(UINT32 frameBufferID, void **ppFrameBuffer);
HOA_STATUS_T HOA_OSD_UnlockFrameBuffer(UINT32 frameBufferID);
HOA_STATUS_T HOA_OSD_UpdateFrameBuffer(UINT32 frameBufferID);
HOA_STATUS_T HOA_OSD_CreateGC(UINT32 *pGCID);
HOA_STATUS_T HOA_OSD_DestroyGC(UINT32 gcID);
HOA_STATUS_T HOA_OSD_GetGCInfo(UINT32 gcID, OSD_GC_T *pGCInfo);
HOA_STATUS_T HOA_OSD_SetGCColor(UINT32 gcID, UINT32 color);
HOA_STATUS_T HOA_OSD_SetGCColorBG(UINT32 gcID, UINT32 color);
HOA_STATUS_T HOA_OSD_SetGCFont(UINT32 gcID, UINT32 fontID, UINT16 fontSize, UINT16 fontWidth);
HOA_STATUS_T HOA_OSD_CreateFont(char *fontName, UINT8 *pFontDataBuf, UINT32 fontDataSize, UINT32 *pFontID);
HOA_STATUS_T HOA_OSD_DestroyFont(UINT32 fontID);
HOA_STATUS_T HOA_OSD_CreateImageFromBuffer(UINT8 *pImageDataBuf, UINT32 imageDataSize, UINT32 *pImageID);
HOA_STATUS_T HOA_OSD_CreateImageFromFile(char *imageFileName, UINT16 imgFileNameSize, UINT32 *pImageID );
HOA_STATUS_T HOA_OSD_GetImageInfo(UINT32 imageID, OSD_IMAGE_T *pImageInfo);
HOA_STATUS_T HOA_OSD_DestroyImage(UINT32 imageID);
HOA_STATUS_T HOA_OSD_DrawLine(UINT32 frameBufferID, UINT32 gcID, UINT16 lineWidth, UINT32 sx, UINT32 sy, UINT32 ex, UINT32 ey);
HOA_STATUS_T HOA_OSD_DrawFillRect(UINT32 frameBufferID, UINT32 gcID, UINT32 x, UINT32 y, UINT32 width, UINT32 height);
HOA_STATUS_T HOA_OSD_DrawRect(UINT32 frameBufferID, UINT32 gcID, UINT16 lineWidth, UINT32 x, UINT32 y, UINT32 width, UINT32 height);
HOA_STATUS_T HOA_OSD_DrawText(UINT32 frameBufferID, UINT32 gcID, char *szString, UINT16 stringSize, OSD_TEXTFLAGS_T flags);
HOA_STATUS_T HOA_OSD_DrawImage(UINT32 frameBufferID, UINT32 imageID, UINT32 x, UINT32 y, UINT32 width, UINT32 height);
HOA_STATUS_T HOA_OSD_CopyArea(UINT32 srcFrameBufferID, UINT32 destFrameBufferID,
								UINT32 srcX, UINT32 srcY, UINT32 srcWidth, UINT32 srcHeight,
								UINT32 destX, UINT32 destY, UINT32 destWidth, UINT32 destHeight);
#endif //INCLUDE_HOA_OSD
#endif //INCLUDE_ADDON_HOST

#ifdef __cplusplus
}
#endif


#endif //__ADDON_HOA_H__

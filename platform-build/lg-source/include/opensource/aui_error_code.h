#ifndef _AUI_ERROR_CODE_H_
#define _AUI_ERROR_CODE_H_


/************************************************************************/
/* error code                                                           */
/************************************************************************/
#define AUI_R_SUCCESS						0
#define AUI_R_GENERAL_ERROR					-1
#define AUI_R_HASH_ERROR					-2
#define AUI_R_INVALID_DATA					-3
#define AUI_R_INVALID_PACKET_SIZE			-4
#define AUI_R_INVALID_TRANSMISSION_RESP		-5
#define AUI_R_INVALID_BCC_VALUE				-6
#define AUI_R_INVALID_RESP_DATAFIELD		-7
#define AUI_R_FAIL_GET_SIGN_CERT			-8
#define AUI_R_INVALID_CHECK_ID				-9
#define AUI_R_REMOVE_ACCESS_USB				-10

#define AUI_R_LIB_NOT_INITIALIZED			-101
#define AUI_R_SERIALPORT_NOT_FOUND			-102
#define AUI_R_ACCESSUSB_NOT_FOUND			-103
#define AUI_R_NOT_CONNECTED_USB				-104
#define AUI_R_INVALID_SEC_SESSION			-105
#define AUI_R_UNREGISTERED_ACCESSUSB		-106
#define AUI_R_USB_RETURNS_ERRCODE			-107
#define AUI_R_MISMATCH_USBUID				-108
#define AUI_R_EXPIRED_TIME					-109
#define AUI_R_EXPIRED_COUNT					-110
#define AUI_R_NO_ACCESS_PERMISSION			-111
#define AUI_R_ACCESS_DENY					-112
#define AUI_R_INVALID_ACCESS_PERMIT			-113
#define AUI_R_FAIL_OPEN_SERIAL_USB			-114
#define AUI_R_EXCEED_NAK_RETRY_LIMIT		-115
#define AUI_R_FAIL_WRITE_COM_USB			-116
#define AUI_R_INVALID_KRI					-117
#define AUI_R_SERIAL_READ_ERROR				-118
#define AUI_R_INVALID_PWD					-119



#endif

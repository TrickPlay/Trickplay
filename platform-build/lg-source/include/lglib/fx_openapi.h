/******************************************************************************
 *   LCD TV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2008 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/

/** @file fx_openapi.h
 *
 *  fxui open api
 *
 *  @author     dhjung(donghwan.jung@lge.com)
 *  @version    1.0
 *  @date       2011.06.20
 *  @note
 *  @see
 */

#ifndef _FX_OPENAPI_H_
#define _FX_OPENAPI_H_

#include <dbus/dbus.h>
#include "appfrwk_openapi_types.h"

#ifdef __cplusplus
extern "C" {
#endif

#if 1
/* fx_openapi_send2fxiui.c */
HOA_STATUS_T HOA_FXUI_RegisterAgreeTermCallback(FXUI_CB_T pfnFXUICB);

#endif

#ifdef __cplusplus
}
#endif
#endif

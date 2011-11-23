/******************************************************************************
 *   LCD TV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2008 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/

/** @file br_openapi.h
 *
 *  browser open api
 *
 *  @author     Hayden Lee (hayden.lee@lge.com)
 *  @version    1.0
 *  @date       2011.09.30
 *  @note
 *  @see
 */

#ifndef _BR_OPENAPI_H_
#define _BR_OPENAPI_H_

#include <dbus/dbus.h>
#include "appfrwk_openapi_types.h"

#ifdef __cplusplus
extern "C" {
#endif

extern HOA_STATUS_T HOA_BROWSER_CallHbbTV( HBBTV_MALLOC_T funcMAlloc, UINT8 **ppRet, UINT32 *pRetSz, UINT8 *pParam, UINT32 nParamSz, BOOLEAN bSync);

#ifdef __cplusplus
}
#endif
#endif

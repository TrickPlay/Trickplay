/*
 * FILE:    ntp.h
 * AUTHOR:  O.Hodson
 * 
 * NTP utility functions to make rtp and rtp round time calculation
 * a little less painful.
 *
 * Copyright (c) 2000 University College London
 * All rights reserved.
 *
 * $Id: ntp.h 461 2000-03-07 14:51:45Z ucacoxh $
 */

#ifndef _NTP_H
#define _NTP_H

#if defined(__cplusplus)
extern "C" {
#endif
        
#define  ntp64_to_ntp32(ntp_sec, ntp_frac)          \
               ((((ntp_sec)  & 0x0000ffff) << 16) | \
                (((ntp_frac) & 0xffff0000) >> 16))

#define  ntp32_sub(now, then) ((now) > (then)) ? ((now) - (then)) : (((now) - (then)) + 0x7fffffff)

void     ntp64_time(uint32_t *ntp_sec, uint32_t *ntp_frac);

#if defined(__cplusplus)
}
#endif

#endif /* _NTP_H */

//
//  rtpenc_h264.h
//  Livu
//
//  Created by Steve McFarlin on 7/29/11.
//  Copyright 2011 Steve McFarlin. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

struct rtp;

/*!
 @abstract Send a NAL unit.
 @discussion
 
	This functon sunds a single NAL unit using the RTP session. The
	NAL unit is expected to be in Annex B format such that the first
	four bytes are 0x00 0x00 0x00 0x01.
 
 @param session The RTP session
 @param rtp_ts The time stamp for the AAC payload
 @param pt Payload type
 @param buff The buffer containing the NAL unit
 @param size The size of the NAL unit in buff
 @result int The number of bytes sent or -1 if an error occured.
 */
int send_nal(struct rtp *session, int64_t rtp_ts, uint8_t pt, const uint8_t *buff, int size, struct timeval *timeout);
int send_sps(struct rtp *session, int64_t rtp_ts, uint8_t pt, const uint8_t *buff, int size, struct timeval *timeout);
int send_pps(struct rtp *session, int64_t rtp_ts, uint8_t pt, const uint8_t *buff, int size, struct timeval *timeout);

#ifdef __cplusplus
}
#endif
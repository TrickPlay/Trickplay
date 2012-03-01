//
//  rtpenc_h264.c
//  Livu
//
//  Created by Steve McFarlin on 7/29/11.
//  Copyright 2011 Steve McFarlin. All rights reserved.
//

#import "rtpenc_h264.h"
#include "rtp.h"
#include "sm_math.h"
#define kMaxPayloadSize 1200



int send_nal(struct rtp *session, int64_t rtp_ts, uint8_t pt, const uint8_t *buff, int size, struct timeval *timeout) {

	uint8_t rtp_nal[kMaxPayloadSize];
	int ret = 0;
	if(size < 5) { return 0;}
	
	size -= 4;
	buff += 4;

	uint8_t type = buff[0] & 0x1F;
	
		
	rtp_ts = rescale(rtp_ts, kAVBaseTime, kRTPAVCBaseTime);
	
	//NSLog(@"Video TS: %u",*buff);
	
	if(size <= kMaxPayloadSize) {
		uint8_t type = buff[0] & 0x1F;
		//printf("NALU of type %d and size %d\n", type, size);
		ret = rtp_send_data(session, rtp_ts, pt, 1, 0, NULL, (char*) buff, size, NULL, 0, 0, timeout);
	}
	else {
		//shamefull jack from FFmpeg. My solution was verbose.
		uint8_t type = buff[0] & 0x1F;
		//printf("NALU of type %d and size %d\n", type, size);
		uint8_t nri = buff[0] & 0x60;
		//rtp_nal[0] = 0; rtp_nal[1] = 0;
		rtp_nal[0] = 28;        // FU Indicator; Type = 28 ---> FU-A
		rtp_nal[0] |= nri;
		rtp_nal[1] = type;
		rtp_nal[1] |= 1 << 7;
		buff += 1;
		size -= 1;
		while (size + 2 > kMaxPayloadSize) {
			memcpy(&rtp_nal[2], buff, kMaxPayloadSize - 2);
			ret += rtp_send_data(session, rtp_ts, pt, 0, 0, NULL, (char*) rtp_nal, kMaxPayloadSize, NULL, 0, 0, timeout);
			buff += kMaxPayloadSize - 2;
			size -= kMaxPayloadSize - 2;
			rtp_nal[1] &= ~(1 << 7);
		}
		rtp_nal[1] |= 1 << 6;
		memcpy(&rtp_nal[2], buff, size);
		ret += rtp_send_data(session, rtp_ts, pt, 1, 0, NULL, (char*) rtp_nal, size + 2, NULL, 0, 0, timeout);
		
	}
	rtp_update(session);
	rtp_send_ctrl(session, rtp_ts, NULL);
	
	//printf("RTP Send Return: %d\n", ret);
	
	return ret;
}

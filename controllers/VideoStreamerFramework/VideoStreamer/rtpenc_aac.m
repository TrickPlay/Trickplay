//
//  rtpenc_aac.c
//  Livu
//
//  Created by Steve McFarlin on 7/29/11.
//  Copyright 2011 Steve McFarlin. All rights reserved.
//

#import <Foundation/Foundation.h>
#include  <string.h>
#include "rtpenc_aac.h"
#include "rtp.h"
#import "sm_math.h"


/*
int build_single_au_payload(AACDiscretePayload *pkt, char *data, int size) {
	
	pkt->payload_size = size + sizeof(pkt->payload.au_header) + sizeof(pkt->payload.au_header_length);
	pkt->payload.au_header_length = 16;
	pkt->payload.au_header = 0 | (size << 3);
	memcpy(pkt->payload.au_data, data, size);
	
	return 0;
}
*/

int send_aac_au(struct rtp *session, uint32_t rtp_ts, uint8_t pt, const char *data, uint16_t size, struct timeval *timeout) {
	AACDiscretePayload pkt;
	int ret ;
	if(size > kMaxAACFrameSize) { return -2; }
	if(size < 7) { return 0;}
	
	//NSLog(@"Audio TS: %u", rtp_ts);
	
	//rtp_ts = rescale(rtp_ts, kAVBaseTime, 44100);
	
	pkt.payload_size = size + sizeof(pkt.payload.au_header) + sizeof(pkt.payload.au_header_length);
	pkt.payload.au_header_length =  0x1000;
	pkt.payload.au_header = CFSwapInt16HostToBig(size << 3);
	
	memcpy(pkt.payload.au_data, data, size);
	ret = rtp_send_data(session, rtp_ts, pt, 1, 0, NULL, (char*) &pkt.payload, pkt.payload_size, NULL, 0, 0, timeout);
	rtp_update(session);
	rtp_send_ctrl(session, rtp_ts, NULL);
	
	//NSLog(@"RTP Send Return: %d", ret);
	
	return ret ;
}

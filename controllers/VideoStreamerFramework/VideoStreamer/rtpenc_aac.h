//
//  rtpenc_aac.h
//  Livu
//
//  Created by Steve McFarlin on 7/29/11.
//  Copyright 2011 Steve McFarlin. All rights reserved.
//

#define kMaxAACFrameSize 1024

struct rtp;

/*!
 @discussion

	This structure only support a single AU for the packet.
 */
struct aac_discrete_payload {
	uint16_t	au_header_length;
	uint16_t	au_header;
	uint8_t		au_data[kMaxAACFrameSize];
};

//This structure will be 1024 bytes
struct aac_single_au_payload {
	uint16_t payload_size;
	struct aac_discrete_payload payload;
};
typedef struct aac_single_au_payload AACDiscretePayload;


/*!
 @abstract Build a single AU RTP payload
 @discussion
 
	This function builds a single AU RTP payload. The AACDiscretePacket structre
	must be preallocated and contain enough space for the header. The packet will
	be structured as follows
 
	[16][ 0 | payload size << 3][data]
 
	This means sizelength = 13 and indexlength = 3. 

 @param pkt AACDiscretePayload
 @param data The data to load into the packet
 @param size The size of the data
 @result int 0 if successful -1 if data is too large. 
 */
//inline int build_single_au_payload(AACDiscretePayload *pkt, char *data, int size);

/*!
 @abstract Send a single aac access unit
 
 @param session The RTP session
 @param rtp_ts The time stamp for the AAC payload
 @param pt Payload type
 @param data The AAC data
 @param size The size of the data
 
 @result int The number of bytes sent or -1 if the size of the data is larger the kMaxAACFrameSize
 */
int send_aac_au(struct rtp *session, uint32_t rtp_ts, uint8_t pt, const char *data, uint16_t size, struct timeval *timeout);


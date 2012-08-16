//
//  RTSPClient.h
//  Video Streaming
//
//  Created by Rex Fenley on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

#include <ctype.h>
#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>    
#include <netdb.h>    
#include <unistd.h>
#include "base64.h"

#include <netinet/tcp.h>

#import <CommonCrypto/CommonDigest.h>

#ifdef __cplusplus
}
#endif

#define RTSP_OK             200
#define RTSP_BAD_USER_PASS  401

#define SOCK_ERR_RESOLVE    -1
#define SOCK_ERR_CREATE     -2
#define SOCK_ERR_CONNECT    -3
#define SOCK_ERR_WRITE      -4
#define SOCK_ERR_READ       -5

#define RTSP_RESP_ERR       -6
#define RTSP_RESP_ERR_SESSION   -7

/* Lower transport type */

enum _rtsp_transport {
    RTSP_TRANSPORT_UDP = 0,
    RTSP_TRANSPORT_TCP = 1
};

enum StreamType {
    RTSP_PLAY,
    RTSP_PUBLISH
};

typedef enum _rtsp_transport rtsp_transport_t;
typedef enum StreamType stream_t;

void *get_in_addr(struct sockaddr *sa);

@interface RTSPClient : NSObject {

    NSString *host;
    NSString *path;
    int port;
    NSString *user;
    NSString *pass;
    
    int sock;
    rtsp_transport_t transport;
    stream_t streamType;
    NSString *sdp;
    
    NSMutableDictionary *responseHeader;
    
    int cSeq;
    NSString *session;
    int mediaCount;
    int channelCount;
    
}

@property (nonatomic, retain, readonly) NSString *host, *path;
@property (nonatomic, copy) NSString *user, *pass;
@property (nonatomic, assign, readonly) int port;
@property (nonatomic, readonly) NSString *url;
@property (nonatomic, retain, readonly) NSMutableDictionary *responseHeader;
@property (nonatomic, copy) NSString *sdp;
@property (nonatomic, readonly) int mediaCount;
@property (nonatomic, assign, readonly) NSString *session;
@property (nonatomic, assign, readonly) int sock;
@property (nonatomic, assign) stream_t streamType;
@property (nonatomic, assign) rtsp_transport_t transport;


/**
 * @abstract Connect to a RTSP server.
 *
 * @param host Host address
 * @param port Host connection port
 * @param path Resource path
 *
 * @result 0 for success negative otherwise.
 */
- (int) connectTo:(NSString*) host onPort:(int) port withPath:(NSString*) path;

/**
 * @abstract Send OPTIONS request
 *
 * @result int RTSP response code or negative if socket error.
 */
- (int) options;

/**
 * @abstract Send ANNOUNCE request
 * 
 * @discussion The SDP sould be set before calling this function.
 * 
 * @result int RTSP response code or negative if socket error.
 */
- (int) announce;


/**
 * @abstract DESCRIBE request
 *
 */
- (int) describe;

/**
 * @abstract Send SETUP request
 *
 * @discussion
 *
 * This will send the SETUP request to the server. For UDP requests you need to pass in
 * the client ports used for RTP and RTCP. For TCP these are not used. For TCP the interleave
 * is auto calculated based on the number of calls to this function. The first call is 0-1 and
 * the next 2-3 and so on.
 *
 * @param streamID The ID of the stream
 * @param rtpPort RTP port
 * @param rtspPort RTCP port
 * @result int The RTSP response code or negative if socket error.
 */
- (int) setup:(int) streamID withRtpPort:(int) rtpPort andRtcpPort:(int) rtcpPort;

/**
 * @abstract Send RECORD request
 *
 * @result int RTSP response code or negative if socket error.
 */
- (int) record;

/**
 * @abstract Send PLAY request
 *
 * @result int RTSP response code or negative if socket error.
 */
- (int) play;


/**
 * @abstract Send TEARDOWN request
 *
 * @result int RTSP response code or negative if socket error.
 */
- (int) teardown;

@end





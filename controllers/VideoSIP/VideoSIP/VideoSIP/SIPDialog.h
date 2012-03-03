//
//  SIPDialog.h
//  VideoSIP
//
//  Created by Rex Fenley on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sys/types.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <CoreFoundation/CoreFoundation.h>

@interface SIPDialog : NSObject {
    // This is our user name
    NSString *user;
    // This is our contact URI
    NSString *contactURI;
    // This is the original destination URI; do not change
    NSString *remoteURI;
    // This is the dynamic destination URI; this is not constant.
    // Used in the Request line and the MD5 authentication.
    // This URI will be updated as SIP discovers the final
    // destination URI.
    NSString *sipURI;
    // This is our IP address
    NSString *udp_client_ip;
    // This is our SIP port
    u_int32_t udp_client_port;
    // This is the destination SIP port
    u_int32_t udp_server_port;
    // This is our UDP socket to Asterisk
    int udp_socket;
    
}

@end

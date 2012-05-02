//
//  STUNClient.m
//  VideoSIP
//
//  Created by Rex Fenley on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "STUNClient.h"

#import <Security/Security.h>

#import <sys/types.h>
#import <sys/socket.h>
#import <netdb.h>


void free_attributes(attribute *attributes[], int length) {
    for (int i = 0; i < length; i++) {
        if (attributes[i]) {
            free(attributes[i]->value);
            free(attributes[i]);
        }
    }
}


@interface STUNClient()

- (NSDictionary *)parseResponse:(uint8_t *)response length:(int)length;

@end


@implementation STUNClient

- (id)init {
    self = [super init];
    
    if (self) {
        message_type = BINDING;
        message_length = 0;
        magic_cookie = MAGIC_COOKIE;
        // Cryptographically secure transaction id
        if (SecRandomCopyBytes(kSecRandomDefault, 12, transaction_id) != 0) {
            perror("Transaction ID for STUN could not be synthesized\n");
            [self release];
            return nil;
        }
    
        for (int i = 0; i < 100; i++) {
            attributes[i] = NULL;
        }
        
        // Set up a Binding request
        memset(request, 0, sizeof(request));
        ((uint16_t *)request)[0] = htons(message_type);
        ((uint16_t *)request)[1] = htons(message_length);
        request[4] = magic_cookie >> 24;
        request[5] = (magic_cookie & 0xFF0000) >> 16;
        request[6] = (magic_cookie & 0xFF00) >> 8;
        request[7] = magic_cookie & 0xFF;
        
        // Fill the request with the transaction id
        for (int i = 8; i < 20; i++) {
            request[i] = transaction_id[i - 8];
        }
    }
    
    return self;
}


- (NSDictionary *)getIpInfo {
    // Form a UDP socket to the STUN server
    struct addrinfo hints, *servinfo, *p;
    
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_protocol = SOCK_DGRAM;
    
    int rv;
    if ((rv = getaddrinfo(STUN_HOST, [[NSString stringWithFormat:@"%d", STUN_PORT] UTF8String], &hints, &servinfo)) != 0) {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
        return;
    }
    
    int sock;
    for (p = servinfo; p != NULL; p = p->ai_next) {
        if ((sock = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1) {
            perror("STUN socket could not be established");
        }
        
        if (connect(sock, p->ai_addr, p->ai_addrlen)) {
            close(sock);
            perror("STUN socket could not connect to STUN server");
        }
        
        break;
    }
    
    if (p == NULL) {
        fprintf(stderr, "STUN client failed to connect\n");
        return;
    }
    
    // Check the socket for writing the request
    fd_set wfds, rfds;
    struct timeval tv;
    
    FD_ZERO(wfds);
    FD_SET(sock, wfds);
    
    tv.tv_sec = 5;
    tv.tv_usec = 0;
    
    int resp_length = 0;
    uint8_t response[1024];
    memset(response, 0, sizeof(response));
    
    if (select(sock+1, NULL, &wfds, NULL, &tv) > 0) {
        // Write the request and wait for a response
        if (FD_ISSET(sock, wfds)) {
            if (send(sock, request, sizeof(request), NULL) != 20) {
                perror("Error Sending STUN request");
                return;
            }
            
            FD_ZERO(rfds);
            FD_SET(sock, rfds);
            tv.tv_sec = 15;
            tv.tv_usec = 0;
            
            if (select(sock+1, &rfds, NULL, NULL, &tv) > 0) {
                if (FD_ISSET(sock, rfds)) {
                    // TODO: No guarentee that the whole response packet was read
                    if ((resp_length = recv(sock, response, sizeof(response), 0)) <= 0) {
                        perror("Error Receiving STUN response");
                        return;
                    }
                    [self parseResponse:response length:resp_length];
                } else {
                    return;
                }
            }
        }
    }
}


- (NSDictionary *)parseResponse:(uint8_t *)response length:(int)length {
    uint16_t response_type = ntohs(((uint16_t *)response)[0]);
    uint16_t response_length = ntohs(((uint16_t *)response)[1]);
    uint32_t response_cookie = ntohl(((uint32_t *)response)[1]);
    
    // Check that this is a Binding Response
    if (response_type != BINDING_RESPONSE) {
        fprintf(stderr, "Response is not a Binding Response\n");
        return;
    }
    // Check that the length is greater than the size of MAPPED-ADDRESS attribute
    if (response_length < 8) {
        fprintf(stderr, "Response length not large enough for Binding Response\n");
        return;
    }
    // Check that the responses magic cookie equals the correct value
    if (response_cookie != MAGIC_COOKIE) {
        fprintf(stderr, "Response Magic Cookie not equal to 0x2112A442\n");
        return;
    }
    
    int current_attribute = 0;
    int pos = 20;
    while (pos < response_length + 20) {
        // Create the attribute
        attribute *attr = malloc(sizeof(attribute));
        attr->type = ((uint16_t)(response[pos]) << 8) + (uint16_t)(response[pos+1]);
        attr->length = ((uint16_t)(response[pos+2]) << 8) + (uint16_t)(response[pos+3]);
        attr->value = malloc(attr->length);
        for (int i = 0; i < attr->length; i++) {
            attr->value[i] = response[pos+4+i];
        }
        // Add the attribute to the lists of attributes
        attributes[current_attribute] = attr;
        current_attribute++;
        // Skip ahead to the next attribute
        int padding = 4 - attr->length%4;
        if (padding == 4) {
            padding = 0;
        }
        pos += 4 + length + padding;
    }
}


- (void)dealloc {
    if (attributes) {
        free_attributes(attributes, 100);
    }
}

@end

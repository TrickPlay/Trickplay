//
//  STUNClient.m
//  VideoSIP
//
//  Created by Rex Fenley on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "STUNClient.h"

#import <Security/Security.h>

#import <netdb.h>
#import <arpa/inet.h>


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

@synthesize sock_fd;
@synthesize publicHostPortSocket;

- (id)initWithOutgoingAddress:(struct sockaddr_in)_outgoing_addr {
    self = [super init];
    
    if (self) {
        if (_outgoing_addr.sin_port < 0 || _outgoing_addr.sin_port > 65535) {
            NSLog(@"STUNClient outgoingPort = %d is not valid, must be 0-65535", _outgoing_addr.sin_port);
            [self release];
            return nil;
        }
        
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
        
        outgoing_addr = _outgoing_addr;
        
        sock_fd = -1;
        
        publicHostPortSocket = nil;
    }
    
    return self;
}


- (NSDictionary *)getIPInfo {
    // Form a UDP socket to the STUN server
    struct addrinfo hints, *servinfo, *p;
    
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_DGRAM;
    
    fprintf(stderr, "stun server: %s stun port: %d\n", inet_ntoa(*((struct in_addr *)gethostbyname(STUN_HOST)->h_addr_list[0])), STUN_PORT);
    
    int rv;
    if ((rv = getaddrinfo(STUN_HOST, [[NSString stringWithFormat:@"%d", STUN_PORT] UTF8String], &hints, &servinfo)) != 0) {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
        return nil;
    }
    
    for (p = servinfo; p != NULL; p = p->ai_next) {
        if ((sock_fd = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1) {
            perror("STUN socket could not be established");
            continue;
        }
        
        if (bind(sock_fd, (struct sockaddr *)&outgoing_addr, sizeof(outgoing_addr)) != 0) {
            close(sock_fd);
            perror("STUN socket could not bind to outgoing address");
            continue;
        }
        
        if (connect(sock_fd, p->ai_addr, p->ai_addrlen)) {
            close(sock_fd);
            perror("STUN socket could not connect to STUN server");
            continue;
        }
        
        break;
    }
    
    if (p == NULL) {
        fprintf(stderr, "STUN client failed to connect\n");
        freeaddrinfo(servinfo);
        return nil;
    }
    
    freeaddrinfo(servinfo);
    
    // Check the socket for writing the request
    fd_set wfds, rfds;
    struct timeval tv;
    
    FD_ZERO(&wfds);
    FD_SET(sock_fd, &wfds);
    
    tv.tv_sec = 5;
    tv.tv_usec = 0;
    
    int resp_length = 0;
    uint8_t response[1024];
    memset(response, 0, sizeof(response));
    
    if (select(sock_fd+1, NULL, &wfds, NULL, &tv) > 0) {
        // Write the request and wait for a response
        if (FD_ISSET(sock_fd, &wfds)) {
            if (send(sock_fd, request, sizeof(request), 0) != 20) {
                perror("Error Sending STUN request");
                close(sock_fd);
                return nil;
            }
            
            FD_ZERO(&rfds);
            FD_SET(sock_fd, &rfds);
            tv.tv_sec = 15;
            tv.tv_usec = 0;
            
            if (select(sock_fd+1, &rfds, NULL, NULL, &tv) > 0) {
                if (FD_ISSET(sock_fd, &rfds)) {
                    // TODO: No guarentee that the whole response packet was read!!
                    if ((resp_length = recv(sock_fd, response, sizeof(response), 0)) <= 0) {
                        perror("Error Receiving STUN response");
                        close(sock_fd);
                        return nil;
                    }
                    if (resp_length < 28) {
                        fprintf(stderr, "STUN Response Length not of adaquate size\n");
                        close(sock_fd);
                        return nil;
                    }
                    
                    return [self parseResponse:response length:resp_length];
                }
            }
        }
    }
    
    close(sock_fd);
    
    return nil;
}


- (NSDictionary *)parseResponse:(uint8_t *)response length:(int)length {
    uint16_t response_type = ntohs(((uint16_t *)response)[0]);
    uint16_t response_length = ntohs(((uint16_t *)response)[1]);
    uint32_t response_cookie = ntohl(((uint32_t *)response)[1]);
    uint8_t response_id[12];
    for (int i = 8; i < 20; i++) {
        response_id[i-8] = response[i];
    }
    
    // Check that this is a Binding Response
    if (response_type != BINDING_RESPONSE) {
        fprintf(stderr, "STUN Response is not a Binding Response\n");
        return nil;
    }
    // Check that the length is at least greater than the size of MAPPED-ADDRESS attribute
    if (response_length < 8) {
        fprintf(stderr, "STUN Response length not large enough for Binding Response\n");
        return nil;
    }
    // Check that the responses magic cookie equals the correct value
    if (response_cookie != MAGIC_COOKIE) {
        fprintf(stderr, "STUN Reponse Magic Cookie not equal to 0x2112A442\n");
        return nil;
    }
    // Check that it's the right transaction id
    for (int i = 0; i < 12; i++) {
        if (response_id[i] != transaction_id[i]) {
            fprintf(stderr, "STUN Reponse Transaction IDs do not match\n");
            return nil;
        }
    }
    
    // Parse out the STUN response attributes
    int current_attribute = 0;
    int pos = 20;
    while (pos < response_length + 20 && current_attribute < 100) {  // attributes buffer = size 100
        // Create the attribute
        
        // TODO: Lookout for packets with ridiculous attribute lengths or attributes
        // that don't properly fit into the packet (i.e. don't allow this to read past the
        // end of the response buffer when parsing 'value')
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
    
    // Search through the list of attributes to find the IP/port
    for (int i = 0; i < current_attribute; i++) {
        switch (attributes[i]->type) {
            case MAPPED_ADDRESS: {
                uint16_t attr_length = attributes[i]->length;
                uint8_t *value = attributes[i]->value;
                uint16_t family = ntohs(((uint16_t *)value)[0]);
                // Confirm IPv4                
                if (family != 0x0001 || attr_length != 8) {
                    return nil;
                }
                
                uint16_t port = ntohs(((uint16_t *)value)[1]);
                
                struct in_addr addr;
                //addr.s_addr = ntohl(((uint32_t *)value)[1]);  // TODO: This is flipping my bytes?
                addr.s_addr = ((uint32_t *)value)[1];
                char str[INET_ADDRSTRLEN];
                inet_ntop(AF_INET, &addr, str, INET_ADDRSTRLEN);
                NSString *host = [NSString stringWithFormat:@"%s", str];
                
                NSLog(@"Doggie dog just got ya host: %@ and port: %d yo!", host, port);
                
                publicHostPortSocket = [[NSDictionary dictionaryWithObjectsAndKeys:host, @"host", [NSNumber numberWithUnsignedShort:port], @"port", [NSNumber numberWithInt:sock_fd], @"socket", nil] retain];
                return publicHostPortSocket;
                
                break;
            }    
            default:
                break;
        }
    }
    
    return nil;
}


- (void)dealloc {
    if (attributes) {
        free_attributes(attributes, 100);
    }

    if (publicHostPortSocket) {
        [publicHostPortSocket release];
    }
    
    [super dealloc];
}

@end









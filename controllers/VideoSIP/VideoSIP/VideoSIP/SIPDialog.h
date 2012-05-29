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


@class VideoStreamerContext;
@class SIPDialog;

@protocol SIPDialogDelegate <NSObject>
@required
- (void)dialogSessionStarted:(SIPDialog *)dialog;
- (void)dialogSessionEnded:(SIPDialog *)dialog;
- (void)dialog:(SIPDialog *)dialog beganRTPStreamWithMediaDestination:(NSDictionary *)mediaDest;
- (void)dialog:(SIPDialog *)dialog endRTPStreamWithMediaDestination:(NSDictionary *)mediaDest;
- (void)dialog:(SIPDialog *)dialog wantsToSendData:(NSData *)data;

@end


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
    NSString *clientPrivateIP;
    NSString *clientPublicIP;
    // This is our SIP port
    u_int32_t udpClientPort;
    // This is the destination SIP port
    u_int32_t udpServerPort;
    
    // Used to record the SIP route taken by a request and
    // used to route the response back to the originator.
    // UAs generating a request records its own address in a Via
    // and adds it to the header.
    // Order of Via header fields is significant as it determines routes
    NSMutableDictionary *via;
    // How many times can this bounce around the network.
    NSUInteger maxForwards;
    // Where are my Requests sending from?
    // tag is generated locally from the UAC.
    NSMutableDictionary *from;
    // Where are my Requests going?
    // tag is generated by UAS.
    NSMutableDictionary *to;
    // All Calls are tied to a specific Call-ID. OPTIONS always
    // has a unique Call-ID. All REGISTER Requests from the same
    // UA have the same Call-ID.
    NSString *callID;
    // Sequence Number; increments per request for same call.
    // Exception is ACK or CANCEL where it uses the CSeq number
    // of the INVITE it's referencing.
    NSUInteger cseq;
    // This is your routable address. The SIP Server caches this and
    // and forwards all outside requests to this address therefore this
    // must reference your address outside the NAT. All INVITES and 200
    // responses must have a Contact. REGISTER Requests may have
    // Contact: * to remove all existing Registrations.
    NSString *contact;
    // A useless name you can include, may help with logs on server side.
    NSString *userAgent;
    // These are the Requests we allow. All of these should be
    // implemented to complete this project.
    NSString *allow;
    // This is additional stuff you support. NOTE: we currently dont'
    // support any of it, but SIP packets analyzed from other sources
    // all seem to have this so we'll include it for now
    NSString *supported;
    
    NSString *branch;
    NSString *authLine;
    NSMutableDictionary *auth;
    
    // Packet writing queue.
    NSMutableArray *writeQueue;
    
    // Delegate to SIPClient
    id <SIPDialogDelegate> delegate;
}

//properties

@property (nonatomic, retain) NSString *user;
@property (nonatomic, retain) NSString *contactURI;
@property (nonatomic, retain) NSString *remoteURI;
@property (nonatomic, retain) NSString *sipURI;
@property (nonatomic, retain) NSString *clientPublicIP;
@property (nonatomic, retain) NSString *clientPrivateIP;
@property (assign) u_int32_t udpClientPort;
@property (assign) u_int32_t udpServerPort;
@property (nonatomic, retain) NSMutableDictionary *via;
@property (assign) NSUInteger maxForwards;
@property (nonatomic, retain) NSMutableDictionary *from;
@property (nonatomic, retain) NSMutableDictionary *to;
@property (nonatomic, retain) NSString *callID;
@property (assign) NSUInteger cseq;
@property (nonatomic, retain) NSString *contact;
@property (nonatomic, retain) NSString *userAgent;
@property (nonatomic, retain) NSString *allow;
@property (nonatomic, retain) NSString *supported;
@property (nonatomic, retain) NSString *branch;
@property (nonatomic, retain) NSString *authLine;
@property (nonatomic, retain) NSMutableDictionary *auth;

@property (nonatomic, retain) NSMutableArray *writeQueue;

@property (nonatomic, assign) id <SIPDialogDelegate> delegate;


// methods

- (id)initWithVideoStreamerContext:(VideoStreamerContext *)_context clientPublicIP:(NSString *)_clientPublicIP clientPrivateIP:(NSString *)_clientPrivateIP writeQueue:(NSMutableArray *)_writeQueue delegate:(id <SIPDialogDelegate>)_delegate;

- (id)initWithUser:(NSString *)_user contactURI:(NSString *)_contactURI remoteURI:(NSString *)_remoteURI udpClientIP:(NSString *)_udpClientIP udpClientPort:(NSUInteger)_udpClientPort udpServerPort:(NSUInteger)_udpServerPort writeQueue:(NSMutableArray *)_writeQueue delegate:(id <SIPDialogDelegate>)_delegate;

- (void)interpretSIP:(NSDictionary *)parsedPacket body:(NSString *)body fromAddr:(NSData *)remoteAddr;

- (void)cancel;

@end



#pragma mark -
#pragma mark REGISTER

@interface RegisterDialog : SIPDialog

- (void)registerToAsteriskWithCallID:(NSString *)registerCallID;

@end

#pragma mark -
#pragma mark OPTIONS

@interface OptionsDialog : SIPDialog

- (void)receivedOptions:(NSDictionary *)optionsPacket fromAddr:(NSData *)remoteAddr;

@end

#pragma mark -
#pragma mark NOTIFY

@interface NotifyDialog : SIPDialog

- (void)receivedNotify:(NSDictionary *)notifyPacket fromAddr:(NSData *)remoteAddr;

@end


#pragma mark -
#pragma mark INVITE

@interface InviteDialog : SIPDialog {
    NSMutableDictionary *previousAcks;
    
    NSData *sps;
    NSData *pps;
    
    // TODO: Currently the mediaDestination is passed from sipThread to the main thread
    // for use with the video encoder. May instead want to make a copy of mediaDestination
    // and pass the copy to the other thread to prevent possibilities of corrupt read/writes
    NSDictionary *mediaDestination;
}

- (id)initWithVideoStreamerContext:(VideoStreamerContext *)_context clientPublicIP:(NSString *)_clientPublicIP clientPrivateIP:(NSString *)_clientPrivateIP writeQueue:(NSMutableArray *)_writeQueue sps:(NSData *)_sps pps:(NSData *)_pps delegate:(id <SIPDialogDelegate>)_delegate;

- (void)inviteWithAuthHeader:(NSString *)key;
- (id)initWithUser:(NSString *)_user contactURI:(NSString *)_contactURI remoteURI:(NSString *)_remoteURI udpClientIP:(NSString *)_udpClientIP udpClientPort:(NSUInteger)_udpClientPort udpServerPort:(NSUInteger)_udpServerPort writeQueue:(NSMutableArray *)_writeQueue sps:(NSData *)_sps pps:(NSData *)_pps delegate:(id <SIPDialogDelegate>)_delegate;

@end






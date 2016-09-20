//
//  FileSharing.m
//  EncryptedSync
//
//  Created by Simon Maddox on 20/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "FileSharing.h"
#import "File.h"

#import <MultipeerConnectivity/MultipeerConnectivity.h>

NSString * const SyncServiceType = @"EncryptedSync";

@interface FileSharing ()<MCNearbyServiceAdvertiserDelegate, MCBrowserViewControllerDelegate, MCSessionDelegate>

@property (nonatomic, strong) MCPeerID *localPeer;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;

@end

@implementation FileSharing

- (instancetype)init
{
	if (self = [super init]){
		self.localPeer = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]]; // TODO: this should be settable by the user
		self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.localPeer discoveryInfo:nil serviceType:SyncServiceType];
		[self.advertiser setDelegate:self];
	}
	return self;
}

- (void)listenForSharing
{
	[self.advertiser startAdvertisingPeer];
}

- (void)stopListening
{
	[self.advertiser stopAdvertisingPeer];
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(nullable NSData *)context invitationHandler:(void (^)(BOOL accept, MCSession * __nullable session))invitationHandler
{
	MCSession *session = [[MCSession alloc] initWithPeer:self.localPeer securityIdentity:nil encryptionPreference:MCEncryptionNone];
	[session setDelegate:self];
	invitationHandler(YES, session);
}

- (void)shareFile:(File *)file fromViewController:(UIViewController *)viewController
{
	MCSession *session = [[MCSession alloc] initWithPeer:self.localPeer securityIdentity:@[] encryptionPreference:MCEncryptionNone];
	[session setDelegate:self];
	MCBrowserViewController *browserViewController = [[MCBrowserViewController alloc] initWithServiceType:SyncServiceType session:session];
	[browserViewController setDelegate:self];
	[viewController presentViewController:browserViewController animated:YES completion:^{
		
	}];
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
	
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
	[browserViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
	if (session.myPeerID != peerID && state == MCSessionStateConnected){
		[session sendData:[@"Hello!" dataUsingEncoding:NSUTF8StringEncoding] toPeers:session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
	}
}

// Received data from remote peer.
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
	NSLog(@"RECEIVED: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

// Received a byte stream from remote peer.
- (void)    session:(MCSession *)session
   didReceiveStream:(NSInputStream *)stream
		   withName:(NSString *)streamName
		   fromPeer:(MCPeerID *)peerID
{
	
}

// Start receiving a resource from remote peer.
- (void)                    session:(MCSession *)session
  didStartReceivingResourceWithName:(NSString *)resourceName
						   fromPeer:(MCPeerID *)peerID
					   withProgress:(NSProgress *)progress
{
	
}

// Finished receiving a resource from remote peer and saved the content
// in a temporary location - the app is responsible for moving the file
// to a permanent location within its sandbox.
- (void)                    session:(MCSession *)session
 didFinishReceivingResourceWithName:(NSString *)resourceName
						   fromPeer:(MCPeerID *)peerID
							  atURL:(NSURL *)localURL
						  withError:(nullable NSError *)error
{
	
}

@end

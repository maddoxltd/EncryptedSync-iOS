//
//  NetworkOperation.m
//  EncryptedSync
//
//  Created by Simon Maddox on 19/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "NetworkOperation.h"
#import <AWSCore/AWSCore.h>
#import <SimpleKeychain/A0SimpleKeychain.h>

@interface NetworkOperation ()
@property (nonatomic, strong) NSString *bucket;
@end

@implementation NetworkOperation

+ (void)initialize
{
	[self reloadKeys];
}

+ (void)reloadKeys
{
	A0SimpleKeychain *keychain = [A0SimpleKeychain keychain];
	
	//@"eu-west-1:90947606-c2a6-48c2-8321-178f24c6f966"
	
	AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionEUWest1 identityPoolId:[keychain stringForKey:@"CognitoID"]];
	AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionEUWest1 credentialsProvider:credentialsProvider];
	[[AWSServiceManager defaultServiceManager] setDefaultServiceConfiguration:configuration];
}

- (instancetype)init
{
	if (self = [super init]){
		A0SimpleKeychain *keychain = [A0SimpleKeychain keychain];
		_bucket = [keychain stringForKey:@"Bucket"];
	}
	return self;
}

- (void)start
{
	NSString *identityPoolID = [(AWSCognitoCredentialsProvider *)[[[AWSServiceManager defaultServiceManager] defaultServiceConfiguration] credentialsProvider] identityPoolId];
	
	if (!self.bucket || self.bucket.length == 0 || identityPoolID == nil || identityPoolID.length == 0){
		[self cancel];
	}
	
	[super start];
}

@end

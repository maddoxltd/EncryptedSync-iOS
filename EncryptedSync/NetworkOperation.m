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

+ (BOOL)isConfigured
{
	A0SimpleKeychain *keychain = [A0SimpleKeychain keychain];

	NSString *identityPoolID = [keychain stringForKey:@"CognitoID"];
	NSString *bucket = [keychain stringForKey:@"Bucket"];
	
	return identityPoolID.length > 0 && bucket.length > 0;
}

- (void)start
{
	if (![[self class] isConfigured]){
		[self cancel];
	}
	
	[super start];
}

@end

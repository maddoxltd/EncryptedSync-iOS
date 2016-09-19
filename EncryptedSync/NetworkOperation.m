//
//  NetworkOperation.m
//  EncryptedSync
//
//  Created by Simon Maddox on 19/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "NetworkOperation.h"
#import <AWSCore/AWSCore.h>

@implementation NetworkOperation

+ (void)initialize
{
	AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionEUWest1 identityPoolId:@"eu-west-1:90947606-c2a6-48c2-8321-178f24c6f966"];
	AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionEUWest1 credentialsProvider:credentialsProvider];
	[[AWSServiceManager defaultServiceManager] setDefaultServiceConfiguration:configuration];
}

- (NSString *)bucket
{
	return @"encryptedsync";
}

@end

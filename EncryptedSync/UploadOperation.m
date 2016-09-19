//
//  UploadOperation.m
//  EncryptedSync
//
//  Created by Simon Maddox on 17/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "UploadOperation.h"
#import <AWSS3/AWSS3.h>

@implementation UploadOperation

- (void)start
{
	[super start];

	AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
	AWSS3TransferManagerUploadRequest *uploadRequest = [[AWSS3TransferManagerUploadRequest alloc] init];
	uploadRequest.bucket = [self bucket];
	uploadRequest.key = [self key];
	uploadRequest.body = self.fileURL;
	uploadRequest.contentLength = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.fileURL path] error:nil][NSFileSize];
	
	__weak typeof(self) weakSelf = self;
	[[transferManager upload:uploadRequest] continueWithBlock:^id _Nullable(AWSTask * _Nonnull task) {
		__strong typeof(weakSelf) strongSelf = weakSelf;
		strongSelf.error = task.error;
		[strongSelf finish];
		
		return nil;
	}];
}

- (NSString *)key
{
	NSString *prefix = self.prefix;
	if (!prefix){
		prefix = @"";
	}
	return [prefix stringByAppendingString:[self.fileURL lastPathComponent]];
}

@end

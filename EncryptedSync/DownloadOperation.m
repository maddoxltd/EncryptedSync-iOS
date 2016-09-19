//
//  DownloadOperation.m
//  EncryptedSync
//
//  Created by Simon Maddox on 17/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "DownloadOperation.h"
#import <AWSS3/AWSS3.h>

@implementation DownloadOperation

- (void)start
{
	[super start];
	
	NSString *localFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.remotePath];
	
	AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
	AWSS3TransferManagerDownloadRequest *downloadRequest = [[AWSS3TransferManagerDownloadRequest alloc] init];
	downloadRequest.bucket = [self bucket];
	downloadRequest.key = self.remotePath;
	downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:localFilePath];
	
	__weak typeof(self) weakSelf = self;
	[[transferManager download:downloadRequest] continueWithBlock:^id _Nullable(AWSTask * _Nonnull task) {
		__strong typeof(weakSelf) strongSelf = weakSelf;
		strongSelf.error = task.error;
		if (!strongSelf.error){
			strongSelf.fileURL = [NSURL fileURLWithPath:localFilePath];
		}
		[strongSelf finish];
		
		return nil;
	}];
}

@end

//
//  DownloadOperation.m
//  EncryptedSync
//
//  Created by Simon Maddox on 17/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "DownloadOperation.h"

@implementation DownloadOperation

- (void)start
{
	[super start];
	
	__weak typeof(self) weakSelf = self;
	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
	[[session dataTaskWithRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		__strong typeof(weakSelf) strongSelf = weakSelf;
		if (!error){
			NSURL *fileURL = [strongSelf generateTemporaryFileURL];
			if ([data writeToURL:fileURL atomically:YES]){
				strongSelf.downloadedFileURL = fileURL;
			}
		}
		[strongSelf finish];
	}] resume];
}

@end

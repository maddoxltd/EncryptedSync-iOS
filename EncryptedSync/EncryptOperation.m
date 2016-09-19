//
//  EncryptOperation.m
//  EncryptedSync
//
//  Created by Simon Maddox on 17/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "EncryptOperation.h"
#import "Encryption.h"

@implementation EncryptOperation

- (void)start
{
	[super start];
	
	__weak typeof(self) weakSelf = self;
	[self.encryption encryptFile:self.fileURL completion:^(NSURL *encryptedURL, NSURL *metadataURL) {
		__strong typeof(weakSelf) strongSelf = weakSelf;
		strongSelf.encryptedFileURL = encryptedURL;
		strongSelf.encryptedMetadataURL = metadataURL;
		[strongSelf finish];
	}];
	
}

@end

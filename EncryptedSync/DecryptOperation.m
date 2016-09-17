//
//  DecryptOperation.m
//  EncryptedSync
//
//  Created by Simon Maddox on 17/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "DecryptOperation.h"
#import "Encryption.h"

@implementation DecryptOperation

- (void)start
{
	[super start];
	
	__weak typeof(self) weakSelf = self;
	[self.encryption decryptFile:self.fileURL completion:^(NSURL *decryptedURL) {
		__strong typeof(weakSelf) strongSelf = weakSelf;
		strongSelf.decryptedFileURL = decryptedURL;
		[strongSelf finish];
	}];
}

@end

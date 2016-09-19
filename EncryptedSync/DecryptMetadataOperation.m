//
//  DecryptMetadataOperation.m
//  EncryptedSync
//
//  Created by Simon Maddox on 19/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "DecryptMetadataOperation.h"
#import "Encryption.h"

@implementation DecryptMetadataOperation

- (void)start
{
	[super start];
	
	__weak typeof(self) weakSelf = self;
	[self.encryption decryptMetadataFile:self.fileURL completion:^(NSString *filename) {
		__strong typeof(weakSelf) strongSelf = weakSelf;
		strongSelf.filename = filename;
		[strongSelf finish];
	}];
}


@end

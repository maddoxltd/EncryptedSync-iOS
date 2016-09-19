//
//  EncryptionBridge.m
//  EncryptedSync
//
//  Created by Simon Maddox on 19/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "EncryptionBridge.h"
#import "Encryption.h"

#import "EncryptOperation.h"
#import "UploadOperation.h"

#import "DownloadOperation.h"
#import "DecryptOperation.h"

@interface EncryptionBridge ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) Encryption *encryption;

@end

@implementation EncryptionBridge

- (instancetype)init
{
	if (self = [super init]){
		NSError *error = nil;
		// TODO: Private key needs to be stored securely
		self.encryption = [[Encryption alloc] initWithPrivateKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"private"] passphrase:@"hello" error:&error];
		if (error){
			NSLog(@"Error setting up encryption: %@", error);
		}
		self.queue = [[NSOperationQueue alloc] init];
	}
	return self;
}

- (void)encryptAndUploadFile:(NSURL *)fileURL completion:(void (^)(NSString *remotePath, NSError *error))completion
{
	EncryptOperation *encryptOperation = [[EncryptOperation alloc] init];
	encryptOperation.encryption = self.encryption;
	encryptOperation.fileURL = fileURL;
	
	UploadOperation *uploadOperation = [[UploadOperation alloc] init];
	[uploadOperation addDependency:encryptOperation];
	
	__weak typeof(encryptOperation) weakEncryptOperation = encryptOperation;
	__weak typeof(uploadOperation) weakUploadOperation = uploadOperation;
	[encryptOperation setOperationCompleteBlock:^{
		__strong typeof(weakEncryptOperation) strongEncryptOperation = weakEncryptOperation;
		__strong typeof(weakUploadOperation) strongUploadOperation = weakUploadOperation;
		
		strongUploadOperation.fileURL = strongEncryptOperation.encryptedFileURL;
	}];
	
	[uploadOperation setOperationCompleteBlock:^{
		__strong typeof(weakUploadOperation) strongUploadOperation = weakUploadOperation;
		completion(strongUploadOperation.key, strongUploadOperation.error);
	}];
	
	[self.queue addOperation:encryptOperation];
	[self.queue addOperation:uploadOperation];
}

- (void)downloadAndDecryptFileAtPath:(NSString *)path completion:(void (^)(NSURL *fileURL, NSError *error))completion
{
	DownloadOperation *downloadOperation = [[DownloadOperation alloc] init];
	downloadOperation.remotePath = path;
	
	DecryptOperation *decryptOperation = [[DecryptOperation alloc] init];
	decryptOperation.encryption = self.encryption;
	[decryptOperation addDependency:downloadOperation];
	
	__weak typeof(downloadOperation) weakDownloadOperation = downloadOperation;
	__weak typeof(decryptOperation) weakDecryptOperation = decryptOperation;
	[downloadOperation setOperationCompleteBlock:^{
		__strong typeof(weakDownloadOperation) strongDownloadOperation = weakDownloadOperation;
		__strong typeof(weakDecryptOperation) strongDecryptOperation = weakDecryptOperation;
		
		strongDecryptOperation.fileURL = strongDownloadOperation.fileURL;
	}];
	
	[decryptOperation setOperationCompleteBlock:^{
		__strong typeof(weakDecryptOperation) strongDecryptOperation = weakDecryptOperation;
		completion(strongDecryptOperation.decryptedFileURL, nil);
	}];
	
	[self.queue addOperation:downloadOperation];
	[self.queue addOperation:decryptOperation];
}

@end

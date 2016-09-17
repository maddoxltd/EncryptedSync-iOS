//
//  AppDelegate.m
//  EncryptedSync
//
//  Created by Simon Maddox on 16/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "Encryption.h"

#import "EncryptOperation.h"
#import "DecryptOperation.h"

@interface AppDelegate ()
@property (nonatomic, strong) Encryption *encryption;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.operationQueue = [[NSOperationQueue alloc] init];
	
	NSError *error = nil;
	// TODO: Private key needs to be stored securely
	self.encryption = [[Encryption alloc] initWithPrivateKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"private"] passphrase:@"hello" error:&error];
	if (error){
		NSLog(@"%@", error);
	} else {
		
		EncryptOperation *encryptOperation = [[EncryptOperation alloc] init];
		encryptOperation.encryption = self.encryption;
		encryptOperation.fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"image" ofType:@"png"]];
		
		DecryptOperation *decryptOperation = [[DecryptOperation alloc] init];
		decryptOperation.encryption = self.encryption;
		
		[decryptOperation addDependency:encryptOperation];
		__weak typeof(encryptOperation) weakEncryptOperation = encryptOperation;
		__weak typeof(decryptOperation) weakDecryptOperation = decryptOperation;
		[encryptOperation setOperationCompleteBlock:^{
			__strong typeof(weakEncryptOperation) strongEncryptOperation = weakEncryptOperation;
			__strong typeof(weakDecryptOperation) strongDecryptOperation = weakDecryptOperation;
			
			strongDecryptOperation.fileURL = strongEncryptOperation.encryptedFileURL;
		}];
		[decryptOperation setOperationCompleteBlock:^{
			__strong typeof(weakDecryptOperation) strongDecryptOperation = weakDecryptOperation;
			NSLog(@"%@", [strongDecryptOperation.decryptedFileURL path]);
		}];
		
		[self.operationQueue addOperation:encryptOperation];
		[self.operationQueue addOperation:decryptOperation];
	}
	
	return YES;
}

@end

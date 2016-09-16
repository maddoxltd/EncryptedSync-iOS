//
//  AppDelegate.m
//  EncryptedSync
//
//  Created by Simon Maddox on 16/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "Encryption.h"

@interface AppDelegate ()
@property (nonatomic, strong) Encryption *encryption;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSError *error = nil;
	self.encryption = [[Encryption alloc] initWithPrivateKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"private"] passphrase:@"hello" error:&error];
	if (error){
		NSLog(@"%@", error);
	} else {
		/*[self.encryption encryptFile:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"image" ofType:@"png"]] completion:^(NSURL *encryptedURL) {
			
			NSLog(@"Written Encrypted file: %@", [encryptedURL path]);
		}];*/
		
		[self.encryption decryptFile:[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"CDB8AEE5-671C-4FFD-9F2D-3C3FE608689C"]] completion:^(NSURL *decryptedURL) {
			NSLog(@"Decrypted: %@", [decryptedURL path]);
		}];
	}
	
	return YES;
}

@end

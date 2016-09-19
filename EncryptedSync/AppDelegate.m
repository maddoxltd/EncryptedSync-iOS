//
//  AppDelegate.m
//  EncryptedSync
//
//  Created by Simon Maddox on 16/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "EncryptionBridge.h"

@interface AppDelegate ()

@property (nonatomic, strong) EncryptionBridge *encryptionBridge;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.encryptionBridge = [[EncryptionBridge alloc] init];
	
	/*__weak typeof(self) weakSelf = self;
	[self.encryptionBridge encryptAndUploadFile:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ClockFace" ofType:@"png"]] completion:^(NSString *remotePath, NSError *error) {
		NSLog(@"Uploaded: %@", remotePath);
		
		__strong typeof(weakSelf) strongSelf = weakSelf;
		[strongSelf.encryptionBridge downloadAndDecryptFileAtPath:remotePath completion:^(NSURL *fileURL, NSError *error) {
			NSLog(@"Downloaded: %@", [fileURL path]);
		}];
	}];*/
	
	[self.encryptionBridge listFilesWithCompletion:^(NSArray<NSString *> *files, NSError *error) {
		NSLog(@"Files: %@", files);
	}];
	return YES;
}

@end

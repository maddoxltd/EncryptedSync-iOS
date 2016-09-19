//
//  AppDelegate.m
//  EncryptedSync
//
//  Created by Simon Maddox on 16/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "EncryptionBridge.h"
#import "File.h"

@interface AppDelegate ()

@property (nonatomic, strong) EncryptionBridge *encryptionBridge;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	return YES;
}

@end

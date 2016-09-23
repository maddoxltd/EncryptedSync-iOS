//
//  BlockingTabBarController.m
//  EncryptedSync
//
//  Created by Simon Maddox on 23/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "BlockingTabBarController.h"
#import "NetworkOperation.h"
#import "SettingsViewController.h"

@interface BlockingTabBarController () <UITabBarControllerDelegate>

@end

@implementation BlockingTabBarController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.delegate = self;
	
	if (![NetworkOperation isConfigured]){
		[self setSelectedIndex:1];
	}
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
	if (![NetworkOperation isConfigured]){
		UINavigationController *navigationController = [[tabBarController viewControllers] lastObject];
		SettingsViewController *settingsViewController = [[navigationController viewControllers] firstObject];
		[settingsViewController shake];
		return NO;
	}
	
	return YES;
}

@end

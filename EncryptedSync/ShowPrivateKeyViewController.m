//
//  ShowPrivateKeyViewController.m
//  EncryptedSync
//
//  Created by Simon Maddox on 23/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "ShowPrivateKeyViewController.h"
#import <SimpleKeychain/A0SimpleKeychain.h>

@interface ShowPrivateKeyViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ShowPrivateKeyViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	A0SimpleKeychain *keychain = [A0SimpleKeychain keychain];
	[self.textView setText:[keychain stringForKey:@"PrivateKey"]];
}

- (IBAction)doneButtonPressed:(id)sender
{
	[self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

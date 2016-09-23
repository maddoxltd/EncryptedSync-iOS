//
//  SettingsViewController.m
//  EncryptedSync
//
//  Created by Simon Maddox on 23/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "SettingsViewController.h"
#import <SimpleKeychain/A0SimpleKeychain.h>
#import "SMXTextFieldCell.h"
#import "NetworkOperation.h"

@interface SettingsViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *cognitoIDField;
@property (nonatomic, strong) UITextField *bucketField;

@property (nonatomic, strong) A0SimpleKeychain *keychain;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.keychain = [A0SimpleKeychain keychain];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	if (indexPath.section == 0){
		if (indexPath.row == 0){ // Cognito ID
			SMXTextFieldCell *textFieldCell = (SMXTextFieldCell *)cell;
			textFieldCell.textField.placeholder = @"Required";
			textFieldCell.textField.text = [self.keychain stringForKey:@"CognitoID"];
			
			self.cognitoIDField = textFieldCell.textField;
			self.cognitoIDField.delegate = self;
			
		} else if (indexPath.row == 1){ // Bucket
			SMXTextFieldCell *textFieldCell = (SMXTextFieldCell *)cell;
			textFieldCell.textField.placeholder = @"Required";
			textFieldCell.textField.text = [self.keychain stringForKey:@"Bucket"];
			
			self.bucketField = textFieldCell.textField;
			self.bucketField.delegate = self;
		}
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if ([cell isKindOfClass:[SMXTextFieldCell class]]){
		SMXTextFieldCell *textFieldCell = (SMXTextFieldCell *)cell;
		[textFieldCell.textField becomeFirstResponder];
	}
	
	if (indexPath.section == 1){
		if (indexPath.row == 1){
			self.keychain = [A0SimpleKeychain keychain];
			NSString *privateKey = [self.keychain stringForKey:@"PrivateKey"];
			[[UIPasteboard generalPasteboard] setString:privateKey];
		} else if (indexPath.row == 2){
			[self importPrivateKey:nil];
		} else if (indexPath.row == 3){
			[self deletePrivateKey:nil];
		}
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == self.cognitoIDField){
		[self.keychain setString:textField.text forKey:@"CognitoID"];
	} else if (textField == self.bucketField){
		[self.keychain setString:textField.text forKey:@"Bucket"];
	}
	
	[NetworkOperation reloadKeys];
	
	[textField resignFirstResponder];
	return YES;
}

- (void)shake
{
	[CATransaction begin];
	[self.cognitoIDField.layer addAnimation:[self makeShakeAnimation] forKey:@"shake"];
	[self.bucketField.layer addAnimation:[self makeShakeAnimation] forKey:@"shake"];
	[CATransaction commit];
}

// From https://github.com/google/macops-keychainminder/blob/master/KeychainMinderGUI/PasswordViewController.m
- (CAAnimation *)makeShakeAnimation {
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
	animation.keyPath = @"position.x";
	animation.values = @[ @0, @10, @-10, @10, @-10, @10, @0 ];
	animation.keyTimes = @[ @0, @(1 / 6.0), @(2 / 6.0), @(3 / 6.0), @(4 / 6.0), @(5 / 6.0), @1 ];
	animation.duration = 0.6;
	animation.additive = YES;
	return animation;
}

- (IBAction)importPrivateKey:(id)sender
{
	[self showOverwritePrivateKeyAlertWithAction:^(UIAlertAction *action) {
		NSString *string = [[UIPasteboard generalPasteboard] string];
		
		// TODO: Check if string is a valid private key
//		[self.keychain setString:string forKey:@"PrivateKey"];
		// TODO: reload
	}];
}

- (IBAction)deletePrivateKey:(id)sender
{
	[self showOverwritePrivateKeyAlertWithAction:^(UIAlertAction *action) {
//		[self.keychain deleteEntryForKey:@"PrivateKey"];
		// TODO: reload
	}];
}

- (void)showOverwritePrivateKeyAlertWithAction:(void(^)(UIAlertAction *action))action
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Danger!" message:@"You're about to overwrite your private key. Unless you have a backup, all files will be inaccessible." preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"Overwrite" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		
	}]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:alert animated:YES completion:nil];
}

@end

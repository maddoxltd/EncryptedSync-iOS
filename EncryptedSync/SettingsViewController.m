//
//  SettingsViewController.m
//  EncryptedSync
//
//  Created by Simon Maddox on 23/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "SettingsViewController.h"
#import <SimpleKeychain/A0SimpleKeychain.h>

@implementation SettingsViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 1){
		if (indexPath.row == 1){
			A0SimpleKeychain *keychain = [A0SimpleKeychain keychain];
			NSString *privateKey = [keychain stringForKey:@"PrivateKey"];
			[[UIPasteboard generalPasteboard] setString:privateKey];
		}
	}
}

@end

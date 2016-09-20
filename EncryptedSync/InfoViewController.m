//
//  InfoViewController.m
//  EncryptedSync
//
//  Created by Simon Maddox on 20/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "InfoViewController.h"
#import "File.h"
#import "FileSharing.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = self.file.filename;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0){
		if (indexPath.row == 1){
			// Share
			[self.fileSharing shareFile:self.file fromViewController:self];
		}
	}
}

@end

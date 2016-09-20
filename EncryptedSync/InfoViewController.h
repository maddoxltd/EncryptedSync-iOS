//
//  InfoViewController.h
//  EncryptedSync
//
//  Created by Simon Maddox on 20/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class File, FileSharing;

@interface InfoViewController : UITableViewController

@property (nonatomic, strong) File *file;
@property (nonatomic, weak) FileSharing *fileSharing;

@end

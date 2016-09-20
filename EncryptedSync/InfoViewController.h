//
//  InfoViewController.h
//  EncryptedSync
//
//  Created by Simon Maddox on 20/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class File;

@interface InfoViewController : UITableViewController

@property (nonatomic, strong) File *file;

@end

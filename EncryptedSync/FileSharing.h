//
//  FileSharing.h
//  EncryptedSync
//
//  Created by Simon Maddox on 20/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@class File;

@interface FileSharing : NSObject

- (void)listenForSharing;
- (void)stopListening;

- (void)shareFile:(File *)file fromViewController:(UIViewController *)viewController;

@end

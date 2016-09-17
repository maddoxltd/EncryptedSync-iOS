//
//  AsynchronousOperation.h
//  EncryptedSync
//
//  Created by Simon Maddox on 17/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsynchronousOperation : NSOperation

- (void)start;
- (void)finish;
- (NSURL *)generateTemporaryFileURL;

@property (nonatomic, copy) void (^operationCompleteBlock)(void);

@end

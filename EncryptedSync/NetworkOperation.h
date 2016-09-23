//
//  NetworkOperation.h
//  EncryptedSync
//
//  Created by Simon Maddox on 19/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "AsynchronousOperation.h"

@interface NetworkOperation : AsynchronousOperation

+ (void)reloadKeys;
- (NSString *)bucket;

@property (nonatomic, copy) NSURL *fileURL;

@property (nonatomic, copy) NSError *error;

@end

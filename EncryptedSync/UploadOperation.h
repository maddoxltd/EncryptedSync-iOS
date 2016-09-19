//
//  UploadOperation.h
//  EncryptedSync
//
//  Created by Simon Maddox on 17/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "NetworkOperation.h"

@interface UploadOperation : NetworkOperation

@property (nonatomic, strong) NSString *prefix;

- (NSString *)key;

@end

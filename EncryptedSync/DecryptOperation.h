//
//  DecryptOperation.h
//  EncryptedSync
//
//  Created by Simon Maddox on 17/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "AsynchronousOperation.h"

@class Encryption;

@interface DecryptOperation : AsynchronousOperation

@property (nonatomic, weak) Encryption *encryption;
@property (nonatomic, copy) NSURL *fileURL;

@property (nonatomic, copy) NSURL *decryptedFileURL;

@end

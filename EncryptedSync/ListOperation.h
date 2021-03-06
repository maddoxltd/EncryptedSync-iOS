//
//  ListOperation.h
//  EncryptedSync
//
//  Created by Simon Maddox on 19/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "NetworkOperation.h"

@class EncryptionBridge, File;

@interface ListOperation : NetworkOperation

@property (nonatomic, copy) NSArray <File *>* files;
@property (nonatomic, weak) EncryptionBridge *encryptionBridge;

@end

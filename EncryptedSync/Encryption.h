//
//  Encryption.h
//  EncryptedSync
//
//  Created by Simon Maddox on 16/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Encryption : NSObject


- (instancetype)initWithUserID:(NSString *)userID passphrase:(NSString *)passphrase error:(NSError **)errorRef;
- (void)encryptFile:(NSURL *)fileURL completion:(void (^)(NSURL *encryptedURL))completion;
- (void)decryptFile:(NSURL *)fileURL completion:(void (^)(NSURL *decryptedURL))completion;

@end

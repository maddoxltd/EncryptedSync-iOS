//
//  Encryption.h
//  EncryptedSync
//
//  Created by Simon Maddox on 16/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Encryption : NSObject

- (instancetype)initWithPrivateKey:(NSString *)privateKey passphrase:(NSString *)passphrase error:(NSError **)errorRef createdPrivateKey:(NSString **)createdPrivateKey;

- (void)encryptFile:(NSURL *)fileURL completion:(void (^)(NSURL *encryptedURL, NSURL *metadataURL))completion;
- (void)decryptFile:(NSURL *)fileURL completion:(void (^)(NSURL *decryptedURL))completion;
- (void)decryptMetadataFile:(NSURL *)fileURL completion:(void (^)(NSString *filename, NSError *error))completion;

@end

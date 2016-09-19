//
//  EncryptionBridge.h
//  EncryptedSync
//
//  Created by Simon Maddox on 19/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncryptionBridge : NSObject

- (void)encryptAndUploadFile:(NSURL *)fileURL completion:(void (^)(NSString *remotePath, NSError *error))completion;
- (void)downloadAndDecryptFileAtPath:(NSString *)path completion:(void (^)(NSURL *fileURL, NSError *error))completion;
- (void)downloadAndDecryptMetadataFileAtPath:(NSString *)path completion:(void (^)(NSString *filename, NSError *error))completion;
- (void)listFilesWithCompletion:(void (^)(NSArray <NSString *> *files, NSError *error))completion;

@end

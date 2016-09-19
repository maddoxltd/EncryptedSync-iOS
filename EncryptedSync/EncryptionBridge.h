//
//  EncryptionBridge.h
//  EncryptedSync
//
//  Created by Simon Maddox on 19/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class File;

@interface EncryptionBridge : NSObject

- (void)encryptAndUploadFile:(NSURL *)fileURL completion:(void (^)(NSString *remotePath, NSError *error))completion;
- (void)downloadAndDecryptFileAtPath:(NSString *)path completion:(void (^)(NSURL *fileURL, NSError *error))completion;
- (void)downloadAndDecryptFile:(File *)file completion:(void (^)(NSURL *fileURL, NSError *error))completion;
- (void)downloadAndDecryptMetadataFileAtPath:(NSString *)path completion:(void (^)(File *file, NSError *error))completion;
- (void)listFilesWithCompletion:(void (^)(NSArray <File *> *files, NSError *error))completion;

@end

//
//  DownloadOperation.h
//  EncryptedSync
//
//  Created by Simon Maddox on 17/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "AsynchronousOperation.h"

@interface DownloadOperation : AsynchronousOperation

@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic, copy) NSURL *downloadedFileURL;

@end

//
//  DownloadOperation.h
//  EncryptedSync
//
//  Created by Simon Maddox on 17/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "NetworkOperation.h"

@interface DownloadOperation : NetworkOperation

@property (nonatomic, copy) NSString *remotePath;

@end

//
//  File.h
//  EncryptedSync
//
//  Created by Simon Maddox on 16/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface File : NSObject

- (instancetype)initWithString:(NSString *)string;

@property (nonatomic, copy) NSString *filename;
@property (nonatomic, copy) NSData *data;

- (NSString *)stringRepresentation;

@end

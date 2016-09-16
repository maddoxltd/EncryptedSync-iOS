//
//  File.m
//  EncryptedSync
//
//  Created by Simon Maddox on 16/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "File.h"

@implementation File

- (instancetype)initWithString:(NSString *)string
{
	if (self = [super init]){
		NSDictionary *object = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
		self.filename = object[@"filename"];
		self.data = [[NSData alloc] initWithBase64EncodedString:object[@"data"] options:0];
	}
	return self;
}

- (NSString *)stringRepresentation
{
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"filename" : self.filename, @"data" : [self.data base64EncodedStringWithOptions:0]} options:0 error:nil];
	return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end

//
//  ListOperation.m
//  EncryptedSync
//
//  Created by Simon Maddox on 19/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "ListOperation.h"
#import "EncryptionBridge.h"

#import <AWSS3/AWSS3.h>
#import <AWSS3/AWSS3Model.h>

#import "File.h"

@implementation ListOperation

- (void)start
{
	[super start];
	
	__weak typeof(self) weakSelf = self;
	
	AWSS3 *awsClient = [AWSS3 defaultS3];
	AWSS3ListObjectsRequest *listRequest = [[AWSS3ListObjectsRequest alloc] init];
	listRequest.bucket = [self bucket];
	listRequest.prefix = @".";
	[[awsClient listObjects:listRequest] continueWithBlock:^id _Nullable(AWSTask<AWSS3ListObjectsOutput *> * _Nonnull task) {
		
		NSMutableArray <File *> *files = [NSMutableArray array];
		
		dispatch_group_t group = dispatch_group_create();
		
		NSArray <AWSS3Object *> *s3Objects = [task.result contents];
		[s3Objects enumerateObjectsUsingBlock:^(AWSS3Object * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			dispatch_group_enter(group);
			__strong typeof(weakSelf) strongSelf = weakSelf;
			[strongSelf.encryptionBridge downloadAndDecryptMetadataFileAtPath:obj.key completion:^(File *file, NSError *error) {
				if (file){
					[files addObject:file];
				}
				dispatch_group_leave(group);
			}];
		}];
		
		dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
		
		__strong typeof(weakSelf) strongSelf = weakSelf;
		strongSelf.files = [files sortedArrayUsingComparator:^NSComparisonResult(File *obj1, File *obj2) {
			return [obj1.filename compare:obj2.filename];
		}];
		[strongSelf finish];
		
		return nil;
	}];
}

@end

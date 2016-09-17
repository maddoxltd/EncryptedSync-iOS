//
//  AsynchronousOperation.m
//  EncryptedSync
//
//  Created by Simon Maddox on 17/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "AsynchronousOperation.h"

@interface AsynchronousOperation (){
	BOOL _executing;
	BOOL _finished;
}

@end

@implementation AsynchronousOperation

- (void)start
{
	[self changePropertyForSelector:@selector(isExecuting) withBlock:^{
		_executing = YES;
	}];
}

- (void)finish
{
	[self changePropertyForSelector:@selector(isExecuting) withBlock:^{
		_executing = NO;
	}];
	
	if (self.operationCompleteBlock){
		self.operationCompleteBlock();
	}
	
	[self changePropertyForSelector:@selector(isFinished) withBlock:^{
		_finished = YES;
	}];
}

- (BOOL)isAsynchronous
{
	return YES;
}

- (BOOL)isExecuting
{
	return _executing;
}

- (BOOL)isFinished
{
	return _finished;
}

- (void)changePropertyForSelector:(SEL)selector withBlock:(void (^)())block
{
	[self willChangeValueForKey:NSStringFromSelector(selector)];
	block();
	[self didChangeValueForKey:NSStringFromSelector(selector)];
}

- (NSURL *)generateTemporaryFileURL
{
	return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]]];
}

@end

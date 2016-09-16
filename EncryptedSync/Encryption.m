//
//  Encryption.m
//  EncryptedSync
//
//  Created by Simon Maddox on 16/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "Encryption.h"
#import "File.h"

@import JavaScriptCore;

@interface Encryption ()

@property (nonatomic, strong) JSContext *JSContext;
@property (nonatomic) NSUInteger timeoutCounter;
@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic, strong) NSMapTable *dispatchSourcesMapping;

@property (nonatomic, strong) JSValue *GPG;
@property (nonatomic, strong) JSValue *keyManager;

@end

@implementation Encryption

- (instancetype)initWithUserID:(NSString *)userID passphrase:(NSString *)passphrase error:(NSError **)errorRef
{
	if (self = [super init]){
		self.timeoutCounter = 0;
		self.queue = dispatch_queue_create("JS timer queue", DISPATCH_QUEUE_CONCURRENT);
		self.dispatchSourcesMapping = [NSMapTable weakToWeakObjectsMapTable];
		
		self.JSContext = [[JSContext alloc] init];
		[self.JSContext setExceptionHandler:^(JSContext *context, JSValue *exception) {
			NSLog(@"%@", exception);
		}];
		self.JSContext[@"console"][@"log"] = ^(JSValue *message){
			NSLog(@"%@", [message toObject]);
		};
		self.JSContext[@"setTimeout"] = [self setTimeout];
		self.JSContext[@"setInterval"] = [self setInterval];
		self.JSContext[@"clearTimeout"] = [self clearTimeout];
		self.JSContext[@"clearInterval"] = [self clearTimeout];
		
		self.JSContext[@"self"] = @{};
		self.JSContext[@"window"] = self.JSContext[@"self"];
		self.JSContext[@"crypto"] = @{};
		self.JSContext[@"crypto"][@"getRandomValues"] = ^(JSValue *countObject){
			// TODO: this should return secure random numbers
			NSArray *countArray = [countObject toArray];
			NSMutableArray *array = [NSMutableArray array];
			for (__unused NSNumber *number in countArray){
				[array addObject:@(arc4random())];
			}
			return [NSArray arrayWithArray:array];
			
		};
		[self.JSContext evaluateScript:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"kbpgp" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil]];
		
		self.GPG = self.JSContext[@"self"][@"kbpgp"];
		
		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
		
		__weak typeof(self) weakSelf = self;
		NSString *privateKeyString = [[NSUserDefaults standardUserDefaults] objectForKey:@"private"];
		if (!privateKeyString){
			[self.GPG[@"KeyManager"] invokeMethod:@"generate_ecc" withArguments:@[@{@"userid": userID}, ^(JSValue *error, JSValue *key){
				__strong typeof(weakSelf) strongSelf = weakSelf;
				strongSelf.keyManager = key;
				[key invokeMethod:@"sign" withArguments:@[@{}, ^(JSValue *error){
					[key invokeMethod:@"export_pgp_private" withArguments:@[@{@"passphrase" : passphrase}, ^(JSValue *error, JSValue *key){
						NSString *keyString = [key toString];
						[[NSUserDefaults standardUserDefaults] setObject:keyString forKey:@"private"];
						NSLog(@"Created new private key");
						dispatch_semaphore_signal(semaphore);
					}]];
				}]];
				
			}]];
		} else {
			[self.GPG[@"KeyManager"] invokeMethod:@"import_from_armored_pgp" withArguments:@[@{@"armored" : privateKeyString}, ^(JSValue *error, JSValue *keyManager){
				
				if ([[keyManager invokeMethod:@"is_pgp_locked" withArguments:nil] toBool]){
					[keyManager invokeMethod:@"unlock_pgp" withArguments:@[@{@"passphrase" : passphrase}, ^(JSValue *error){
						__strong typeof(weakSelf) strongSelf = weakSelf;
						if (![error isNull]){
							if (errorRef){
								// TODO: Handle errors
//								*errorRef = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey : [error toString]}];
							}
							NSLog(@"Failed to load private key with error: %@", [error toString]);
							dispatch_semaphore_signal(semaphore);
						} else {
							NSLog(@"Loaded private key with passphrase");
							strongSelf.keyManager = keyManager;
							dispatch_semaphore_signal(semaphore);
						}
					}]];
				} else {
					NSLog(@"Loaded private key without passphrase");
					__strong typeof(weakSelf) strongSelf = weakSelf;
					strongSelf.keyManager = keyManager;
					dispatch_semaphore_signal(semaphore);
				}
			}]];
		}
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
	}
	return self;
}


- (NSNumber *)timerWithFunction:(JSValue *)function delay:(JSValue *)delay arguments:(NSArray *)originalArguments repeats:(BOOL)repeats
{
	NSArray *arguments = @[];
	if (originalArguments.count > 2){
		arguments = [originalArguments subarrayWithRange:NSMakeRange(2, [originalArguments count] - 2)];
	}
	
	__block NSNumber *timeoutID = @(self.timeoutCounter += 1);
	__block dispatch_source_t dispatchSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue);
	dispatch_source_set_event_handler(dispatchSource, ^{
		if (!repeats){
			dispatch_source_cancel(dispatchSource);
		}
		
		if ([function isString]){
			[function.context evaluateScript:[function toString]];
		} else {
			[function callWithArguments:arguments];
		}
	});
	
	dispatch_time_t dispatchInterval = [delay toUInt32] * NSEC_PER_MSEC;
	dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, dispatchInterval);
	dispatch_source_set_timer(dispatchSource, dispatchTime, repeats ? dispatchInterval : DISPATCH_TIME_FOREVER, 0);
	dispatch_resume(dispatchSource);
	[self.dispatchSourcesMapping setObject:dispatchSource forKey:timeoutID];
	
	return timeoutID;
}

- (id)setTimeout
{
	__weak typeof(self) weakSelf = self;
	return ^(JSValue *function, JSValue *timeout){
		__strong typeof(weakSelf) strongSelf = weakSelf;
		return [strongSelf timerWithFunction:function delay:timeout arguments:[JSContext currentArguments] repeats:NO];
	};
}

- (id)clearTimeout
{
	__weak typeof(self) weakSelf = self;
	return ^(NSNumber *timeoutID){
		__strong typeof(weakSelf) strongSelf = weakSelf;
		dispatch_source_t dispatchSource = [strongSelf.dispatchSourcesMapping objectForKey:timeoutID];
		if (dispatchSource){
			dispatch_source_cancel(dispatchSource);
		}
	};
}

- (id)setInterval
{
	__weak typeof(self) weakSelf = self;
	return ^(JSValue *function, JSValue *timeout){
		__strong typeof(weakSelf) strongSelf = weakSelf;
		return [strongSelf timerWithFunction:function delay:timeout arguments:[JSContext currentArguments] repeats:YES];
	};
}

#pragma mark - Public

- (void)encryptFile:(NSURL *)fileURL completion:(void (^)(NSURL *encryptedURL))completion
{
	if (!fileURL || !self.keyManager){
		completion(nil);
		return;
	}
	
	NSData *data = [NSData dataWithContentsOfURL:fileURL];
	
	if (!data){
		completion(nil);
		return;
	}
	
	File *file = [[File alloc] init];
	file.filename = [fileURL lastPathComponent];
	file.data = data;
	
	[self.GPG invokeMethod:@"box" withArguments:@[@{@"msg": [file stringRepresentation], @"sign_with": self.keyManager}, ^(JSValue *error, JSValue *resultString, JSValue *resultBuffer){
		
		NSString *encryptedFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
		[[resultString toString] writeToFile:encryptedFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
		completion([NSURL fileURLWithPath:encryptedFile]);
		
	}]];
}

- (void)decryptFile:(NSURL *)fileURL completion:(void (^)(NSURL *decryptedURL))completion
{
	if (!fileURL || !self.keyManager){
		completion(nil);
		return;
	}
	
	JSValue *keyRing = [self.GPG[@"keyring"][@"KeyRing"] constructWithArguments:nil];
	[keyRing invokeMethod:@"add_key_manager" withArguments:@[self.keyManager]];
	
	NSString *encryptedString = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:nil];
	
	if (!encryptedString){
		completion(nil);
		return;
	}
	
	[self.GPG invokeMethod:@"unbox" withArguments:@[@{@"keyfetch" : keyRing, @"armored": encryptedString}, ^(JSValue *error, JSValue *resultString){
		
		File *file = [[File alloc] initWithString:[resultString toString]];
		
		
		NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:file.filename];
		[file.data writeToFile:path atomically:YES];
		completion([NSURL fileURLWithPath:path]);
	}]];
}

@end

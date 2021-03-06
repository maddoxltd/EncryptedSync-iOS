//
//  FilesViewController.m
//  EncryptedSync
//
//  Created by Simon Maddox on 19/09/2016.
//  Copyright © 2016 Maddox Ltd. All rights reserved.
//

#import "FilesViewController.h"
#import "EncryptionBridge.h"
#import "File.h"
#import "InfoViewController.h"
#import "FileSharing.h"

@interface FilesViewController () <UIDocumentInteractionControllerDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate>
@property (nonatomic, strong) NSArray *files;
@property (nonatomic, strong) NSMutableArray *temporaryFiles;
@property (nonatomic, strong) EncryptionBridge *encryptionBridge;
@property (nonatomic, strong) FileSharing *fileSharing;

@property (nonatomic, strong) id encryptionReloadObserver;
@end

@implementation FilesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.temporaryFiles = [NSMutableArray array];
	
	__weak typeof(self) weakSelf = self;
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		__strong typeof(weakSelf) strongSelf = weakSelf;
		[strongSelf loadEncryptionBridge];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			__strong typeof(weakSelf) strongSelf = weakSelf;
			[strongSelf refreshFiles:nil];
		});
	});
	
	self.encryptionReloadObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"Reload Encryption" object:nil queue:[[NSOperationQueue alloc] init] usingBlock:^(NSNotification * _Nonnull note) {
		__strong typeof(weakSelf) strongSelf = weakSelf;
		strongSelf.encryptionBridge = nil;
		[strongSelf loadEncryptionBridge];
	}];
	
	self.fileSharing = [[FileSharing alloc] init];
//	[self.fileSharing listenForSharing];

}

- (void)loadEncryptionBridge
{
	__weak typeof(self) weakSelf = self;
	self.encryptionBridge = [[EncryptionBridge alloc] initWithPassphraseCallback:^NSString *{
		
		__block NSString *passphrase = nil;
		
		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
		dispatch_async(dispatch_get_main_queue(), ^{
			
			UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter a passphrase for your private key" message:@"Remember this - there's no way to retrieve it later!" preferredStyle:UIAlertControllerStyleAlert];
			[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
				[textField setSecureTextEntry:YES];
				[textField setPlaceholder:@"Passphrase"];
			}];
			[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
				[textField setSecureTextEntry:YES];
				[textField setPlaceholder:@"Passphrase (again)"];
			}];
			[alertController addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
				
				NSArray *passphraseValues = [alertController.textFields valueForKeyPath:@"text"];
				
				if ([passphraseValues count] == 2 && [[passphraseValues firstObject] isEqual:[passphraseValues lastObject]]){
					passphrase = [passphraseValues firstObject];
					dispatch_semaphore_signal(semaphore);
				} else {
					NSLog(@"Passphrases not equal");
				}
				
			}]];
			[alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
				
			}]];
			
			__strong typeof(weakSelf) strongSelf = weakSelf;
			[strongSelf presentViewController:alertController animated:YES completion:nil];
			
		});
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
		return passphrase;
	}];
}

- (IBAction)refreshFiles:(id)sender
{
	__weak typeof(self) weakSelf = self;
	[self.encryptionBridge listFilesWithCompletion:^(NSArray<File *> *files, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			__strong typeof(weakSelf) strongSelf = weakSelf;
			strongSelf.files = files;
			[strongSelf.tableView reloadData];
			[strongSelf.refreshControl endRefreshing];
		});
	}];
}

#pragma mark - Adding Files from a UIDocumentPicker

- (IBAction)addFile:(id)sender
{
	UIDocumentMenuViewController *documentMenuViewController = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:@[@"public.item"] inMode:UIDocumentPickerModeImport];
	documentMenuViewController.delegate = self;
	[self.navigationController presentViewController:documentMenuViewController animated:YES completion:nil];
}

- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker
{
	documentPicker.delegate = self;
	[self.navigationController presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
	File *file = [[File alloc] init];
	file.filename = [url lastPathComponent];
	file.status = @"Encrypting...";
	[self.temporaryFiles addObject:file];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
	
	__weak typeof(self) weakSelf = self;
	[self.encryptionBridge encryptAndUploadFile:url encryptionCompleteHandler:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			__strong typeof(weakSelf) strongSelf = weakSelf;
			file.status = @"Uploading...";
			[strongSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
		});
	} completion:^(NSString *remotePath, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			__strong typeof(weakSelf) strongSelf = weakSelf;
			[strongSelf.temporaryFiles removeObject:file];
			[strongSelf refreshFiles:nil];
		});
	}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0){
		return [self.temporaryFiles count];
	}
    return [self.files count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0){
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UploadingCell" forIndexPath:indexPath];
		File *file = self.temporaryFiles[indexPath.row];
		cell.textLabel.text = file.filename;
		cell.detailTextLabel.text = file.status;
		
		return cell;
	} else {
	
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
		
		File *file = self.files[indexPath.row];
		cell.textLabel.text = file.filename;
		cell.detailTextLabel.text = file.status;
		
		return cell;
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1){
		File *file = self.files[indexPath.row];
		file.status = @"Downloading...";
		[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
		
		__weak typeof(self) weakSelf = self;
		[self.encryptionBridge downloadAndDecryptFile:file downloadCompleteHandler:^{
			dispatch_async(dispatch_get_main_queue(), ^{
				file.status = @"Decrypting...";
				__strong typeof(weakSelf) strongSelf = weakSelf;
				[strongSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
				
			});
		} completion:^(NSURL *fileURL, NSError *error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				__strong typeof(weakSelf) strongSelf = weakSelf;
				file.status = nil;
				[strongSelf.tableView deselectRowAtIndexPath:indexPath animated:YES];
				[strongSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
				UIDocumentInteractionController *documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
				documentInteractionController.delegate = strongSelf;
				[documentInteractionController presentPreviewAnimated:YES];
			});
		}];
	} else {
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
	}
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
	return self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"ShowFileInfo"]){
		InfoViewController *viewController = (InfoViewController *)segue.destinationViewController;
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		viewController.file = self.files[indexPath.row];
		viewController.fileSharing = self.fileSharing;
	}
}

@end

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

@interface FilesViewController () <UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) NSArray *files;
@property (nonatomic, strong) EncryptionBridge *encryptionBridge;
@end

@implementation FilesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.files = [NSArray array];
	
	self.encryptionBridge = [[EncryptionBridge alloc] init];
	
	[self refreshFiles:nil];

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.files count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
	File *file = self.files[indexPath.row];
	cell.textLabel.text = file.filename;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	File *file = self.files[indexPath.row];
	
	__weak typeof(self) weakSelf = self;
	[self.encryptionBridge downloadAndDecryptFile:file completion:^(NSURL *fileURL, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			__strong typeof(weakSelf) strongSelf = weakSelf;
			
			[strongSelf.tableView deselectRowAtIndexPath:indexPath animated:YES];
			UIDocumentInteractionController *documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
			documentInteractionController.delegate = strongSelf;
			[documentInteractionController presentPreviewAnimated:YES];
		});
	}];
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
	return self;
}

@end

//
//  ProfileViewController.m
//  Anchor
//
//  Created by Eric Li on 7/21/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ProfileViewController.h"
#import "ZLEditCell.h"
#import "ZLPhotoCell.h"
#import "ZLTableSectionHeaderView.h"
#import "ANDataStoreCoordinator.h"

@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate, ZLEditCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIView *titleBar;

@end

@implementation ProfileViewController

- (id)init
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.detailViewIdentifier = NSStringFromClass([self class]);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_tableView registerNib:[UINib nibWithNibName:@"ZLEditCell" bundle:nil] forCellReuseIdentifier:@"ZLEditCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ZLPhotoCell" bundle:nil] forCellReuseIdentifier:@"ZLPhotoCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshProfilePicture:) name:kProfilePictureDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_tableView release];
    [_titleBar release];
    [_launchOption release];
    [super dealloc];
}

- (void)setLaunchOption:(NSString *)launchOption
{
    if (launchOption != _launchOption) {
        [_launchOption release];
        _launchOption = [launchOption retain];
        
        if (_launchOption) {
            NSInteger launchOption = [_launchOption intValue];
            if (launchOption > 0 && launchOption < 5) {
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:launchOption] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        }
    }
}

#pragma mark - Actions
- (IBAction)menuButtonPressed:(UIButton *)sender
{
    [self.delegate ANDetailViewControllerDidClickMenuButton:self];
}

- (IBAction)homeButtonPressed:(UIButton *)sender
{
    [self.delegate ANDetailViewControllerDidClickHomeButton:self];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 5;
            break;
        case 2:
            return 3;
            break;
        case 3:
            return 5;
            break;
        case 4:
            return 4;
            break;
        default:
            return 0;
            break;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 30)] autorelease];
    label.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
//    label.backgroundColor = [_titleBar.backgroundColor colorWithAlphaComponent:0.8];
    label.textColor = [UIColor darkTextColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.contentMode = UIViewContentModeBottom;
    label.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:17];
    
    switch (section) {
        case 0:
            label.text = @"  Profile Photo";
            break;
        case 1:
            label.text = @"  Demographics";
            break;
        case 2:
            label.text = @"  Contact";
            break;
        case 3:
            label.text = @"  Clinical";
            break;
        case 4:
            label.text = @"  Insurance (If Applicable)";
            break;
        default:
            label.text = nil;
            break;
    }

    return label;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 88.0;
            break;
        default:
            return 50.0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *currentUser = [[ANDataStoreCoordinator shared] getCurrentUser];
    
    switch (indexPath.section) {
        case 0:
        {
            ZLPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZLPhotoCell"];
            User *currentUser = [[ANDataStoreCoordinator shared] getCurrentUser];
            if ([[NSFileManager defaultManager] fileExistsAtPath:currentUser.profilePhotoPath]) {
                [cell.profileImageView setImage:[UIImage imageWithContentsOfFile:currentUser.profilePhotoPath]];
            }
            else {
                [cell.profileImageView setImage:[UIImage imageNamed:@"profile_default"]];
            }
            return cell;
        }
            break;
        case 1:
        {
            ZLEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZLEditCell"];
            cell.delegate = self;
            cell.managedObject = currentUser;
            cell.customSeparatorView.hidden = YES;
            cell.customSeparatorViewTop.hidden = YES;
            switch (indexPath.row) {
                case 0:
                    cell.editingKey = @"firstName";
                    cell.titleLabel.text = @"First Name";
                    cell.customSeparatorViewTop.hidden = NO;
                    break;
                case 1:
                    cell.editingKey = @"middleName";
                    cell.titleLabel.text = @"Middle Name";
                    break;
                case 2:
                    cell.editingKey = @"lastName";
                    cell.titleLabel.text = @"Last Name";
                    break;
                case 3:
                    cell.editingKey = @"nickname";
                    cell.titleLabel.text = @"Nickname";
                    break;
                case 4:
                    cell.editingKey = @"dateOfBirth";
                    cell.titleLabel.text = @"Date of Birth";
                    break;
                default:
                    break;
            }
            return cell;
        }
            break;
        case 2:
        {
            ZLEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZLEditCell"];
            cell.delegate = self;
            cell.managedObject = currentUser;
            cell.customSeparatorView.hidden = YES;
            cell.customSeparatorViewTop.hidden = YES;
            switch (indexPath.row) {
                case 0:
                    cell.editingKey = @"primaryPhone";
                    cell.titleLabel.text = @"Primary Phone";
                    cell.customSeparatorViewTop.hidden = NO;
                    break;
                case 1:
                    cell.editingKey = @"secondaryPhone";
                    cell.titleLabel.text = @"Secondary Phone";
                    break;
                case 2:
                    cell.editingKey = @"email";
                    cell.titleLabel.text = @"E-Mail";
                    break;
                default:
                    break;
            }
            return cell;
        }
            break;
        case 3:
        {
            ZLEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZLEditCell"];
            cell.delegate = self;
            cell.managedObject = currentUser;
            cell.customSeparatorView.hidden = YES;
            cell.customSeparatorViewTop.hidden = YES;
            switch (indexPath.row) {
                case 0:
                    cell.editingKey = @"psychologist";
                    cell.titleLabel.text = @"Counselor";
                    cell.customSeparatorViewTop.hidden = NO;
                    break;
                case 1:
                    cell.editingKey = @"psychologistPhone";
                    cell.titleLabel.text = @"Phone";
                    break;
                case 2:
                    cell.editingKey = @"psychiatrist";
                    cell.titleLabel.text = @"Psychiatrist";
                    break;
                case 3:
                    cell.editingKey = @"psychiatristPhone";
                    cell.titleLabel.text = @"Phone";
                    break;
                case 4:
                    cell.editingKey = @"diagnosis";
                    cell.titleLabel.text = @"Diagnosis";
                    break;
                default:
                    break;
            }
            return cell;
        }
            break;
        case 4:
        {
            ZLEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZLEditCell"];
            cell.delegate = self;
            cell.managedObject = currentUser;
            cell.customSeparatorView.hidden = YES;
            cell.customSeparatorViewTop.hidden = YES;
            switch (indexPath.row) {
                case 0:
                    cell.editingKey = @"primaryInsuranceName";
                    cell.titleLabel.text = @"Primary";
                    cell.customSeparatorViewTop.hidden = NO;
                    break;
                case 1:
                    cell.editingKey = @"primaryInsuranceId";
                    cell.titleLabel.text = @"ID#";
                    break;
                case 2:
                    cell.editingKey = @"secondaryInsuranceName";
                    cell.titleLabel.text = @"Secondary";
                    break;
                case 3:
                    cell.editingKey = @"secondaryInsuranceId";
                    cell.titleLabel.text = @"ID#";
                    break;
                default:
                    break;
            }
            return cell;
        }
            break;
        default:
            return nil;
            break;
    }
    
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self takeProfilePicture];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Notification Handler
- (void)handleKeyboardWillShowNotification:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
       [_tableView setContentInset:UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)];
    }];
}

- (void)handleKeyboardWillHideNotification:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [_tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }];
}

- (void)refreshProfilePicture:(id)sender
{
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - ZLEditCellDelegate 
- (void)ZLEditCellDidStartEditing:(ZLEditCell *)cell
{
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_tableView scrollToRowAtIndexPath:[_tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:YES];

    });
}

- (void)ZLEditCellRequestEndEditing:(ZLEditCell *)cell
{
    [_tableView endEditing:NO];
}

- (void)ZLEditCellDidPressReturn:(ZLEditCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSInteger rowCount = [self tableView:_tableView numberOfRowsInSection:section];
    NSInteger sectionCount = [self numberOfSectionsInTableView:_tableView];
    
    if (row < rowCount - 1) {
        ZLEditCell *cell = (ZLEditCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row+1 inSection:section]];
        [cell.textField becomeFirstResponder];
    }
    else if (section < sectionCount - 1) {
        ZLEditCell *cell = (ZLEditCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section + 1]];
        [cell.textField becomeFirstResponder];
    }
}

#pragma mark - Profile Picture
- (void)takeProfilePicture
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Your device doesn't have camera" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
		return;
	}
    
    picker.allowsEditing = YES;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    
	[self presentViewController:picker animated:YES completion:^{}];
    [picker release];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
	if (!image) image = [info objectForKey:UIImagePickerControllerOriginalImage];
	if (!image) return;
        
    User *currentUser = [[ANDataStoreCoordinator shared] getCurrentUser];
    if ([currentUser.profilePhotoPath length] > 0) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:currentUser.profilePhotoPath error:&error];
    }
    
    CFUUIDRef uuid = CFUUIDCreate(nil);
	NSString *uuidString = [(NSString*)CFUUIDCreateString(nil, uuid) autorelease];
    NSString *path = [NSString stringWithFormat:@"%@/%@.jpg", [[ANDataStoreCoordinator shared] profilePictureDirectory], uuidString];
    
    NSData *imageData= UIImageJPEGRepresentation(image, 1.0);
    [imageData writeToFile:path atomically:YES];
    
    currentUser.profilePhotoPath = path;
    [[ANDataStoreCoordinator shared] saveDataStore];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProfilePictureDidChangeNotification object:nil];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self refreshProfilePicture:nil];
    }];
}
@end

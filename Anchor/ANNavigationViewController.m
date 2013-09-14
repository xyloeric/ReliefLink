//
//  ANNavigationViewController.m
//  Anchor
//
//  Created by Eric Li on 7/15/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ANCommons.h"
#import "ANDataStoreCoordinator.h"

#import "ANNavigationViewController.h"
#import "ANNavigationCell.h"

#import "MoodEntryViewController.h"
#import "MoodViewController.h"
#import "EmergencyViewController.h"
#import "SafetyPlanningViewController.h"
#import "SettingsViewController.h"
#import "ProfileViewController.h"
#import "ReminderViewController.h"
#import "ResourceViewController.h"
#import "CopingViewController.h"

static NSString *CellIdentifier = @"NavigationCell";

@interface ANNavigationViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{

}
@property (retain, nonatomic) IBOutlet UIImageView *profileImageView;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSArray *navigationMainItems;
@property (nonatomic, retain) NSArray *navigationUtilityItems;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;

@property (retain, nonatomic) IBOutlet UIView *buttonContainerView;
@property (retain, nonatomic) IBOutlet UIButton *settingsButton;
@property (nonatomic, retain) UIButton *button1, *button2, *button3, *button4, *button5, *button6;
@end

@implementation ANNavigationViewController

- (id)init
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshProfilePicture:) name:kProfilePictureDidChangeNotification object:nil];
    
    [_tableView registerNib:[UINib nibWithNibName:@"ANNavigationCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    [_profileImageView.layer setCornerRadius:_profileImageView.frame.size.width/2];
    [_profileImageView.layer setMasksToBounds:YES];
    [self refreshProfilePicture:nil];
    
    [_settingsButton setBackgroundImage:[UIImage imageNamed:@"icon_settings"] forState:UIControlStateNormal];
    
    [self initializeButtons];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self layoutButtons];
    
    User *currentUser = [[ANDataStoreCoordinator shared] getCurrentUser];
    
    if ([currentUser.nickname length] > 0) {
        self.nameLabel.text = currentUser.nickname;
    }
    else {
        NSMutableString *name = [NSMutableString string];
        if (currentUser.firstName) {
            [name appendString:currentUser.firstName];
        }
        
        if (currentUser.lastName) {
            [name appendFormat:@" %@", currentUser.lastName];
        }
        
        self.nameLabel.text = name;
    }
    
    if ([self.nameLabel.text length] == 0) {
        self.nameLabel.text = @"Your Name";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_navigationMainItems release];
    [_navigationUtilityItems release];
    [_profileImageView release];
    [_tableView release];
    
    [_buttonContainerView release];
    [_button1 release];
    [_button2 release];
    [_button3 release];
    [_button4 release];
    [_button5 release];
    [_button6 release];
    [_settingsButton release];
    [_nameLabel release];
    [super dealloc];
}

#pragma mark - Actions
- (void)navButtonClicked:(UIButton *)button
{
    switch (button.tag) {
        case 1:
            
            break;
        case 2:
        
            break;
        case 3:
        
            break;
        case 4:
        {
            MoodViewController *vc = [[MoodViewController alloc] init];
            [_delegate ANNavigationViewController:self requestPresentingViewController:vc];
            [vc release];
        }
            break;
        case 5:
        
            break;
        case 6:
        
            break;
        default:
            break;
    }
}

- (IBAction)settingsButtonClicked:(id)sender
{
    SettingsViewController *vc = [[SettingsViewController alloc] init];
    [_delegate ANNavigationViewController:self requestPresentingViewController:vc];
    [vc release];
}

- (IBAction)takeProfilePictureButtonClicked:(id)sender
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
    
    _profileImageView.image = image;
    
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
    
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

- (void)refreshProfilePicture:(id)sender
{
    User *currentUser = [[ANDataStoreCoordinator shared] getCurrentUser];
    if ([[NSFileManager defaultManager] fileExistsAtPath:currentUser.profilePhotoPath]) {
        [_profileImageView setImage:[UIImage imageWithContentsOfFile:currentUser.profilePhotoPath]];
    }
    else {
        [_profileImageView setImage:[UIImage imageNamed:@"profile_default"]];
    }
}

#pragma mark - View initialization Helpers
- (void)initializeButtons
{
    UIButton *temp = [UIButton buttonWithType:UIButtonTypeCustom];
    [temp setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
    [temp setContentMode:UIViewContentModeScaleAspectFit];
    [temp setBackgroundColor:[UIColor lightGrayColor]];
    [temp setImage:[UIImage imageNamed:@"icon_profile"] forState:UIControlStateNormal];
    [temp setTitle:@"User Profile" forState:UIControlStateNormal];
    [temp setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [temp addTarget:self action:@selector(navButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    temp.tag = 1;
    [temp.titleLabel setFont:[UIFont fontWithName:@"AvenirNextCondensed-Medium" size:17]];
    temp.layer.borderWidth = [[UIScreen mainScreen] scale] == 2.0 ? 0.5 : 1.0;
    temp.layer.borderColor = kANBoarderSemiTransparentColor.CGColor;
    [_buttonContainerView addSubview:temp];
    self.button1 = temp;
        
    temp = [UIButton buttonWithType:UIButtonTypeCustom];
    [temp setTitle:@"Safety Planning" forState:UIControlStateNormal];
    [temp setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [temp addTarget:self action:@selector(navButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    temp.tag = 2;
    [temp.titleLabel setFont:[UIFont fontWithName:@"AvenirNextCondensed-Medium" size:17]];
    temp.layer.borderWidth = [[UIScreen mainScreen] scale] == 2.0 ? 0.5 : 1.0;
    temp.layer.borderColor = kANBoarderSemiTransparentColor.CGColor;
    [_buttonContainerView addSubview:temp];
    self.button2 = temp;
    
    temp = [UIButton buttonWithType:UIButtonTypeCustom];
    [temp setTitle:@"Resource Kit" forState:UIControlStateNormal];
    [temp setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [temp addTarget:self action:@selector(navButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    temp.tag = 3;
    [temp.titleLabel setFont:[UIFont fontWithName:@"AvenirNextCondensed-Medium" size:17]];
    temp.layer.borderWidth = [[UIScreen mainScreen] scale] == 2.0 ? 0.5 : 1.0;
    temp.layer.borderColor = kANBoarderSemiTransparentColor.CGColor;
    [_buttonContainerView addSubview:temp];
    self.button3 = temp;

    temp = [UIButton buttonWithType:UIButtonTypeCustom];
    [temp setTitle:@"Mood Monitor" forState:UIControlStateNormal];
    [temp setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [temp addTarget:self action:@selector(navButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    temp.tag = 4;
    [temp.titleLabel setFont:[UIFont fontWithName:@"AvenirNextCondensed-Medium" size:17]];
    temp.layer.borderWidth = [[UIScreen mainScreen] scale] == 2.0 ? 0.5 : 1.0;
    temp.layer.borderColor = kANBoarderSemiTransparentColor.CGColor;
    [_buttonContainerView addSubview:temp];
    self.button4 = temp;
    
    temp = [UIButton buttonWithType:UIButtonTypeCustom];
    [temp setTitle:@"Coping Kit" forState:UIControlStateNormal];
    [temp setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [temp addTarget:self action:@selector(navButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    temp.tag = 5;
    [temp.titleLabel setFont:[UIFont fontWithName:@"AvenirNextCondensed-Medium" size:17]];
    temp.layer.borderWidth = [[UIScreen mainScreen] scale] == 2.0 ? 0.5 : 1.0;
    temp.layer.borderColor = kANBoarderSemiTransparentColor.CGColor;
    [_buttonContainerView addSubview:temp];
    self.button5 = temp;
    
    temp = [UIButton buttonWithType:UIButtonTypeCustom];
    [temp setTitle:@"Emergency" forState:UIControlStateNormal];
    [temp setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [temp addTarget:self action:@selector(navButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    temp.tag = 6;
    [temp.titleLabel setFont:[UIFont fontWithName:@"AvenirNextCondensed-Medium" size:17]];
    temp.layer.borderWidth = [[UIScreen mainScreen] scale] == 2.0 ? 0.5 : 1.0;
    temp.layer.borderColor = kANBoarderSemiTransparentColor.CGColor;
    [_buttonContainerView addSubview:temp];
    self.button6 = temp;
}

- (void)layoutButtons
{
    CGFloat originX = 0.0, originY = 0.0;
    CGFloat sizeWidth = _buttonContainerView.frame.size.width / 2.0;
    CGFloat sizeHeight = _buttonContainerView.frame.size.height / 3.0;
    
    [_button1 setFrame:CGRectMake(originX, originY, sizeWidth, sizeHeight)];
    
    originY += sizeHeight;
    [_button2 setFrame:CGRectMake(originX, originY, sizeWidth, sizeHeight)];

    originY += sizeHeight;
    [_button3 setFrame:CGRectMake(originX, originY, sizeWidth, sizeHeight)];
    
    originY = 0;
    originX += sizeWidth;
    [_button4 setFrame:CGRectMake(originX, originY, sizeWidth, sizeHeight)];

    originY += sizeHeight;
    [_button5 setFrame:CGRectMake(originX, originY, sizeWidth, sizeHeight)];

    originY += sizeHeight;
    [_button6 setFrame:CGRectMake(originX, originY, sizeWidth, sizeHeight)];

}

#pragma mark - Content Helpers
- (NSArray *)navigationMainItems
{
    if (!_navigationMainItems) {
        NSArray *result = @[@{@"title": @"How do I feel", @"icon": @"icon_mood"},
                            @{@"title": @"Reminders", @"icon": @"icon_reminder"},
                            @{@"title": @"Safety Planning", @"icon": @"icon_safety_planning"},
                            @{@"title": @"Resources", @"icon": @"icon_resource_kit"},
                            @{@"title": @"Emergency", @"icon": @"icon_emergency"}];
        _navigationMainItems = [result retain];
    }

    
    return _navigationMainItems;
}

- (NSArray *)navigationUtilityItems
{
    if (!_navigationUtilityItems) {
        NSArray *result = @[@{@"title": @"Profile", @"icon": @"icon_profile"}];
        _navigationUtilityItems = [result retain];
    }

    
    return _navigationUtilityItems;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [self.navigationMainItems count];
            break;
        case 1:
            return [self.navigationUtilityItems count];
            break;
        default:
            return 0;
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ANNavigationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    switch (indexPath.section) {
        case 0:
        {
            NSDictionary *item = [self.navigationMainItems objectAtIndex:indexPath.row];
            cell.navigationItem = item;
        }
            break;
        case 1:
        {
            NSDictionary *item = [self.navigationUtilityItems objectAtIndex:indexPath.row];
            cell.navigationItem = item;
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    MoodViewController *vc = [[MoodViewController alloc] init];
                    [_delegate ANNavigationViewController:self requestPresentingViewController:vc];
                    [vc release];
                }
                    break;
                case 1:
                {
                    ReminderViewController *vc = [[ReminderViewController alloc] init];
                    [_delegate ANNavigationViewController:self requestPresentingViewController:vc];
                    [vc release];
                }
                    break;
                case 2:
                {
                    SafetyPlanningViewController *vc = [[SafetyPlanningViewController alloc] init];
                    [_delegate ANNavigationViewController:self requestPresentingViewController:vc];
                    [vc release];
                }
                    break;
                case 3:
                {
                    ResourceViewController *vc = [[ResourceViewController alloc] init];
                    [_delegate ANNavigationViewController:self requestPresentingViewController:vc];
                    [vc release];
                }
                    break;
                case 4:
                {
                    EmergencyViewController *vc = [[EmergencyViewController alloc] init];
                    [_delegate ANNavigationViewController:self requestPresentingViewController:vc];
                    [vc release];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            ProfileViewController *vc = [[ProfileViewController alloc] init];
            [_delegate ANNavigationViewController:self requestPresentingViewController:vc];
            [vc release];
        }
            break;
        default:
            break;
    }
}

@end

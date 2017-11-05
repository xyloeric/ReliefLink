//
//  EmergencyViewController.m
//  Anchor
//
//  Created by Eric Li on 7/21/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "EmergencyViewController.h"
#import "ZLEmergencyActionCell.h"
#import "ZLWebViewController.h"
#import <MessageUI/MessageUI.h>
#import "ANDataStoreCoordinator.h"
#import "PersonForHelp.h"

@interface EmergencyViewController () <UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIView *titleBar;
@property (nonatomic, retain) NSArray *contacts;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *titleHeightConstraint;
@end

@implementation EmergencyViewController

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
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        _titleHeightConstraint.constant = 64.0;
    }
    else {
        _titleHeightConstraint.constant = 44.0;
    }
    
    [_tableView registerNib:[UINib nibWithNibName:@"ZLEmergencyActionCell" bundle:nil] forCellReuseIdentifier:@"ZLEmergencyActionCell"];
    
    NSArray *contacts = [[ANDataStoreCoordinator shared] fetchObjectsOfEntityType:@"PersonForHelp" count:-1];
    self.contacts = contacts;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZLEmergencyActionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZLEmergencyActionCell"];
    
    switch (indexPath.row) {
        case 0:
            cell.titleLabel.text = @"Call 911";
            cell.iconImageView.image = [UIImage imageNamed:@"911"];
            break;
        case 1:
            cell.titleLabel.text = @"Call Helpline";
            cell.iconImageView.image = [UIImage imageNamed:@"Helpline"];
            break;
        case 2:
            cell.titleLabel.text = @"Call Counselor";
            cell.iconImageView.image = [UIImage imageNamed:@"Helpline"];
            break;
        case 3:
            cell.titleLabel.text = @"Call Psychiatrist";
            cell.iconImageView.image = [UIImage imageNamed:@"Helpline"];
            break;
        case 4:
            cell.titleLabel.text = @"Live Chat";
            cell.iconImageView.image = [UIImage imageNamed:@"TextMessage"];
            break;
        case 5:
            cell.titleLabel.text = @"Text Friends and Family";
            cell.iconImageView.image = [UIImage imageNamed:@"TextMessage"];
            break;
        case 6:
            cell.titleLabel.text = @"Email Friends and Family";
            cell.iconImageView.image = [UIImage imageNamed:@"email"];
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [[ANDataStoreCoordinator shared] callPhoneNumber:@"911"];
            break;
        case 1:
            [[ANDataStoreCoordinator shared] callPhoneNumber:@"+18002738255"];
            break;
        case 2:
        {
            User *currentUser = [[ANDataStoreCoordinator shared] getCurrentUser];
            if (currentUser.psychologistPhone.length > 0) {
                [[ANDataStoreCoordinator shared] callPhoneNumber:currentUser.psychologistPhone];
            }
            else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"You haven't setup your conuselor's contact yet, please go to profile and set it up" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Take Me There" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestSwitchView" object:@{@"class": @"Profile", @"launchOption": @"3"}];
                }]];
                [alert addAction:[UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
            break;
        case 3:
        {
            User *currentUser = [[ANDataStoreCoordinator shared] getCurrentUser];
            if (currentUser.psychiatristPhone.length > 0) {
                [[ANDataStoreCoordinator shared] callPhoneNumber:currentUser.psychiatristPhone];
            }
            else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"You haven't setup your psychiatrist's contact yet, please go to profile and set it up" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Take Me There" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestSwitchView" object:@{@"class": @"Profile", @"launchOption": @"3"}];
                }]];
                [alert addAction:[UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
            break;
        case 4:
        {
            ZLWebViewController *vc = [[ZLWebViewController alloc] init];
            vc.titleBarColor = _titleBar.backgroundColor;
            vc.title = @"Live Chat";
            [self presentViewController:vc animated:YES completion:^{
                [vc loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://suicidepreventionlifeline.org/GetHelp/LifelineChat.aspx"]]];
            }];
            [vc release];
        }
            break;
        case 5:
        {
            NSMutableArray *temp = [NSMutableArray array];
            for (PersonForHelp *pfh in _contacts) {
                if ([pfh.phone length] > 0) {
                    [temp addObject:pfh.phone];
                }
            }
            
            if ([temp count] == 0) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"You don't have any contacts with phone number setup yet, please add your friends and family's contacts in the safety plan section" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Take Me There" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestSwitchView" object:@{@"class": @"SafetyPlan", @"launchOption": @"3"}];                }]];
                [alert addAction:[UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else {
                if([MFMessageComposeViewController canSendText])
                {
                    MFMessageComposeViewController *vc = [[[MFMessageComposeViewController alloc] init] autorelease];
                    vc.body = @"I want to chat.";
                    vc.recipients = temp;
                    vc.messageComposeDelegate = self;
                    [self presentViewController:vc animated:YES completion:^{}];
                }
            }
        }
            break;
        case 6:
        {
            NSMutableArray *temp = [NSMutableArray array];
            for (PersonForHelp *pfh in _contacts) {
                if ([pfh.email length] > 0) {
                    [temp addObject:pfh.email];
                }
            }
            
            if ([_contacts count] == 0) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"You don't have any contacts with email address setup yet, please add your friends and family's contacts in the safety plan section" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Take Me There" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestSwitchView" object:@{@"class": @"SafetyPlan", @"launchOption": @"3"}];                }]];
                [alert addAction:[UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else {
                if ([MFMailComposeViewController canSendMail]) {
                    MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
                    vc.mailComposeDelegate = self;
                    [vc setMessageBody:@"I'm feeling like I need some help." isHTML:NO];
                    [vc setSubject:@"I want to chat with you"];
                    [vc setToRecipients:temp];
                    [self presentViewController:vc animated:YES completion:^{}];
                }
            }
        }
            break;
        default:
            break;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc {
    [_tableView release];
    [_titleBar release];
    [_titleHeightConstraint release];
    [super dealloc];
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
            break;
        case MessageComposeResultSent:
            break;
        default:
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:^{}];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:^{}];
}
@end

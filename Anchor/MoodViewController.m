//
//  MoodViewController.m
//  ReliefLink
//
//  Created by Eric Li on 8/7/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "MoodViewController.h"
#import "MoodCell.h"
#import "Mood.h"
#import "SuicidalThought.h"
#import "ANDataStoreCoordinator.h"
#import "UIImage+ANUniversalImage.h"
#import "ImageAndTitleCell.h"
#import "ANCommons.h"
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>

@interface MoodViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) NSInteger moodMode;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIButton *modeSwitchButton;

@property (nonatomic) NSInteger promptMode;
@property (nonatomic, retain) UIView *promptViewContainer;
@property (retain, nonatomic) IBOutlet UIView *promptView;
@property (retain, nonatomic) IBOutlet UITableView *promptTableView;
@property (retain, nonatomic) NSArray *promptViewVerticalConstraints;
@property (nonatomic, retain) UIView *coverView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *titleHeightConstraint;
@end

@implementation MoodViewController

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
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    view.userInteractionEnabled = YES;
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.0;
    self.coverView = view;
    [view release];
    [self.view addSubview:_coverView];
    NSDictionary *views = @{@"cover": _coverView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[cover]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[cover]-0-|" options:0 metrics:nil views:views]];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverViewTapped:)];
    [_coverView addGestureRecognizer:recognizer];
    [recognizer release];
    
    [_modeSwitchButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:14]];
    [_modeSwitchButton setBackgroundImage:[UIImage universalButtonImage] forState:UIControlStateNormal];
    [_tableView registerNib:[UINib nibWithNibName:@"MoodCell" bundle:nil] forCellReuseIdentifier:@"MoodCell"];
    [_promptTableView registerNib:[UINib nibWithNibName:@"ImageAndTitleCell" bundle:nil] forCellReuseIdentifier:@"ImageAndTitleCell"];
    
    _moodMode = 0;
    _promptMode = 0;
    [_modeSwitchButton setTitle:@"Mood" forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableView release];
    [_modeSwitchButton release];
    [_promptView release];
    [_promptViewVerticalConstraints release];
    [_coverView release];
    [_promptTableView release];
    [_titleHeightConstraint release];
    [super dealloc];
}

- (IBAction)menuButtonPressed:(UIButton *)sender
{
    [self.delegate ANDetailViewControllerDidClickMenuButton:self];
}

- (IBAction)homeButtonPressed:(UIButton *)sender
{
    [self.delegate ANDetailViewControllerDidClickHomeButton:self];
}

- (IBAction)modeSwitchButtonClicked:(UISegmentedControl *)sender
{
    self.moodMode = sender.selectedSegmentIndex;
    switch (_moodMode) {
        case 0:
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        case 1:
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
            break;
    }
}

- (IBAction)promptTitleButtonClicked:(id)sender
{
    if (_promptMode == 1) {
        [self showWholePromptView];
    }
    else if (_promptMode == 2) {
        [self hideWholePromptViewLeaveTitle:YES];
    }
}

- (void)coverViewTapped:(UITapGestureRecognizer *)recognizer
{
    [self hideWholePromptViewLeaveTitle:YES];
}

- (void)showPromptViewTitle
{
    if (!_promptViewContainer) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height, 280, 320)];
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        view.backgroundColor = [UIColor clearColor];
        view.clipsToBounds = NO;
        self.promptViewContainer = view;
        [view release];
        
        [self.view addSubview:_promptViewContainer];
        NSDictionary *views = @{@"container": _promptViewContainer};
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[container]-20-|" options:0 metrics:nil views:views]];
        
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-viewHeight-[container(==320)]" options:0 metrics:@{@"viewHeight": @(self.view.bounds.size.height)} views:views];        
        [self.view addConstraints:constraints];
        self.promptViewVerticalConstraints = constraints;

        _promptView.layer.cornerRadius = 5.0;
        [_promptView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_promptViewContainer addSubview:_promptView];
        
        views = @{@"prompt": _promptView};
        [_promptViewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[prompt]-0-|" options:0 metrics:nil views:views]];
        [_promptViewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[prompt]-0-|" options:0 metrics:nil views:views]];
    }

    
    [UIView animateWithDuration:0.3 animations:^{
        NSDictionary *views = @{@"container": _promptViewContainer};
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-viewHeight-[container(==320)]" options:0 metrics:@{@"viewHeight": @(self.view.bounds.size.height - 44)} views:views];
        [self.view removeConstraints:_promptViewVerticalConstraints];
        [self.view addConstraints:constraints];
        self.promptViewVerticalConstraints = constraints;

       [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        _promptMode = 1;
        _promptViewContainer.layer.shadowColor = [UIColor blackColor].CGColor;
        _promptViewContainer.layer.shadowOpacity = 0.5;
        _promptViewContainer.layer.shadowRadius = 5.0;
        _promptViewContainer.layer.shadowOffset = CGSizeMake(0, 0);
        CGPathRef path = CGPathCreateWithRect(_promptViewContainer.layer.bounds, NULL);
        _promptViewContainer.layer.shadowPath = path;
    }];
}

- (void)showWholePromptView
{
    [UIView animateWithDuration:0.3 animations:^{
        _coverView.alpha = 0.8;
        NSDictionary *views = @{@"container": _promptViewContainer};
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-space-[container(==320)]-space-|" options:0 metrics:@{@"space": @((self.view.bounds.size.height - 320)/2.0)} views:views];
        [self.view removeConstraints:_promptViewVerticalConstraints];
        [self.view addConstraints:constraints];
        self.promptViewVerticalConstraints = constraints;
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        _promptMode = 2;
        _promptViewContainer.layer.shadowColor = [UIColor whiteColor].CGColor;
        _promptViewContainer.layer.shadowOpacity = 0.5;
        _promptViewContainer.layer.shadowRadius = 5.0;
        _promptViewContainer.layer.shadowOffset = CGSizeMake(0, 0);
        CGPathRef path = CGPathCreateWithRect(_promptViewContainer.layer.bounds, NULL);
        _promptViewContainer.layer.shadowPath = path;
    }];
}

- (void)hideWholePromptViewLeaveTitle:(BOOL)leaveTitle
{
    [UIView animateWithDuration:0.3 animations:^{
        _coverView.alpha = 0.0;
        NSDictionary *views = @{@"container": _promptViewContainer};
        NSArray *constraints = nil;
        if (leaveTitle) {
            constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-viewHeight-[container(==320)]" options:0 metrics:@{@"viewHeight": @(self.view.bounds.size.height - 44)} views:views];
        }
        else {
            constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-viewHeight-[container(==320)]" options:0 metrics:@{@"viewHeight": @(self.view.bounds.size.height)} views:views];
        }
        [self.view removeConstraints:_promptViewVerticalConstraints];
        [self.view addConstraints:constraints];
        self.promptViewVerticalConstraints = constraints;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (leaveTitle) {
            _promptMode = 1;
            _promptViewContainer.layer.shadowColor = [UIColor blackColor].CGColor;
            _promptViewContainer.layer.shadowOpacity = 0.5;
            _promptViewContainer.layer.shadowRadius = 5.0;
            _promptViewContainer.layer.shadowOffset = CGSizeMake(0, 0);
            CGPathRef path = CGPathCreateWithRect(_promptViewContainer.layer.bounds, NULL);
            _promptViewContainer.layer.shadowPath = path;
        }
        else {
            _promptMode = 0;
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView) {
        return 5;
    }
    else {
        return 4;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView) {
        return 70.0;
    }
    else {
        return 44.0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView) {
        switch (indexPath.row) {
            case 0:
                cell.backgroundColor = [UIColor colorWithRed:0.404 green:0.690 blue:0.149 alpha:0.7];
                break;
            case 1:
                cell.backgroundColor = [UIColor colorWithRed:0.890 green:0.816 blue:0.200 alpha:0.7];
                break;
            case 2:
                cell.backgroundColor = [UIColor colorWithRed:0.945 green:0.447 blue:0.157 alpha:0.7];
                break;
            case 3:
                cell.backgroundColor = [UIColor colorWithRed:0.816 green:0.259 blue:0.125 alpha:0.7];
                break;
            case 4:
                cell.backgroundColor = [UIColor colorWithRed:0.600 green:0.094 blue:0.082 alpha:0.7];
                break;
            default:
                break;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView) {
        MoodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoodCell"];
        
        if (_moodMode == 0) {
            switch (indexPath.row) {
                case 0:
                    cell.titleLabel.text = @"Very Good";
                    cell.titleImageView.image = [UIImage imageNamed:@"icon_very_good"];
                    break;
                case 1:
                    cell.titleLabel.text = @"Good";
                    cell.titleImageView.image = [UIImage imageNamed:@"icon_not_bad"];
                    break;
                case 2:
                    cell.titleLabel.text = @"OK";
                    cell.titleImageView.image = [UIImage imageNamed:@"icon_average"];
                    break;
                case 3:
                    cell.titleLabel.text = @"Low";
                    cell.titleImageView.image = [UIImage imageNamed:@"icon_low"];
                    break;
                case 4:
                    cell.titleLabel.text = @"Very Low";
                    cell.titleImageView.image = [UIImage imageNamed:@"icon_very_low"];
                    break;
                default:
                    break;
            }
        }
        else {
            switch (indexPath.row) {
                case 0:
                    cell.titleLabel.text = @"No suicidal thoughts";
                    cell.titleImageView.image = [UIImage imageNamed:@"icon_very_good"];
                    break;
                case 1:
                    cell.titleLabel.text = @"Suicidal thoughts without plan";
                    cell.titleImageView.image = [UIImage imageNamed:@"icon_not_bad"];
                    break;
                case 2:
                    cell.titleLabel.text = @"Suicidal thoughts with plan";
                    cell.titleImageView.image = [UIImage imageNamed:@"icon_average"];
                    break;
                case 3:
                    cell.titleLabel.text = @"Have access to plan or preparations made";
                    cell.titleImageView.image = [UIImage imageNamed:@"icon_low"];
                    break;
                case 4:
                    cell.titleLabel.text = @"Strong urge to act on the plan immediately";
                    cell.titleImageView.image = [UIImage imageNamed:@"icon_very_low"];
                    break;
                default:
                    break;
            }
        }
        
        return cell;
    }
    else {
        ImageAndTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageAndTitleCell"];
        switch (indexPath.row) {
            case 0:
                cell.titleLabel.text = @"Call Lifeline";
                cell.titleImageView.image = [UIImage imageNamed:@"Helpline"];
                break;
            case 1:
                cell.titleLabel.text = @"View safety plan";
                cell.titleImageView.image = [UIImage imageNamed:@"icon_safety_planning"];
                break;
            case 2:
                cell.titleLabel.text = @"View in-app resources";
                cell.titleImageView.image = [UIImage imageNamed:@"icon_resource_kit"];
                break;
            case 3:
                cell.titleLabel.text = @"Tweet us";
                cell.titleImageView.image = [UIImage imageNamed:@"icon_twitter_2"];
                break;
            default:
                break;
        }
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *nowComponents = [gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
        
        NSDate *newDate = [gregorian dateFromComponents:nowComponents];
        
        if (_moodMode == 0) {
            Mood *mood = nil;
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Mood"];
            [request setPredicate:[NSPredicate predicateWithFormat:@"recordDate == %@", newDate]];
            NSError *error = nil;
            NSArray *result = [[[ANDataStoreCoordinator shared] managedObjectContext] executeFetchRequest:request error:&error];
            
            if ([result count] > 0) {
                mood = result[0];
            }
            else {
                mood = [NSEntityDescription insertNewObjectForEntityForName:@"Mood" inManagedObjectContext:[[ANDataStoreCoordinator shared] managedObjectContext]];
                
            }
            
            switch (indexPath.row) {
                case 0:
                    mood.moodType = @(10);
                    break;
                case 1:
                    mood.moodType = @(8);
                    break;
                case 2:
                    mood.moodType = @(6);
                    break;
                case 3:
                    mood.moodType = @(4);
                    [self showPromptViewTitle];
                    break;
                case 4:
                    mood.moodType = @(2);
                    [self showPromptViewTitle];
                    break;
                default:
                    break;
            }
            
            mood.recordDate = newDate;
            
            [[ANDataStoreCoordinator shared] saveDataStore];
        }
        else {
            SuicidalThought *thought = nil;
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SuicidalThought"];
            [request setPredicate:[NSPredicate predicateWithFormat:@"recordDate == %@", newDate]];
            NSError *error = nil;
            NSArray *result = [[[ANDataStoreCoordinator shared] managedObjectContext] executeFetchRequest:request error:&error];
            
            if ([result count] > 0) {
                thought = result[0];
            }
            else {
                thought = [NSEntityDescription insertNewObjectForEntityForName:@"SuicidalThought" inManagedObjectContext:[[ANDataStoreCoordinator shared] managedObjectContext]];
            }
            
            switch (indexPath.row) {
                case 0:
                    thought.thoughtType = @(10);
                    break;
                case 1:
                    thought.thoughtType = @(8);
                    break;
                case 2:
                    thought.thoughtType = @(6);
                    break;
                case 3:
                    thought.thoughtType = @(4);
                    [self showPromptViewTitle];
                    break;
                case 4:
                    thought.thoughtType = @(2);
                    [self showPromptViewTitle];
                    break;
                default:
                    break;
            }
            
            thought.recordDate = newDate;
            
            [[ANDataStoreCoordinator shared] saveDataStore];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshMoodGraph" object:nil];
    }
    else {
        [self hideWholePromptViewLeaveTitle:YES];
        switch (indexPath.row) {
            case 0:
                [[ANDataStoreCoordinator shared] callPhoneNumber:@"+18002738255"];
                break;
            case 1:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestSwitchView" object:@{@"class": @"SafetyPlan", @"launchOption": @"3"}];
                break;
            case 2:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestSwitchView" object:@{@"class": @"Resources"}];
                break;
            case 3:
            {
                SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [vc setInitialText:@"@relieflink @800273TALK Please help me.."];
                [self presentViewController:vc animated:NO completion:^{}];
            }
                break;
            default:
                break;
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end

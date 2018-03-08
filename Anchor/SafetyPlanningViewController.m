//
//  SafetyPlanningViewController.m
//  Anchor
//
//  Created by Eric Li on 7/21/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "SafetyPlanningViewController.h"
#import "ZLCard.h"
#import "ZLCardView.h"

#import "SafetyPlanningStep1ViewController.h"
#import "SafetyPlanningStep2ViewController.h"
#import "SafetyPlanningStep3ViewController.h"
#import "SafetyPlanningStep4ViewController.h"
#import "SafetyPlanningStep5ViewController.h"
#import "SafetyPlanningStep6ViewController.h"
#import "SafetyPlanningStepDelegate.h"

#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>


@interface SafetyPlanningViewController () <ZLCardViewDataSource, ZLCardViewDelegate, SafetyPlanningStepDelegate, MFMailComposeViewControllerDelegate>
@property (retain, nonatomic) IBOutlet ZLCardView *cardView;
@property (nonatomic, retain) NSMutableDictionary *controllerCache;
@property (nonatomic, retain) UIView *coverView;

@property (nonatomic, retain) UIView *hoveringEditView;
@property (nonatomic, retain) NSLayoutConstraint *hoveringEditViewTopConstraint;
@property (nonatomic, retain) UIView *hoveringEditContainerView;
@property (nonatomic, retain) UIView *hoveringEditContentView;
@property (nonatomic, retain) NSArray *hoveringEditContainerViewType1Constraints;
@property (nonatomic, retain) NSArray *hoveringEditContainerViewType2Constraints;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *titleHeightConstraint;

@end

@implementation SafetyPlanningViewController

- (id)init
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.detailViewIdentifier = NSStringFromClass([self class]);
        self.controllerCache = [NSMutableDictionary dictionaryWithCapacity:6];
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
    view.userInteractionEnabled = NO;
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.0;
    self.coverView = view;
    [view release];
    [self.view addSubview:_coverView];
    NSDictionary *views = @{@"cover": _coverView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[cover]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[cover]-0-|" options:0 metrics:nil views:views]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendEmail:) name:@"SendEmailFromSafetyPlan" object:nil];
    
    _cardView.cardDataSource = self;
    _cardView.cardDelegate = self;
    _cardView.pageControlOffset = -10.0;
    _cardView.shouldAvoidKeyboard = NO;
    
    [_cardView reloadData];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSInteger cachedPage = [[NSUserDefaults standardUserDefaults] integerForKey:@"safetyPlanPageCache"];
    if (cachedPage > 0) {
        [_cardView scrollToCardAtIndex:cachedPage animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_cardView release];
    [_controllerCache release];
    [_hoveringEditView release];
    [_hoveringEditViewTopConstraint release];
    [_hoveringEditContainerView release];
    [_hoveringEditContentView release];
    [_hoveringEditContainerViewType1Constraints release];
    [_hoveringEditContainerViewType2Constraints release];
    [_launchOption release];
    [_titleHeightConstraint release];
    [super dealloc];
}

- (void)setLaunchOption:(NSString *)launchOption
{
    if (launchOption != _launchOption) {
        [_launchOption release];
        _launchOption = [launchOption retain];
        
        if (_launchOption) {
            int launchOption = [_launchOption intValue];
            if (launchOption > 0 && launchOption < 6) {
                [_cardView scrollToCardAtIndex:launchOption animated:NO];
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

- (void)hoveringEditViewBackgroundTapped:(id)sender
{
    [self hideHoveringEditViewCompletionBlock:^(BOOL complete) {}];
}


#pragma mark - ZLCardViewDataSource
- (NSInteger)numberOfCardsInCardView:(ZLCardView *)cardView
{
    return 6;
}

- (ZLCard *)cardView:(ZLCardView *)cardView viewAtIndex:(NSInteger)index
{
    NSString *cardIdentifier = [NSString stringWithFormat:@"%li", (long)index];
    ZLCard *card = [cardView dequeueCardFromCardView:cardView withReuseIdentifier:cardIdentifier];
    
    if (!card) {
        card = [[[ZLCard alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, _cardView.bounds.size.height)] autorelease];
        card.shouldDecorateCard = YES;
        card.reuseIdentifier = cardIdentifier;
        card.cardIndex = index;
    }

    switch (index) {
        case 0:
        {
            SafetyPlanningStep1ViewController *vc = _controllerCache[@(index)];
            if (!vc) {
                vc = [[SafetyPlanningStep1ViewController alloc] init];
                vc.delegate = self;
                _controllerCache[@(index)] = vc;
                [vc release];
            }
              
            card.mainView = vc.view;
            card.orientation = 0;
        }
            break;
        case 1:
        {
            SafetyPlanningStep2ViewController *vc = _controllerCache[@(index)];
            if (!vc) {
                vc = [[SafetyPlanningStep2ViewController alloc] init];
                vc.delegate = self;
                _controllerCache[@(index)] = vc;
                [vc release];
            }
            card.mainView = vc.view;
            card.orientation = 0;
        }
            break;
        case 2:
        {
            SafetyPlanningStep3ViewController *vc = _controllerCache[@(index)];
            if (!vc) {
                vc = [[SafetyPlanningStep3ViewController alloc] init];
                vc.delegate = self;
                _controllerCache[@(index)] = vc;
                [vc release];
            }
            card.mainView = vc.view;
            card.orientation = 0;
        }
            break;
        case 3:
        {
            SafetyPlanningStep4ViewController *vc = _controllerCache[@(index)];
            if (!vc) {
                vc = [[SafetyPlanningStep4ViewController alloc] init];
                vc.delegate = self;
                _controllerCache[@(index)] = vc;
                [vc release];
            }
            card.mainView = vc.view;
            card.orientation = 0;
        }
            break;
        case 4:
        {
            SafetyPlanningStep5ViewController *vc = _controllerCache[@(index)];
            if (!vc) {
                vc = [[SafetyPlanningStep5ViewController alloc] init];
                vc.delegate = self;
                _controllerCache[@(index)] = vc;
                [vc release];
            }
            card.mainView = vc.view;
            card.orientation = 0;
        }
            break;
        case 5:
        {
            SafetyPlanningStep6ViewController *vc = _controllerCache[@(index)];
            if (!vc) {
                vc = [[SafetyPlanningStep6ViewController alloc] init];
                vc.delegate = self;
                _controllerCache[@(index)] = vc;
                [vc release];
            }
            card.mainView = vc.view;
            card.orientation = 0;
        }
            break;
        default:
            break;
    }

    return card;
}

- (void)cardView:(ZLCardView *)cardView refreshCard:(ZLCard *)card
{
    
}

#pragma mark - ZLCardDelegate
- (void)cardView:(ZLCardView *)cardView didSwipeDownAtIndex:(NSInteger)index
{
    
}

- (void)cardView:(ZLCardView *)cardView didSwipeUpAtIndex:(NSInteger)index
{
    
}

- (void)cardView:(ZLCardView *)cardView didTapElseWhereAtIndex:(NSInteger)index
{
    
}

- (void)cardViewDidDragOverContentSize:(ZLCardView *)cardView
{
    
}

- (void)cardView:(ZLCardView *)cardView didShowCardAtIndex:(NSInteger)index
{
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"safetyPlanPageCache"];
}

#pragma mark - Helper
- (void)showHoveringEditViewWithContentView:(UIView *)contentView hoverType:(NSInteger)hoverType completionBlock:(void(^)(BOOL complete))block
{
    if (!_hoveringEditView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height)];
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        view.backgroundColor = [UIColor clearColor];
        self.hoveringEditView = view;
        [view release];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [button addTarget:self action:@selector(hoveringEditViewBackgroundTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_hoveringEditView addSubview:button];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(button);
        [_hoveringEditView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[button]-0-|" options:0 metrics:nil views:views]];
        [_hoveringEditView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[button]-0-|" options:0 metrics:nil views:views]];
        
        [self.view addSubview:_hoveringEditView];
        views = @{@"hover": _hoveringEditView};
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[hover]-0-|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[hover(==viewHeight)]" options:0 metrics:@{@"viewHeight": @(self.view.bounds.size.height)} views:views]];
        
        self.hoveringEditViewTopConstraint = [NSLayoutConstraint constraintWithItem:_hoveringEditView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:-self.view.bounds.size.height];
        [self.view addConstraint:_hoveringEditViewTopConstraint];
        
        view = [[UIView alloc] initWithFrame:CGRectMake(20, 30, 280, 240)];
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        view.backgroundColor = [UIColor clearColor];
        self.hoveringEditContainerView = view;
        [view release];
        [_hoveringEditView addSubview:_hoveringEditContainerView];
        
        views = @{@"container": _hoveringEditContainerView};
        [_hoveringEditView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[container]-20-|" options:0 metrics:nil views:views]];
        
        self.hoveringEditContainerViewType1Constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[container(==210)]" options:0 metrics:nil views:views];
        self.hoveringEditContainerViewType2Constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[container]-20-|" options:0 metrics:nil views:views];
        
        switch (hoverType) {
            case 1:
                [_hoveringEditView removeConstraints:_hoveringEditContainerViewType2Constraints];
                [_hoveringEditView addConstraints:_hoveringEditContainerViewType1Constraints];
                break;
            case 2:
                [_hoveringEditView removeConstraints:_hoveringEditContainerViewType1Constraints];
                [_hoveringEditView addConstraints:_hoveringEditContainerViewType2Constraints];
                break;
            default:
                [_hoveringEditView removeConstraints:_hoveringEditContainerViewType2Constraints];
                [_hoveringEditView addConstraints:_hoveringEditContainerViewType1Constraints];
                break;
        }
    }
    
    _hoveringEditView.hidden = NO;

    if (_hoveringEditContentView) {
        [_hoveringEditContentView removeFromSuperview];
        self.hoveringEditContentView = nil;
    }
    
    contentView.frame = CGRectMake(0, 0, _hoveringEditContainerView.bounds.size.width, _hoveringEditContainerView.bounds.size.height);
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.hoveringEditContentView = contentView;
    [_hoveringEditContainerView addSubview:_hoveringEditContentView];
    
    _hoveringEditContentView.layer.cornerRadius = 5.0;

    NSDictionary *views = @{@"content": _hoveringEditContentView};
    [_hoveringEditContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[content]-0-|" options:0 metrics:nil views:views]];
    [_hoveringEditContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[content]-0-|" options:0 metrics:nil views:views]];
    
    [UIView animateWithDuration:0.3 animations:^{
        _coverView.alpha = 0.8;
        _hoveringEditViewTopConstraint.constant = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        _hoveringEditContainerView.layer.shadowColor = [UIColor whiteColor].CGColor;
        _hoveringEditContainerView.layer.shadowOpacity = 0.5;
        _hoveringEditContainerView.layer.shadowRadius = 10.0;
        _hoveringEditContainerView.layer.shadowOffset = CGSizeMake(0, 0);
        CGPathRef path = CGPathCreateWithRect(_hoveringEditContainerView.layer.bounds, NULL);
        _hoveringEditContainerView.layer.shadowPath = path;
        CGPathRelease(path);
        
        block(finished);
    }];
    
}

- (void)hideHoveringEditViewCompletionBlock:(void(^)(BOOL complete))block
{
    [_hoveringEditView endEditing:NO];
    
    _hoveringEditContainerView.layer.shadowColor = [UIColor clearColor].CGColor;
    _hoveringEditContainerView.layer.shadowOpacity = 0.0;
    _hoveringEditContainerView.layer.shadowRadius = 0.0;
    _hoveringEditContainerView.layer.shadowOffset = CGSizeMake(0, 0);
    _hoveringEditContainerView.layer.shadowPath = nil;
    
    [UIView animateWithDuration:0.3 animations:^{
        _coverView.alpha = 0.0;
        _hoveringEditViewTopConstraint.constant = -self.view.bounds.size.height;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        _hoveringEditView.hidden = YES;
        self.hoveringEditContentView = nil;
        block(finished);
    }];
}

#pragma mark - SafetyPlanningStepDelegate
- (void)safetyPlanningStepViewController:(UIViewController *)controller requestDisplayingHoveringView:(UIView *)hoverView hoveringViewType:(NSInteger)hoverType
{
    switch (hoverType) {
        case 1:
            [_hoveringEditView removeConstraints:_hoveringEditContainerViewType2Constraints];
            [_hoveringEditView addConstraints:_hoveringEditContainerViewType1Constraints];
            break;
        case 2:
            [_hoveringEditView removeConstraints:_hoveringEditContainerViewType1Constraints];
            [_hoveringEditView addConstraints:_hoveringEditContainerViewType2Constraints];
            break;
        default:
            [_hoveringEditView removeConstraints:_hoveringEditContainerViewType2Constraints];
            [_hoveringEditView addConstraints:_hoveringEditContainerViewType1Constraints];
            break;
    }
    
    [_hoveringEditView layoutIfNeeded];
    
    [self showHoveringEditViewWithContentView:hoverView hoverType:hoverType completionBlock:^(BOOL complete) {
        UIView *firstResponder = [hoverView viewWithTag:10];
        [firstResponder becomeFirstResponder];
    }];
}

- (void)safetyPlanningStepViewControllerRequestHideHoveringView:(UIViewController *)controller
{
    [self hideHoveringEditViewCompletionBlock:^(BOOL complete) {}];
}

- (void)sendEmail:(NSNotification *)notification
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
        vc.mailComposeDelegate = self;
        [vc setMessageBody:@"I'm feeling like I need some help." isHTML:NO];
        [vc setSubject:@"I want to chat with you"];
        [vc setToRecipients:@[notification.object]];
        [self presentViewController:vc animated:YES completion:^{}];
    }
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

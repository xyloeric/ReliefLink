//
//  MoodEntryViewController.m
//  Anchor
//
//  Created by Eric Li on 7/17/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "ANCommons.h"
#import "MoodEntryViewController.h"

@interface MoodEntryViewController ()
@property (retain, nonatomic) IBOutlet UIView *buttonContainerView;
@property (retain, nonatomic) IBOutlet UIButton *button1;
@property (retain, nonatomic) IBOutlet UIButton *button2;
@property (retain, nonatomic) IBOutlet UIButton *button3;
@property (retain, nonatomic) IBOutlet UIButton *button4;

@property (retain, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *titleHeightConstraint;
@end

@implementation MoodEntryViewController

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
    
    _button1.tag = 1;
    [_button1 addTarget:self action:@selector(moodButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _button2.tag = 2;
    [_button2 addTarget:self action:@selector(moodButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _button3.tag = 3;
    [_button3 addTarget:self action:@selector(moodButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    _button4.tag = 4;
    [_button4 addTarget:self action:@selector(moodButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
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
    [_buttonContainerView release];
    [_button1 release];
    [_button2 release];
    [_button3 release];
    [_button4 release];
    [_contentScrollView release];
    [_titleHeightConstraint release];
    [super dealloc];
}

#pragma mark - Actions
- (void)moodButtonPressed:(UIButton *)sender
{
    switch (sender.tag) {
        case 1:
            
            break;
        case 2:
            
            break;
        case 3:
            
            break;
        case 4:
            
            break;
        default:
            break;
    }
}

- (IBAction)menuButtonPressed:(UIButton *)sender
{
    [self.delegate ANDetailViewControllerDidClickMenuButton:self];
}

- (IBAction)homeButtonPressed:(UIButton *)sender
{
    [self.delegate ANDetailViewControllerDidClickHomeButton:self];
}

@end

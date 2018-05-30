//
//  ANDetailViewController.m
//  Anchor
//
//  Created by Eric Li on 7/15/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ANDetailViewController.h"

@interface ANDetailViewController ()

@end

@implementation ANDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [super dealloc];
    [_detailViewIdentifier release];
}


#pragma mark - Actions
- (void)menuButtonTapped:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(ANDetailViewControllerDidClickMenuButton:)]) {
        [_delegate ANDetailViewControllerDidClickMenuButton:self];
    }
}

@end

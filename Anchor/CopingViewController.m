//
//  CopingViewController.m
//  Anchor
//
//  Created by Eric Li on 7/21/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "CopingViewController.h"

@interface CopingViewController ()

@end

@implementation CopingViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

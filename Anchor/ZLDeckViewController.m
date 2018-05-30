//
//  DRDeckViewController.m
//  Anchor
//
//  Created by Eric Li on 7/15/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ZLDeckViewController.h"

@interface ZLDeckViewController ()
@property (nonatomic, retain) NSLayoutConstraint *leftConstraint;
@property (nonatomic, retain) UIView *overlayView;
@property (nonatomic, retain) UIScrollView *containerScrollView;
@end

@implementation ZLDeckViewController

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
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.containerScrollView = [[[UIScrollView alloc] initWithFrame:self.view.bounds] autorelease];
    [_containerScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:_containerScrollView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[scroll]-0-|" options:0 metrics:nil views:@{@"scroll": _containerScrollView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scroll]-0-|" options:0 metrics:nil views:@{@"scroll": _containerScrollView}]];
    _containerScrollView.pagingEnabled = YES;
    _containerScrollView.bounces = NO;
    _containerScrollView.showsHorizontalScrollIndicator = NO;
    _containerScrollView.backgroundColor = [UIColor clearColor];

    self.overlayView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
    [_overlayView setTranslatesAutoresizingMaskIntoConstraints:NO];
    _overlayView.backgroundColor = [UIColor blackColor];
    _overlayView.alpha = 0.0;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleLeftAppearence:)];
    [_overlayView addGestureRecognizer:recognizer];
    [recognizer release];
    
    [self.view addSubview:_overlayView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[overlay]-0-|" options:0 metrics:nil views:@{@"overlay": _overlayView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[overlay]-0-|" options:0 metrics:nil views:@{@"overlay": _overlayView}]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_centerViewController release];
    [_leftViewController release];
    
    [_leftConstraint release];
    [_overlayView release];
    [_homeViewController release];
    [_containerScrollView release];
    [super dealloc];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (_centerViewController) {
        _containerScrollView.contentSize = CGSizeMake(2 * self.view.frame.size.width, self.view.frame.size.height);
    }
    else {
        _containerScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    }
}

#pragma mark - Custom Getter/Setter
- (void)setHomeViewController:(UIViewController *)homeViewController
{
    if (_homeViewController != homeViewController) {
        [_homeViewController removeFromParentViewController];
        [_homeViewController.view removeFromSuperview];
        [_homeViewController release];
        _homeViewController = [homeViewController retain];
        
        [_homeViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
        
        _homeViewController.view.frame = CGRectMake(0, 0, _containerScrollView.frame.size.width, _containerScrollView.frame.size.height);
        [self.containerScrollView addSubview:_homeViewController.view];

        [self addChildViewController:_homeViewController];
                
        if (_centerViewController) {
            _containerScrollView.contentSize = CGSizeMake(2 * self.view.frame.size.width, self.view.frame.size.height);
        }
        else {
            _containerScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
        }
    }
}


- (void)setCenterViewController:(UIViewController *)centerViewController
{
    if (_centerViewController != centerViewController) {
        
        if (_centerViewController) {
            centerViewController.view.frame = CGRectMake(_containerScrollView.frame.size.width, _containerScrollView.frame.size.height, _containerScrollView.frame.size.width, _containerScrollView.frame.size.height);
            [self.containerScrollView insertSubview:centerViewController.view belowSubview:_homeViewController.view];
            
            UIView *blackOverlay = [[UIView alloc] initWithFrame:_centerViewController.view.bounds];
            blackOverlay.backgroundColor = [UIColor blackColor];
            blackOverlay.alpha = 0;
            [_centerViewController.view addSubview:blackOverlay];
            [blackOverlay release];
            
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                blackOverlay.alpha = 0.8;
                _centerViewController.view.transform = CGAffineTransformMakeScale(0.8, 0.8);
                centerViewController.view.frame = CGRectMake(_containerScrollView.frame.size.width, 0, _containerScrollView.frame.size.width, _containerScrollView.frame.size.height);

            } completion:^(BOOL finished) {
                [_centerViewController removeFromParentViewController];
                [_centerViewController.view removeFromSuperview];
                [_centerViewController release];
                _centerViewController = [centerViewController retain];
                
                [self addChildViewController:_centerViewController];
                
                _containerScrollView.contentSize = CGSizeMake(2 * self.view.frame.size.width, self.view.frame.size.height);
            }];
        }
        else {
            _centerViewController = [centerViewController retain];
            
            [_centerViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            
            _centerViewController.view.frame = CGRectMake(_containerScrollView.frame.size.width, 0, _containerScrollView.frame.size.width, _containerScrollView.frame.size.height);
            [self.containerScrollView insertSubview:_centerViewController.view belowSubview:_homeViewController.view];
            
            [self addChildViewController:_centerViewController];
            
            _containerScrollView.contentSize = CGSizeMake(2 * self.view.frame.size.width, self.view.frame.size.height);
        }
    }
}

- (void)setLeftViewController:(UIViewController *)leftViewController
{
    if (_leftViewController != leftViewController) {
        [_leftViewController removeFromParentViewController];
        [_leftViewController.view removeFromSuperview];
        [_leftViewController release];
        _leftViewController = [leftViewController retain];
        
        [_leftViewController willMoveToParentViewController:self];
        [_leftViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self.view insertSubview:_leftViewController.view aboveSubview:_overlayView];
        
        CGFloat leftWidth = (self.view.bounds.size.width / 6) * 5;
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[left(==width)]" options:0 metrics:@{@"width": @(leftWidth)} views:@{@"left": _leftViewController.view}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[left]-0-|" options:0 metrics:nil views:@{@"left": _leftViewController.view}]];
        
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:_leftViewController.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-leftWidth];
        self.leftConstraint = leftConstraint;
        [leftConstraint relation];
        
        [self.view addConstraint:_leftConstraint];
        [self.view layoutIfNeeded];
        [self addChildViewController:_leftViewController];
    }
}

#pragma mark - Helpers
- (void)toggleLeftAppearence:(id)sender
{
    if (_leftViewController.view.frame.origin.x < 0) {
        [self.view removeConstraint:_leftConstraint];
        
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:_leftViewController.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
        self.leftConstraint = leftConstraint;
        [leftConstraint relation];
        
        [self.view addConstraint:_leftConstraint];
        [UIView animateWithDuration:0.3 animations:^{
            _overlayView.alpha = 0.5;
            [self.view layoutIfNeeded];
            [self.leftViewController.view setNeedsLayout];
        }];
    }
    else {
        [self.view removeConstraint:_leftConstraint];
        
        CGFloat leftWidth = (self.view.bounds.size.width / 6) * 5;

        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:_leftViewController.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-leftWidth];
        self.leftConstraint = leftConstraint;
        [leftConstraint relation];
        
        [self.view addConstraint:_leftConstraint];
        [UIView animateWithDuration:0.3 animations:^{
            _overlayView.alpha = 0.0;
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)showHomeView
{
    [_containerScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)showCenterView
{
    [_containerScrollView setContentOffset:CGPointMake(_containerScrollView.frame.size.width, 0) animated:YES];
}

- (void)showHomeViewCompletionBlock:(void(^)(void))block
{
    [UIView animateWithDuration:0.3 animations:^{
        [_containerScrollView setContentOffset:CGPointMake(0, 0)];
    } completion:^(BOOL finished) {
        block();
    }];
}

- (void)showCenterViewCompletionBlock:(void(^)(void))block
{
    [UIView animateWithDuration:0.3 animations:^{
        [_containerScrollView setContentOffset:CGPointMake(_containerScrollView.frame.size.width, 0)];
    } completion:^(BOOL finished) {
        block();
    }];
}
@end

//
//  ZLCard.m
//  ZLCardViewController
//
//  Created by Eric Li on 1/22/13.
//  Copyright (c) 2013 Eric Li. All rights reserved.
//

#import "ZLCard.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_FLIP_ANIMATION_DURATION (1.0)
#define DEFAULT_CORNER_RADIUS (10.0)
#define DEFAULT_SHADOW_OPACITY (0.2)

#define StyleLayerForView(v)				      \
do {						      \
(v).layer.cornerRadius = DEFAULT_CORNER_RADIUS;	      \
(v).layer.masksToBounds = YES;			      \
} while (0)

#define ShouldHide(f) (BOOL)(!(_orientation == (f)))
#define ShouldHideFront() ShouldHide(DRCardSideFront)
#define ShouldHideBack() ShouldHide(DRCardSideBack)

#define ViewSetter(o, n, f)			\
do {					\
    if (o != n) {				\
        UIView *v = o;			\
        o = [n retain];			\
        [v removeFromSuperview];		\
        [v release];			\
        o.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; \
        o.frame = self.bounds;\
        [self addSubview:o];		\
        o.hidden = ShouldHide(f);		\
    }					\
    else { \
        o = [n retain];	\
        o.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; \
        o.frame = self.bounds;\
        [self addSubview:o];		\
        o.hidden = ShouldHide(f);		\
    }\
} while (0)

@interface ZLCard ()
@end

@implementation ZLCard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _orientation = DRCardSideFront;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _orientation = DRCardSideFront;
    }
    return self;
}

- (void)setMainView:(UIView *)mainView
{
    ViewSetter(_mainView, mainView, DRCardSideFront);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || _shouldDecorateCard) {
        StyleLayerForView(_mainView);
    }
}

- (void)setAccessoryView:(UIView *)accessoryView
{
    ViewSetter(_accessoryView, accessoryView, DRCardSideBack);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || _shouldDecorateCard) {
        StyleLayerForView(_accessoryView);
    }
    if (_accessoryView && !_accessoryView.superview) {
        [self addSubview:_accessoryView];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.mainView.frame = self.bounds;
    self.accessoryView.frame = self.bounds;
//    self.curlView.frame = self.bounds;
}

- (void)dealloc
{
    [_reuseIdentifier release];
    [_accessoryView release];
    [_mainView release];
    [super dealloc];
}

- (void)decorateCard
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || _shouldDecorateCard) {
        StyleLayerForView(self);
        self.layer.shadowRadius = 2.0;
        self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        self.layer.shadowOpacity = DEFAULT_SHADOW_OPACITY;
        
        CGPathRef path = CGPathCreateWithRect(self.layer.bounds, NULL);
        self.layer.shadowPath = path;
        CGPathRelease(path);
        
        self.layer.masksToBounds = self.clipsToBounds = NO;
    }
}


- (void)setOrientation:(DRCardSide)orientation {
    if (orientation != _orientation) {
        _orientation = orientation;
        _mainView.hidden = ShouldHideFront();
        _accessoryView.hidden = ShouldHideBack();
    }
}

- (void)setOrientation:(DRCardSide)orientation animated:(BOOL)animated {
    [self flipWithDuration:(animated ? DEFAULT_FLIP_ANIMATION_DURATION : 0) callDelegate:NO];
}

#pragma mark -
#pragma mark Flip card
- (void) flipViews
{
    [self flipWithDuration:DEFAULT_FLIP_ANIMATION_DURATION callDelegate:NO];
}

- (void) flipViewsWithDuration:(NSTimeInterval)duration andCompletionBlock:(void(^)(void))cBlock
{
    if (!_accessoryView) {
        return;
    }
    
    DRCardSide newOrientation = FlipOrientation(_orientation);
	UIView *startView = (_orientation == DRCardSideFront) ? _mainView : _accessoryView;
	UIView *endView = (_orientation == DRCardSideFront) ? _accessoryView : _mainView;
    UIViewAnimationOptions options = UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionAllowAnimatedContent;

	options |= (_orientation == DRCardSideFront) ?  UIViewAnimationOptionTransitionFlipFromRight:UIViewAnimationOptionTransitionFlipFromLeft;
    [UIView transitionFromView:startView toView:endView duration:duration options:options completion:^(BOOL finished) {
        cBlock();
    }];
    _orientation = newOrientation;
}

- (void)flipWithDuration:(NSTimeInterval)duration callDelegate:(BOOL)callDelegate {
    if (!_accessoryView) {
        return;
    }
    
    DRCardSide newOrientation = FlipOrientation(_orientation);
	UIView *startView = (_orientation == DRCardSideFront) ? _mainView : _accessoryView;
	UIView *endView = (_orientation == DRCardSideFront) ? _accessoryView : _mainView;
    UIViewAnimationOptions options = UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionAllowAnimatedContent;

	options |= (_orientation == DRCardSideFront) ? UIViewAnimationOptionTransitionCurlUp : UIViewAnimationOptionTransitionCurlDown;
    [UIView transitionFromView:startView toView:endView duration:duration options:options completion:^(BOOL finished) {

    }];
    _orientation = newOrientation;
}

@end

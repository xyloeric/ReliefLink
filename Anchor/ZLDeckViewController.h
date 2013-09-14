//
//  DRDeckViewController.h
//  Anchor
//
//  Created by Eric Li on 7/15/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ZLDeckViewController : UIViewController
@property (nonatomic, retain) UIViewController *homeViewController;
@property (nonatomic, retain) UIViewController *centerViewController;
@property (nonatomic, retain) UIViewController *leftViewController;


- (void)toggleLeftAppearence:(id)sender;

- (void)showHomeView;
- (void)showCenterView;
- (void)showHomeViewCompletionBlock:(void(^)(void))block;
- (void)showCenterViewCompletionBlock:(void(^)(void))block;

@end

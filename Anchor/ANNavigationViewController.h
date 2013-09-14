//
//  ANNavigationViewController.h
//  Anchor
//
//  Created by Eric Li on 7/15/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ANNavigationViewController;
@class ANDetailViewController;

@protocol ANNavigationViewControllerDelegate <NSObject>
- (void)ANNavigationViewController:(ANNavigationViewController *)navController requestPresentingViewController:(ANDetailViewController *)detailController;
@end

@interface ANNavigationViewController : UIViewController
@property (nonatomic, assign) id<ANNavigationViewControllerDelegate> delegate;
@end

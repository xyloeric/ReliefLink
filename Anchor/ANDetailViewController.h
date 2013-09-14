//
//  ANDetailViewController.h
//  Anchor
//
//  Created by Eric Li on 7/15/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ANDetailViewController;

@protocol ANDetailViewControllerDelegate <NSObject>
- (void)ANDetailViewControllerDidClickMenuButton:(ANDetailViewController *)detailViewController;
- (void)ANDetailViewControllerDidClickHomeButton:(ANDetailViewController *)detailViewController;
- (void)ANDetailViewController:(ANDetailViewController *)landingController requestPresentViewController:(ANDetailViewController *)detailController;
@end

@interface ANDetailViewController : UIViewController
@property (nonatomic, assign) id<ANDetailViewControllerDelegate> delegate;
@property (nonatomic, retain) NSString *detailViewIdentifier;
@end

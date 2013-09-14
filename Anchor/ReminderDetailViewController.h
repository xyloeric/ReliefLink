//
//  ReminderDetailViewController.h
//  Anchor
//
//  Created by Eric Li on 7/28/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reminder.h"
@class ReminderDetailViewController;

@protocol ReminderDetailViewControllerDelegate <NSObject>
@required
- (void)ReminderDetailViewControllerWillDismiss:(ReminderDetailViewController *)controller;

@end

@interface ReminderDetailViewController : UIViewController
@property (nonatomic, assign) id<ReminderDetailViewControllerDelegate> delegate;

@property (nonatomic, retain) Reminder *reminder;
@property (nonatomic) BOOL isNewReminder;
@end

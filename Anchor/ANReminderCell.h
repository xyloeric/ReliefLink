//
//  ANReminderCell.h
//  Anchor
//
//  Created by Eric Li on 7/28/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reminder.h"

@interface ANReminderCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *reminderStatusImageView;
@property (retain, nonatomic) IBOutlet UITextField *reminderTitleLabel;
@property (nonatomic, assign) Reminder *reminder;
@end

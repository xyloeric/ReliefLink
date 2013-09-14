//
//  ANReminderCell.m
//  Anchor
//
//  Created by Eric Li on 7/28/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ANReminderCell.h"
#import "ANDataStoreCoordinator.h"

@implementation ANReminderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [_reminderStatusImageView release];
    [_reminderTitleLabel release];
    [super dealloc];
}

#pragma mark - Actions
- (IBAction)checkboxClicked:(id)sender
{
    if ([_reminder.reminderScheduled boolValue]) {
        [[ANDataStoreCoordinator shared] unscheduleNotificationRelatedToReminder:_reminder];
    }
    else {
        [[ANDataStoreCoordinator shared] scheduleNotificationForReminder:_reminder];
    }
    
    [[ANDataStoreCoordinator shared] saveDataStore];
}

@end

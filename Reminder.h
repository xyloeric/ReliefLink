//
//  Reminder.h
//  Anchor
//
//  Created by Eric Li on 8/3/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Reminder : NSManagedObject

@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSDate * reminderDate;
@property (nonatomic, retain) NSDate * repeateUntil;
@property (nonatomic, retain) NSNumber * repeatType;
@property (nonatomic, retain) NSNumber * reminderIsDone;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * reminderScheduled;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSString * reminderType;
@property (nonatomic, retain) User *user;

@end

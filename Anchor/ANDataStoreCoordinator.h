//
//  ANDataStoreCoordinator.h
//  Anchor
//
//  Created by Eric Li on 7/30/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Reminder.h"

#define kProfilePictureDidChangeNotification @"kProfilePictureDidChangeNotification"

@interface ANDataStoreCoordinator : NSObject
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSInteger relieflinkTweetCount;

+(ANDataStoreCoordinator *)shared;

- (NSString *)profilePictureDirectory;
- (NSString *)cacheDirectory;

- (User *)getCurrentUser;
- (NSArray *)fetchObjectsOfEntityType:(NSString *)entityType count:(NSInteger)count;
- (NSInteger)numberOfObjectsOfEntity:(NSString *)entityType;
- (void)removeManagedObject:(NSManagedObject *)object;
- (void)saveDataStore;
- (NSString *)getUUID;

- (void)unscheduleNotificationRelatedToReminder:(Reminder *)reminder;;
- (void)scheduleNotificationForReminder:(Reminder *)reminder;
- (void)refreshScheduledStatusOfReminders;

- (void)callPhoneNumber:(NSString *)phoneNumber;

- (void)createDemoData;
@end

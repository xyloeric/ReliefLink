//
//  ANDataStoreCoordinator.m
//  Anchor
//
//  Created by Eric Li on 7/30/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ANDataStoreCoordinator.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "ANCommons.h"
#import "Mood.h"
#import "SuicidalThought.h"

#define kAlertPhoneCall 100

@interface ANDataStoreCoordinator () <UIAlertViewDelegate>
@property (nonatomic, retain) User *currentUser;
@end

@implementation ANDataStoreCoordinator

+(ANDataStoreCoordinator *)shared
{
    static dispatch_once_t onceToken;
    static ANDataStoreCoordinator *shareDataStoreCoordinator;
    dispatch_once(&onceToken, ^{
        shareDataStoreCoordinator = [[self alloc] init];
    });
    return shareDataStoreCoordinator;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self loadTwitterAccount];
    }
    return self;
}

- (void)dealloc
{
    [_managedObjectContext release];
    [super dealloc];
}

#pragma mark - Private Methods
- (void)loadTwitterAccount
{
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [store requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                NSArray *twitterAccounts = [store accountsWithAccountType:twitterAccountType];
                if ([twitterAccounts count] > 0) {
                    // Use the first account for simplicity
                    ACAccount *account = [twitterAccounts objectAtIndex:0];
                    
                    [self startStreamWithAccount:account forTimelineOfUser:@"relieflink"];
                }
                else {
                    [self twitterAlert];
                }
            }
            else {
                [self twitterAlert];
            }
        });
    }];
}

- (void)twitterAlert
{
    if ([[[UIApplication sharedApplication] windows] count] > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Account" message:@"Please setup a twitter account from the settings of your iPhone to enjoy a more connected experience of this app" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)startStreamWithAccount:(ACAccount *)twitterAccount forTimelineOfUser:(NSString *)screenName
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
        [params setObject:@"0" forKey:@"trim_user"];
        [params setObject:screenName forKey:@"screen_name"];
        
        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
        
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
        
        [request setAccount:twitterAccount];
        
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            id result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
            
            if ([result isKindOfClass:[NSArray class]]) {
                self.relieflinkTweetCount = [result count];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateReliefLinkTweetCount" object:nil];
            }
        }];
    });
}

#pragma mark - Public Methods
- (User *)getCurrentUser
{
    if (_currentUser) {
        return _currentUser;
    }
    else {
        NSError *error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
        [request setFetchLimit:1];
        NSArray *queryResult = [_managedObjectContext executeFetchRequest:request error:&error];
        if ([queryResult count] > 0) {
            self.currentUser = queryResult[0];
            return _currentUser;
        }
        else {
            User *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:_managedObjectContext];
            self.currentUser = newUser;
            return _currentUser;
        }
    }
}

- (NSString *)cacheDirectory
{
    NSString *cachePath = [NSString stringWithFormat:@"%@/Library/Cache/ImageCache", NSHomeDirectory()];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return cachePath;
}

- (NSString *)profilePictureDirectory
{
    NSString *cachePath = [NSString stringWithFormat:@"%@/Library/Profile", NSHomeDirectory()];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return cachePath;
}

- (NSArray *)fetchObjectsOfEntityType:(NSString *)entityType count:(NSInteger)count
{
    NSError *error = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityType];
    if (count > 0) {
        [request setFetchLimit:count];
    }
    NSArray *queryResult = [_managedObjectContext executeFetchRequest:request error:&error];
    
    return queryResult;
}

- (NSInteger)numberOfObjectsOfEntity:(NSString *)entityType
{
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[NSEntityDescription entityForName:entityType inManagedObjectContext:_managedObjectContext]];
    
    [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)
    
    NSError *err;
    NSUInteger count = [_managedObjectContext countForFetchRequest:request error:&err];
    if (count == NSNotFound) {
        count = 0;
    }
    
    return count;
}

- (void)removeManagedObject:(NSManagedObject *)object
{
    [_managedObjectContext deleteObject:object];
    
    [self saveDataStore];
}

- (void)saveDataStore
{
    NSError *error = nil;
    [_managedObjectContext save:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (NSString *)getUUID
{
    CFUUIDRef uuid = CFUUIDCreate(nil);
    CFStringRef uuidCFString = CFUUIDCreateString(nil, uuid);
	NSString *uuidString = [NSString stringWithString:(NSString *)uuidCFString];
    CFRelease(uuid);
    CFRelease(uuidCFString);
    return uuidString;
}

- (void)unscheduleNotificationRelatedToReminder:(Reminder *)reminder;
{
    if (reminder.uuid) {
        for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
            if ([notification.userInfo[@"uuid"] isEqualToString:reminder.uuid]) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                reminder.reminderScheduled = @NO;
                break;
            }
        }
    }
}

- (void)scheduleNotificationForReminder:(Reminder *)reminder
{
    if ([reminder.reminderDate timeIntervalSinceDate:[NSDate date]] > 0 || [reminder.repeatType integerValue] != 0) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = reminder.reminderDate;
        switch ([reminder.repeatType intValue]) {
            case 0:
                notification.repeatInterval = 0;
                break;
            case 1:
                notification.repeatInterval = NSHourCalendarUnit;
                break;
            case 2:
                notification.repeatInterval = NSDayCalendarUnit;
                break;
            case 3:
                notification.repeatInterval = NSWeekCalendarUnit;
                break;
            case 4:
                notification.repeatInterval = NSMonthCalendarUnit;
                break;
            case 5:
                notification.repeatInterval = NSYearCalendarUnit;
                break;
            default:
                break;
        }
        
        if ([reminder.reminderScheduled boolValue]) {
            [self unscheduleNotificationRelatedToReminder:reminder];
        }
        
        notification.alertAction = reminder.title;
        notification.alertBody = reminder.title;
        notification.soundName = UILocalNotificationDefaultSoundName;
        
        NSString *uuid = [[ANDataStoreCoordinator shared] getUUID];
        notification.userInfo = @{@"uuid": uuid, @"note": reminder.note ? reminder.note : @""};
        reminder.uuid = uuid;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        [notification release];
        
        reminder.reminderScheduled = @YES;
    }
}

- (void)refreshScheduledStatusOfReminders
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Reminder"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reminderScheduled == %@", @YES];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *scheduledReminders = [_managedObjectContext executeFetchRequest:request error:&error];
    
    if ([scheduledReminders count] < [[[UIApplication sharedApplication] scheduledLocalNotifications] count]) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        for (Reminder *reminder in scheduledReminders) {
            [self scheduleNotificationForReminder:reminder];
        }
    }
    else {
        for (Reminder *reminder in scheduledReminders) {
            BOOL found = NO;
            for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
                NSLog(@"%@, %@", reminder.uuid, notification.userInfo[@"uuid"]);
                if ([reminder.uuid isEqualToString:notification.userInfo[@"uuid"]]) {
                    found = YES;
                    break;
                }
            }
            
            if (!found) {
                reminder.reminderScheduled = @NO;
                reminder.uuid = nil;
            }
        }
    }
    
    [[ANDataStoreCoordinator shared] saveDataStore];
}


- (void)callPhoneNumber:(NSString *)phoneNumber
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Call This Number?" message:phoneNumber delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call", nil];
    alert.tag = kAlertPhoneCall;
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertPhoneCall) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", alertView.message]]];
        }
    }

}

- (void)createDemoData
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *nowComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
        nowComponents.day = nowComponents.day - 10;
        NSDate *newDate = [gregorian dateFromComponents:nowComponents];
        
        Mood *mood = [NSEntityDescription insertNewObjectForEntityForName:@"Mood" inManagedObjectContext:_managedObjectContext];
        mood.moodType = @(2);
        mood.recordDate = newDate;
        SuicidalThought *thought = [NSEntityDescription insertNewObjectForEntityForName:@"SuicidalThought" inManagedObjectContext:_managedObjectContext];
        thought.thoughtType = @(10);
        thought.recordDate = newDate;
        
        nowComponents.day += 1;
        newDate = [gregorian dateFromComponents:nowComponents];
        mood = [NSEntityDescription insertNewObjectForEntityForName:@"Mood" inManagedObjectContext:_managedObjectContext];
        mood.moodType = @(6);
        mood.recordDate = newDate;
        thought = [NSEntityDescription insertNewObjectForEntityForName:@"SuicidalThought" inManagedObjectContext:_managedObjectContext];
        thought.thoughtType = @(8);
        thought.recordDate = newDate;
        
        nowComponents.day += 1;
        newDate = [gregorian dateFromComponents:nowComponents];
        mood = [NSEntityDescription insertNewObjectForEntityForName:@"Mood" inManagedObjectContext:_managedObjectContext];
        mood.moodType = @(4);
        mood.recordDate = newDate;
        thought = [NSEntityDescription insertNewObjectForEntityForName:@"SuicidalThought" inManagedObjectContext:_managedObjectContext];
        thought.thoughtType = @(6);
        thought.recordDate = newDate;
        
        nowComponents.day += 1;
        newDate = [gregorian dateFromComponents:nowComponents];
        mood = [NSEntityDescription insertNewObjectForEntityForName:@"Mood" inManagedObjectContext:_managedObjectContext];
        mood.moodType = @(4);
        mood.recordDate = newDate;
        thought = [NSEntityDescription insertNewObjectForEntityForName:@"SuicidalThought" inManagedObjectContext:_managedObjectContext];
        thought.thoughtType = @(8);
        thought.recordDate = newDate;
        
        nowComponents.day += 1;
        newDate = [gregorian dateFromComponents:nowComponents];
        mood = [NSEntityDescription insertNewObjectForEntityForName:@"Mood" inManagedObjectContext:_managedObjectContext];
        mood.moodType = @(8);
        mood.recordDate = newDate;
        thought = [NSEntityDescription insertNewObjectForEntityForName:@"SuicidalThought" inManagedObjectContext:_managedObjectContext];
        thought.thoughtType = @(10);
        thought.recordDate = newDate;
        
        nowComponents.day += 1;
        newDate = [gregorian dateFromComponents:nowComponents];
        mood = [NSEntityDescription insertNewObjectForEntityForName:@"Mood" inManagedObjectContext:_managedObjectContext];
        mood.moodType = @(10);
        mood.recordDate = newDate;
        thought = [NSEntityDescription insertNewObjectForEntityForName:@"SuicidalThought" inManagedObjectContext:_managedObjectContext];
        thought.thoughtType = @(8);
        thought.recordDate = newDate;
        
        nowComponents.day += 1;
        newDate = [gregorian dateFromComponents:nowComponents];
        mood = [NSEntityDescription insertNewObjectForEntityForName:@"Mood" inManagedObjectContext:_managedObjectContext];
        mood.moodType = @(6);
        mood.recordDate = newDate;
        thought = [NSEntityDescription insertNewObjectForEntityForName:@"SuicidalThought" inManagedObjectContext:_managedObjectContext];
        thought.thoughtType = @(10);
        thought.recordDate = newDate;
        
        nowComponents.day += 1;
        newDate = [gregorian dateFromComponents:nowComponents];
        mood = [NSEntityDescription insertNewObjectForEntityForName:@"Mood" inManagedObjectContext:_managedObjectContext];
        mood.moodType = @(8);
        mood.recordDate = newDate;
        thought = [NSEntityDescription insertNewObjectForEntityForName:@"SuicidalThought" inManagedObjectContext:_managedObjectContext];
        thought.thoughtType = @(8);
        thought.recordDate = newDate;
        
        nowComponents.day += 1;
        newDate = [gregorian dateFromComponents:nowComponents];
        mood = [NSEntityDescription insertNewObjectForEntityForName:@"Mood" inManagedObjectContext:_managedObjectContext];
        mood.moodType = @(4);
        mood.recordDate = newDate;
        thought = [NSEntityDescription insertNewObjectForEntityForName:@"SuicidalThought" inManagedObjectContext:_managedObjectContext];
        thought.thoughtType = @(6);
        thought.recordDate = newDate;
        
        nowComponents.day += 1;
        newDate = [gregorian dateFromComponents:nowComponents];
        mood = [NSEntityDescription insertNewObjectForEntityForName:@"Mood" inManagedObjectContext:_managedObjectContext];
        mood.moodType = @(10);
        mood.recordDate = newDate;
        thought = [NSEntityDescription insertNewObjectForEntityForName:@"SuicidalThought" inManagedObjectContext:_managedObjectContext];
        thought.thoughtType = @(10);
        thought.recordDate = newDate;
        
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
    }
}
@end

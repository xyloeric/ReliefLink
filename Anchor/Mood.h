//
//  Mood.h
//  ReliefLink
//
//  Created by Eric Li on 8/6/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Mood : NSManagedObject

@property (nonatomic, retain) NSNumber * moodIntensity;
@property (nonatomic, retain) NSNumber * moodType;
@property (nonatomic, retain) NSDate * recordDate;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) User *user;

@end

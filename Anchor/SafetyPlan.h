//
//  SafetyPlan.h
//  ReliefLink
//
//  Created by Eric Li on 8/6/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface SafetyPlan : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * selectedFromDefault;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) User *user;

@end

//
//  SuicidalThought.h
//  ReliefLink
//
//  Created by Eric Li on 8/7/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SuicidalThought : NSManagedObject

@property (nonatomic, retain) NSNumber * thoughtIntensity;
@property (nonatomic, retain) NSNumber * thoughtType;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSDate * recordDate;

@end

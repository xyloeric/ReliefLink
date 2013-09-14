//
//  LocalUrgentCare.h
//  ReliefLink
//
//  Created by Eric Li on 8/6/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LocalUrgentCare : NSManagedObject

@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * address;

@end

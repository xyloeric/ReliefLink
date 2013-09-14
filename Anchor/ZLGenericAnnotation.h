//
//  ZLGenericAnnotation.h
//  ReliefLink
//
//  Created by Eric Li on 8/4/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ZLGenericAnnotation : NSObject<MKAnnotation>

@property (nonatomic, retain) MKMapItem *mapItem;

-(id)initWithMapItem:(MKMapItem *)mapItem;

@end

//
//  ZLGenericAnnotation.m
//  ReliefLink
//
//  Created by Eric Li on 8/4/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ZLGenericAnnotation.h"


@implementation ZLGenericAnnotation

-(id)initWithMapItem:(MKMapItem *)mapItem {
    self = [super init];
    if (self) {
        self.mapItem = mapItem;
    }
    return self;
}

- (void)dealloc
{
    [_mapItem release];
    [super dealloc];
}

- (NSString *)title
{
    return _mapItem.name;
}

- (NSString *)subtitle
{
    return _mapItem.phoneNumber;
}

- (CLLocationCoordinate2D)coordinate
{
    return _mapItem.placemark.coordinate;
}

@end

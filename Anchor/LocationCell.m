//
//  LocationCell.m
//  ReliefLink
//
//  Created by Eric Li on 8/7/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "LocationCell.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationCell ()
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *mapButton;

@end

@implementation LocationCell

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

- (void)dealloc {
    [_titleLabel release];
    [_locationDistraction release];
    [_mapButton release];
    [super dealloc];
}

- (IBAction)mapButtonClicked:(id)sender
{
    CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
    [geocoder geocodeAddressString:_locationDistraction.address completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0) {
            CLPlacemark *placemark = placemarks[0];
            MKPlacemark *mkPlacemark = [[MKPlacemark alloc] initWithPlacemark:placemark];
            
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:mkPlacemark];
            [mkPlacemark release];
            
            NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
            [mapItem openInMapsWithLaunchOptions:options];
        }
    }];
}

- (void)setLocationDistraction:(LocationDistraction *)locationDistraction
{
    if (_locationDistraction != locationDistraction) {
        [_locationDistraction release];
        _locationDistraction = [locationDistraction retain];
    }
    
    _titleLabel.text = _locationDistraction.title;
    _mapButton.enabled = _locationDistraction.address.length > 0 ? YES : NO;
}

@end

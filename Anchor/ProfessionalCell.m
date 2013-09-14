//
//  ProfessionalCell.m
//  ReliefLink
//
//  Created by Eric Li on 8/7/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ProfessionalCell.h"
#import "ANDataStoreCoordinator.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ProfessionalCell ()
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *phoneButton;
@property (retain, nonatomic) IBOutlet UIButton *emailButton;
@property (retain, nonatomic) IBOutlet UIButton *mapButton;
@end

@implementation ProfessionalCell

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
    [_phoneButton release];
    [_emailButton release];
    [_professional release];
    [_mapButton release];
    [super dealloc];
}


- (IBAction)phoneButtonClicked:(id)sender
{
    [[ANDataStoreCoordinator shared] callPhoneNumber:_professional.phone];
}

- (IBAction)emailButtonClicked:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SendEmailFromSafetyPlan" object:_professional.email];
}

- (IBAction)mapButtonClicked:(id)sender
{
    CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
    [geocoder geocodeAddressString:_professional.address completionHandler:^(NSArray *placemarks, NSError *error) {
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

- (void)setProfessional:(ProfessionalToContact *)professional
{
    if (_professional != professional) {
        [_professional release];
        _professional = [professional retain];
    }
    
    if ([_professional.professionalType isEqualToString:@"Professional"]) {
        _mapButton.hidden = YES;
        _emailButton.hidden = NO;
    }
    else {
        _mapButton.hidden = NO;
        _emailButton.hidden = YES;
    }
    
    _titleLabel.text = _professional.name;
    _phoneButton.enabled = _professional.phone.length > 0 ? YES : NO;
    _emailButton.enabled = _professional.email.length > 0 ? YES : NO;
    _mapButton.enabled = _professional.address.length > 0 ? YES : NO;
}
@end

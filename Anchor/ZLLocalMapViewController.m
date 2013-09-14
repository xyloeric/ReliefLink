//
//  ZLLocalMapViewController.m
//  ReliefLink
//
//  Created by Eric Li on 8/4/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ZLLocalMapViewController.h"
#import <MapKit/MapKit.h>
#import "ANCommons.h"
#import "ZLGenericAnnotation.h"
#import <QuartzCore/QuartzCore.h>
#import "ANTwoLabelCell.h"
#import "ZLOneLabelCell.h"
#import "ANDataStoreCoordinator.h"

#import "ProfessionalToContact.h"

@interface ZLLocalMapViewController () <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    BOOL _firstload;
}
@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray *relevantAnnotations;

@property (retain, nonatomic) IBOutlet UIView *detailView;
@property (retain, nonatomic) IBOutlet UITableView *detailTableView;
@property (nonatomic, retain) UIView *coverView;
@property (nonatomic, retain) UIView *hoveringEditView;
@property (nonatomic, retain) NSLayoutConstraint *hoveringEditViewTopConstraint;
@property (nonatomic, retain) UIView *hoveringEditContainerView;
@property (nonatomic, retain) UIView *hoveringEditContentView;

@property (nonatomic, retain) MKMapItem *selectedItem;
@property (nonatomic, retain) ProfessionalToContact *editingProfessional;
@end

@implementation ZLLocalMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    view.userInteractionEnabled = NO;
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.0;
    self.coverView = view;
    [view release];
    [self.view addSubview:_coverView];
    NSDictionary *views = @{@"cover": _coverView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[cover]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[cover]-0-|" options:0 metrics:nil views:views]];
    
    [_detailTableView registerNib:[UINib nibWithNibName:@"ANTwoLabelCell" bundle:nil] forCellReuseIdentifier:@"ANTwoLabelCell"];
    [_detailTableView registerNib:[UINib nibWithNibName:@"ZLOneLabelCell" bundle:nil] forCellReuseIdentifier:@"ZLOneLabelCell"];

    _firstload = YES;
    self.relevantAnnotations = [NSMutableArray array];
    
    [_mapView setShowsUserLocation:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_mapView release];
    [_relevantAnnotations release];
    
    [_coverView release];
    [_hoveringEditView release];
    [_hoveringEditViewTopConstraint release];
    [_hoveringEditContainerView release];
    [_hoveringEditContentView release];
    [_detailTableView release];
    
    [_selectedItem release];
    [_detailView release];
    [_editingProfessional release];
    [super dealloc];
}

#pragma mark - Actions
- (IBAction)closeButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)refreshButtonClicked:(id)sender
{
    [_mapView removeAnnotations:_relevantAnnotations];
    [_relevantAnnotations removeAllObjects];
    for (NSString *term in kMapRelevantTerms) {
        [self searchForLocationWithTerm:term];
    }
}

- (IBAction)detailViewCloseButtonClicked:(id)sender
{
    [self hideHoveringEditViewCompletionBlock:^(BOOL complete) {}];
}

- (void)hoveringEditViewBackgroundTapped:(id)sender
{
    [self hideHoveringEditViewCompletionBlock:^(BOOL complete) {}];
}

#pragma mark - Helpers
- (void)searchForLocationWithTerm:(NSString *)term
{
    MKLocalSearchRequest *request = [[[MKLocalSearchRequest alloc] init] autorelease];
    request.naturalLanguageQuery = term;
    request.region = _mapView.region;
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        for (MKMapItem *item in response.mapItems) {
            ZLGenericAnnotation *annotation = [[ZLGenericAnnotation alloc] initWithMapItem:item];
            [_relevantAnnotations addObject:annotation];
            [_mapView addAnnotation:annotation];
        }
        
        [self zoomMapViewToFitAnnotations:_mapView animated:YES];
    }];
}

#pragma mark -
#pragma mark Map Manipulation Helpers
- (void)zoomMapViewToFitAnnotations:(MKMapView *)zoomMapView animated:(BOOL)animated
{
	[self zoomMapViewToFitArrayOfAnnotations:zoomMapView.annotations animated:animated];
}

- (void)zoomMapViewToFitArrayOfAnnotations:(NSArray *)annotations animated:(BOOL)animated
{
	int count = [annotations count];
	if ( count == 0) {
		return;
	}
	
        //convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
        //can't use NSArray with MKMapPoint because MKMapPoint is not an id
	MKMapPoint points[count]; //C array of MKMapPoint struct
	for( int i=0; i<count; i++ ) //load points C array by converting coordinates to points
	{
		CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
		points[i] = MKMapPointForCoordinate(coordinate);
	}
        //create MKMapRect from array of MKMapPoint
	MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];
        //convert MKCoordinateRegion from MKMapRect
	MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
	
        //add padding so pins aren't scrunched on the edges
	region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
	region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
        //but padding can't be bigger than the world
	if( region.span.latitudeDelta > MAX_DEGREES_ARC ) { region.span.latitudeDelta  = MAX_DEGREES_ARC; }
	if( region.span.longitudeDelta > MAX_DEGREES_ARC ){ region.span.longitudeDelta = MAX_DEGREES_ARC; }
	
        //and don't zoom in stupid-close on small samples
	if( region.span.latitudeDelta  < MINIMUM_ZOOM_ARC ) { region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }
	if( region.span.longitudeDelta < MINIMUM_ZOOM_ARC ) { region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }
        //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
	if( count == 1 )
	{
		region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
		region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
	}
	
	[_mapView setRegion:region animated:animated];
}

#pragma mark MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (_firstload) {
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 20.0*METERS_PER_MILE, 20.0*METERS_PER_MILE);
        MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
        [mapView setRegion:adjustedRegion animated:NO];
        
        [mapView removeAnnotations:_relevantAnnotations];
        [_relevantAnnotations removeAllObjects];
        for (NSString *term in kMapRelevantTerms) {
            [self searchForLocationWithTerm:term];
        }
        
        _firstload = NO;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
    
	if (annotation == _mapView.userLocation){
		return nil; //default to blue dot
	}
    
    else if ([_relevantAnnotations containsObject:annotation])
	{
		MKPinAnnotationView *annView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pharmLoc"];
		if (annView == nil) {
			annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pharmLoc"];
		}
		
		annView.pinColor = MKPinAnnotationColorRed;
		annView.animatesDrop=TRUE;
		
		annView.canShowCallout = YES;
        
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annView.rightCalloutAccessoryView = detailButton;
		
		return annView;
        
	}
    
    else {
		return nil;
	}
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    ZLGenericAnnotation *annotation = view.annotation;
    MKMapItem *mapItem = annotation.mapItem;
    self.selectedItem = mapItem;
    self.editingProfessional = [self getProfesisonalFromMapItem:_selectedItem];
    [self showHoveringEditViewWithContentView:_detailView hoverType:2 completionBlock:^(BOOL complete) {
       [_detailTableView reloadData];
    }];
}

#pragma mark - Helper
- (ProfessionalToContact *)getProfesisonalFromMapItem:(MKMapItem *)mapItem
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ProfessionalToContact"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", mapItem.name];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [[[ANDataStoreCoordinator shared] managedObjectContext] executeFetchRequest:request error:&error];
    if ([result count] > 0) {
        return result[0];
    }
    else {
        return nil;
    }
}

- (void)showHoveringEditViewWithContentView:(UIView *)contentView hoverType:(NSInteger)hoverType completionBlock:(void(^)(BOOL complete))block
{
    if (!_hoveringEditView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height)];
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        view.backgroundColor = [UIColor clearColor];
        self.hoveringEditView = view;
        [view release];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [button addTarget:self action:@selector(hoveringEditViewBackgroundTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_hoveringEditView addSubview:button];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(button);
        [_hoveringEditView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[button]-0-|" options:0 metrics:nil views:views]];
        [_hoveringEditView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[button]-0-|" options:0 metrics:nil views:views]];
        
        [self.view addSubview:_hoveringEditView];
        views = @{@"hover": _hoveringEditView};
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[hover]-0-|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[hover(==viewHeight)]" options:0 metrics:@{@"viewHeight": @(self.view.bounds.size.height)} views:views]];
        
        self.hoveringEditViewTopConstraint = [NSLayoutConstraint constraintWithItem:_hoveringEditView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:-self.view.bounds.size.height];
        [self.view addConstraint:_hoveringEditViewTopConstraint];
        
        view = [[UIView alloc] initWithFrame:CGRectMake(20, 30, 280, 240)];
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        view.backgroundColor = [UIColor clearColor];
        self.hoveringEditContainerView = view;
        [view release];
        [_hoveringEditView addSubview:_hoveringEditContainerView];
        
        views = @{@"container": _hoveringEditContainerView};
        [_hoveringEditView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[container]-20-|" options:0 metrics:nil views:views]];
        [_hoveringEditView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[container]-20-|" options:0 metrics:nil views:views]];

    }
    
    _hoveringEditView.hidden = NO;
    
    if (_hoveringEditContentView) {
        [_hoveringEditContentView removeFromSuperview];
        self.hoveringEditContentView = nil;
    }
    
    contentView.frame = CGRectMake(0, 0, _hoveringEditContainerView.bounds.size.width, _hoveringEditContainerView.bounds.size.height);
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.hoveringEditContentView = contentView;
    [_hoveringEditContainerView addSubview:_hoveringEditContentView];
    
    _hoveringEditContentView.layer.cornerRadius = 5.0;
    
    NSDictionary *views = @{@"content": _hoveringEditContentView};
    [_hoveringEditContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[content]-0-|" options:0 metrics:nil views:views]];
    [_hoveringEditContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[content]-0-|" options:0 metrics:nil views:views]];
    
    [UIView animateWithDuration:0.3 animations:^{
        _coverView.alpha = 0.8;
        _hoveringEditViewTopConstraint.constant = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        _hoveringEditContainerView.layer.shadowColor = [UIColor whiteColor].CGColor;
        _hoveringEditContainerView.layer.shadowOpacity = 0.5;
        _hoveringEditContainerView.layer.shadowRadius = 10.0;
        _hoveringEditContainerView.layer.shadowOffset = CGSizeMake(0, 0);
        CGPathRef path = CGPathCreateWithRect(_hoveringEditContainerView.layer.bounds, NULL);
        _hoveringEditContainerView.layer.shadowPath = path;
        CGPathRelease(path);
        
        block(finished);
    }];
    
}

- (void)hideHoveringEditViewCompletionBlock:(void(^)(BOOL complete))block
{
    [_hoveringEditView endEditing:NO];
    
    _hoveringEditContainerView.layer.shadowColor = [UIColor clearColor].CGColor;
    _hoveringEditContainerView.layer.shadowOpacity = 0.0;
    _hoveringEditContainerView.layer.shadowRadius = 0.0;
    _hoveringEditContainerView.layer.shadowOffset = CGSizeMake(0, 0);
    _hoveringEditContainerView.layer.shadowPath = nil;
    
    [UIView animateWithDuration:0.3 animations:^{
        _coverView.alpha = 0.0;
        _hoveringEditViewTopConstraint.constant = -self.view.bounds.size.height;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.hoveringEditContentView = nil;
        _hoveringEditView.hidden = YES;
        block(finished);
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
            return 3;
            break;
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 30)] autorelease];
    label.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
        //    label.backgroundColor = [_titleBar.backgroundColor colorWithAlphaComponent:0.8];
    label.textColor = [UIColor darkTextColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.contentMode = UIViewContentModeBottom;
    label.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:17];
    
    switch (section) {
        case 0:
            label.text = @"  Location Information";
            break;
        case 1:
            label.text = @"  Action";
            break;
    }
    
    return label;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            ANTwoLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ANTwoLabelCell"];
            switch (indexPath.row) {
                case 0:
                    cell.titleLabel.text = @"Name";
                    cell.secondaryTitleLabel.text = _selectedItem.name;
                    break;
                case 1:
                    cell.titleLabel.text = @"Phone";
                    cell.secondaryTitleLabel.text = _selectedItem.phoneNumber;
                    break;
                case 2:
                    cell.titleLabel.text = @"Website";
                    cell.secondaryTitleLabel.text = [_selectedItem.url absoluteString];
                    break;
                default:
                    break;
            }
            
            return cell;
        }
            break;
        case 1:
        {
            ZLOneLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZLOneLabelCell"];
            
            switch (indexPath.row) {
                case 0:
                    cell.titleLabel.text = @"Directions from here";
                    break;
                case 1:
                    cell.titleLabel.text = @"Add to Safety Plan as Professional";
                    break;
                case 2:
                    cell.titleLabel.text = @"Add to Safety Plan as Facility";
                    break;
                default:
                    break;
            }
            
            return cell;
        }
        
            break;
        default:
            return nil;
            break;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 1:
                {
                    [[ANDataStoreCoordinator shared] callPhoneNumber:_selectedItem.phoneNumber];
                }
                    break;
                case 2:
                {
                    [[UIApplication sharedApplication] openURL:_selectedItem.url];
                }
                    break;
            }
        }
            break;
        case 1:
        {
            NSMutableString *addressOfSelectedItem = [NSMutableString string];
            if ([_selectedItem.placemark.thoroughfare length] > 0) {
                [addressOfSelectedItem appendFormat:@"%@", _selectedItem.placemark.thoroughfare];
            }
            if ([_selectedItem.placemark.locality length] > 0) {
                [addressOfSelectedItem appendFormat:@", %@", _selectedItem.placemark.locality];
            }
            if ([_selectedItem.placemark.administrativeArea length] > 0) {
                [addressOfSelectedItem appendFormat:@", %@", _selectedItem.placemark.administrativeArea];
            }
            if ([_selectedItem.placemark.postalCode length] > 0) {
                [addressOfSelectedItem appendFormat:@", %@", _selectedItem.placemark.postalCode];
            }
            
            switch (indexPath.row) {
                case 0:
                {
                    NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
                    [_selectedItem openInMapsWithLaunchOptions:options];
                }
                    break;
                case 1:
                {
                    if (_editingProfessional) {
                        _editingProfessional.name = _selectedItem.name;
                        _editingProfessional.phone = _selectedItem.phoneNumber;
                        _editingProfessional.address = addressOfSelectedItem;
                        _editingProfessional.professionalType = @"Professional";
                    }
                    else {
                        ProfessionalToContact *professional = [NSEntityDescription insertNewObjectForEntityForName:@"ProfessionalToContact" inManagedObjectContext:[[ANDataStoreCoordinator shared] managedObjectContext]];
                        professional.name = _selectedItem.name;
                        professional.phone = _selectedItem.phoneNumber;
                        professional.address = addressOfSelectedItem;
                        professional.professionalType = @"Professional";
                    }
                    
                    [[ANDataStoreCoordinator shared] saveDataStore];
                }
                    break;
                case 2:
                {
                    if (_editingProfessional) {
                        _editingProfessional.name = _selectedItem.name;
                        _editingProfessional.phone = _selectedItem.phoneNumber;
                        _editingProfessional.address = addressOfSelectedItem;
                        _editingProfessional.professionalType = @"Facility";
                    }
                    else {
                        ProfessionalToContact *professional = [NSEntityDescription insertNewObjectForEntityForName:@"ProfessionalToContact" inManagedObjectContext:[[ANDataStoreCoordinator shared] managedObjectContext]];
                        professional.name = _selectedItem.name;
                        professional.phone = _selectedItem.phoneNumber;
                        professional.address = addressOfSelectedItem;
                        professional.professionalType = @"Facility";
                    }
                    
                    [[ANDataStoreCoordinator shared] saveDataStore];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end

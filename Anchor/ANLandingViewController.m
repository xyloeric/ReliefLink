//
//  ANLandingViewController.m
//  Anchor
//
//  Created by Eric Li on 7/16/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import "ANCommons.h"
#import "ANDataStoreCoordinator.h"

#import "ANLandingViewController.h"
#import "ZLTableSectionHeaderView.h"
#import "SingleGridCell.h"
#import "DualGridCell.h"

#import "ZLSparkline.h"
#import "ZLTimelineGraph.h"

#import "MoodEntryViewController.h"
#import "MoodViewController.h"
#import "EmergencyViewController.h"
#import "SafetyPlanningViewController.h"
#import "SettingsViewController.h"
#import "ProfileViewController.h"
#import "ReminderViewController.h"
#import "ResourceViewController.h"
#import "CopingViewController.h"

#import "MWPhotoBrowser.h"
#import "ZLGenericAnnotation.h"
#import "Mood.h"
#import "SuicidalThought.h"

static NSString *SingleGridCellIdentifier = @"SingleGridCell";
static NSString *DualGridCellIdentifier = @"DualGridCell";

#define kGridIdentifierReminder @"Reminder"
#define kGridIdentifierMood @"Mood"
#define kGridIdentifierHelp @"Help"
#define kGridIdentifierCope @"Cope"
#define kGridIdentifierCrisisCenter @"CrisisCenter"
#define kGridIdentifierMoodTrend @"MoodTrend"

@interface ANLandingViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, MKMapViewDelegate, SingleGridCellDelegate, DualGridCellDelegate, MWPhotoBrowserDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    CGSize _coverImageSizeCache;
    int _randomImageIndex;
    BOOL _firstload;
}
@property (retain, nonatomic) IBOutlet UIImageView *coverImageView;
@property (retain, nonatomic) IBOutlet UIImageView *profileImageView;
@property (nonatomic, retain) MKMapView *mapView;
@property (retain, nonatomic) IBOutlet UIButton *menuButton;
@property (retain, nonatomic) IBOutlet UIButton *emergencyButton;

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSMutableArray *photos;
@property (nonatomic, retain) NSMutableArray *mapAnnotations;

@property (nonatomic, retain) ZLTimelineGraph *timelineGraph;
@property (nonatomic, retain) NSString *latestMood;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *coverViewHeightConstraint;
@end

@implementation ANLandingViewController

- (id)init
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        _firstload = YES;
        self.detailViewIdentifier = NSStringFromClass([self class]);
        self.photos = [NSMutableArray array];
        self.mapAnnotations = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        _coverViewHeightConstraint.constant = 160.0;
    }
    else {
        _coverViewHeightConstraint.constant = 140.0;
    }
    
    [_tableView registerNib:[UINib nibWithNibName:@"SingleGridCell" bundle:nil] forCellReuseIdentifier:SingleGridCellIdentifier];
    [_tableView registerNib:[UINib nibWithNibName:@"DualGridCell" bundle:nil] forCellReuseIdentifier:DualGridCellIdentifier];
    
    MKMapView *mapView = [[[MKMapView alloc] init] autorelease];
    mapView.delegate = self;
    mapView.userInteractionEnabled = NO;
    [mapView setShowsUserLocation:YES];
    self.mapView = mapView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshProfilePicture:) name:kProfilePictureDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCoverPicture:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshReminder:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTweets:) name:@"UpdateReliefLinkTweetCount" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTimelineGraph:) name:@"RefreshMoodGraph" object:nil];

    
    [_profileImageView.layer setCornerRadius:_profileImageView.frame.size.width/2];
    [_profileImageView.layer setMasksToBounds:YES];
    [_profileImageView.layer setBorderWidth:3.0];
    [_profileImageView.layer setBorderColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5].CGColor];
    [self refreshProfilePicture:nil];
    [self refreshCoverPicture:nil];
    
    [_menuButton addTarget:self action:@selector(menuButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_menuButton setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
    [_menuButton.layer setCornerRadius:5.0];
    [_menuButton.layer setBorderWidth:1.0];
    [_menuButton.layer setBorderColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5].CGColor];
    
    [_emergencyButton addTarget:self action:@selector(emergencyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_emergencyButton setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5]];
    [_emergencyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_emergencyButton.layer setCornerRadius:5.0];
    [_emergencyButton.layer setBorderWidth:1.0];
    [_emergencyButton.layer setBorderColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5].CGColor];
    
    for (int i = 0; i < 14; i++) {
        [_photos addObject:[MWPhoto photoWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%i", i]]]];
    }
    
    [_tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_coverImageView release];
    [_profileImageView release];
    [_menuButton release];
    [_tableView release];
    [_emergencyButton release];
    [_photos release];
    [_mapView release];
    [_mapAnnotations release];
    [_timelineGraph release];
    [_latestMood release];
    [_coverViewHeightConstraint release];
    [super dealloc];
}

- (void)refreshTimelineGraph:(id)sender
{
    if (!_timelineGraph) {
        ZLTimelineGraph *sparkline = [[[ZLTimelineGraph alloc] init] autorelease];
        self.timelineGraph = sparkline;
        
        sparkline.backgroundColor = [UIColor whiteColor];
    }
    
    NSMutableArray *data = [NSMutableArray arrayWithCapacity:2];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Mood"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"recordDate" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    [sortDescriptor release];
    [request setFetchBatchSize:10];
    [request setFetchLimit:20];
    
    NSManagedObjectContext *context = [[ANDataStoreCoordinator shared] managedObjectContext];
    NSError *error = nil;
    NSArray *moods = [context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    if ([moods count] > 0) {
        NSEnumerator *reverseEnumerator = [moods reverseObjectEnumerator];
        
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:[moods count]];
        
        Mood *mood = nil;
        while ((mood = [reverseEnumerator nextObject]) != nil) {
            [temp addObject:@{@"date": mood.recordDate, @"value": [NSString stringWithFormat:@"%@", mood.moodType]}];
        }

        [data addObject:temp];        
    }
    
    _latestMood = [self getMoodDescriptionFromType:moods[0]];

    request = [[NSFetchRequest alloc] initWithEntityName:@"SuicidalThought"];
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"recordDate" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    [sortDescriptor release];
    [request setFetchBatchSize:10];
    [request setFetchLimit:20];
    
    NSArray *thoughts = [context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    if ([thoughts count] > 0) {
        NSEnumerator *reverseEnumerator = [thoughts reverseObjectEnumerator];

        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:[thoughts count]];
        
        SuicidalThought *thought = nil;
        while ((thought = [reverseEnumerator nextObject]) != nil) {
            [temp addObject:@{@"date": thought.recordDate, @"value": [NSString stringWithFormat:@"%@", thought.thoughtType]}];

        }
        [data addObject:temp];
    }
    
    if ([data count] == 1) {
        [_timelineGraph visualizeData:data startDate:data[0][0][@"date"] endDate:[data[0] lastObject][@"date"] settings:@[@{@"key": @"data1", @"title": @"data1", @"unit": @"", @"width": @2, @"color": kDRGraphBrightColorScheme[0]}]];
    }else if ([data count] == 2) {
        NSDate *date1First = data[0][0][@"date"];
        NSDate *date2First = data[1][0][@"date"];
        NSDate *date1Last = [data[0] lastObject][@"date"];
        NSDate *date2Last = [data[1] lastObject][@"date"];
        
        NSDate *startDate = [date1First compare:date2First] == NSOrderedAscending ? date1First : date2First;
        NSDate *endDate = [date1Last compare:date2Last] == NSOrderedAscending ? date2Last : date1Last;
        
        [_timelineGraph visualizeData:data startDate:startDate endDate:endDate settings:@[@{@"key": @"data1", @"title": @"data1", @"unit": @"", @"width": @2, @"color": kDRGraphBrightColorScheme[0]}, @{@"key": @"data2", @"title": @"data2", @"unit": @"", @"width": @2, @"color": kDRGraphBrightColorScheme[1]}]];
    }
    else {
        [_timelineGraph visualizeData:@[] startDate:nil endDate:nil settings:@[]];
    }
}

- (NSString *)getMoodDescriptionFromType:(Mood *)mood
{
    if (!mood) {
        return @"N/A";
    }
    else {
        switch ([mood.moodType intValue]) {
            case 2:
                return @"LOW";
                break;
            case 4:
                return @"LOW";
                break;
            case 6:
                return @"OK";
                break;
            case 8:
                return @"GOOD";
                break;
            case 10:
                return @"HAPPY";
                break;
            default:
                return @"N/A";
                break;
        }
    }
}

- (IBAction)takeProfilePictureButtonClicked:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Your device doesn't have camera" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
		return;
	}
    
    picker.allowsEditing = YES;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;

	[self presentViewController:picker animated:YES completion:^{}];
    [picker release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {    
	UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
	if (!image) image = [info objectForKey:UIImagePickerControllerOriginalImage];
	if (!image) return;
    
    _profileImageView.image = image;
    
    User *currentUser = [[ANDataStoreCoordinator shared] getCurrentUser];
    if ([currentUser.profilePhotoPath length] > 0) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:currentUser.profilePhotoPath error:&error];
    }
    
	NSString *uuidString = [[ANDataStoreCoordinator shared] getUUID];
    NSString *path = [NSString stringWithFormat:@"%@/%@.jpg", [[ANDataStoreCoordinator shared] profilePictureDirectory], uuidString];
    
    NSData *imageData= UIImageJPEGRepresentation(image, 1.0);
    [imageData writeToFile:path atomically:YES];
    
    currentUser.profilePhotoPath = path;
    [[ANDataStoreCoordinator shared] saveDataStore];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProfilePictureDidChangeNotification object:nil];

    [picker dismissViewControllerAnimated:YES completion:^{}];
}

- (void)refreshProfilePicture:(id)sender
{
    User *currentUser = [[ANDataStoreCoordinator shared] getCurrentUser];
    if ([[NSFileManager defaultManager] fileExistsAtPath:currentUser.profilePhotoPath]) {
        [_profileImageView setImage:[UIImage imageWithContentsOfFile:currentUser.profilePhotoPath]];
    }
    else {
        [_profileImageView setImage:[UIImage imageNamed:@"profile_default"]];
    }
}

- (void)refreshCoverPicture:(id)sender
{
    _randomImageIndex = arc4random() % 13;
    [_coverImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%i.jpg", _randomImageIndex]]];
}

- (void)refreshData:(id)sender
{
    [_tableView reloadData];
}

- (void)refreshReminder:(id)sender
{
    [_tableView reloadData];
}

- (void)refreshTweets:(id)sender
{
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 66.0;
            break;
        case 1:
            return 120.0;
            break;
        case 2:
            return 116.0;
            break;
        default:
            return 0;
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0) {
                DualGridCell *cell = [tableView dequeueReusableCellWithIdentifier:DualGridCellIdentifier];
                
                UILabel *label1 = [[[UILabel alloc] init] autorelease];
                label1.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:40];
                label1.textColor = [UIColor orangeColor];
                label1.text = [NSString stringWithFormat:@"%i", [[ANDataStoreCoordinator shared] numberOfObjectsOfEntity:@"Reminder"]];
                label1.textAlignment = NSTextAlignmentCenter;
                UILabel *label2 = [[[UILabel alloc] init] autorelease];
                label2.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:40];
                label2.textColor = [UIColor blueColor];
                label2.text = _latestMood;
                label2.textAlignment = NSTextAlignmentCenter;
                
                [cell setGrid1Title:@"Reminders" grid1ContentView:label1 grid2Title:@"Feeling" grid2ContentView:label2];
                cell.grid1Identifier = kGridIdentifierReminder;
                cell.grid2Identifier = kGridIdentifierMood;
                cell.delegate = self;
                
                return cell;
            }
            else {
                DualGridCell *cell = [tableView dequeueReusableCellWithIdentifier:DualGridCellIdentifier];
                
                UILabel *label1 = [[[UILabel alloc] init] autorelease];
                label1.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:40];
                label1.textColor = [UIColor redColor];
                label1.text = [NSString stringWithFormat:@"%i", [_mapAnnotations count]];
                label1.textAlignment = NSTextAlignmentCenter;
                UILabel *label2 = [[[UILabel alloc] init] autorelease];
                label2.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:40];
                label2.textColor = [UIColor purpleColor];
                label2.text = [NSString stringWithFormat:@"%i", [ANDataStoreCoordinator shared].relieflinkTweetCount];
                label2.textAlignment = NSTextAlignmentCenter;
                
                [cell setGrid1Title:@"Help Near You" grid1ContentView:label1 grid2Title:@"Tweets from Us" grid2ContentView:label2];
                cell.grid1Identifier = kGridIdentifierHelp;
                cell.grid2Identifier = kGridIdentifierCope;
                cell.delegate = self;
                
                return cell;
            }

        }
            break;
        case 1:
        {
            SingleGridCell *cell = [tableView dequeueReusableCellWithIdentifier:SingleGridCellIdentifier];
            
            [cell setTitle:nil contentView:_mapView];
            cell.gridIdentifier = kGridIdentifierCrisisCenter;
            cell.delegate = self;
            
            return cell;
        }
            break;
        case 2:
        {
            SingleGridCell *cell = [tableView dequeueReusableCellWithIdentifier:SingleGridCellIdentifier];
            [cell setTitle:nil contentView:_timelineGraph];
            cell.gridIdentifier = kGridIdentifierMoodTrend;
            cell.delegate = self;
            
            [self refreshTimelineGraph:nil];
            return cell;
        }
            break;
        default:
            return nil;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0;
            break;
        case 1:
            return 20;
            break;
        case 2:
            return 20;
            break;
        default:
            return 0;
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return nil;
            break;
        case 1:
        {
            ZLTableSectionHeaderView *view = [[[ZLTableSectionHeaderView alloc] initDarkStyleWithFrame:CGRectMake(0, 0, 320, 20) textAlignment:NSTextAlignmentCenter] autorelease];
            [view setText:@"Health Centers"];
            return view;
        }
            break;
        case 2:
        {
            ZLTableSectionHeaderView *view = [[[ZLTableSectionHeaderView alloc] initLightStyleWithFrame:CGRectMake(0, 0, 320, 20) textAlignment:NSTextAlignmentCenter] autorelease];
            [view setText:@"Mood Trends"];
            return view;
        }
            break;
        default:
        {
            return nil;
        }
            break;
    }
}

#pragma mark - UITableViewDelegate

#pragma mark - Helpers
- (void)presentViewControllerWithGridIdentifier:(NSString *)gridIdentifier
{
    if ([gridIdentifier isEqualToString:kGridIdentifierCrisisCenter]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestSwitchView" object:@{@"class": @"Resources", @"launchOption": @"5"}];
//
//        ResourceViewController *vc = [[[ResourceViewController alloc] init] autorelease];
//        [self.delegate ANDetailViewController:self requestPresentViewController:vc];
    }
    else if ([gridIdentifier isEqualToString:kGridIdentifierMoodTrend]) {
        MoodViewController *vc = [[[MoodViewController alloc] init] autorelease];
        [self.delegate ANDetailViewController:self requestPresentViewController:vc];
    }
    else if ([gridIdentifier isEqualToString:kGridIdentifierReminder]) {
        ReminderViewController *vc = [[[ReminderViewController alloc] init] autorelease];
        [self.delegate ANDetailViewController:self requestPresentViewController:vc];
    }
    else if ([gridIdentifier isEqualToString:kGridIdentifierMood]) {
        MoodViewController *vc = [[[MoodViewController alloc] init] autorelease];
        [self.delegate ANDetailViewController:self requestPresentViewController:vc];
    }
    else if ([gridIdentifier isEqualToString:kGridIdentifierHelp]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestSwitchView" object:@{@"class": @"Resources", @"launchOption": @"5"}];
//
//        ResourceViewController *vc = [[[ResourceViewController alloc] init] autorelease];
//        [self.delegate ANDetailViewController:self requestPresentViewController:vc];
    }
    else if ([gridIdentifier isEqualToString:kGridIdentifierCope]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestSwitchView" object:@{@"class": @"Resources", @"launchOption": @"3"}];
//
//        ResourceViewController *vc = [[[ResourceViewController alloc] init] autorelease];
//        [self.delegate ANDetailViewController:self requestPresentViewController:vc];
    }
}

- (void)showPhotoViewerFromRect:(CGRect)rect
{
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [browser setInitialPageIndex:_randomImageIndex];
    browser.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:browser animated:YES completion:^{}];
    [browser release];
//    [self addChildViewController:browser];
//    [browser release];
//    browser.view.frame = rect;
//    [self.view addSubview:browser.view];
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        browser.view.frame = self.view.bounds;
//    }];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 14;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < 14)
    {
        MWPhoto *photo = [MWPhoto photoWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%i.jpg", index]]];
        return photo;
    }
    
    return nil;
}

- (void)photoBrowserDidClickCloseButton:(MWPhotoBrowser *)photoBrowser
{
    [photoBrowser dismissViewControllerAnimated:YES completion:^{}];
}

- (void)emergencyButtonTapped:(id)sender
{
    EmergencyViewController *vc = [[[EmergencyViewController alloc] init] autorelease];
    [self.delegate ANDetailViewController:self requestPresentViewController:vc];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _coverImageSizeCache = CGSizeMake(self.view.frame.size.width, _coverViewHeightConstraint.constant);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0) {
        CGFloat ratio = _coverImageSizeCache.width / _coverImageSizeCache.height;
        
        CGFloat newHeight = _coverImageSizeCache.height - scrollView.contentOffset.y;
        CGFloat newWidth = newHeight * ratio;
        
        _coverImageView.frame = CGRectMake(-(newWidth - _coverImageSizeCache.width) / 2.0, 0, newWidth, newHeight);
        _profileImageView.alpha = -1.67 * ((-scrollView.contentOffset.y) / _coverImageSizeCache.height) + 1.5;
    }
    else {
        _coverImageView.frame = CGRectMake(0, 0, _coverImageSizeCache.width, _coverImageSizeCache.height);
        _profileImageView.alpha = 1.0;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y < 0) {
        if (-scrollView.contentOffset.y > _coverImageSizeCache.height * 0.6) {
            [self showPhotoViewerFromRect:CGRectMake(0, 0, 320, _coverImageView.frame.size.height)];
        }
    }
}

#pragma mark MKMapViewDelegate

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
            [_mapAnnotations addObject:annotation];
            [_mapView addAnnotation:annotation];
        }
        [self zoomMapViewToFitAnnotations:_mapView animated:YES];
        [self refreshTweets:nil];
    }];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (_firstload && userLocation.location) {
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 1.0*METERS_PER_MILE, 1.0*METERS_PER_MILE);
        MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
        [mapView setRegion:adjustedRegion animated:NO];
        
        [mapView removeAnnotations:_mapAnnotations];
        [_mapAnnotations removeAllObjects];
        for (NSString *term in kMapRelevantTerms) {
            [self searchForLocationWithTerm:term];
        }
        
        _firstload = NO;
        
        [_tableView reloadData];
    }
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

#pragma mark SingleGridCellDelegate
- (void)SingleGridCellDidClickButton:(SingleGridCell *)cell
{
    [self presentViewControllerWithGridIdentifier:cell.gridIdentifier];
}

#pragma mark DualGridCellDelegate
- (void)DualGridCellDidClickButton1:(DualGridCell *)cell
{
    [self presentViewControllerWithGridIdentifier:cell.grid1Identifier];
}

- (void)DualGridCellDidClickButton2:(DualGridCell *)cell
{
    [self presentViewControllerWithGridIdentifier:cell.grid2Identifier];
}

@end

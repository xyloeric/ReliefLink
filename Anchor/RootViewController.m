    //
    //  RootViewController.m
    //  Anchor
    //
    //  Created by Eric Li on 7/15/13.
    //  Copyright (c) 2013 ericli. All rights reserved.
    //

#import "RootViewController.h"
#import "ANLandingViewController.h"
#import "ANNavigationViewController.h"
#import "SafetyPlanningViewController.h"
#import "ResourceViewController.h"
#import "ProfileViewController.h"

@interface RootViewController () <ANDetailViewControllerDelegate, ANNavigationViewControllerDelegate>
    //@property (nonatomic, retain) ANLandingViewController *homeViewController;

@property (nonatomic, retain) ANDetailViewController *detailViewController;
@property (nonatomic, retain) ANNavigationViewController *navController;
@end

@implementation RootViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchView:) name:@"RequestSwitchView" object:nil];
    
    self.homeViewController = [[[ANLandingViewController alloc] init] autorelease];
    ((ANLandingViewController *)self.homeViewController).delegate = self;
    
    self.navController = [[[ANNavigationViewController alloc] init] autorelease];
    _navController.delegate = self;
    
    self.leftViewController = _navController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_detailViewController release];
    [_navController release];
    [super dealloc];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)switchView:(NSNotification *)notification
{
    NSDictionary *viewInfo = notification.object;
    NSString *vcClass = viewInfo[@"class"];
    
    if ([vcClass isEqualToString:@"SafetyPlan"]) {
        SafetyPlanningViewController *vc = [[SafetyPlanningViewController alloc] init];
        [self showViewController:vc completionBlock:^{
            vc.launchOption = viewInfo[@"launchOption"];
        }];
        [vc release];
    }
    else if ([vcClass isEqualToString:@"Resources"]) {
        ResourceViewController *vc = [[ResourceViewController alloc] init];
        [self showViewController:vc completionBlock:^{
            vc.launchOption = viewInfo[@"launchOption"];
        }];
        [vc release];
    }
    else if ([vcClass isEqualToString:@"Profile"]) {
        ProfileViewController *vc = [[ProfileViewController alloc] init];
        [self showViewController:vc completionBlock:^{
            vc.launchOption = viewInfo[@"launchOption"];
        }];
        [vc release];
    }
}

- (void)showViewController:(ANDetailViewController *)detailController
{
    if (![detailController.detailViewIdentifier isEqualToString:_detailViewController.detailViewIdentifier]) {
        double delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            detailController.delegate = self;
            
            self.detailViewController = detailController;
            self.centerViewController = _detailViewController;
            
            [self showCenterView];
        });
    }
    else {
        [self showCenterView];
    }
}

- (void)showViewController:(ANDetailViewController *)detailController completionBlock:(void(^)(void))block
{
    detailController.delegate = self;
    
    self.detailViewController = detailController;
    self.centerViewController = _detailViewController;
    
    [self showCenterViewCompletionBlock:^{
       block();
    }];
}

#pragma mark - ANDetailViewControllerDelegate
- (void)ANDetailViewControllerDidClickMenuButton:(ANDetailViewController *)detailViewController
{
    [self toggleLeftAppearence:nil];
}

- (void)ANDetailViewControllerDidClickHomeButton:(ANDetailViewController *)detailViewController
{
    [self showHomeView];
}

- (void)ANDetailViewController:(ANDetailViewController *)landingController requestPresentViewController:(ANDetailViewController *)detailController
{
    [self showViewController:detailController];
}

#pragma mark - ANNavigationViewControllerDelegate
- (void)ANNavigationViewController:(ANNavigationViewController *)navController requestPresentingViewController:(ANDetailViewController *)detailController
{
    [self toggleLeftAppearence:nil];
    
    [self showViewController:detailController];
}

@end

//
//  ResourceViewController.m
//  Anchor
//
//  Created by Eric Li on 7/21/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ResourceViewController.h"
#import "ResourceCell.h"
#import "ZLWebViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ZLMusicPlayerViewController.h"
#import "ZLTwitterViewController.h"
#import "ZLLocalMapViewController.h"

@interface ResourceViewController () <UITableViewDataSource, UITableViewDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIView *titleBar;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *titleHeightConstraint;

@end

@implementation ResourceViewController

- (id)init
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.detailViewIdentifier = NSStringFromClass([self class]);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        _titleHeightConstraint.constant = 64.0;
    }
    else {
        _titleHeightConstraint.constant = 44.0;
    }
    
    [_tableView registerNib:[UINib nibWithNibName:@"ResourceCell" bundle:nil] forCellReuseIdentifier:@"ResourceCell"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableView release];
    [_titleBar release];
    [_launchOption release];
    [_titleHeightConstraint release];
    [super dealloc];
}

- (void)setLaunchOption:(NSString *)launchOption
{
    if (launchOption != _launchOption) {
        [_launchOption release];
        _launchOption = [launchOption retain];
        
        if (_launchOption) {
            NSInteger launchOption = [_launchOption intValue];
            switch (launchOption) {
                case 2:
                {
                    ZLMusicPlayerViewController *vc = [[ZLMusicPlayerViewController alloc] initWithType:0];
                    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                    [self presentViewController:vc animated:YES completion:^{}];
                    [vc release];
                }
                    break;
                case 3:
                {
                    ZLTwitterViewController *vc = [[ZLTwitterViewController alloc] init];
                    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                    [self presentViewController:vc animated:YES completion:^{}];
                    [vc release];
                }
                    
                    break;
                case 4:
                {
                    ZLWebViewController *vc = [[ZLWebViewController alloc] init];
                    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                    vc.titleBarColor = _titleBar.backgroundColor;
                    vc.title = @"Relaxing Music";
                    [self presentViewController:vc animated:YES completion:^{
                        [vc loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://sc9106.xpx.pl:9106/listen.pls"]]];
                    }];
                    [vc release];
                }
                    break;
                case 5:
                {
                    ZLLocalMapViewController *vc = [[ZLLocalMapViewController alloc] init];
                    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                    [self presentViewController:vc animated:YES completion:^{}];
                    [vc release];
                }
                    break;
                case 6:
                {
                    ZLWebViewController *vc = [[ZLWebViewController alloc] init];
                    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                    vc.titleBarColor = _titleBar.backgroundColor;
                    vc.title = @"Therapist";
                    [self presentViewController:vc animated:YES completion:^{
                        [vc loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://therapists.psychologytoday.com/rms/?tr=Hdr_Brand"]]];
                    }];
                    [vc release];
                }
                    break;
                case 7:
                {
                    ZLWebViewController *vc = [[ZLWebViewController alloc] init];
                    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                    vc.titleBarColor = _titleBar.backgroundColor;
                    vc.title = @"Support Group";
                    [self presentViewController:vc animated:YES completion:^{
                        [vc loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.suicidology.org/suicide-support-group-directory"]]];
                    }];
                    [vc release];
                }
                    break;
                case 8:
                {
                    ZLWebViewController *vc = [[ZLWebViewController alloc] init];
                    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                    vc.titleBarColor = _titleBar.backgroundColor;
                    vc.title = @"Treatments";
                    [self presentViewController:vc animated:YES completion:^{
                        [vc loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://findtreatment.samhsa.gov"]]];
                    }];
                    [vc release];
                }
                    break;
                default:
                    break;
            }

        }
    }
}

#pragma mark - Actions
- (IBAction)menuButtonPressed:(UIButton *)sender
{
    [self.delegate ANDetailViewControllerDidClickMenuButton:self];
}

- (IBAction)homeButtonPressed:(UIButton *)sender
{
    [self.delegate ANDetailViewControllerDidClickHomeButton:self];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResourceCell"];
    
    switch (indexPath.row) {
        case 0:
            cell.titleLabel.text = @"Relaxation Exercises";
            cell.iconImageView.image = [UIImage imageNamed:@"icon_resource_kit"];
            break;
        case 1:
            cell.titleLabel.text = @"Twitter";
            cell.iconImageView.image = [UIImage imageNamed:@"icon_twitter_2"];
            break;
        case 2:
            cell.titleLabel.text = @"Relaxing Music";
            cell.iconImageView.image = [UIImage imageNamed:@"icon_music_1"];
            break;
        case 3:
            cell.titleLabel.text = @"Help Near You";
            cell.iconImageView.image = [UIImage imageNamed:@"icon_map"];
            break;
        case 4:
            cell.titleLabel.text = @"Therapist Locator";
            cell.iconImageView.image = [UIImage imageNamed:@"icon_map"];
            break;
        case 5:
            cell.titleLabel.text = @"Support Group Finder";
            cell.iconImageView.image = [UIImage imageNamed:@"icon_map"];
            break;
        case 6:
            cell.titleLabel.text = @"Treatment Services Locator";
            cell.iconImageView.image = [UIImage imageNamed:@"icon_map"];
            break;
        default:
            break;
    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            ZLMusicPlayerViewController *vc = [[ZLMusicPlayerViewController alloc] initWithType:0];
            [self presentViewController:vc animated:YES completion:^{}];
            [vc release];
        }
            break;
        case 1:
        {
            ZLTwitterViewController *vc = [[ZLTwitterViewController alloc] init];
            [self presentViewController:vc animated:YES completion:^{}];
            [vc release];
        }
            
            break;
        case 2:
        {            
            ZLWebViewController *vc = [[ZLWebViewController alloc] init];
            vc.titleBarColor = _titleBar.backgroundColor;
            vc.title = @"Relaxing Music";
            [self presentViewController:vc animated:YES completion:^{
                [vc loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://sc9106.xpx.pl:9106/listen.pls"]]];
            }];
            [vc release];
        }
            break;
        case 3:
        {
            ZLLocalMapViewController *vc = [[ZLLocalMapViewController alloc] init];
            [self presentViewController:vc animated:YES completion:^{}];
            [vc release];
        }
            break;
        case 4:
        {
            ZLWebViewController *vc = [[ZLWebViewController alloc] init];
            vc.titleBarColor = _titleBar.backgroundColor;
            vc.title = @"Therapist";
            [self presentViewController:vc animated:YES completion:^{
                [vc loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://therapists.psychologytoday.com/rms/?tr=Hdr_Brand"]]];
            }];
            [vc release];
        }
            break;
        case 5:
        {
            ZLWebViewController *vc = [[ZLWebViewController alloc] init];
            vc.titleBarColor = _titleBar.backgroundColor;
            vc.title = @"Support Group";
            [self presentViewController:vc animated:YES completion:^{
                [vc loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.suicidology.org/suicide-support-group-directory"]]];
            }];
            [vc release];
        }
            break;
        case 6:
        {
            ZLWebViewController *vc = [[ZLWebViewController alloc] init];
            vc.titleBarColor = _titleBar.backgroundColor;
            vc.title = @"Treatments";
            [self presentViewController:vc animated:YES completion:^{
               [vc loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://findtreatment.samhsa.gov"]]];
            }];
            [vc release];
        }
            break;
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end

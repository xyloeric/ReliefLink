//
//  ZLMusicPlayerViewController.m
//  Anchor
//
//  Created by Eric Li on 7/28/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ZLMusicPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZLMusicPlayerCell.h"
#import "F3BarGauge.h"
#import "ZLWebViewController.h"

#define kMindfulnessBreathing @{@"title": @"Mindfulness of Breathing",@"url": @"https://medical.mit.edu/sites/default/files/mindfulness_of_breathing.mp3", @"description": @"Mindfulness is an amazing tool for stress management and overall wellness because it can be used at virtually any time and can quickly bring lasting results"}

#define kBodyScan @{@"title": @"Mindefulness Meditation - Body Scan", @"url": @"https://medical.mit.edu/sites/default/files/body_scan.mp3"}

#define kGuidedMeditation @{@"title": @"Relax: Guided Meditation", @"url": @"https://medical.mit.edu/sites/default/files/guided_meditation.mp3"}

#define kEnergizingBreath @{@"title": @"Revive Yourself: Energizing Breath", @"url": @"https://medical.mit.edu/sites/default/files/energize.mp3"}

#define kRelaxationVisualization @{@"title": @"Guided Visualization for Relaxation", @"url": @"https://medical.mit.edu/sites/default/files/guided_visualization.mp3"}

#define kProgressiveRelexation @{@"title": @"Progressive Relaxation: Release Muscle Tension", @"url": @"https://medical.mit.edu/sites/default/files/progressive_relaxation.mp3"}

@interface ZLMusicPlayerViewController () <UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate>
{
    double _lowPassReslts;
}
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) AVPlayer *audioPlayer;
@property (nonatomic, retain) NSArray *localAssets;
@property (nonatomic, retain) NSDictionary *selectedAsset;
@property (retain, nonatomic) IBOutlet F3BarGauge *chanelOneMeter;
@property (retain, nonatomic) IBOutlet F3BarGauge *chanelTwoMeter;

@property (retain, nonatomic) IBOutlet UIView *backgroundView;
@property (nonatomic, retain) NSTimer *updateTimer;
@property (nonatomic) NSInteger exerciseType;
@end

@implementation ZLMusicPlayerViewController

- (id)initWithType:(NSInteger)exerciseType
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.exerciseType = exerciseType;
        if (exerciseType == 0) {
            self.localAssets = @[kGuidedMeditation, kEnergizingBreath, kRelaxationVisualization, kProgressiveRelexation, kBodyScan, kMindfulnessBreathing];
        }
        else {
            self.localAssets = @[kBodyScan, kMindfulnessBreathing];
        }
    }
    return self;
}

- (id)init
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_tableView registerNib:[UINib nibWithNibName:@"ZLMusicPlayerCell" bundle:nil] forCellReuseIdentifier:@"ZLMusicPlayerCell"];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    if (_exerciseType == 1) {
        _backgroundView.backgroundColor = [UIColor colorWithRed:0.114 green:0.675 blue:0.929 alpha:1.000];
    }
    
    _chanelOneMeter.numBars = 20;
    _chanelOneMeter.minLimit = 0.05;
    _chanelOneMeter.maxLimit = 1.0;
    _chanelOneMeter.holdPeak = NO;
    _chanelOneMeter.litEffect = NO;
    // UIColor *clrBar = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]; //if u want to make it
    _chanelOneMeter.normalBarColor = [UIColor colorWithRed:0.635 green:0.867 blue:0.435 alpha:1.000];
    _chanelOneMeter.warningBarColor = [UIColor colorWithRed:0.984 green:0.733 blue:0.404 alpha:1.000];
    _chanelOneMeter.dangerBarColor = [UIColor colorWithRed:0.933 green:0.435 blue:0.396 alpha:1.000];;
    _chanelOneMeter.backgroundColor = [UIColor colorWithHue:0.584 saturation:0.567 brightness:0.701 alpha:1.000];
    _chanelOneMeter.outerBorderColor = [UIColor clearColor];
    _chanelOneMeter.innerBorderColor = [UIColor clearColor];
    
    _chanelTwoMeter.numBars = 20;
    _chanelTwoMeter.minLimit = 0.05;
    _chanelTwoMeter.maxLimit = 1.0;
    _chanelTwoMeter.holdPeak = NO;
    _chanelTwoMeter.litEffect = NO;
    _chanelTwoMeter.normalBarColor = [UIColor colorWithRed:0.635 green:0.867 blue:0.435 alpha:1.000];
    _chanelTwoMeter.warningBarColor = [UIColor colorWithRed:0.984 green:0.733 blue:0.404 alpha:1.000];
    _chanelTwoMeter.dangerBarColor = [UIColor colorWithRed:0.933 green:0.435 blue:0.396 alpha:1.000];
    _chanelTwoMeter.backgroundColor = [UIColor colorWithHue:0.584 saturation:0.567 brightness:0.701 alpha:1.000];
    _chanelTwoMeter.outerBorderColor = [UIColor clearColor];
    _chanelTwoMeter.innerBorderColor = [UIColor clearColor];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setImage:[UIImage imageNamed:@"icon_x_white1"] forState:UIControlStateNormal];
    [self.view addSubview:closeButton];
    NSDictionary *views = @{@"button" : closeButton};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(==30)]-5-|" options:0 metrics:nil views:views]];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        _topConstraint.constant = 64.0;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-25-[button(==30)]" options:0 metrics:nil views:views]];
    }
    else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[button(==30)]" options:0 metrics:nil views:views]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_audioPlayer release];
    [_localAssets release];
    [_tableView release];
    [_updateTimer invalidate];
    [_updateTimer release];
    [_chanelOneMeter release];
    [_chanelTwoMeter release];
    [_backgroundView release];
    [_topConstraint release];
    [super dealloc];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Actions
- (void)closeButtonClicked:(id)sender
{
    [_audioPlayer pause];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_localAssets count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [_localAssets count]) {
        
        ZLMusicPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZLMusicPlayerCell"];
        
        NSDictionary *item = [_localAssets objectAtIndex:indexPath.row];
        
        cell.titleLabel.text = item[@"title"];
        cell.detailLabel.text = item[@"description"];
        
        if (_selectedAsset == item && _audioPlayer.rate == 1.0) {
            cell.titleImageView.image = [UIImage imageNamed:@"icon_pause"];
        }
        else {
            cell.titleImageView.image = [UIImage imageNamed:@"icon_play"];
        }
        
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        cell.textLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:13];
        cell.textLabel.text = @"Audio resources belongs to and are made available by MIT Community Wellness Downloads";
        cell.textLabel.numberOfLines = 0;
        cell.tintColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < [_localAssets count]) {
        NSDictionary *item = [_localAssets objectAtIndex:indexPath.row];
        
        if (_selectedAsset == item) {
            if (_audioPlayer.rate == 1.0) {
                [_audioPlayer pause];
            }
            else {
                [_audioPlayer play];
            }
        }
        else {
            self.selectedAsset = item;
            
            NSURL *assetURL = nil;
            
            if (_selectedAsset[@"url"]) {
                assetURL = [NSURL URLWithString:_selectedAsset[@"url"]];
            }
            else {
                assetURL = [[NSBundle mainBundle] URLForResource:item[@"file"] withExtension:item[@"fileType"]];
                
            }
            
            self.audioPlayer = [AVPlayer playerWithURL:assetURL];
            [_audioPlayer play];
        }
        
        [tableView reloadData];
    }
    else {
        ZLWebViewController *vc = [[ZLWebViewController alloc] init];
        vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        vc.titleBarColor = self.view.backgroundColor;
        vc.title = @"";
        [self presentViewController:vc animated:YES completion:^{
            [vc loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://medical.mit.edu/community/sleep/resources"]]];
        }];
        [vc release];
    }

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 != 0) {
        cell.backgroundColor = [UIColor colorWithRed:0.114 green:0.675 blue:0.929 alpha:0.3];
    }
    else {
//        cell.backgroundColor = [UIColor colorWithRed:0.114 green:0.675 blue:0.929 alpha:0.6];
    }
}

//- (void)updateMeters:(NSTimer *)timer
//{
//    [_audioPlayer updateMeters];
//    
//    const double ALPHA = 1.05;
//    double averagePowerForChannel = pow(10, (0.05 * [_audioPlayer averagePowerForChannel:0]));
//	_lowPassReslts = ALPHA * averagePowerForChannel + (1.0 - ALPHA) * _lowPassReslts;
//    
//    float rand1 = (float)rand() / RAND_MAX;
//    float rand2 = (float)rand() / RAND_MAX;
//    
//    _chanelOneMeter.value = _lowPassReslts * (1+rand1 * 0.2);
//    _chanelTwoMeter.value = _lowPassReslts * (1+rand2 * 0.2);
//    
//}


//- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
//{
//    [_tableView reloadData];
//}

- (void)itemDidFinishPlaying:(NSNotification *)notification
{
    [_tableView reloadData];
}
@end

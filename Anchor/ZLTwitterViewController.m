//
//  ZLTwitterViewController.m
//  Anchor
//
//  Created by Eric Li on 7/31/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ZLTwitterViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "ZLTweetCell.h"

#define kTwitterAccounts @[@"TWLOHA", @"800273TALK", @"APAHealthyMinds", @"relieflink"]

@interface ZLTwitterViewController () <NSURLConnectionDataDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIWebViewDelegate>
{
    NSInteger _currentPage;
}
@property (retain, nonatomic) IBOutlet UIScrollView *containerScrollView;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableDictionary *connectionDict;
@property (nonatomic, retain) NSMutableDictionary *dataDict;
@property (nonatomic, retain) NSMutableArray *tweets;
@property (nonatomic, retain) NSArray *reliefLinkTweets;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (retain, nonatomic) IBOutlet UIButton *refreshButton;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;
@property (nonatomic, retain) UIWebView *webView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *titleHeightConstraint;
@end

@implementation ZLTwitterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.connectionDict = [NSMutableDictionary dictionaryWithCapacity:2];
        self.dataDict = [NSMutableDictionary dictionaryWithCapacity:2];
        self.tweets = [NSMutableArray array];
        
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
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
    
    _currentPage = 0;
    
    _tableView.frame = _containerScrollView.bounds;
    [_containerScrollView addSubview:_tableView];
    
    [_tableView registerNib:[UINib nibWithNibName:@"ZLTweetCell" bundle:nil] forCellReuseIdentifier:@"ZLTweetCell"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadTwitterAccount];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (_tableView) {
        _tableView.frame = _containerScrollView.bounds;
    }
    
    if (_webView) {
        _webView.frame = CGRectMake(_containerScrollView.bounds.size.width, 0, _containerScrollView.bounds.size.width, _containerScrollView.bounds.size.height);
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)dealloc
{
    [_tableView release];
    [_connectionDict release];
    [_dataDict release];
    [_tweets release];
    [_reliefLinkTweets release];
    [_containerScrollView release];
    [_webView release];
    [_loadingIndicator release];
    [_refreshButton release];
    [_closeButton release];
    [_titleHeightConstraint release];
    [super dealloc];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Actions
- (IBAction)closeButtonClicked:(id)sender
{
    if (_currentPage == 0) {
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
    else {
        if (_containerScrollView.contentSize.width > _containerScrollView.frame.size.width) {
            [_containerScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
        
        [_loadingIndicator stopAnimating];
        _refreshButton.hidden = NO;
    }
}

- (IBAction)refreshButtonClicked:(id)sender
{
    if (_currentPage == 0) {
        [_tweets removeAllObjects];
        self.reliefLinkTweets = nil;
        [self loadTwitterAccount];
    }
    else {
        [_webView reload];
    }
}

- (IBAction)composeButtonClicked:(id)sender
{
    SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [vc setInitialText:@"@relieflink #relieflink\n"];
    [self presentViewController:vc animated:YES completion:^{}];
}

- (IBAction)backButtonClicked:(id)sender
{
    if (_containerScrollView.contentSize.width > _containerScrollView.frame.size.width) {
        [_containerScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (IBAction)forwardButtonClicked:(id)sender
{
    if (_containerScrollView.contentSize.width > _containerScrollView.frame.size.width) {
        [_containerScrollView setContentOffset:CGPointMake(_containerScrollView.frame.size.width, 0) animated:YES];
    }
}

#pragma mark - Helpers
- (void)loadTwitterAccount
{
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [store requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *twitterAccounts = [store accountsWithAccountType:twitterAccountType];
            if ([twitterAccounts count] > 0) {
                    // Use the first account for simplicity
                ACAccount *account = [twitterAccounts objectAtIndex:0];
                
                for (NSString *username in kTwitterAccounts) {
                    [self startStreamWithAccount:account forTimelineOfUser:username];
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                    [vc setInitialText:@"Hello from @relieflink"];
                    [self presentViewController:vc animated:NO completion:^{}];
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{                
                SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [vc setInitialText:@"Hello from @relieflink"];
                [self presentViewController:vc animated:NO completion:^{}];
            });
            
        }
    }];
}


- (void)startStreamWithAccount:(ACAccount *)twitterAccount forTimelineOfUser:(NSString *)screenName
{
    [_loadingIndicator startAnimating];
    _refreshButton.hidden = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
        [params setObject:@"0" forKey:@"trim_user"];
        [params setObject:screenName forKey:@"screen_name"];
        
        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
        
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
        
        [request setAccount:twitterAccount];
        NSURLRequest *preparedRequest = request.preparedURLRequest;
        
        NSURLConnection *twitterConnection = [[NSURLConnection alloc] initWithRequest:preparedRequest delegate:self];
        
        NSRunLoop *loop = [NSRunLoop currentRunLoop];
        [twitterConnection scheduleInRunLoop:loop forMode:NSRunLoopCommonModes];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_connectionDict setValue:twitterConnection forKey:screenName];
            [_dataDict setValue:[NSMutableData data] forKey:screenName];
            [twitterConnection release];
        });

        [loop run];
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Tweets from us";
            break;
        case 1:
            return @"Tweets from other friends";
            break;
        default:
            return nil;
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [_reliefLinkTweets count];
            break;
        case 1:
            return [_tweets count];
            break;
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZLTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZLTweetCell"];
    
    switch (indexPath.section) {
        case 0:
        {
            NSDictionary *tweet = [_reliefLinkTweets objectAtIndex:indexPath.row];
            cell.tweet = tweet;
        }
            break;
        case 1:
        {
            NSDictionary *tweet = [_tweets objectAtIndex:indexPath.row];
            cell.tweet = tweet;
        }
            break;
        default:
            break;
    }

    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSDictionary *tweet = nil;
    switch (indexPath.section) {
        case 0:
            tweet = _reliefLinkTweets[indexPath.row];
            break;
        case 1:
            tweet = _tweets[indexPath.row];
            break;
        default:
            break;
    }
    
    NSString *urlString = nil;
    
    if ([tweet[@"entities"][@"urls"] count] > 0) {
         urlString = tweet[@"entities"][@"urls"][0][@"url"];

    }
    else if (tweet[@"retweeted_status"]) {
         urlString = tweet[@"retweeted_status"][@"entities"][@"urls"][0][@"url"];
    }
    
    if (urlString) {
        if (!_webView) {
            UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(_containerScrollView.frame.size.width, 0, _containerScrollView.frame.size.width, _containerScrollView.frame.size.height)];
            webView.multipleTouchEnabled = YES;
            webView.scalesPageToFit = YES;
            webView.delegate = self;
            self.webView = webView;
            [webView release];
            
            [_containerScrollView addSubview:webView];
            [_containerScrollView setContentSize:CGSizeMake(2 * _containerScrollView.frame.size.width, _containerScrollView.frame.size.height)];
        }
        
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
        [_containerScrollView setContentOffset:CGPointMake(_containerScrollView.frame.size.width, 0) animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *key = [[_connectionDict allKeysForObject:connection] firstObject];
    NSMutableData *dataContainer = [_dataDict valueForKey:key];
    
    [dataContainer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [_loadingIndicator stopAnimating];
    _refreshButton.hidden = NO;
    
    NSString *key = [[_connectionDict allKeysForObject:connection] firstObject];
    NSMutableData *dataContainer = [_dataDict valueForKey:key];
    
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:dataContainer options:NSJSONReadingAllowFragments error:&error];
    
    if ([result isKindOfClass:[NSDictionary class]] && [result[@"errors"] count] > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Seems like we encountered a authentication issue with your twitter account, please verify it in the system setting of your phone" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([key isEqualToString:@"relieflink"]) {
                if ([result count] > 10) {
                    self.reliefLinkTweets = [result subarrayWithRange:NSMakeRange(0, 10)];
                }
                else {
                    self.reliefLinkTweets = result;
                }
            }
            else {
                [_tweets addObjectsFromArray:result];
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO];
                [_tweets sortUsingDescriptors:@[sortDescriptor]];
            }
            
            [_tableView reloadData];
            
            [_connectionDict setValue:nil forKey:key];
            [_dataDict setValue:nil forKey:key];
        });
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [_loadingIndicator stopAnimating];
    _refreshButton.hidden = NO;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.bounds.size.width;
    int page = floorf((scrollView.contentOffset.x - pageWidth / 2.0) / pageWidth) + 1;
    _currentPage = page;
    
    if (page == 0) {
        [_closeButton setTitle:@"Close" forState:UIControlStateNormal];
    }
    else {
        [_closeButton setTitle:@"Back" forState:UIControlStateNormal];
    }
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_loadingIndicator startAnimating];
    _refreshButton.hidden = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_loadingIndicator stopAnimating];
    _refreshButton.hidden = NO;
}

@end

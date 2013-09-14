//
//
//  Created by Eric Li on 3/4/13.
//
//

#import "ZLWebViewController.h"

@interface ZLWebViewController () <UIWebViewDelegate, UIScrollViewDelegate>
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *titleHeightConstraint;

@end

@implementation ZLWebViewController

- (id)init
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        _titleHeightConstraint.constant = 50.0;
    }
    else {
        _titleHeightConstraint.constant = 30.0;
    }
    
    
    _webView.scalesPageToFit = YES;
    _titleLabel.text = self.title;
    
    if (_titleBarColor) {
        self.titleBar.backgroundColor = _titleBarColor;
        self.footerBar.backgroundColor = _titleBarColor;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_webView release];
    [_loadingIndicator release];
    [_titleLabel release];
    [_titleBarColor release];
    [_titleBar release];
    [_footerBar release];
    [_titleHeightConstraint release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setLoadingIndicator:nil];
    [super viewDidUnload];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark -
#pragma mark Public Methods
- (void)loadRequest:(NSURLRequest *)request
{
    [_webView loadRequest:request];
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    [_webView loadHTMLString:string baseURL:baseURL];
}

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL
{
    [_webView loadData:data MIMEType:MIMEType textEncodingName:textEncodingName baseURL:baseURL];
}

#pragma mark -
#pragma mark Actions
- (IBAction)backButtonClicked:(id)sender
{
    [_webView goBack];
}

- (IBAction)forwardButtonClicked:(id)sender
{
    [_webView goForward];
}

- (IBAction)refreshButtonClicked:(id)sender
{
    [_webView reload];
}

- (IBAction)stopButtonClicked:(id)sender
{
    [_webView stopLoading];
}

- (IBAction)closeButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_loadingIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_loadingIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_loadingIndicator stopAnimating];
}

@end

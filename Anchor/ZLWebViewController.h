//
//
//  Created by Eric Li on 3/4/13.
//
//

#import <UIKit/UIKit.h>

@interface ZLWebViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIView *titleBar;
@property (retain, nonatomic) IBOutlet UIView *footerBar;
@property (nonatomic, retain) UIColor *titleBarColor;

- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;
- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL;

@end

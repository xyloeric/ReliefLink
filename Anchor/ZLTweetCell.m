//
//  ZLTweetCell.m
//  TEST
//
//  Created by Eric Li on 7/29/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ZLTweetCell.h"

@interface ZLTweetCell () <NSURLConnectionDataDelegate>
{
    int _retryCount;
}
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *profileImageView;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, retain) NSMutableData *imageData;
@end

@implementation ZLTweetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _retryCount = 0;
    
}

- (void)dealloc {
    [_titleLabel release];
    [_profileImageView release];
    [_tweet release];
    [_imageConnection release];
    [_loadingIndicator release];
    [_screenNameLabel release];
    [_imageData release];
    [super dealloc];
}

- (void)setTweet:(NSDictionary *)tweet
{
    if (_tweet != tweet) {
        [_tweet release];
        _tweet = [tweet retain];
        
        if (_imageConnection) {
            [_imageConnection cancel];
            self.imageConnection = nil;
        }
        
        self.imageData = [NSMutableData data];

        self.titleLabel.text = _tweet[@"text"];
        self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", _tweet[@"user"][@"screen_name"]];
        self.profileImageView.image = nil;
        _retryCount = 0;
        
        [self updateProfilePicture];
    }
    
}

- (NSString *)cacheDirectory
{
    NSString *cachePath = [NSString stringWithFormat:@"%@/Library/Cache/ImageCache", NSHomeDirectory()];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return cachePath;
}

- (void)updateProfilePicture
{
    _profileImageView.image = nil;
    
    NSMutableString *urlString = [_tweet[@"user"][@"profile_image_url"] mutableCopy];
    [urlString replaceOccurrencesOfString:@"normal" withString:@"bigger" options:0 range:NSMakeRange(urlString.length - 10, 10)];
    
    NSURL *profileUrl = [NSURL URLWithString:urlString];
    [urlString release];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [self cacheDirectory], [profileUrl.pathComponents lastObject]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        _profileImageView.image = image;
    }
    else {
        [_loadingIndicator startAnimating];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:profileUrl];
        NSURLConnection *imageConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        self.imageConnection = imageConnection;
        [imageConnection release];
        [_imageConnection start];
    }
}

#pragma mark - NSURLConenctionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *image = [UIImage imageWithData:_imageData];
    [_loadingIndicator stopAnimating];
    if (image) {
        NSMutableString *urlString = [_tweet[@"user"][@"profile_image_url"] mutableCopy];
        [urlString replaceOccurrencesOfString:@"normal" withString:@"bigger" options:0 range:NSMakeRange(urlString.length - 10, 10)];
        
        NSURL *profileUrl = [NSURL URLWithString:urlString];
        [urlString release];
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", [self cacheDirectory], [profileUrl.pathComponents lastObject]];
        [_imageData writeToFile:filePath atomically:YES];
        
        _profileImageView.image = image;
        self.imageConnection = nil;
        self.imageData = [NSMutableData data];
    }
    else if (_retryCount < 5){
        _retryCount ++;
        [self updateProfilePicture];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [_loadingIndicator stopAnimating];
}

@end

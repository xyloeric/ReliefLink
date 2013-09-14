//
//  ANNavigationCell.m
//  Anchor
//
//  Created by Eric Li on 7/16/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ANNavigationCell.h"

@interface ANNavigationCell ()
@property (retain, nonatomic) IBOutlet UIImageView *titleImageView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ANNavigationCell

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
}

- (void)dealloc
{
    [_navigationItem release];
    [_titleLabel release];
    [_titleImageView release];
    [super dealloc];
}

#pragma mark - Custom Getter/Setter
- (void)setNavigationItem:(NSDictionary *)navigationItem
{
    if (_navigationItem != navigationItem) {
        [_navigationItem release];
        _navigationItem = [navigationItem retain];
        
        _titleLabel.text = _navigationItem[@"title"];
        _titleImageView.image = [UIImage imageNamed:_navigationItem[@"icon"]];
    }
}

@end

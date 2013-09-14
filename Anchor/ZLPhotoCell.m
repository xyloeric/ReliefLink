//
//  ZLPhotoCell.m
//  Anchor
//
//  Created by Eric Li on 7/27/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ZLPhotoCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ZLPhotoCell

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

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _profileImageView.layer.cornerRadius = 5;
    _profileImageView.layer.borderWidth = 0.5;
    _profileImageView.layer.borderColor = [UIColor blackColor].CGColor;
}

- (void)dealloc {
    [_titleLabel release];
    [_profileImageView release];
    [_customSeparatorViewTop release];
    [super dealloc];
}

@end

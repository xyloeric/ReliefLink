//
//  ZLMusicPlayerCell.m
//  Anchor
//
//  Created by Eric Li on 7/30/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ZLMusicPlayerCell.h"

@interface ZLMusicPlayerCell ()


@end

@implementation ZLMusicPlayerCell

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

- (void)dealloc {
    [_titleLabel release];
    [_detailLabel release];
    [_titleImageView release];
    [super dealloc];
}
@end

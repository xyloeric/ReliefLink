//
//  ZLOneLabelCell.m
//  ReliefLink
//
//  Created by Eric Li on 8/3/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ZLOneLabelCell.h"

@implementation ZLOneLabelCell

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
    [super dealloc];
}
@end

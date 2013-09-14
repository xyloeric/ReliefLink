//
//  SafetyTipCell.m
//  ReliefLink
//
//  Created by Eric Li on 8/7/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "SafetyTipCell.h"

@interface SafetyTipCell ()
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *noteLabel;
@end

@implementation SafetyTipCell

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

- (void)dealloc
{
    [_titleLabel release];
    [_noteLabel release];
    [_safetyTip release];
    [super dealloc];
}

- (void)setSafetyTip:(SafetyTip *)safetyTip
{
    if (_safetyTip != safetyTip) {
        [_safetyTip release];
        _safetyTip = [safetyTip retain];
    }
    
    _titleLabel.text = _safetyTip.name;
    _noteLabel.text = _safetyTip.note;
}

@end

//
//  WarningSignCell.m
//  ReliefLink
//
//  Created by Eric Li on 8/6/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "WarningSignCell.h"

@interface WarningSignCell ()
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *noteLabel;

@end

@implementation WarningSignCell

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
    [_noteLabel release];
    [_warningSign release];
    [super dealloc];
}

- (void)setWarningSign:(WarningSign *)warningSign
{
    if (_warningSign != warningSign) {
        [_warningSign release];
        _warningSign = [warningSign retain];
    }
    
    _titleLabel.text = _warningSign.name;
    _noteLabel.text = _warningSign.note;
}
@end

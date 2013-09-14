//
//  CopingStrategyCell.m
//  ReliefLink
//
//  Created by Eric Li on 8/6/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "CopingStrategyCell.h"
#import <QuartzCore/QuartzCore.h>

@interface CopingStrategyCell ()
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *noteLabel;
@property (retain, nonatomic) IBOutlet UIButton *goButton;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *titleTrailingConstraint;
@end

@implementation CopingStrategyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _goButton.layer.cornerRadius = 5.0;
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
    [_internalCopingStrategy release];
    [_goButton release];
    [_titleTrailingConstraint release];
    [super dealloc];
}

- (void)setInternalCopingStrategy:(InternalCopingStrategy *)internalCopingStrategy
{
    if (_internalCopingStrategy != internalCopingStrategy) {
        [_internalCopingStrategy release];
        _internalCopingStrategy = [internalCopingStrategy retain];
    }
    
    _titleLabel.text = _internalCopingStrategy.name;
    _noteLabel.text = _internalCopingStrategy.note;
    
    if ([internalCopingStrategy.keyToResource intValue] > 0) {
        _goButton.hidden = NO;
        _titleTrailingConstraint.constant = 50;
    }
    else {
        _goButton.hidden = YES;
        _titleTrailingConstraint.constant = 20;
    }
}

- (IBAction)goButtonClicked:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestSwitchView" object:@{@"class": @"Resources", @"launchOption": _internalCopingStrategy.keyToResource}];
}

@end

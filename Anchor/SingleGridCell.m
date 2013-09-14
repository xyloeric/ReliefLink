//
//  SingleGridCell.m
//  Anchor
//
//  Created by Eric Li on 7/18/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "SingleGridCell.h"
#import <QuartzCore/QuartzCore.h>

@interface SingleGridCell()
@property (retain, nonatomic) IBOutlet UILabel *gridTitleLabel;
@property (retain, nonatomic) IBOutlet UIView *gridContainerView;
@property (nonatomic, retain) UIView *gridContentView;
@end

@implementation SingleGridCell

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

- (void)dealloc {
    [_gridTitleLabel release];
    [_gridContainerView release];
    [_gridContentView release];
    [_gridIdentifier release];
    
    [super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _gridTitleLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
    _gridTitleLabel.textColor = [UIColor whiteColor];
    _gridTitleLabel.layer.cornerRadius = 5;
}

- (IBAction)buttonClicked:(id)sender
{
    if (_delegate) {
        [_delegate SingleGridCellDidClickButton:self];
    }
}

#pragma mark - Public Methods
- (void)setTitle:(NSString *)title contentView:(UIView *)contentView
{
    if (!title) {
        _gridTitleLabel.hidden = YES;
    }
    else {
        _gridTitleLabel.text = title;
    }

    [_gridContentView removeFromSuperview];
    
    self.gridContentView = contentView;

    if (_gridContentView) {
        [_gridContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        _gridContentView.frame = _gridContainerView.bounds;
        
        [_gridContainerView addSubview:_gridContentView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_gridContentView);
        [_gridContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_gridContentView]-0-|" options:0 metrics:nil views:views]];
        [_gridContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_gridContentView]-0-|" options:0 metrics:nil views:views]];        
    }    
}
@end

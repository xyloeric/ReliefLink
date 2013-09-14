//
//  DualGridCell.m
//  Anchor
//
//  Created by Eric Li on 7/18/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "DualGridCell.h"

@interface DualGridCell ()
@property (retain, nonatomic) IBOutlet UIView *grid1View;
@property (retain, nonatomic) IBOutlet UIView *grid2View;
@property (retain, nonatomic) IBOutlet UILabel *grid1TitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *grid2TitleLabel;
@property (retain, nonatomic) IBOutlet UIView *grid1Container;
@property (retain, nonatomic) IBOutlet UIView *grid2Container;

@property (nonatomic, retain) UIView *grid1ContentView;
@property (nonatomic, retain) UIView *grid2ContentView;
@end

@implementation DualGridCell

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
    [_grid1View release];
    [_grid2View release];
    [_grid1TitleLabel release];
    [_grid2TitleLabel release];
    [_grid1Container release];
    [_grid2Container release];
    [_grid1ContentView release];
    [_grid2ContentView release];
    [_grid1Identifier release];
    [_grid2Identifier release];
    [super dealloc];
}

- (IBAction)button1Clicked:(id)sender
{
    if (_delegate) {
        [_delegate DualGridCellDidClickButton1:self];
    }
}

- (IBAction)button2Clicked:(id)sender
{
    if (_delegate) {
        [_delegate DualGridCellDidClickButton2:self];
    }
}

#pragma mark - Public Methods
- (void)setGrid1Title:(NSString *)title1 grid1ContentView:(UIView *)contentView1 grid2Title:(NSString *)title2 grid2ContentView:(UIView *)contentView2
{
    [_grid1ContentView removeFromSuperview];
    [_grid2ContentView removeFromSuperview];
    self.grid1ContentView = contentView1;
    self.grid2ContentView = contentView2;
    
    _grid1TitleLabel.text = title1;
    _grid2TitleLabel.text = title2;

    [contentView1 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [_grid1Container addSubview:_grid1ContentView];
    [_grid2Container addSubview:_grid2ContentView];

    NSDictionary *views = NSDictionaryOfVariableBindings(_grid1ContentView, _grid2ContentView);
    if (_grid1ContentView) {
        [_grid1Container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_grid1ContentView]-0-|" options:0 metrics:nil views:views]];
        [_grid1Container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_grid1ContentView]-0-|" options:0 metrics:nil views:views]];
    }
    if (_grid2ContentView) {
        [_grid2Container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_grid2ContentView]-0-|" options:0 metrics:nil views:views]];
        [_grid2Container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_grid2ContentView]-0-|" options:0 metrics:nil views:views]];
    }


    
}

@end

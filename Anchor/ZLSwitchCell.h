//
//  ZLSwitchCell.h
//  ReliefLink
//
//  Created by Eric Li on 8/3/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZLSwitchCell;

@protocol ZLSwitchCellDelegate <NSObject>
- (void)ZLSwitchCell:(ZLSwitchCell *)cell switchValueDidChange:(BOOL)value;
@end

@interface ZLSwitchCell : UITableViewCell
@property (nonatomic, assign) id<ZLSwitchCellDelegate> delegate;

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UISwitch *toggleSwitch;
@property (retain, nonatomic) IBOutlet UIView *customSeparatorViewTop;

@end

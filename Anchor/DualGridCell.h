//
//  DualGridCell.h
//  Anchor
//
//  Created by Eric Li on 7/18/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DualGridCell;
@protocol DualGridCellDelegate <NSObject>
- (void)DualGridCellDidClickButton1:(DualGridCell *)cell;
- (void)DualGridCellDidClickButton2:(DualGridCell *)cell;
@end

@interface DualGridCell : UITableViewCell
@property (nonatomic, assign) id<DualGridCellDelegate> delegate;
@property (nonatomic, retain) NSString *grid1Identifier, *grid2Identifier;

- (void)setGrid1Title:(NSString *)title1 grid1ContentView:(UIView *)contentView1 grid2Title:(NSString *)title2 grid2ContentView:(UIView *)contentView2;
@end

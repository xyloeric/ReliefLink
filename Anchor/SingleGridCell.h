//
//  SingleGridCell.h
//  Anchor
//
//  Created by Eric Li on 7/18/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SingleGridCell;

@protocol SingleGridCellDelegate <NSObject>
- (void)SingleGridCellDidClickButton:(SingleGridCell *)cell;
@end

@interface SingleGridCell : UITableViewCell
@property (nonatomic, assign) id<SingleGridCellDelegate> delegate;
@property (nonatomic, retain) NSString *gridIdentifier;

- (void)setTitle:(NSString *)title contentView:(UIView *)contentView;
@end

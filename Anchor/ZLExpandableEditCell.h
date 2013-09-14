//
//  ANExpandableEditCell.h
//  ReliefLink
//
//  Created by Eric Li on 8/3/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLTextView.h"
@class ZLExpandableEditCell;

@protocol ZLExpandableEditCellDelegate <NSObject>
- (void)ZLExpandableEditCellDidStartEditing:(ZLExpandableEditCell *)cell;
- (void)ZLExpandableEditCellDidEndEditing:(ZLExpandableEditCell *)cell;
- (void)ZLExpandableEditCellRequestEndEditing:(ZLExpandableEditCell *)cell;
@end

@interface ZLExpandableEditCell : UITableViewCell
@property (nonatomic, assign) id<ZLExpandableEditCellDelegate> delegate;
@property (retain, nonatomic) IBOutlet ZLTextView *textField;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIView *customSeparatorViewTop;
@property (retain, nonatomic) IBOutlet UIView *customSeparatorView;

@property (nonatomic, retain) NSManagedObject *managedObject;
@property (nonatomic, retain) NSString *editingKey;
@end

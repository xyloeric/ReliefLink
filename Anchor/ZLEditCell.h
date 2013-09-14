//
//  ZLEditCell.h
//  Anchor
//
//  Created by Eric Li on 7/26/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "ZLTextField.h"

@class ZLEditCell;

@protocol ZLEditCellDelegate <NSObject>
- (void)ZLEditCellDidStartEditing:(ZLEditCell *)cell;
- (void)ZLEditCellDidPressReturn:(ZLEditCell *)cell;
- (void)ZLEditCellRequestEndEditing:(ZLEditCell *)cell;
@end

@interface ZLEditCell : UITableViewCell
@property (nonatomic, assign) id<ZLEditCellDelegate> delegate;
@property (retain, nonatomic) IBOutlet ZLTextField *textField;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIView *customSeparatorViewTop;
@property (retain, nonatomic) IBOutlet UIView *customSeparatorView;

@property (nonatomic, retain) NSManagedObject *managedObject;
@property (nonatomic, retain) NSString *editingKey;

@end

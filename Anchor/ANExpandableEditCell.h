//
//  ANExpandableEditCell.h
//  ReliefLink
//
//  Created by Eric Li on 8/3/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANExpandableEditCell : UITableViewCell
//@property (nonatomic, assign) id<ZLEditCellDelegate> delegate;
//@property (retain, nonatomic) IBOutlet ZLTextField *textField;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIView *customSeparatorViewTop;
@property (retain, nonatomic) IBOutlet UIView *customSeparatorView;

@end

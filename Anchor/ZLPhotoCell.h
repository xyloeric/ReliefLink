//
//  ZLPhotoCell.h
//  Anchor
//
//  Created by Eric Li on 7/27/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZLPhotoCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIImageView *profileImageView;
@property (retain, nonatomic) IBOutlet UIView *customSeparatorViewTop;

@end

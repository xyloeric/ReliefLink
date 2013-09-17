//
//  DRTableSectionHeaderView.h
//  DRKit
//
//  Created by Eric Li on 2/19/13.
//
//

#import <UIKit/UIKit.h>

#define kLabelOffset (10.0)

@interface ZLTableSectionHeaderView : UIView
@property (nonatomic, retain) UILabel *label;

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor shadowColor:(UIColor *)shadowColor textColor:(UIColor *)textColor textAlignment:(NSTextAlignment)textAlignment;
- (id)initWithFrame:(CGRect)frame gradient:(NSArray *)gradient shadowColor:(UIColor *)shadowColor textColor:(UIColor *)textColor textAlignment:(NSTextAlignment)textAlignment;
- (id)initDarkStyleWithFrame:(CGRect)frame textAlignment:(NSTextAlignment)textAlignment;
- (id)initLightStyleWithFrame:(CGRect)frame textAlignment:(NSTextAlignment)textAlignment;

- (void)setText:(NSString *)text;

@end

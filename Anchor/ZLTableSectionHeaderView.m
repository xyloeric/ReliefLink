    //
    //  DRTableSectionHeaderView.m
    //  DRKit
    //
    //  Created by Eric Li on 2/19/13.
    //
    //

#import <QuartzCore/QuartzCore.h>

#import "ZLTableSectionHeaderView.h"
#import "ANCommons.h"

@interface ZLTableSectionHeaderView ()
@end

@implementation ZLTableSectionHeaderView

+(Class) layerClass {
    return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor shadowColor:(UIColor *)shadowColor textColor:(UIColor *)textColor textAlignment:(UITextAlignment)textAlignment {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = self.frame.size.width - kLabelOffset/2.0;
        _label = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.origin.x+kLabelOffset, self.frame.origin.y-1, width, self.frame.size.height)];
        _label.textColor = textColor;
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
        _label.shadowColor = shadowColor;
        _label.shadowOffset = CGSizeMake(0, 1);
        _label.textAlignment = textAlignment;
        _label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        if (backgroundColor) self.backgroundColor = backgroundColor;
        [self addSubview:_label];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)];
        view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.07];
        [self addSubview:view];
        [view release];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame gradient:(NSArray *)gradient shadowColor:(UIColor *)shadowColor textColor:(UIColor *)textColor textAlignment:(UITextAlignment)textAlignment {
    self = [self initWithFrame:frame backgroundColor:nil shadowColor:shadowColor textColor:textColor textAlignment:textAlignment];
    if (self) {
        [(CAGradientLayer *)self.layer setColors:gradient];
    }
    return self;
}

- (id)initDarkStyleWithFrame:(CGRect)frame textAlignment:(UITextAlignment)textAlignment {
    NSArray *gradient = @[(id)[[UIColor colorWithRed:CG(140) green:CG(140) blue:CG(140) alpha:1.0] CGColor],
                          (id)[[UIColor colorWithRed:CG(120) green:CG(120) blue:CG(120) alpha:1.0] CGColor]];
    return [self initWithFrame:frame
                      gradient:gradient
                   shadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.35]
                     textColor:[UIColor colorWithRed:CG(255) green:CG(255) blue:CG(255) alpha:1.0]
                 textAlignment:textAlignment];
}

- (id)initLightStyleWithFrame:(CGRect)frame textAlignment:(UITextAlignment)textAlignment {
    NSArray *gradient = @[(id)[[UIColor colorWithRed:CG(230) green:CG(230) blue:CG(230) alpha:1.0] CGColor],
                          (id)[[UIColor colorWithRed:CG(210) green:CG(210) blue:CG(210) alpha:1.0] CGColor]];
    return [self initWithFrame:frame
                      gradient:gradient
                   shadowColor:[UIColor colorWithRed:CG(255) green:CG(255) blue:CG(255) alpha:0.35]
                     textColor:[UIColor colorWithRed:CG(102) green:CG(102) blue:CG(102) alpha:1.0]
                 textAlignment:textAlignment];
}

- (void)dealloc {
    [_label release];
    [super dealloc];
}

- (void)setText:(NSString *)text {
    _label.text = text;
}


@end

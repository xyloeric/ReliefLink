//
//
//

#import "ZLTextField.h"
#import "ANCommons.h"


#define DEFAULT_BACKGROUND_IMAGE_NAME @"textfield_default_32x32.png"
#define RED_BACKGROUND_IMAGE_NAME @"textfield_error_32x32.png"
#define DARK_BACKGROUND_IMAGE_NAME @"textfield_lightgray_32x32.png"

#define kDefaultXInset (8.0)
#define kXInsetWithRightView (2.0)
#define kDefaultYInset (0.0)

@implementation ZLTextField {
    NSBundle *_bundle;
    NSUInteger _textFieldColor;
}

- (void)useDefaultInset {
    _xInset = kDefaultXInset;
    _yInset = kDefaultYInset;
}

- (void)configure {
    _bundle = [NSBundle mainBundle];
    [self useDefaultInset];
    _mode = kDRBaseTextFieldImageMode;
    _textFieldColor = kDRBaseTextFieldWhiteColor;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self != nil) {
	[self configure];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
	[self configure];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect superBounds = [super textRectForBounds:bounds];
    if (self.rightView) {
        return CGRectMake(self.xInset, bounds.origin.y + self.yInset, bounds.size.width - self.xInset - self.rightView.frame.size.width, bounds.size.height - 2 * self.yInset);
    }
    else {
        return CGRectInset(superBounds, self.xInset, self.yInset);
    }
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect superBounds = [super editingRectForBounds:bounds];
    if (self.rightView) {
        return CGRectMake(self.xInset, bounds.origin.y + self.yInset, bounds.size.width - self.xInset - self.rightView.frame.size.width, bounds.size.height - 2 * self.yInset);
    }
    else {
        return CGRectInset(superBounds, self.xInset, self.yInset);
    }
}

- (void)drawRect:(CGRect)rect {
    @autoreleasepool {
	if (_mode == kDRBaseTextFieldImageMode) {
	    NSString *imageName = DEFAULT_BACKGROUND_IMAGE_NAME;
	    if (_textFieldColor == kDRBaseTextFieldRedColor) {
		imageName = RED_BACKGROUND_IMAGE_NAME;
	    }
	    else if (_textFieldColor == kDRBaseTextFieldDarkColor) {
		imageName = DARK_BACKGROUND_IMAGE_NAME;
	    }
	    UIImage *tmpImage = [UIImage imageWithContentsOfFile:[[_bundle resourcePath] stringByAppendingPathComponent:imageName]];
	    UIImage *image = [tmpImage resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 5.0, 15.0, 5.0)];
	    [image drawInRect:[self bounds]];
	}
    }
}

- (void)setTextFieldColor:(DRBaseTextFieldColor)textFieldColor {
    _textFieldColor = textFieldColor;
    if (_mode == kDRBaseTextFieldCGMode) {
	self.backgroundColor = [self colorForTextFieldColor:_textFieldColor];
    }
    [self setNeedsDisplay];
}

- (DRBaseTextFieldColor)textFieldColor {
    return _textFieldColor;
}

#pragma mark - Private Methods

- (UIColor *)colorForTextFieldColor:(DRBaseTextFieldColor)textFieldColor {
    UIColor *color = [UIColor clearColor];
    switch (textFieldColor) {
    case kDRBaseTextFieldWhiteColor:
	color = [UIColor whiteColor];
    [self setValue:[UIColor colorWithRed:CG(179) green:CG(179) blue:CG(179) alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
	break;
    case kDRBaseTextFieldRedColor:
	color = [UIColor colorWithRed:CG(255) green:CG(235) blue:CG(235) alpha:1.0];
    [self setValue:[UIColor colorWithRed:CG(204) green:CG(90) blue:CG(90) alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
	break;
    case kDRBaseTextFieldClearColor:
	color = [UIColor clearColor];
	break;
    case kDRBaseTextFieldDarkColor:
	color = [UIColor darkGrayColor];
	break;
    }
    return color;
}

@end

//
//
//

#import <UIKit/UIKit.h>

typedef enum {
    kDRBaseTextFieldWhiteColor = 0,
    kDRBaseTextFieldRedColor,
    kDRBaseTextFieldClearColor,
    kDRBaseTextFieldDarkColor,
} DRBaseTextFieldColor;

typedef enum {
    kDRBaseTextFieldImageMode = 0,
    kDRBaseTextFieldCGMode,
} DRBaseTextFieldMode;
	
@interface ZLTextField : UITextField

@property (nonatomic, assign) DRBaseTextFieldColor textFieldColor;
@property (nonatomic, assign) DRBaseTextFieldMode mode;
@property (nonatomic) CGFloat xInset;
@property (nonatomic) CGFloat yInset;

- (void)useDefaultInset;
- (void)configure;

@end

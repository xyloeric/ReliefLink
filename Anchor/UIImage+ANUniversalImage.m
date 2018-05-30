//
//  UIImage+ANUniversalImage.m
//  Anchor
//
//  Created by Eric Li on 7/16/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "UIImage+ANUniversalImage.h"

#define kUniversalButtonImage @"button_universal_38x38a.png"

@implementation UIImage (ANUniversalImage)

+ (UIImage *)universalButtonImageWithInsets:(UIEdgeInsets)insets {
	return [[UIImage imageNamed:kUniversalButtonImage] resizableImageWithCapInsets:insets];
}

+ (UIImage *)universalButtonImage {
	UIEdgeInsets insets = UIEdgeInsetsMake(15.0, 8.0, 15.0, 8.0);
	return [self universalButtonImageWithInsets:insets];
}

@end

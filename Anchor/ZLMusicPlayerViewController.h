//
//  ZLMusicPlayerViewController.h
//  Anchor
//
//  Created by Eric Li on 7/28/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZLMusicPlayerViewController : UIViewController
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

- (id)initWithType:(NSInteger)exerciseType;

@end

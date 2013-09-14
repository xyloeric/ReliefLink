//
//  ZLCard.h
//  ZLCardViewController
//
//  Created by Eric Li on 1/22/13.
//  Copyright (c) 2013 Eric Li. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DRCardSideFront = 0,
    DRCardSideBack
} DRCardSide;
#define FlipOrientation(o) (1-(o))

@interface ZLCard : UIView
@property (nonatomic, retain) NSString *reuseIdentifier;
@property (nonatomic) BOOL mainViewVisible;
@property (nonatomic) DRCardSide orientation;
@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *accessoryView;
@property (nonatomic) BOOL shouldDecorateCard;

@property (nonatomic) NSInteger cardIndex;

@property (nonatomic) BOOL isCurledUp;

- (void) flipViews;
- (void) flipViewsWithDuration:(NSTimeInterval)duration andCompletionBlock:(void(^)(void))cBlock;
- (void) decorateCard;


- (void)setOrientation:(DRCardSide)orientation animated:(BOOL)animated;

@end

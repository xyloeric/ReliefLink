//
//  ZLCardView.h
//  ZLCardViewController
//
//  Created by Eric Li on 1/18/13.
//  Copyright (c) 2013 Eric Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZLCardView;
@class ZLCard;

@protocol ZLCardViewDataSource <NSObject>
- (NSInteger)numberOfCardsInCardView:(ZLCardView *)cardView;
- (ZLCard *)cardView:(ZLCardView *)cardView viewAtIndex:(NSInteger)index;
- (void)cardView:(ZLCardView *)cardView refreshCard:(ZLCard *)card;
@end

@protocol ZLCardViewDelegate <NSObject>
- (void)cardView:(ZLCardView *)cardView didSwipeDownAtIndex:(NSInteger)index;
- (void)cardView:(ZLCardView *)cardView didSwipeUpAtIndex:(NSInteger)index;
- (void)cardView:(ZLCardView *)cardView didTapElseWhereAtIndex:(NSInteger)index;
- (void)cardViewDidDragOverContentSize:(ZLCardView *)cardView;
- (void)cardView:(ZLCardView *)cardView didShowCardAtIndex:(NSInteger)index;
@end

@interface ZLCardView : UIView
@property (nonatomic, assign) id<ZLCardViewDataSource> cardDataSource;
@property (nonatomic, assign) id<ZLCardViewDelegate> cardDelegate;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *secondaryBottomView;
@property (nonatomic, strong) NSArray *passthroughViews;
@property (nonatomic, strong) UIView *placeholderView;
@property (nonatomic, readonly) NSInteger focusPage;

@property (nonatomic) BOOL isPrimaryBottomViewVisible;

@property (nonatomic) CGFloat horizontalOffset, cardHorizontalOffset, pageControlOffset, keyboardAvoidanceMovement;
@property (nonatomic) BOOL independendAccessoryView, shouldAvoidKeyboard;

@property (nonatomic) BOOL reverseInitialization;
@property (nonatomic) NSInteger numOfActiveCards;
@property (nonatomic) CGFloat verticalOffset;

- (void)registerTemplateNibNamed:(NSString *)nibNamed;

- (void)reloadData;
- (void)refreshData;
- (void)layoutCards;
- (ZLCard *)dequeueCardFromCardView:(ZLCardView *)cardView withReuseIdentifier:(NSString *)reuseIdentifer;

- (void)addCardAnimated:(BOOL)animated;
- (void)addCardFromDrag;
- (void)deleteCardAtIndex:(NSInteger)index animated:(BOOL)animated;

- (ZLCard *)getFocusCard;
- (NSInteger)getIndexForCard:(ZLCard *)card;
- (ZLCard *)getCardOfIndex:(NSInteger)index;

- (void)scrollToCardAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)scrollToCardAtIndex:(NSInteger)index animationTime:(CGFloat)animationTime;

- (void)swapBottomView:(id)sender;
- (void)stopSwappingBottomView;

- (void)showCardAtPage:(NSInteger)page forceRefresh:(BOOL)forceRefresh;
@end

//
//  ZLCardView.m
//  ZLCardViewController
//
//  Created by Eric Li on 1/18/13.
//  Copyright (c) 2013 Eric Li. All rights reserved.
//

#import "ZLCardView.h"
#import "ZLCard.h"
#import <QuartzCore/QuartzCore.h>

#define kHorizontalOffset 15.0
#define kCardHorizontalOffset 10.0
#define kVerticalOffset 0.0
#define PAGING_VIEWS 3
#define kExtraPageOffset 320.0
#define kDefaultKeyboardAvoidanceMovement 100.0
#define PAGE_CONTROL_DEFAULT_OFFSET 20

@interface ZLCardView () <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    CGFloat _previousHorizontalOffset;
    NSInteger _scrollDirection;
    CGPoint _scrollBeginCache;
}
@property (nonatomic, retain) NSMutableArray *activeCards;
@property (nonatomic, retain) UIScrollView *innerScrollView;
@property (nonatomic, retain) NSMutableSet *cardPool;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic) NSInteger numOfCards;
@property (nonatomic) NSInteger perspectivePage;
@property (nonatomic) NSRange activeCardsRange;
@property (nonatomic) NSInteger currentPageIndex;
@property (nonatomic, retain) ZLCard *templateView;
@property (nonatomic) BOOL mainViewVisible;
@property (nonatomic, retain) NSTimer *swapTimer;

@property (nonatomic, retain) UITapGestureRecognizer *tapRecognizer;
@end

@implementation ZLCardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _currentPageIndex = 0;
        
        _horizontalOffset = kHorizontalOffset;
        _cardHorizontalOffset = kCardHorizontalOffset;
        _pageControlOffset = PAGE_CONTROL_DEFAULT_OFFSET;
        _independendAccessoryView = NO;
        _shouldAvoidKeyboard = YES;
        _numOfActiveCards = 3;
        _reverseInitialization = NO;
        _verticalOffset = kVerticalOffset;
        _keyboardAvoidanceMovement = kDefaultKeyboardAvoidanceMovement;
        
        _innerScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _innerScrollView.delegate = self;
        _innerScrollView.backgroundColor = [UIColor clearColor];
        _innerScrollView.clipsToBounds = NO;
        _innerScrollView.pagingEnabled = YES;
        _innerScrollView.scrollEnabled = YES;
        _innerScrollView.showsHorizontalScrollIndicator = NO;
        _innerScrollView.showsVerticalScrollIndicator = NO;
        _innerScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_innerScrollView];

        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_blue_gradient.jpg"]];
        self.activeCards = [[[NSMutableArray alloc] init] autorelease];
        self.cardPool = [[[NSMutableSet alloc] init] autorelease];
        
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDownGestureRecognizer:)];
        [recognizer setDirection:UISwipeGestureRecognizerDirectionDown];
        [self addGestureRecognizer:recognizer];
        [recognizer release];
        
        recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUpGestureRecognizer:)];
        [recognizer setDirection:UISwipeGestureRecognizerDirectionUp];
        [self addGestureRecognizer:recognizer];
        [recognizer release];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        tapRecognizer.cancelsTouchesInView = NO;
        tapRecognizer.delegate = self;
//        tapRecognizer.delaysTouchesBegan = YES;
        [self addGestureRecognizer:tapRecognizer];
        self.tapRecognizer = tapRecognizer;
        [tapRecognizer release];
        
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 20, self.bounds.size.width, 15)];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [pageControl respondsToSelector:@selector(setPageIndicatorTintColor:)]) {
            pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
            pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        }
        pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        pageControl.userInteractionEnabled = NO;
        [self addSubview:pageControl];
        self.pageControl = pageControl;
        [pageControl release];
        
        [self initializeKeyboardNotificationObservers];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _currentPageIndex = 0;
        
        _horizontalOffset = kHorizontalOffset;
        _cardHorizontalOffset = kCardHorizontalOffset;
        _pageControlOffset = PAGE_CONTROL_DEFAULT_OFFSET;
        _independendAccessoryView = NO;
        _shouldAvoidKeyboard = YES;
        _numOfActiveCards = 3;
        _reverseInitialization = NO;
        _verticalOffset = kVerticalOffset;
        _keyboardAvoidanceMovement = kDefaultKeyboardAvoidanceMovement;

        _innerScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _innerScrollView.delegate = self;
        _innerScrollView.backgroundColor = [UIColor clearColor];
        _innerScrollView.clipsToBounds = NO;
        _innerScrollView.pagingEnabled = YES;
        _innerScrollView.scrollEnabled = YES;
        _innerScrollView.showsHorizontalScrollIndicator = NO;
        _innerScrollView.showsVerticalScrollIndicator = NO;
        _innerScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_innerScrollView];

        self.activeCards = [[[NSMutableArray alloc] init] autorelease];
        self.cardPool = [[[NSMutableSet alloc] init] autorelease];
        
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDownGestureRecognizer:)];
        [recognizer setDirection:UISwipeGestureRecognizerDirectionDown];
        [self addGestureRecognizer:recognizer];
        [recognizer release];
        
        recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUpGestureRecognizer:)];
        [recognizer setDirection:UISwipeGestureRecognizerDirectionUp];
        [self addGestureRecognizer:recognizer];
        [recognizer release];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        tapRecognizer.cancelsTouchesInView = NO;
        tapRecognizer.delegate = self;
//        tapRecognizer.delaysTouchesBegan = YES;
        [self addGestureRecognizer:tapRecognizer];
        self.tapRecognizer = tapRecognizer;
        [tapRecognizer release];
        
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 20, self.bounds.size.width, 15)];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [pageControl respondsToSelector:@selector(setPageIndicatorTintColor:)]) {
            pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
            pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        }
        pageControl.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        pageControl.userInteractionEnabled = NO;
        [self addSubview:pageControl];
        self.pageControl = pageControl;
        [pageControl release];
        
        [self initializeKeyboardNotificationObservers];

    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_activeCards release];
    [_cardPool release];
    [_pageControl release];
    [_innerScrollView release];
    [_templateView release];
    [_passthroughViews release];
    [_swapTimer release];
    [_tapRecognizer release];
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutCards];
}

- (void)showCardAtPage:(NSInteger)page forceRefresh:(BOOL)forceRefresh
{
    if (self.numOfCards > 0 && _placeholderView.superview) {
        [_placeholderView removeFromSuperview];
    }
    
    if (!_independendAccessoryView) {
        for (ZLCard *card in _activeCards) {
            if (card.orientation == DRCardSideBack) {
                [card flipViewsWithDuration:0.5 andCompletionBlock:^{
                    [card.accessoryView removeFromSuperview];
                    card.accessoryView = nil;
                }];
            }
        }
    }
    
    if (page != _focusPage || forceRefresh) {
        NSInteger minValue; NSInteger maxValue;
		NSInteger maxPage = _numOfCards - 1;
		NSInteger minPage = 0;
        
		if ((page < minPage) || (page > maxPage)) return;
        
		if (maxPage <= PAGING_VIEWS) // Few pages
		{
			minValue = minPage;
			maxValue = maxPage;
		}
		else // Handle more pages
		{
			minValue = (page - 1);
			maxValue = (page + 1);
            
			if (minValue < minPage)
            {minValue++; maxValue++;}
			else
				if (maxValue > maxPage)
                {minValue--; maxValue--;}
		}
        
        CGRect viewRect = CGRectZero;
        viewRect.size = _innerScrollView.bounds.size;
        
        NSMutableArray *newActiveCards = [NSMutableArray array];
        for (NSInteger number = minValue; number <= maxValue; number++){
            ZLCard *card = nil;
            if (number < _activeCardsRange.location || number >= _activeCardsRange.location + _activeCardsRange.length) {
                card = [_cardDataSource cardView:self viewAtIndex:number];
                
                card.frame = CGRectMake(self.innerScrollView.bounds.size.width * number + _cardHorizontalOffset, _verticalOffset, self.innerScrollView.bounds.size.width - 2*_cardHorizontalOffset, self.innerScrollView.bounds.size.height - 2*_verticalOffset);
                
                [card decorateCard];
                
                if (card.superview != self.innerScrollView) {
                    [self.innerScrollView addSubview:card];
                }
                
                card.hidden = NO;
            }
            else {
                card = [_activeCards objectAtIndex:number - _activeCardsRange.location];
                card.frame = CGRectMake(self.innerScrollView.bounds.size.width * number + _cardHorizontalOffset, _verticalOffset, self.innerScrollView.bounds.size.width - 2*_cardHorizontalOffset, self.innerScrollView.bounds.size.height - 2*_verticalOffset);
            }
            
            [newActiveCards addObject:card];
        }

        for (ZLCard *card in newActiveCards) {
            if (![_cardPool containsObject:card]) {
                [_cardPool addObject:card];
            }
        }
        for (ZLCard *card in _activeCards) {
            if (![newActiveCards containsObject:card]) {
                card.hidden = YES;
            }
        }
        
        self.activeCards = newActiveCards;
        
        self.activeCardsRange = NSMakeRange(minValue, maxValue-minValue + 1);
        
        _focusPage = page;
        
        [_cardDelegate cardView:self didShowCardAtIndex:_focusPage];
    }

    [self refreshPageControlForPage:_focusPage];
}

- (void)showCardAtPage:(NSInteger)page
{
    [self showCardAtPage:page forceRefresh:NO];
}

- (void)scrollToCardAtIndex:(NSInteger)index animated:(BOOL)animated
{
    if (index < _numOfCards) {        
        [_innerScrollView setContentOffset:CGPointMake(index * _innerScrollView.bounds.size.width, _innerScrollView.contentOffset.y) animated:animated];
    }
}

- (void)scrollToCardAtIndex:(NSInteger)index animationTime:(CGFloat)animationTime
{
    if (index < _numOfCards) {
        [UIView animateWithDuration:animationTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_innerScrollView setContentOffset:CGPointMake(index * _innerScrollView.bounds.size.width, _innerScrollView.contentOffset.y)];
        } completion:^(BOOL finished) {}];
    }
}

- (void)handleSwipeDownGestureRecognizer:(UISwipeGestureRecognizer *)recognizer
{
    [_cardDelegate cardView:self didSwipeDownAtIndex:_focusPage];
}

- (void)handleSwipeUpGestureRecognizer:(UISwipeGestureRecognizer *)recognizer
{
    [_cardDelegate cardView:self didSwipeUpAtIndex:_focusPage];
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:_innerScrollView];
    for (int i = 0; i < [_activeCards count]; i++) {
        ZLCard *card = [_activeCards objectAtIndex:i];
        
        if (CGRectContainsPoint(card.frame, location)) {
            [_cardDelegate cardView:self didTapElseWhereAtIndex:i + _activeCardsRange.location];
            return;
        }
    }
    
    [_cardDelegate cardView:self didTapElseWhereAtIndex:_focusPage];
    
}

- (void)refreshPageControlForPage:(NSInteger)page
{
    if ([_activeCards count] == 0) {
        self.pageControl.hidden = YES;
    }
    else {
        self.pageControl.hidden = NO;
    }
    
    self.pageControl.numberOfPages = self.numOfCards;
    self.pageControl.currentPage = page;
    
    CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:self.numOfCards];

    if (pageControlSize.width > 240) {
        self.pageControl.hidden = YES;
        self.innerScrollView.showsHorizontalScrollIndicator = YES;
    }
    else {
        self.pageControl.hidden = NO;
        self.innerScrollView.showsHorizontalScrollIndicator = NO;
    }
}

- (void)updateTemplateViewFrame
{
    if (_templateView) {
        self.templateView.frame = CGRectMake(self.numOfCards * self.innerScrollView.bounds.size.width + _cardHorizontalOffset, _verticalOffset, self.innerScrollView.bounds.size.width - 2*_cardHorizontalOffset, self.innerScrollView.bounds.size.height - 2*_verticalOffset);
        
        _templateView.layer.cornerRadius = 10.0;
        _templateView.layer.masksToBounds = YES;
        
        [self.innerScrollView addSubview:_templateView];
        [_templateView setAlpha:0.2];
    }
}

#pragma mark -
#pragma mark Custom Getter/Setter
- (void)setTopView:(UIView *)topView
{
    if (topView != _topView) {
        _topView = topView;
        
        topView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, 34.0);
        [self addSubview:topView];
        [self sendSubviewToBack:topView];
    }
}

- (void)setBottomView:(UIView *)bottomView
{
    if (bottomView != _bottomView) {
        _bottomView = bottomView;
        
        bottomView.frame = CGRectMake(self.bounds.origin.x, self.bounds.size.height - 44.0, self.bounds.size.width, 44.0);
        [self addSubview:bottomView];
        [self sendSubviewToBack:bottomView];
        
        self.isPrimaryBottomViewVisible = YES;
    }
}

- (void)setSecondaryBottomView:(UIView *)secondaryBottomView
{
    if (_secondaryBottomView != secondaryBottomView) {
        _secondaryBottomView = secondaryBottomView;
        
        secondaryBottomView.frame = CGRectMake(self.bounds.origin.x + self.bounds.size.width, self.bounds.size.height - 44.0, self.bounds.size.width, 44.0);
        [self addSubview:secondaryBottomView];
        [self sendSubviewToBack:secondaryBottomView];        
        
        self.swapTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(swapBottomView:) userInfo:nil repeats:NO];
    }
}

#pragma mark -
#pragma mark Public Methods
- (void)reloadData
{
    for (ZLCard *card in _activeCards) {
        [card removeFromSuperview];
    }
    [_activeCards removeAllObjects];
    [_cardPool removeAllObjects];
    _previousHorizontalOffset = 0.0;
    [_placeholderView removeFromSuperview];
    
    self.activeCardsRange = NSMakeRange(0, 0);
    if (_reverseInitialization) {
        _focusPage = _numOfCards - 1;
        
        self.numOfCards = [_cardDataSource numberOfCardsInCardView:self];
        NSInteger numOfActiveCards = _numOfCards > _numOfActiveCards ? _numOfActiveCards : _numOfCards;
        
        [self.innerScrollView setContentOffset:CGPointMake(0, 0)];
        CGFloat origin = _cardHorizontalOffset;
        for (int i = _numOfCards - numOfActiveCards; i < _numOfCards; i++) {
            ZLCard *card = [_cardDataSource cardView:self viewAtIndex:i];
            card.frame = CGRectMake(origin, _verticalOffset, self.innerScrollView.bounds.size.width - 2*_cardHorizontalOffset, self.innerScrollView.bounds.size.height - 2*_verticalOffset);
            [self.innerScrollView addSubview:card];
            [_activeCards addObject:card];
            
            if (![_cardPool containsObject:card]) {
                [_cardPool addObject:card];
            }
            
            origin += self.innerScrollView.frame.size.width;
        }
        
        self.activeCardsRange = NSMakeRange(_numOfCards - numOfActiveCards, numOfActiveCards);
        _focusPage = _numOfCards - 1;
    }
    else {
        _focusPage = 0;
        
        self.numOfCards = [_cardDataSource numberOfCardsInCardView:self];
        NSInteger numOfActiveCards = _numOfCards > _numOfActiveCards ? _numOfActiveCards : _numOfCards;
        
        [self.innerScrollView setContentOffset:CGPointMake(0, 0)];
        CGFloat origin = _cardHorizontalOffset;
        for (int i = 0; i < numOfActiveCards; i++) {
            ZLCard *card = [_cardDataSource cardView:self viewAtIndex:i];
            card.frame = CGRectMake(origin, _verticalOffset, self.innerScrollView.bounds.size.width - 2*_cardHorizontalOffset, self.innerScrollView.bounds.size.height - 2*_verticalOffset);
            [self.innerScrollView addSubview:card];
            [_activeCards addObject:card];
            
            if (![_cardPool containsObject:card]) {
                [_cardPool addObject:card];
            }
            
            origin += self.innerScrollView.frame.size.width;
        }
        
        self.activeCardsRange = NSMakeRange(0, numOfActiveCards);
        _focusPage = 0;
    }

    
    if (self.numOfCards == 0) {
        if (_placeholderView) {
            [self addSubview:_placeholderView];
        }
    }
    
    [self refreshPageControlForPage:0];
    [self updateTemplateViewFrame];    
}

- (void)refreshData
{
    for (ZLCard *card in _activeCards) {
        [_cardDataSource cardView:self refreshCard:card];
    }
}

- (void)layoutCards
{    
    self.innerScrollView.frame = CGRectMake(self.bounds.origin.x + _horizontalOffset, self.bounds.origin.y + self.topView.frame.size.height, self.bounds.size.width - 2*_horizontalOffset, self.bounds.size.height - self.topView.frame.size.height - self.bottomView.frame.size.height);
    
    if (_templateView) {
        self.innerScrollView.contentSize = CGSizeMake((_numOfCards + 1) * self.innerScrollView.frame.size.width, self.innerScrollView.frame.size.height);
    }
    else {
        self.innerScrollView.contentSize = CGSizeMake(_numOfCards * self.innerScrollView.frame.size.width, self.innerScrollView.frame.size.height);
    }

    
    for (ZLCard *card in _activeCards) {
        NSInteger cardIndex = [self getIndexForCard:card];
        card.frame = CGRectIntegral(CGRectMake(self.innerScrollView.bounds.size.width * cardIndex + _cardHorizontalOffset, _verticalOffset, self.innerScrollView.bounds.size.width - 2*_cardHorizontalOffset, self.innerScrollView.bounds.size.height - 2*_verticalOffset));
        
        [card decorateCard];
    }
    
    [_innerScrollView setContentOffset:CGPointMake(_focusPage * _innerScrollView.bounds.size.width, _innerScrollView.contentOffset.y) animated:NO];
    
    _pageControl.frame = CGRectMake(0, self.innerScrollView.frame.origin.y + self.innerScrollView.frame.size.height - _pageControlOffset, self.bounds.size.width, 15);
    
    _placeholderView.frame = CGRectMake(self.innerScrollView.frame.origin.x, self.innerScrollView.frame.origin.y + _verticalOffset, self.innerScrollView.bounds.size.width, self.innerScrollView.bounds.size.height - 2*_verticalOffset);
    _placeholderView.layer.cornerRadius = 10.0;
    _placeholderView.layer.masksToBounds = YES;
    
    [self updateTemplateViewFrame];
}



- (ZLCard *)dequeueCardFromCardView:(ZLCardView *)cardView withReuseIdentifier:(NSString *)reuseIdentifer
{
    NSSet *cardWithIdentifier = [_cardPool filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"reuseIdentifier == %@", reuseIdentifer]];
    ZLCard *reusableCard = nil;
    for (ZLCard * card in cardWithIdentifier) {
        if (![_activeCards containsObject:card]) {
            [_cardPool removeObject:card];
            reusableCard = [[card retain] autorelease];
            break;
        }
    }
    return reusableCard;
}

- (void)deleteCardAtIndex:(NSInteger)index animated:(BOOL)animated
{
    CGFloat duration = 0.5;
    
    if (index == _focusPage && animated) {
        ZLCard *targetCard = nil;
        ZLCard *animateCard = nil;
        CGRect animatedCardTargetFrame = CGRectZero;
        for (ZLCard *card in _activeCards) {
            if (card.frame.origin.x == self.innerScrollView.frame.size.width * _focusPage + _cardHorizontalOffset) {
                targetCard = card;
                break;
            }
        }
        
        if (targetCard == [_activeCards objectAtIndex:0]) {
            
            if ([_activeCards count] > 1) {
                animateCard = [_activeCards objectAtIndex:1];
            }
            
            if (animateCard) {
                animatedCardTargetFrame = CGRectOffset(animateCard.frame, -self.innerScrollView.frame.size.width, 0);
            }
        }
        else if (targetCard == [_activeCards lastObject]) {
            if ([_activeCards count] > 1) {
                animateCard = [_activeCards objectAtIndex:[_activeCards indexOfObject:targetCard] - 1];
            }
            
            if (animateCard) {
                animatedCardTargetFrame = CGRectOffset(animateCard.frame, self.innerScrollView.frame.size.width, 0);
            }
        }
        else {
            if ([_activeCards count] > 1) {
                animateCard = [_activeCards objectAtIndex:[_activeCards indexOfObject:targetCard] + 1];
            }
            
            if (animateCard) {
                animatedCardTargetFrame = CGRectOffset(animateCard.frame, -self.innerScrollView.frame.size.width, 0);
            }
        }
        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
            targetCard.frame = CGRectOffset(targetCard.frame, 0, self.innerScrollView.frame.size.height);
            targetCard.alpha = 0.0;
            if (animateCard) {
                animateCard.frame = animatedCardTargetFrame;
            }
        } completion:^(BOOL finished) {
            targetCard.alpha = 1.0;
            self.numOfCards = [_cardDataSource numberOfCardsInCardView:self];
            
            if (_numOfCards == 0) {
                for (ZLCard *card in _activeCards) {
                    [card removeFromSuperview];
                }
                
                [_activeCards removeAllObjects];
                self.activeCardsRange = NSMakeRange(0, 0);
                
                if (_placeholderView) {
                    [self addSubview:_placeholderView];
                }
                
                [self refreshPageControlForPage:_focusPage];
            }
            else {
                [self.innerScrollView setContentSize:CGSizeMake(self.numOfCards * self.innerScrollView.frame.size.width + kExtraPageOffset, self.innerScrollView.frame.size.height)];
                if (_focusPage == self.numOfCards) {
                    [self showCardAtPage:_focusPage-1 forceRefresh:YES];
                    [self.innerScrollView setContentOffset:CGPointMake((self.numOfCards - 1) * self.innerScrollView.frame.size.width, 0) animated:NO];
                    
                    [self refreshPageControlForPage:_focusPage];
                }
                else {
                    [self showCardAtPage:_focusPage forceRefresh:YES];
                }
            }
            
            if (_focusPage - _activeCardsRange.location < [_activeCards count]) {
                ZLCard *focuscard = [_activeCards objectAtIndex:_focusPage - _activeCardsRange.location];
                [_cardDataSource cardView:self refreshCard:focuscard];
            }
            
            [self updateTemplateViewFrame];
            
        }];
        
    }
    else {
        self.numOfCards = [_cardDataSource numberOfCardsInCardView:self];
        
        if (_numOfCards == 0) {
            for (ZLCard *card in _activeCards) {
                [card removeFromSuperview];
            }
            
            if (_placeholderView) {
                [self addSubview:_placeholderView];
            }
            
            [self refreshPageControlForPage:_focusPage];
        }
        else {
            [self.innerScrollView setContentSize:CGSizeMake(self.numOfCards * self.innerScrollView.frame.size.width + kExtraPageOffset, self.innerScrollView.frame.size.height)];
            [self showCardAtPage:_focusPage forceRefresh:YES];
            
            [self refreshPageControlForPage:_focusPage];
        }
        
        ZLCard *focuscard = [_activeCards objectAtIndex:_focusPage - _activeCardsRange.location];
        [_cardDataSource cardView:self refreshCard:focuscard];
        
        [self updateTemplateViewFrame];
        
    }
    
}

- (void)addCardAnimated:(BOOL)animated
{
    self.numOfCards = [_cardDataSource numberOfCardsInCardView:self];
    [self showCardAtPage:_focusPage forceRefresh:YES];
    [self.innerScrollView setContentSize:CGSizeMake(self.numOfCards * self.innerScrollView.frame.size.width + kExtraPageOffset, self.innerScrollView.frame.size.height)];
    [self.innerScrollView setContentOffset:CGPointMake((self.numOfCards - 1) * self.innerScrollView.frame.size.width, 0) animated:animated];

    [self updateTemplateViewFrame];
}

- (void)addCardFromDrag
{
    self.numOfCards = [_cardDataSource numberOfCardsInCardView:self];
    [self showCardAtPage:_focusPage forceRefresh:YES];
    [self.innerScrollView setContentSize:CGSizeMake(self.numOfCards * self.innerScrollView.frame.size.width + kExtraPageOffset, self.innerScrollView.frame.size.height)];
    [self updateTemplateViewFrame];
}

- (void)registerTemplateNibNamed:(NSString *)nibNamed
{    
    self.templateView = [[[NSBundle mainBundle] loadNibNamed:nibNamed owner:nil options:nil] objectAtIndex:0];
}

- (ZLCard *)getCardAtPage:(NSInteger)page
{
    if (page >= self.activeCardsRange.location && page < self.activeCardsRange.location + self.activeCardsRange.length) {
        return [_activeCards objectAtIndex:page - self.activeCardsRange.location];
    }
    
    return nil;
}

- (ZLCard *)getFocusCard
{
    return [self getCardAtPage:_focusPage];
}

- (NSInteger)getIndexForCard:(ZLCard *)card
{
    if ([_activeCards containsObject:card]) {
        NSInteger index = [_activeCards indexOfObject:card];
        return self.activeCardsRange.location + index;
    }
    else {
        return -1;
    }
}

- (ZLCard *)getCardOfIndex:(NSInteger)index
{
    if (index >= self.activeCardsRange.location && index < self.activeCardsRange.location + self.activeCardsRange.length) {
        return [_activeCards objectAtIndex:index - self.activeCardsRange.location];
    }
    
    return nil;
}

#pragma mark -
#pragma mark Responder Customization

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *testView = [super hitTest:point withEvent:event];
    if (testView == self || testView == _topView || [_passthroughViews containsObject:testView]) {
        ZLCard *currentCard = [self getCardAtPage:_focusPage];
        if (currentCard && currentCard.frame.origin.y < 0) {
            return [currentCard hitTest:[self convertPoint:point toView:currentCard] withEvent:event];
        }
    }
    
    CGRect scrollLeftRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y + self.topView.frame.size.height, _horizontalOffset, self.bounds.size.height - self.topView.frame.size.height - self.bottomView.frame.size.height);
    CGRect scrollRightRect = CGRectMake(self.bounds.size.width - _horizontalOffset, self.bounds.origin.y + self.topView.frame.size.height, _horizontalOffset, self.bounds.size.height - self.topView.frame.size.height - self.bottomView.frame.size.height);
    
    if (CGRectContainsPoint(scrollLeftRect, point) || CGRectContainsPoint(scrollRightRect, point)) {
        return _innerScrollView;
    }
    
    return testView;
}

#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.bounds.size.width;
    int page = floorf((scrollView.contentOffset.x - pageWidth / 2.0) / pageWidth) + 1;
    [self showCardAtPage:page];
    
    if (page > self.numOfCards - 1 && (scrollView.contentOffset.x - _scrollBeginCache.x) > 0) {
        [_cardDelegate cardViewDidDragOverContentSize:self];
    }
    
    if (scrollView.contentOffset.x / pageWidth > self.numOfCards - 1) {
        [self.templateView setAlpha:(scrollView.contentOffset.x / pageWidth - _focusPage) * 2 + 0.2];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    for (ZLCard *card in _activeCards) {
        [_cardDataSource cardView:self refreshCard:card];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _scrollBeginCache = scrollView.contentOffset;
    [self endEditing:YES];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{

}

#pragma mark -
#pragma mark Keyboard Notification Handlers
- (void)handleKeyboardDidShowNotification:(NSNotification *)notification
{
    if (_shouldAvoidKeyboard) {
        ZLCard *targetCard = [self getCardAtPage:_focusPage];
        [UIView animateWithDuration:0.3 animations:^{
            targetCard.frame = CGRectMake(self.innerScrollView.bounds.size.width * _focusPage + _cardHorizontalOffset, _verticalOffset - _keyboardAvoidanceMovement, self.innerScrollView.bounds.size.width - 2*_cardHorizontalOffset, self.innerScrollView.bounds.size.height - 2*_verticalOffset);
        }];
    }
}

- (void)handleKeyboardWillHideNotification:(NSNotification *)notification
{
    if (_shouldAvoidKeyboard) {
        ZLCard *targetCard = [self getCardAtPage:_focusPage];
        [UIView animateWithDuration:0.3 animations:^{
            targetCard.frame = CGRectMake(self.innerScrollView.bounds.size.width * _focusPage + _cardHorizontalOffset, _verticalOffset, self.innerScrollView.bounds.size.width - 2*_cardHorizontalOffset, self.innerScrollView.bounds.size.height - 2*_verticalOffset);
        }];
    }
}


- (void)initializeKeyboardNotificationObservers
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardDidShowNotification:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark -
#pragma mark Transit bottom view

- (void)swapBottomView:(id)sender
{
    [self stopSwappingBottomView];
    
    if (_bottomView && _secondaryBottomView) {
        if (_bottomView.frame.origin.x == 0) {
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                _bottomView.frame = CGRectMake(self.bounds.origin.x - self.bounds.size.width, self.bounds.size.height - 44.0, self.bounds.size.width, 44.0);
                _secondaryBottomView.frame = CGRectMake(self.bounds.origin.x, self.bounds.size.height - 44.0, self.bounds.size.width, 44.0);
            } completion:^(BOOL finished) {
                self.isPrimaryBottomViewVisible = NO;
                if ([sender isKindOfClass:[NSTimer class]]) {
                    self.swapTimer = [NSTimer scheduledTimerWithTimeInterval:8.0 target:self selector:@selector(swapBottomView:) userInfo:nil repeats:NO];
                }
            }];
        }
        else {
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                _bottomView.frame = CGRectMake(self.bounds.origin.x, self.bounds.size.height - 44.0, self.bounds.size.width, 44.0);
                _secondaryBottomView.frame = CGRectMake(self.bounds.origin.x + self.bounds.size.width, self.bounds.size.height - 44.0, self.bounds.size.width, 44.0);
            } completion:^(BOOL finished) {
                self.isPrimaryBottomViewVisible = YES;
                if ([sender isKindOfClass:[NSTimer class]]) {
                    self.swapTimer = [NSTimer scheduledTimerWithTimeInterval:8.0 target:self selector:@selector(swapBottomView:) userInfo:nil repeats:NO];
                }
            }];
        }
    }
}

- (void)stopSwappingBottomView
{
    if (self.swapTimer) {
        [self.swapTimer invalidate];
        self.swapTimer = nil;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([[touch view] isKindOfClass:[UIButton class]]) {
        return NO;
    }
    
    if ([touch view] != self) {
        for (id recognizer in [[touch view] gestureRecognizers]) {
            if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
                return NO;
            }
        }
    }

    return YES;
}

@end

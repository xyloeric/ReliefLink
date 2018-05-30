//
//  DROverviewLineGraph.m
//  ZLCommonLibrary
//
//  Created by Eric Li on 3/19/13.
//  Copyright (c) 2013 Eric Li. All rights reserved.
//

#import "ZLOverviewLineGraph.h"
#import <QuartzCore/QuartzCore.h>
#import "ANCommons.h"

typedef enum {
    kInteractionTypeNone,
    kInteractionTypeDragSelectionBox,
    kInteractionTypeDragLeftHandle,
    kInteractionTypeDragRightHandle,
}OverviewLineInteractionType;

@interface OverviewLineSelectionBoxView : UIView
@property CGRect leftSelectionRect, rightSelectionRect, leftHandleRect, rightHandleRect;
@end

@implementation OverviewLineSelectionBoxView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    DrawSelectionBox(_leftSelectionRect);
    DrawSelectionBox(_rightSelectionRect);
//    DrawLeftHandle(_leftHandleRect);
//    DrawRightHandle(_rightHandleRect);
}

void DrawSelectionBox(CGRect box)
{
    UIColor* color1 = [UIColor colorWithRed:CG(175) green:CG(175) blue:CG(175) alpha:.8];
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMaxX(box), CGRectGetMinY(box))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(box), CGRectGetMaxY(box))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(box), CGRectGetMaxY(box))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(box), CGRectGetMinY(box))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(box), CGRectGetMinY(box))];
    [color1 setFill];
    [bezierPath fill];
//    [color0 setStroke];
//    bezierPath.lineWidth = kOverviewLineBoarderWidth;
//    [bezierPath stroke];
}

void DrawHandleDateLabel(CGContextRef context, CGRect contextRect, CGRect box, NSString *text, int length)
{
    CGFloat w, h;
    w = contextRect.size.width;
    h = contextRect.size.height;
    
    UIColor* color0 = [UIColor colorWithRed:CG(0) green:CG(0) blue:CG(0) alpha:0.5];
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMaxX(box), CGRectGetMinY(box))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(box), CGRectGetMaxY(box))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(box), CGRectGetMaxY(box))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(box), CGRectGetMinY(box))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(box), CGRectGetMinY(box))];
    [color0 setFill];
    [bezierPath fill];
    
    CGSize textSize = [text sizeWithFont:[UIFont fontWithName:@"Verdana" size:10.0]];
    CGFloat textOriginX = (box.size.width - textSize.width) / 2.0;
    CGFloat textOriginY = box.origin.y + (box.size.height - textSize.height) / 2.0;
    
    CGContextSelectFont (context, "Verdana", 10, kCGEncodingMacRoman);
    CGContextSetCharacterSpacing (context, 1);
    CGContextSetTextDrawingMode (context, kCGTextFillStroke);
    CGAffineTransform flipTransform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0.f, contextRect.size.height),
                                                              CGAffineTransformMakeScale(1.f, -1.f));
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextSetTextMatrix (context, flipTransform);
    
    CGContextShowTextAtPoint (context, textOriginX, textOriginY, [text UTF8String], length);
}


@end


@interface ZLOverviewLineGraph ()
{
    OverviewLineInteractionType _interactionType;
    
    CGRect _leftSelectionRect;
    CGRect _rightSelectionRect;
    CGRect _leftHandleRect;
    CGRect _rightHandleRect;
    CGRect _leftHandleDateLabelRect;
    CGRect _rightHandleDateLabelRect;
    
    CGPoint _previousLocation;
    
    CGFloat _selectionRectXRatioCache, _selectionRectWidthRatioCache;
    
    int _dataCount;
    
}
@property (nonatomic, retain) NSArray *originalData;
@property (nonatomic, retain) NSArray *drawingSettings;
@property (nonatomic, retain) NSArray *normalizedData;
@property (nonatomic, retain) NSArray *validData;

@property (nonatomic, retain) NSMutableArray *drawingPaths;

@property (nonatomic) CGRect selectionRect;

@property (nonatomic) double maximumValue, minimumValue;
@property (nonatomic) double startTimeInterval, endTimeInterval;
@property (nonatomic, retain) NSString *leftHandleDateText, *rightHandleDateText;
@property (nonatomic, retain) UIView *leftHandleDateLabel, *rightHandleDateLabel;

@property (nonatomic, retain) NSArray *graphLayers;
@property (nonatomic, retain) OverviewLineSelectionBoxView *selectionBoxView;

@property (nonatomic, copy) NSDate *availableStartDate, *availableEndDate;
@property (nonatomic, copy) NSDate *hardStartDate, *hardEndDate;
@end

@implementation ZLOverviewLineGraph
@synthesize selectionRect = _selectionRect;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _interactionType = kInteractionTypeNone;
        _leftSelectionRect = CGRectZero;
        _rightSelectionRect = CGRectZero;
        _leftHandleRect = CGRectZero;
        _rightHandleRect = CGRectZero;
        _leftHandleDateLabelRect = CGRectZero;
        _rightHandleDateLabelRect = CGRectZero;
        _selectionRect = CGRectNull;
        
        self.autoresizesSubviews = YES;
        _drawingPaths = [[NSMutableArray alloc] init];
        _selectionBoxView = [[OverviewLineSelectionBoxView alloc] initWithFrame:self.bounds];
        _selectionBoxView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_selectionBoxView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _interactionType = kInteractionTypeNone;
        _leftSelectionRect = CGRectZero;
        _rightSelectionRect = CGRectZero;
        _leftHandleRect = CGRectZero;
        _rightHandleRect = CGRectZero;
        _leftHandleDateLabelRect = CGRectZero;
        _rightHandleDateLabelRect = CGRectZero;
        _selectionRect = CGRectNull;

        self.autoresizesSubviews = YES;
        _drawingPaths = [[NSMutableArray alloc] init];
        _selectionBoxView = [[OverviewLineSelectionBoxView alloc] initWithFrame:self.bounds];
        _selectionBoxView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_selectionBoxView];
    }
    return self;
}

- (void)dealloc
{
    [_originalData release];
    [_drawingSettings release];
    [_normalizedData release];
    [_validData release];
    
    [_drawingPaths release];
    
    [_leftHandleDateText release];
    [_rightHandleDateText release];
    [_leftHandleDateLabel release];
    [_rightHandleDateLabel release];
    
    [_graphLayers release];
    [_selectionBoxView release];
    
    [_availableStartDate release];
    [_availableEndDate release];
    [_hardStartDate release];
    [_hardEndDate release];
    [super dealloc];
}

#pragma mark - Custom Setter/Getter
- (void)setSelectionRect:(CGRect)selectionRect
{
    _selectionRect = selectionRect;
    
    _selectionRectXRatioCache = (_selectionRect.origin.x - kOverviewLineLeftPadding) / (self.bounds.size.width - kOverviewLineLeftPadding - kOverviewLineRightPadding);
    _selectionRectWidthRatioCache = _selectionRect.size.width / (self.bounds.size.width - kOverviewLineLeftPadding - kOverviewLineRightPadding);
    
    _leftSelectionRect = CGRectMake(0.0, 0.0, _selectionRect.origin.x, _selectionRect.size.height);
    _rightSelectionRect = CGRectMake(_leftSelectionRect.size.width + _selectionRect.size.width, 0.0, self.bounds.size.width - _selectionRect.size.width - _leftSelectionRect.size.width, self.bounds.size.height);
    _leftHandleRect = CGRectMake(_selectionRect.origin.x, 0.0, 36.0, 36.0);
    _rightHandleRect = CGRectMake(_selectionRect.origin.x + _selectionRect.size.width - 36.0, self.bounds.size.height - 36.0, 36.0, 36.0);
    
    
    double leftTimeInterval = (_selectionRect.origin.x - kOverviewLineLeftPadding) * ((_endTimeInterval - _startTimeInterval) / (self.bounds.size.width - kOverviewLineLeftPadding - kOverviewLineRightPadding)) + _startTimeInterval;
    double rightTimeInterval = (_leftSelectionRect.size.width + _selectionRect.size.width - kOverviewLineLeftPadding) * ((_endTimeInterval - _startTimeInterval) / (self.bounds.size.width - kOverviewLineLeftPadding - kOverviewLineRightPadding)) + _startTimeInterval;
    
    NSDate *leftTime = [NSDate dateWithTimeIntervalSince1970:leftTimeInterval];
    NSDate *rightTime = [NSDate dateWithTimeIntervalSince1970:rightTimeInterval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    self.leftHandleDateText = [formatter stringFromDate:leftTime];
    self.rightHandleDateText = [formatter stringFromDate:rightTime];
    [formatter release];
    
    UIFont *labelFont = [UIFont fontWithName:@"Verdana" size:10];
    
    CGFloat leftLabelWidth = [_leftHandleDateText sizeWithFont:labelFont].width + 5.0;
    CGFloat rightLabelWidth = [_rightHandleDateText sizeWithFont:labelFont].width + 5.0;
    CGFloat leftLabelViewWidth = leftLabelWidth + 36;
    CGFloat rightLabelViewWidth = rightLabelWidth + 36;
    
    if (_selectionRect.origin.x > leftLabelViewWidth + 5.0) {
        _leftHandleDateLabelRect = CGRectMake(_selectionRect.origin.x - leftLabelViewWidth - 5.0, self.bounds.size.height - 26.0, leftLabelViewWidth, 24.0);
    }
    else {
        _leftHandleDateLabelRect = CGRectMake(_selectionRect.origin.x + 5.0, self.bounds.size.height - 26.0, leftLabelViewWidth, 24.0);;
    }
    
    if (self.bounds.size.width - _selectionRect.size.width - _leftSelectionRect.size.width > rightLabelViewWidth + 5.0) {
        _rightHandleDateLabelRect = CGRectMake(_leftSelectionRect.size.width + _selectionRect.size.width + 5.0, 2.0, rightLabelViewWidth, 24.0);;
    }
    else {
        _rightHandleDateLabelRect = CGRectMake(_leftSelectionRect.size.width + _selectionRect.size.width - rightLabelViewWidth - 5.0, 2.0, rightLabelViewWidth, 24.0);;
    }
    
    
    if (!_leftHandleDateLabel) {
        _leftHandleDateLabel = [[UIView alloc] initWithFrame:_leftHandleDateLabelRect];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 2, 16, 20)];
        [imageView setContentMode:UIViewContentModeCenter];
        imageView.image = [UIImage imageNamed:@"icon_arrow_handle_left1"];
        [_leftHandleDateLabel addSubview:imageView];
        [imageView release];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(leftLabelViewWidth - 20, 2, 16, 20)];
        [imageView setContentMode:UIViewContentModeCenter];
        imageView.image = [UIImage imageNamed:@"icon_arrow_handle_right1"];
        [_leftHandleDateLabel addSubview:imageView];
        [imageView release];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, leftLabelWidth, 24.0)];
        label.tag = 99;
        label.backgroundColor = [UIColor colorWithRed:CG(51) green:CG(51) blue:CG(51) alpha:0.8];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont fontWithName:@"Verdana" size:10];
        [_leftHandleDateLabel addSubview:label];
        [label release];
        [self addSubview:_leftHandleDateLabel];
    }
    
    ((UILabel *)[_leftHandleDateLabel viewWithTag:99]).text = _leftHandleDateText;
    _leftHandleDateLabel.frame = CGRectIntegral(_leftHandleDateLabelRect);
    
    if (!_rightHandleDateLabel) {
        _rightHandleDateLabel = [[UIView alloc] initWithFrame:_rightHandleDateLabelRect];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 2, 16, 20)];
        [imageView setContentMode:UIViewContentModeCenter];
        imageView.image = [UIImage imageNamed:@"icon_arrow_handle_left1"];
        [_rightHandleDateLabel addSubview:imageView];
        [imageView release];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(rightLabelViewWidth - 20, 2, 16, 20)];
        [imageView setContentMode:UIViewContentModeCenter];
        imageView.image = [UIImage imageNamed:@"icon_arrow_handle_right1"];
        [_rightHandleDateLabel addSubview:imageView];
        [imageView release];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, rightLabelWidth, 24.0)];
        label.tag = 99;
        label.backgroundColor = [UIColor colorWithRed:CG(51) green:CG(51) blue:CG(51) alpha:0.8];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont fontWithName:@"Verdana" size:10];
        [_rightHandleDateLabel addSubview:label];
        [label release];
        [self addSubview:_rightHandleDateLabel];
    }
    ((UILabel *)[_rightHandleDateLabel viewWithTag:99]).text = _rightHandleDateText;
    _rightHandleDateLabel.frame = CGRectIntegral(_rightHandleDateLabelRect);

    _selectionBoxView.leftHandleRect = _leftHandleRect;
    _selectionBoxView.rightHandleRect = _rightHandleRect;
    _selectionBoxView.leftSelectionRect = _leftSelectionRect;
    _selectionBoxView.rightSelectionRect = _rightSelectionRect;
    [_selectionBoxView setNeedsDisplay];
}

- (void)layoutIfNeeded
{
    [self normalizeData];
    [self refreshOverviewLine];
    [self refreshSelectionBoxIfNeeded];
    [self extractDataFromSelectionRectForceRefresh:YES];
    [super layoutIfNeeded];
}


- (void)normalizeData
{
    @autoreleasepool {
        [_drawingPaths removeAllObjects];

        double earliestTime = DBL_MAX;
        double latestTime = DBL_MIN;
        double minimumValue = DBL_MAX;
        double maximumValue = -DBL_MAX;
        
        NSMutableArray *validData = [NSMutableArray array];
        
        int dataCount = 0;
        
        for (NSArray *dataArray in _originalData) {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
            NSMutableArray *sortedData = [[[dataArray sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy] autorelease];
            [sortDescriptor release];
            
            NSMutableArray *invalidData = [NSMutableArray array];
            
            for (NSDictionary *data in sortedData) {
                if ([data valueForKey:@"date"] && [data valueForKey:@"value"] && ![[data valueForKey:@"value"] isEqualToString:@"None"]) {
                    double time = [data[@"date"] timeIntervalSince1970];
                    
                    if (_hardStartDate && _hardEndDate && (time < [_hardStartDate timeIntervalSince1970] || time > [_hardEndDate timeIntervalSince1970])) {
                        [invalidData addObject:data];
                    }
                    else {
                        double value = [data[@"value"] doubleValue];
                        
                        if (time < earliestTime) earliestTime = time;
                        
                        if (time > latestTime) latestTime = time;
                        
                        if (value < minimumValue) minimumValue = value;
                        
                        if (value > maximumValue) maximumValue = value;
                    }
                }
                else {
                    [invalidData addObject:data];
                }
            }
            
            [sortedData removeObjectsInArray:invalidData];
            
            [validData addObject:sortedData];
            
            dataCount += [sortedData count];
        }
        
        self.validData = validData;
        _dataCount = dataCount;
        
        self.maximumValue = maximumValue;
        self.minimumValue = minimumValue;
        
        if (earliestTime == DBL_MAX && latestTime == DBL_MIN) {
            earliestTime = [[NSDate date] timeIntervalSince1970];
            latestTime = earliestTime;
        }
        
        if (earliestTime == latestTime) {
            earliestTime = earliestTime - 86400.0;
            latestTime = latestTime + 86400.0;
        }
        
        if (!_availableStartDate && !_availableEndDate) {
            self.availableStartDate = [NSDate dateWithTimeIntervalSince1970:earliestTime];
            self.availableEndDate = [NSDate dateWithTimeIntervalSince1970:latestTime];
        }
        
        if (!_hardStartDate && !_hardEndDate) {
            self.hardStartDate = _availableStartDate;
            self.hardEndDate = _availableEndDate;
            
            if ([_delegate respondsToSelector:@selector(overviewLineGraph:didSelectHardStartDate:andHardEndDate:)]) {
                [_delegate overviewLineGraph:self didSelectHardStartDate:_hardStartDate andHardEndDate:_hardEndDate];
            }
        }
        else {
            earliestTime = [_hardStartDate timeIntervalSince1970];
            latestTime = [_hardEndDate timeIntervalSince1970];
        }
        
        self.startTimeInterval = earliestTime;
        self.endTimeInterval = latestTime;
        
        if (dataCount == 0) {
            for (CALayer *layer in _graphLayers) {
                [layer removeFromSuperlayer];
            }
            self.graphLayers = nil;
        }
        else {
            
            double valueSpan = maximumValue - minimumValue;
            double mean = (maximumValue + minimumValue) / 2.0;
            double timeSpan = latestTime - earliestTime;
            
            NSMutableArray *result = [NSMutableArray array];
            
            for (NSArray *dataArray in validData) {
                NSMutableArray *temp = [NSMutableArray array];
                
                for (NSDictionary *data in dataArray) {
                    double time = [data[@"date"] timeIntervalSince1970];
                    double value = [data[@"value"] doubleValue];
                    
                    double normValue = self.frame.size.height - ((self.frame.size.height / 2.0) + ((value - mean) * (valueSpan != 0 ? ((self.frame.size.height - kOverviewLineTopPadding - kOverviewLineBottomPadding) / valueSpan) : 0)));
                    double normTime = ((time - earliestTime) / timeSpan) * (self.frame.size.width - kOverviewLineLeftPadding - kOverviewLineRightPadding) + kOverviewLineLeftPadding;
                    
                    [temp addObject:@{@"date": @(normTime), @"value" : @(normValue)}];
                }
                
                [result addObject:temp];
            }            
            self.normalizedData = result;
            
            [self createDrawingPaths];
        }
    }
}

- (void)createDrawingPaths
{    
    for (int i = 0; i < [_normalizedData count]; i++) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth = 1.0;
        
        NSArray *data = [_normalizedData objectAtIndex:i];
        
        if ([data count] > 1) {
            
            int factor = 1 + ([data count] / kMaximumDataPointsPerOverviewLine);
            
            for (int j = 0; j < [data count]; j++) {
                NSDictionary *datum = [data objectAtIndex:j];
                double value = [datum[@"value"] doubleValue];
                double time = [datum[@"date"] doubleValue];
                
                if (j == 0) {
                    [path moveToPoint:CGPointMake(time, value)];
                }
                else {
                    if (j%factor == 0) {
                        [path addLineToPoint:CGPointMake(time, value)];
                    }
                }
            }
        }
        else if ([data count] == 1) {
            NSDictionary *datum = [data objectAtIndex:0];
            double time = [datum[@"date"] doubleValue];
            double value = [datum[@"value"] doubleValue];
            
            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(time - 1.5, value - 1.5, 3.0, 3.0)];
            path.lineWidth = 4.0;
        }
        
        [_drawingPaths addObject:path];
    }

}

- (CGRect)validSelectionRectFromProposedRect:(CGRect)proposedSelectionRect
{
    if (proposedSelectionRect.origin.x + proposedSelectionRect.size.width > self.bounds.size.width) {
        return CGRectMake(proposedSelectionRect.origin.x, proposedSelectionRect.origin.y, self.bounds.size.width - proposedSelectionRect.origin.x, proposedSelectionRect.size.height);
    }
    else if (proposedSelectionRect.origin.x < 0.0) {
        return CGRectMake(0.0, proposedSelectionRect.origin.y, proposedSelectionRect.size.width, proposedSelectionRect.size.height);
    }
    else if (proposedSelectionRect.size.width < 36.0) {
        return CGRectMake(proposedSelectionRect.origin.x, proposedSelectionRect.origin.y, 36.0, proposedSelectionRect.size.height);
    }
    
    return proposedSelectionRect;
}

- (void)refreshSelectionBoxIfNeeded
{
    if (CGRectIsNull(_selectionRect)) {
        self.selectionRect = self.bounds;
    }
    else {
        CGRect selectionRectTemp = CGRectMake(_selectionRectXRatioCache * (self.bounds.size.width - kOverviewLineRightPadding - kOverviewLineLeftPadding) + kOverviewLineLeftPadding, 0.0, _selectionRectWidthRatioCache * (self.bounds.size.width - kOverviewLineRightPadding - kOverviewLineLeftPadding), self.bounds.size.height);
        self.selectionRect = selectionRectTemp;
    }
}


- (void)extractDataFromSelectionRectForceRefresh:(BOOL)forceRefresh
{
    int dataCount = 0;
    
    NSArray *result = _validData;
    
    double selectionBeginTimeInterval = (_selectionRect.origin.x - kOverviewLineLeftPadding) * ((_endTimeInterval - _startTimeInterval) / (self.bounds.size.width - kOverviewLineLeftPadding - kOverviewLineRightPadding)) + _startTimeInterval;
    double selectionEndTimeInterval = (_leftSelectionRect.size.width + _selectionRect.size.width - kOverviewLineLeftPadding) * ((_endTimeInterval - _startTimeInterval) / (self.bounds.size.width - kOverviewLineLeftPadding - kOverviewLineRightPadding)) + _startTimeInterval;
    
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:selectionBeginTimeInterval];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:selectionEndTimeInterval];    
    
    if (forceRefresh) {
        [_delegate overviewLineGraph:self didSelectdData:result startDate:startDate endDate:endDate andSettings:_drawingSettings];
    }
    else {
        if (dataCount < 500) {
            [_delegate overviewLineGraph:self didSelectdData:result startDate:startDate endDate:endDate andSettings:_drawingSettings];
        }
    }
}

#pragma mark - Public
- (void)visualizeData:(NSArray *)data settings:(NSArray *)settings;
{
    NSAssert([data count] == [settings count], @"For each data array, there must be a companion setting dict");
    
    self.originalData = data;
    self.drawingSettings = settings;
    self.availableStartDate = nil;
    self.availableEndDate = nil;
    self.hardStartDate = nil;
    self.hardEndDate = nil;
    
    [self normalizeData];
    [self refreshOverviewLine];
    [self refreshSelectionBoxIfNeeded];
    [self extractDataFromSelectionRectForceRefresh:YES];
}

- (void)setHardDateRangeWithStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate
{
//    double proposedStartTimeInterval = [startDate timeIntervalSince1970];
//    double proposedEndTimeInterval = [endDate timeIntervalSince1970];
//    
//    proposedStartTimeInterval = proposedStartTimeInterval < _startTimeInterval ? _startTimeInterval : proposedStartTimeInterval;
//    proposedEndTimeInterval = proposedEndTimeInterval > _endTimeInterval ? _endTimeInterval : proposedEndTimeInterval;
//    
//    if (proposedStartTimeInterval < _startTimeInterval || proposedStartTimeInterval > _endTimeInterval) {
//        proposedStartTimeInterval = _startTimeInterval;
//    }
//    
//    if (proposedEndTimeInterval > _endTimeInterval || proposedEndTimeInterval < _startTimeInterval) {
//        proposedEndTimeInterval = _endTimeInterval;
//    }
//    
//    CGFloat originX, originY, sizeWidth, sizeHeight;
//    CGFloat timeSpan = _endTimeInterval - _startTimeInterval;
//    CGFloat timeSpanWidth = self.bounds.size.width - kOverviewLineLeftPadding - kOverviewLineRightPadding;
//    
//    originX = ((proposedStartTimeInterval - _startTimeInterval) / timeSpan) * timeSpanWidth + kOverviewLineLeftPadding;
//    originY = 0.0;
//    sizeWidth = ((proposedEndTimeInterval - proposedStartTimeInterval) / timeSpan) * timeSpanWidth;
//    sizeHeight = self.bounds.size.height;
//    
//    self.selectionRect = CGRectMake(originX, originY, sizeWidth, sizeHeight);

    double proposedHardStartDate = [startDate timeIntervalSince1970];
    double proposedHardEndDate = [endDate timeIntervalSince1970];
    double availableStartDate = [_availableStartDate timeIntervalSince1970];
    double availableEndDate = [_availableEndDate timeIntervalSince1970];
    
    if (proposedHardEndDate > proposedHardStartDate) {
        double hardStartDate = availableStartDate;
        double hardEndDate = availableEndDate;
        
        if (proposedHardStartDate > availableStartDate) {
            if (proposedHardStartDate < availableEndDate) {
                hardStartDate = proposedHardStartDate;
            }
        }
        
        if (proposedHardEndDate < availableEndDate) {
            if (proposedHardEndDate > availableStartDate) {
                hardEndDate = proposedHardEndDate;
            }
        }

        self.hardStartDate = [NSDate dateWithTimeIntervalSince1970:hardStartDate];
        self.hardEndDate = [NSDate dateWithTimeIntervalSince1970:hardEndDate];
        
        if ([_delegate respondsToSelector:@selector(overviewLineGraph:didSelectHardStartDate:andHardEndDate:)]) {
            [_delegate overviewLineGraph:self didSelectHardStartDate:_hardStartDate andHardEndDate:_hardEndDate];
        }
        
        [self normalizeData];
        [self refreshOverviewLine];
        self.selectionRect = self.bounds;
        [self extractDataFromSelectionRectForceRefresh:YES];
    }
    else {
        if ([_delegate respondsToSelector:@selector(overviewLineGraph:didSelectHardStartDate:andHardEndDate:)]) {
            [_delegate overviewLineGraph:self didSelectHardStartDate:_hardStartDate andHardEndDate:_hardEndDate];
        }
    }
}

- (void)resetHardDateRange
{
    self.hardStartDate = _availableStartDate;
    self.hardEndDate = _availableEndDate;
    
    if ([_delegate respondsToSelector:@selector(overviewLineGraph:didSelectHardStartDate:andHardEndDate:)]) {
        [_delegate overviewLineGraph:self didSelectHardStartDate:_hardStartDate andHardEndDate:_hardEndDate];
    }
    
    [self normalizeData];
    [self refreshOverviewLine];
    self.selectionRect = self.bounds;
    [self extractDataFromSelectionRectForceRefresh:YES];
}

#pragma mark -
#pragma mark Refresh Box
- (void)refreshOverviewLine
{
    if ([_graphLayers count] != [_drawingPaths count]) {
    
        for (CALayer *layer in _graphLayers) {
            [layer removeFromSuperlayer];
        }
        
        NSMutableArray *temp = [NSMutableArray array];
        
        for (int i = 0; i < [_drawingPaths count]; i ++) {
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.frame = self.bounds;
            [self.layer insertSublayer:shapeLayer atIndex:0];
            [temp addObject:shapeLayer];
        }
        
        self.graphLayers = temp;
    }
    
    for (int i = 0; i < [_drawingPaths count]; i ++) {
    
        NSDictionary *setting = [_drawingSettings objectAtIndex:i];
        UIBezierPath *path = [_drawingPaths objectAtIndex:i];
        CAShapeLayer *shapeLayer = [_graphLayers objectAtIndex:i];
        
        shapeLayer.strokeColor = [setting[@"color"] CGColor];
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        shapeLayer.lineWidth = 1;
        shapeLayer.path = path.CGPath;
    }
    
}

#pragma mark - Touch Handling
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    if (CGRectContainsPoint(_leftHandleDateLabelRect, location)) {
        _interactionType = kInteractionTypeDragLeftHandle;
    }
    else if (CGRectContainsPoint(_rightHandleDateLabelRect, location)) {
        _interactionType = kInteractionTypeDragRightHandle;
    }
    else {
        _interactionType = kInteractionTypeDragSelectionBox;
    }
    
    _previousLocation = location;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    CGFloat xOffset = _previousLocation.x - location.x;
    
    switch (_interactionType) {
        case kInteractionTypeDragLeftHandle:
        {
            CGRect proposedSelectionRect = CGRectMake(_selectionRect.origin.x - xOffset, _selectionRect.origin.y, _selectionRect.size.width + xOffset, _selectionRect.size.height);
            
            CGFloat width = proposedSelectionRect.size.width;
            CGFloat height = proposedSelectionRect.size.height;
            CGFloat originX = proposedSelectionRect.origin.x;
            CGFloat originY = proposedSelectionRect.origin.y;
            
            if (originX < 0.0) {
                originX = 0.0;
            }
            
            if (width < 10.0) {
                width = 10.0;
            }
            
            if (originX + width > _selectionRect.origin.x + _selectionRect.size.width) {
                originX = _selectionRect.origin.x;
                width = _selectionRect.size.width;
            }
            
            self.selectionRect = CGRectMake(originX, originY, width, height);
        }
            break;
        case kInteractionTypeDragRightHandle:
        {
            CGRect proposedSelectionRect = CGRectMake(_selectionRect.origin.x, _selectionRect.origin.y, _selectionRect.size.width - xOffset, _selectionRect.size.height);
            
            CGFloat width = proposedSelectionRect.size.width;
            CGFloat height = proposedSelectionRect.size.height;
            CGFloat originX = proposedSelectionRect.origin.x;
            CGFloat originY = proposedSelectionRect.origin.y;
            
            if (width < 10.0) {
                width = 10.0;
            }
            
            if (originX + width > self.bounds.size.width) {
                width = self.bounds.size.width - originX;
            }
            
            self.selectionRect = CGRectMake(originX, originY, width, height);
        }
            break;
        case kInteractionTypeDragSelectionBox:
        {
            CGRect proposedSelectionRect = CGRectOffset(_selectionRect, - xOffset, 0.0);

            CGFloat width = proposedSelectionRect.size.width;
            CGFloat height = proposedSelectionRect.size.height;
            CGFloat originX = proposedSelectionRect.origin.x;
            CGFloat originY = proposedSelectionRect.origin.y;
            
            if (originX < 0.0) {
                originX = 0.0;
            }
            
            if (originX + width > self.bounds.size.width) {
                originX = self.bounds.size.width - width;
            }
            
            self.selectionRect = CGRectMake(originX, originY, width, height);
        }
            break;
        default:
            break;
    }
    
    [self extractDataFromSelectionRectForceRefresh:YES];
    _previousLocation = location;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self extractDataFromSelectionRectForceRefresh:YES];
    _interactionType = kInteractionTypeNone;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _interactionType = kInteractionTypeNone;
}

@end

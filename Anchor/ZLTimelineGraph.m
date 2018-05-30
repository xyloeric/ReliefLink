//
//  DRTimelineGraph.m
//  ZLCommonLibrary
//
//  Created by Eric Li on 3/19/13.
//  Copyright (c) 2013 Eric Li. All rights reserved.
//

#import "ZLTimelineGraph.h"
#import <QuartzCore/QuartzCore.h>
#import "ANCommons.h"

static void *DRTimelineGraphContext = &DRTimelineGraphContext;


@interface ZLTimelineGraph () <UIScrollViewDelegate>
{
    double _axisStartValue;
    double _axisEndValue;
    double _earliestDateTimeInterval;
    double _latestDateTimeInterval;
    
    double _maximumValue;
    double _minimumValue;
    int _dataCount;
    int _nonEmptyDataArrayCount;
    
    CGFloat _hoverLinePositionRatioCache;
    
    BOOL _shouldRefresh;
}
@property (nonatomic, retain) NSArray *originalData;
@property (nonatomic, retain) NSMutableArray *drawingSettings;
@property (nonatomic, retain) NSArray *allDrawingSettings;
@property (nonatomic, retain) NSMutableArray *hiddenDrawingSettings;

@property (nonatomic, retain) NSDictionary *normalizedData;
@property (nonatomic, retain) NSDictionary *validData;
@property (nonatomic, retain) NSMutableDictionary *leftAnchorData, *rightAnchorData;
@property (nonatomic, retain) NSDictionary *firstData;

@property (nonatomic, retain) NSString *referenceValue;
@property (nonatomic, retain) NSNumber *normalizedRefValue;

@property (nonatomic, retain) NSArray *yTickers;
@property (nonatomic, retain) NSArray *yTickerLabels;
@property (nonatomic, retain) NSArray *xTickerLabels;

@property (nonatomic, retain) NSArray *valuesForHoverLine;
@property (nonatomic, retain) NSArray *hoverlineLabels;
@property (nonatomic, retain) UILabel *hoverDateLabel;
@property (nonatomic, retain) CAShapeLayer *hoverLine;

@property (nonatomic, retain) NSArray *toggleSwitches;
@property (nonatomic, retain) UIScrollView *toggleSwitchContainer;
@property (nonatomic, retain) UIButton *toggleSwitchAllButton;
@property (nonatomic, retain) UIView *leftShadowView, *rightShadowView;

@property (nonatomic, retain) NSDictionary *drawingPaths;
@property (nonatomic, retain) NSDictionary *graphLayers;

@property (nonatomic, retain) NSArray *supportedGraphTypes;

@property (nonatomic) CGFloat dateSelectionStart;
@property (nonatomic, retain) CAShapeLayer *dateSelectionBox;
@end

@implementation ZLTimelineGraph

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _hoverLinePositionRatioCache = -1;
        
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
        recognizer.minimumNumberOfTouches = 2.0;
        recognizer.maximumNumberOfTouches = 2.0;
        [self addGestureRecognizer:recognizer];
        [recognizer release];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _hoverLinePositionRatioCache = -1;
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
        recognizer.minimumNumberOfTouches = 2.0;
        recognizer.maximumNumberOfTouches = 2.0;
        [self addGestureRecognizer:recognizer];
        [recognizer release];
    }
    return self;
}

- (void)dealloc
{
    [_toggleSwitchContainer removeObserver:self forKeyPath:@"contentOffset" context:DRTimelineGraphContext];
    
    [_originalData release];
    [_drawingSettings release];
    [_allDrawingSettings release];
    [_hiddenDrawingSettings release];

    [_normalizedData release];
    [_validData release];
    [_leftAnchorData release];
    [_rightAnchorData release];
    [_firstData release];

    [_referenceValue release];
    [_normalizedRefValue release];

    [_yTickers release];
    [_yTickerLabels release];
    [_xTickerLabels release];

    [_valuesForHoverLine release];
    [_hoverlineLabels release];
    [_hoverDateLabel release];
    [_hoverLine release];
    
    [_toggleSwitches release];
    [_toggleSwitchContainer release];
    [_toggleSwitchAllButton release];
    [_leftShadowView release];
    [_rightShadowView release];
    
    [_drawingPaths release];
    [_graphLayers release];

    [_supportedGraphTypes release];
    [_dateSelectionBox release];
    [super dealloc];
}

- (void)setGraphType:(DRGraphType)graphType
{
    for (NSNumber *supportedType in _supportedGraphTypes) {
        if ([supportedType intValue] == graphType) {
            
            if (_graphType != graphType) {
                _graphType = graphType;
                
                [self preprocessData];
                [self refreshGraphIfNeeded];
            }
            break;
        }
    }
    
    [_delegate timelineGraph:self didSelectGraphType:_graphType withSupportedGraphTypes:_supportedGraphTypes];
}

- (void)refreshGraphIfNeeded
{
    [self normalizeData];
    
    if (_shouldRefresh) {
        [self updateTickerLabels];
        
        if (_hoverLinePositionRatioCache > 0) {
            [self findUpdateNearestValueByLocation:_hoverLinePositionRatioCache * (self.bounds.size.width - kTimelineLeftPadding - kTimelineRightPadding) + kTimelineLeftPadding];
        }
        
//        [self updateHoverLineLabels];
        [self refreshTimeLine];
//        [self updateToggleSwitches];
        [self setNeedsDisplay];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    DrawCoordinatesInContext(self.bounds.size.height - kTimelineXAxisOffsetFromBottom, kTimelineYAxisOffsetFromLeft, self.bounds.size.width - kTimelineRightPadding, self.bounds.size.height - kTimelineBottomPadding);
    DrawXTicker(CGPointMake(kTimelineLeftPadding + (self.bounds.size.width - kTimelineLeftPadding)/2.0, self.bounds.size.height - kTimelineBottomPadding));
    
    for (NSDictionary *ticker in _yTickers) {
        double pos = [ticker[@"position"] doubleValue];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(kTimelineLeftPadding, pos)];
        [path addLineToPoint:CGPointMake(self.bounds.size.width - kTimelineRightPadding, pos)];

        path.lineWidth = 1.0;
        [kTimelineCoordinateColor setStroke];
        [path stroke];
    }
}

void DrawCoordinatesInContext(CGFloat xPosition, CGFloat yPosition, CGFloat xEnd, CGFloat yEnd)
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(yPosition, xPosition)];
    [path addLineToPoint:CGPointMake(xEnd, xPosition)];
    path.lineWidth = 0.0;
    [kTimelineCoordinateColor setStroke];
    [path stroke];
    
    path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(yPosition, 0.0)];
    [path addLineToPoint:CGPointMake(yPosition, yEnd)];
    path.lineWidth = 0.0;
    [kTimelineCoordinateColor setStroke];
    [path stroke];
    
    path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(xEnd, 0.0)];
    [path addLineToPoint:CGPointMake(xEnd, yEnd)];
    path.lineWidth = 0.0;
    [kTimelineCoordinateColor setStroke];
    [path stroke];
}

void DrawXTicker(CGPoint start)
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:start];
    [path addLineToPoint:CGPointMake(start.x, start.y - 5.0)];
    path.lineWidth = 2.0;
    [kTimelineCoordinateColor setStroke];
    [path stroke];
}

void DrawHoverLine (CGPoint startPoint, CGPoint endPoint)
{
    UIBezierPath *path = [UIBezierPath bezierPath];

    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    path.lineWidth = 1;
    float lineDash[1];
    lineDash[0] = 4.0;
    [path setLineDash:lineDash count:1 phase:0.0];
    [kTimelineHoverlineColor setStroke];
    [path stroke];
}

- (void)layoutIfNeeded
{
    [self refreshGraphIfNeeded];
    [super layoutIfNeeded];
}

- (CGRect)graphRect
{
    return CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - kTimelineBottomPadding);
}

- (void)preprocessData
{
    @autoreleasepool {
        double earlistTime = DBL_MAX;
        double latestTime = DBL_MIN;
        double minimumValue = DBL_MAX;
        double maximumValue = -DBL_MAX;
        
        NSMutableDictionary *validData = [NSMutableDictionary dictionary];
        NSMutableDictionary *firstDataDict = [NSMutableDictionary dictionary];
        
        NSMutableDictionary *leftAnchorData = [NSMutableDictionary dictionary];
        NSMutableDictionary *rightAnchorData = [NSMutableDictionary dictionary];
        
        int dataCount = 0;
        int nonEmptyDataArrayCount = 0;
        
        for (int i = 0; i < [_drawingSettings count]; i++) {
            NSDictionary *setting = [_drawingSettings objectAtIndex:i];
            NSString *dataKey = setting[@"key"];
            NSInteger settingIndex = [_allDrawingSettings indexOfObject:setting];
            
            NSArray *dataArray = [_originalData objectAtIndex:settingIndex];
            
            if ([dataArray count] > 0) {
                nonEmptyDataArrayCount ++;
            }
            
            NSMutableArray *temp = [NSMutableArray array];
            
            NSDictionary *firstData = nil;
            
            for (NSDictionary *data in dataArray) {
                if ([data valueForKey:@"date"] && [data valueForKey:@"value"] && ![[data valueForKey:@"value"] isEqualToString:@"None"]) {
                    
                    double time = [data[@"date"] timeIntervalSince1970];
                    
                    if (time >= _earliestDateTimeInterval && time <= _latestDateTimeInterval) {
                        if (!firstData) {
                            firstData = data;
                            [firstDataDict setValue:firstData forKey:dataKey];
                        }
                        
                        double value = [data[@"value"] doubleValue];
                        
                        double firstValue = [firstData[@"value"] doubleValue];
                        double percentOfChange = 0.0;
                        if (firstValue != 0.0) {
                            percentOfChange = ((value - firstValue) / firstValue) * 100;
                        }
                        [temp addObject:@{@"date": @(time), @"value": @(value), @"percentOfChange": @(percentOfChange)}];
                        
                        if (time < earlistTime) earlistTime = time;
                        if (time > latestTime) latestTime = time;
                        
                        switch (_graphType) {
                            case kGraphTypeActualValue:
                            {
                                if (value < minimumValue) minimumValue = value;
                                if (value > maximumValue) maximumValue = value;
                            }
                                break;
                            case kGraphTypePercentOfChange:
                            {
                                if (percentOfChange < minimumValue) minimumValue = percentOfChange;
                                if (percentOfChange > maximumValue) maximumValue = percentOfChange;
                            }
                                break;
                            default:
                                break;
                        }
                    }
                    else if (time < _earliestDateTimeInterval) {
                        [leftAnchorData setValue:data forKey:dataKey];
                    }
                    else if (time > _latestDateTimeInterval) {
                        if (![rightAnchorData valueForKey:dataKey]) {
                            [rightAnchorData setValue:data forKey:dataKey];
                        }
                    }
                }
            }
            
            [validData setValue:temp forKey:dataKey];
            dataCount += [temp count];
            
        }
        
        NSMutableDictionary *leftAnchorDictWithPOC = [NSMutableDictionary dictionary];
        for (id key in leftAnchorData) {
            NSDictionary *data = [leftAnchorData valueForKey:key];
            
            double time = [data[@"date"] timeIntervalSince1970];
            double firstValue = [firstDataDict[key][@"value"] doubleValue];
            double value = [data[@"value"] doubleValue];
            double percentOfChange = 0.0;
            if (firstValue != 0.0) {
                percentOfChange = ((value - firstValue) / firstValue) * 100;
            }
            
            switch (_graphType) {
                case kGraphTypeActualValue:
                {
                    if (value < minimumValue) minimumValue = value;
                    if (value > maximumValue) maximumValue = value;
                }
                    break;
                case kGraphTypePercentOfChange:
                {
                    if (percentOfChange < minimumValue) minimumValue = percentOfChange;
                    if (percentOfChange > maximumValue) maximumValue = percentOfChange;
                }
                    break;
                default:
                    break;
            }
            
            [leftAnchorDictWithPOC setValue:@{@"date": @(time), @"value": @(value), @"percentOfChange": @(percentOfChange)} forKey:key];
        }
        
        NSMutableDictionary *rightAnchorDictWithPOC = [NSMutableDictionary dictionary];
        for (id key in rightAnchorData) {
            NSDictionary *data = [rightAnchorData valueForKey:key];
            
            double time = [data[@"date"] timeIntervalSince1970];
            double firstValue = [firstDataDict[key][@"value"] doubleValue];
            double value = [data[@"value"] doubleValue];
            double percentOfChange = 0.0;
            if (firstValue != 0.0) {
                percentOfChange = ((value - firstValue) / firstValue) * 100;
            }
            
            switch (_graphType) {
                case kGraphTypeActualValue:
                {
                    if (value < minimumValue) minimumValue = value;
                    if (value > maximumValue) maximumValue = value;
                }
                    break;
                case kGraphTypePercentOfChange:
                {
                    if (percentOfChange < minimumValue) minimumValue = percentOfChange;
                    if (percentOfChange > maximumValue) maximumValue = percentOfChange;
                }
                    break;
                default:
                    break;
            }
            
            [rightAnchorDictWithPOC setValue:@{@"date": @(time), @"value": @(value), @"percentOfChange": @(percentOfChange)} forKey:key];
        }
        
        if (maximumValue == -DBL_MAX || minimumValue == DBL_MAX) {
            maximumValue = 9;
            minimumValue = 0;
        }
        
        _maximumValue = maximumValue;
        _minimumValue = minimumValue;
        _dataCount = dataCount;
        self.validData = validData;
        self.leftAnchorData = leftAnchorDictWithPOC;
        self.rightAnchorData = rightAnchorDictWithPOC;
        self.firstData = firstDataDict;
        _nonEmptyDataArrayCount = nonEmptyDataArrayCount;
        
        [self determineAxisStartAndEndValuesWithMinValue:minimumValue maxValue:maximumValue];
    }
}

- (void)normalizeData
{
    @autoreleasepool {
        self.drawingPaths = nil;
        self.valuesForHoverLine = nil;
        
        double coordinateSpan = _axisEndValue - _axisStartValue;
        double timeSpan = _latestDateTimeInterval - _earliestDateTimeInterval;
        
        if ([_validData count] == 0 || _nonEmptyDataArrayCount == 0) {
            _shouldRefresh = YES;
            self.normalizedData = nil;
            
            [_hoverLine removeFromSuperlayer];
            [self setNeedsDisplayInRect:_hoverLine.frame];
            self.hoverLine = nil;
            
            for (UILabel *label in _hoverlineLabels) {
                [label removeFromSuperview];
            }
            self.hoverlineLabels = nil;
            
            for (CALayer *layer in [_graphLayers allValues]) {
                [layer removeFromSuperlayer];
            }
            self.graphLayers = nil;
            
            for (UIView *toggleSwitch in _toggleSwitches) {
                [toggleSwitch removeFromSuperview];
            }
            self.toggleSwitches = nil;
            
        }
        else {
            _shouldRefresh = YES;
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            
            for (int i = 0; i < [_drawingSettings count]; i++) {
                NSDictionary *setting = [_drawingSettings objectAtIndex:i];
                NSString *dataKey = setting[@"key"];
                NSArray *dataArray = [_validData valueForKey:dataKey];
                
                NSMutableArray *temp = [NSMutableArray array];
                
                for (NSDictionary *data in dataArray) {
                    [temp addObject:[self normalizedData:data timeSpan:timeSpan coordinateSpan:coordinateSpan]];
                }
                
                [result setValue:temp forKey:dataKey];
            }
            
            self.normalizedData = result;
            
        }
        
        for (int i = 0; i < [_drawingSettings count]; i++) {
            NSDictionary *setting = [_drawingSettings objectAtIndex:i];
            NSString *dataKey = setting[@"key"];
            
            if ([_leftAnchorData valueForKey:dataKey]) {
                [_leftAnchorData setValue:[self normalizedData:[_leftAnchorData valueForKey:dataKey] timeSpan:timeSpan coordinateSpan:coordinateSpan] forKey:dataKey];
            }
            
            if ([_rightAnchorData valueForKey:dataKey]) {
                [_rightAnchorData setValue:[self normalizedData:[_rightAnchorData valueForKey:dataKey] timeSpan:timeSpan coordinateSpan:coordinateSpan] forKey:dataKey];
            }
        }
        
        NSMutableArray *tickersTemp = [NSMutableArray array];
        double ticker = _axisStartValue;
        double tickerStep = coordinateSpan / 2;
        for (int i = 0; i < 3; i++) {
            double normTicker = self.frame.size.height - ((((ticker - _axisStartValue) * (self.frame.size.height - kTimelineTopPadding - kTimelineBottomPadding)) / coordinateSpan) + kTimelineBottomPadding);
            
            NSString *normTickerString = [self trimTrailingZeros:[NSString stringWithFormat:@"%.2f", ticker]];
            
            if (_graphType == kGraphTypePercentOfChange) {
                if (ticker > 0) {
                    normTickerString = [NSString stringWithFormat:@"+%@%%", normTickerString];
                }
                else {
                    normTickerString = [NSString stringWithFormat:@"%@%%", normTickerString];
                }
            }
            
            [tickersTemp addObject:@{@"value" : normTickerString, @"position": @(normTicker)}];
            ticker += tickerStep;
        }
        
        self.yTickers = tickersTemp;
        
        if (_drawingPaths == nil) {
            [self createDrawingPaths];
        }
        
        
    }
}

- (NSDictionary *)normalizedData:(NSDictionary *)data timeSpan:(double)timeSpan coordinateSpan:(double)coordinateSpan
{
    double time = [data[@"date"] doubleValue];
    double value = [data[@"value"] doubleValue];
    double percentOfChange = [data[@"percentOfChange"] doubleValue];
    
    double normValue = 0.0;
    switch (_graphType) {
        case kGraphTypeActualValue:
            normValue = self.frame.size.height - ((((value - _axisStartValue) * (self.frame.size.height - kTimelineTopPadding - kTimelineBottomPadding)) / coordinateSpan) + kTimelineBottomPadding);
            break;
        case kGraphTypePercentOfChange:
            normValue = self.frame.size.height - ((((percentOfChange - _axisStartValue) * (self.frame.size.height - kTimelineTopPadding - kTimelineBottomPadding)) / coordinateSpan) + kTimelineBottomPadding);
            break;
        default:
            break;
    }
    
    
    double normTime = ((time - _earliestDateTimeInterval) / timeSpan) * (self.frame.size.width - kTimelineLeftPadding - kTimelineRightPadding) + kTimelineLeftPadding;
    
    return @{@"date": @(normTime), @"value": @(normValue), @"originalDate": @(time), @"originalValue": @(value), @"percentOfChange": @(percentOfChange)};
}

- (void)determineAxisStartAndEndValuesWithMinValue:(double)minimumValue maxValue:(double)maximumValue
{
//    int valueSpan = (int)((maximumValue - minimumValue) * 1.2) + 1;
//    
//    if (valueSpan > 9.0) {
//    
//        _axisStartValue = (int)(minimumValue - (maximumValue - minimumValue) * 0.1);
//        _axisEndValue = _axisStartValue + valueSpan;
//        
//        int step = 0;
//        
//        while ((int)(_axisEndValue - _axisStartValue)%9 != 0) {
//            if (step%2 == 0) {
//                _axisStartValue = (int)(_axisStartValue - 1);
//            }
//            else {
//                _axisEndValue = (int)(_axisEndValue + 1);
//            }
//            step ++;
//        }
//        
//    }
//    else {
//        if (maximumValue - minimumValue == 0.0) {
//            _axisStartValue = minimumValue - (minimumValue == 0.0?1:minimumValue * 0.2);
//            _axisEndValue = maximumValue +  (minimumValue == 0.0?1:minimumValue * 0.2);
//        }
//        else {
//            _axisStartValue = minimumValue - (maximumValue - minimumValue) * 0.2;
//            _axisEndValue = maximumValue +  (maximumValue - minimumValue) * 0.2;
//        }
//    }
    _axisStartValue = 0;
    _axisEndValue = 10;
}

- (void)updateTickerLabels
{
    if ([_yTickerLabels count] != [_yTickers count]) {
        for (UILabel *label in _yTickerLabels) {
            [label removeFromSuperview];
        }
        
        NSMutableArray *temp = [NSMutableArray array];
        for (NSDictionary *ticker in _yTickers) {
            UILabel *tickerLabel = [[UILabel alloc] init];
            tickerLabel.textColor = kTimelineTickerLabelTextColor;
            tickerLabel.textAlignment = UITextAlignmentRight;
//            tickerLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
            tickerLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:12];
            tickerLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:tickerLabel];
            [temp addObject:tickerLabel];
            [tickerLabel release];
        }
        self.yTickerLabels = temp;
    }
    for (int i = 0; i < [_yTickers count]; i ++) {
        NSDictionary *ticker = [_yTickers objectAtIndex:i];
        double position = [ticker[@"position"] doubleValue] - 9.0;
        UILabel *tickerLabel = [_yTickerLabels objectAtIndex:i];
        tickerLabel.frame = CGRectIntegral(CGRectMake(2.0, position, kTimelineLeftPadding-8.0, 18.0));
        tickerLabel.text = ticker[@"value"];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    if (_latestDateTimeInterval - _earliestDateTimeInterval > 432000) {
//        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
//    }
//    else {
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
//    }
    
    if ([_xTickerLabels count] != 3) {
        for (UILabel *label in _xTickerLabels) {
            [label removeFromSuperview];
        }
        
        NSMutableArray *temp = [NSMutableArray array];
        for (int i = 0; i < 3; i ++) {
            UILabel *tickerLabel = [[UILabel alloc] init];
            tickerLabel.textColor = kTimelineTickerLabelTextColor;
            tickerLabel.textAlignment = UITextAlignmentRight;
//            tickerLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
            tickerLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:12];
            tickerLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:tickerLabel];
            [temp addObject:tickerLabel];
            [tickerLabel release];
        }
        
        self.xTickerLabels = temp;
    }
    
    for (int i = 0; i < 3; i ++) {
        UILabel *tickerLabel = [_xTickerLabels objectAtIndex:i];
        if (i == 0) {
            tickerLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:_earliestDateTimeInterval]];
            tickerLabel.frame = CGRectIntegral(CGRectMake(kTimelineLeftPadding, self.bounds.size.height - kTimelineBottomPadding + 2.0, [tickerLabel.text sizeWithFont:tickerLabel.font].width, 18.0));
        }
        else if (i == 1) {
            tickerLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(_earliestDateTimeInterval + _latestDateTimeInterval)/2.0]];
            double labelWidth = [tickerLabel.text sizeWithFont:tickerLabel.font].width;
            tickerLabel.frame = CGRectIntegral(CGRectMake(kTimelineLeftPadding + (self.bounds.size.width - kTimelineLeftPadding) / 2.0 - labelWidth/2.0, self.bounds.size.height - kTimelineBottomPadding + 2.0, labelWidth, 18.0));

        }
        else if (i == 2) {
            tickerLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:_latestDateTimeInterval]];
            tickerLabel.frame = CGRectIntegral(CGRectMake(self.bounds.size.width - [tickerLabel.text sizeWithFont:tickerLabel.font].width - 2.0 - kTimelineRightPadding, self.bounds.size.height - kTimelineBottomPadding + 2.0, [tickerLabel.text sizeWithFont:tickerLabel.font].width, 18.0));

        }
    }
    
    [dateFormatter release];
}


- (void)findUpdateNearestValueByLocation:(CGFloat)locationX
{
    _hoverLinePositionRatioCache = (locationX - kTimelineLeftPadding) / (self.bounds.size.width - kTimelineLeftPadding - kTimelineRightPadding);
    
    NSMutableArray *temp = [NSMutableArray array];
    
    for (NSDictionary *setting in _drawingSettings) {
        NSArray *dataArray = [_normalizedData valueForKey:setting[@"key"]];
        
        if ([dataArray count] > 0) {
            
            __block NSDictionary *closest = nil;
            __block double distance = DBL_MAX;
            
            if (locationX - kTimelineLeftPadding > self.bounds.size.width - locationX) {
                closest = [dataArray lastObject];
                [dataArray enumerateObjectsUsingBlock:^(NSDictionary *data, NSUInteger idx, BOOL *stop) {
                    double time = [data[@"date"] doubleValue];
                    double currentDist = fabs(locationX - time);
                    if (currentDist < distance) {
                        distance = currentDist;
                    }
                    else {
                        closest = [dataArray objectAtIndex:idx - 1];
                        *stop = YES;
                    }
                }];
            }
            else {
                closest = [dataArray objectAtIndex:0];
                [dataArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSDictionary *data, NSUInteger idx, BOOL *stop) {
                    double time = [data[@"date"] doubleValue];
                    double currentDist = fabs(locationX - time);
                    if (currentDist < distance) {
                        distance = currentDist;
                    }
                    else {
                        closest = [dataArray objectAtIndex:idx + 1];
                        *stop = YES;
                    }
                }];
            }
            
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            [result addEntriesFromDictionary:closest];
            [result setValue:setting[@"color"] forKey:@"color"];
            [result setValue:setting[@"title"] forKey:@"title"];
            [result setValue:setting[@"unit"] forKey:@"unit"];
            [result setValue:setting[@"key"] forKey:@"key"];
            [temp addObject:result];
        }
    }
    
    __block double distance = DBL_MAX;
//    double unitLength =  (self.bounds.size.width - kTimelineLeftPadding - kTimelineRightPadding) / (_latestDateTimeInterval - _earliestDateTimeInterval);
    __block NSMutableArray *result = [NSMutableArray array];
    
    [temp enumerateObjectsUsingBlock:^(NSDictionary *data, NSUInteger idx, BOOL *stop) {
        double time = [data[@"date"] doubleValue];
        double currentDist = fabs(locationX - time);
        if (currentDist < distance) {
            distance = currentDist;
            [result removeAllObjects];
            [result addObject:data];
        }
        else if (currentDist == distance) {
            [result addObject:data];
        }
    }];
    
//    [temp enumerateObjectsUsingBlock:^(NSDictionary *data, NSUInteger idx, BOOL *stop) {
//        double time = [data[@"date"] doubleValue];
//        double currentDist = fabs(locationX - time);
//        
//        if (fabs(currentDist - distance) <= unitLength) {
//            [result addObject:data];
//        }
//    }];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"value" ascending:YES];
    self.valuesForHoverLine = [result sortedArrayUsingDescriptors:@[sortDescriptor]];
    [sortDescriptor release];
}

- (void)updateHoverLineLabels
{
    [_hoverLine removeFromSuperlayer];
    [self setNeedsDisplayInRect:_hoverLine.frame];
    self.hoverLine = nil;
    
    for (UILabel *label in _hoverlineLabels) {
        [label removeFromSuperview];
    }
    self.hoverlineLabels = nil;
    
    [_hoverDateLabel removeFromSuperview];
    
    if ([_valuesForHoverLine count] > 0) {
        
        UIFont *labelFont = [UIFont fontWithName:@"Verdana" size:12];
        NSMutableArray *temp = [NSMutableArray array];
        
        CGFloat yOrigin = 4.0;
        
        for (NSDictionary * value in _valuesForHoverLine) {
            double anchorLoc = [_valuesForHoverLine[0][@"date"] doubleValue];
            
            double percentOfChange = [value[@"percentOfChange"] doubleValue];
            
            NSString *percentOfChangeDisplay = nil;
            if (percentOfChange > 0) {
                percentOfChangeDisplay = [NSString stringWithFormat:@"+%.2f%%", percentOfChange];
            }
            else if (percentOfChange == 0.0) {
                percentOfChangeDisplay = @"±0%";
            }
            else {
                percentOfChangeDisplay = [NSString stringWithFormat:@"%.2f%%", percentOfChange];
            }
            
            NSString *text = nil;
            NSString *unit = value[@"unit"];
            
            switch (_graphType) {
                case kGraphTypeActualValue:
                    if (unit) {
                        text = [NSString stringWithFormat:@"%@: %@ %@ (%@)", value[@"title"], value[@"originalValue"], unit, percentOfChangeDisplay];
                    }
                    else {
                        text = [NSString stringWithFormat:@"%@: %@ (%@)", value[@"title"], value[@"originalValue"], percentOfChangeDisplay];
                    }
                    break;
                case kGraphTypePercentOfChange:
                    if (unit) {
                        text = [NSString stringWithFormat:@"%@: %@ (%@ %@)", value[@"title"], percentOfChangeDisplay, value[@"originalValue"], unit];
                    }
                    else {
                        text = [NSString stringWithFormat:@"%@: %@ (%@)", value[@"title"], percentOfChangeDisplay, value[@"originalValue"]];
                    }
                    break;
                default:
                    break;
            }
            
            CGSize textSize = [text sizeWithFont:labelFont];
            CGSize labelSize = CGSizeMake(textSize.width + 4.0 > 36.0 ? textSize.width + 4.0 : 36.0, textSize.height);
            
            UILabel *label = [[UILabel alloc] init];
            CGRect labelFrame = CGRectZero;
            if (self.bounds.size.width - anchorLoc - kTimelineRightPadding < labelSize.width + 12.0) {
                labelFrame = CGRectMake(anchorLoc - labelSize.width - 6.0, yOrigin, labelSize.width, labelSize.height);
            }
            else {
                labelFrame = CGRectMake(anchorLoc + 6.0, yOrigin, labelSize.width, labelSize.height);
            }
            label.frame = CGRectIntegral(labelFrame);
            
            label.backgroundColor = [value[@"color"] colorWithAlphaComponent:0.5];
            label.alpha = 1.0;
            label.textColor = [UIColor blackColor];// ContrastColor(value[@"color"]);
            label.text = text;
            label.textAlignment = UITextAlignmentCenter;
            label.font = labelFont;
            label.layer.cornerRadius = 2.0;
            
            yOrigin = yOrigin + labelSize.height + 2.0;
            
            [self addSubview:label];
            [temp addObject:label];
            [label release];
        }
        
        self.hoverlineLabels = temp;
        
        if (!_hoverDateLabel) {
            UILabel *label = [[UILabel alloc] init];
            
            label.backgroundColor = [UIColor colorWithRed:CG(0) green:CG(0) blue:CG(0) alpha:0.8];
            label.alpha = 0.8;
            label.textColor = kTimelineHoverDateLabelTextColor;
            label.textAlignment = UITextAlignmentCenter;
            label.layer.cornerRadius = 2.0;
            _hoverDateLabel = label;
        }
        
        UIFont *dateLabelFont = [UIFont fontWithName:@"Verdana" size:12];
        
        NSDictionary *value = [_valuesForHoverLine objectAtIndex:0];
        double anchorLoc = [value[@"date"] doubleValue];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        if (_latestDateTimeInterval - _earliestDateTimeInterval > 432000) {
//            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
//        }
//        else {
            [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
//        }
        NSString *text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[value[@"originalDate"] doubleValue]]];
        [dateFormatter release];
        
        CGSize textSize = [text sizeWithFont:dateLabelFont];
        CGSize labelSize = CGSizeMake(textSize.width + 4.0 > 36.0 ? textSize.width + 4.0 : 36.0, textSize.height);
        
        CGRect labelFrame = CGRectZero;
        CGFloat y = self.bounds.size.height - kTimelineBottomPadding - labelSize.height - 2.0;
        if (self.bounds.size.width - anchorLoc - kTimelineRightPadding < labelSize.width + 12.0) {
            labelFrame = CGRectMake(anchorLoc - labelSize.width - 6.0, y, labelSize.width, labelSize.height);
        }
        else {
            labelFrame = CGRectMake(anchorLoc + 6.0, y, labelSize.width, labelSize.height);
        }
        _hoverDateLabel.frame = CGRectIntegral(labelFrame);
        _hoverDateLabel.text = text;
        _hoverDateLabel.font = dateLabelFont;
        
        [self addSubview:_hoverDateLabel];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        self.hoverLine = shapeLayer;
        
        [_hoverLine setFrame:CGRectMake(anchorLoc - 1, 0.0, 3.0, self.bounds.size.height - kTimelineBottomPadding)];
        [_hoverLine setFillColor:[[UIColor clearColor] CGColor]];
        [_hoverLine setStrokeColor:[kTimelineHoverlineColor CGColor]];
        [_hoverLine setLineWidth:1.0f];
        [_hoverLine setLineJoin:kCALineJoinRound];
        [_hoverLine setLineDashPattern:
         [NSArray arrayWithObjects:@(4), nil]];
        
            // Setup the path
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 1, 0);
        CGPathAddLineToPoint(path, NULL, 1, _hoverLine.frame.size.height);
        
        [_hoverLine setPath:path];
        CGPathRelease(path);
        
        [[self layer] addSublayer:_hoverLine];
    }
}

- (void)updateToggleSwitches {
    if (!_toggleSwitchContainer) {
        _toggleSwitchContainer = [[UIScrollView alloc] init];
        _toggleSwitchContainer.showsHorizontalScrollIndicator = NO;
        _toggleSwitchContainer.showsVerticalScrollIndicator = NO;
        _toggleSwitchContainer.delegate = self;
        [self addSubview:_toggleSwitchContainer];
        
        [_toggleSwitchContainer addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:DRTimelineGraphContext];
    }
    
    if (!_toggleSwitchAllButton) {
        self.toggleSwitchAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_toggleSwitchAllButton setBackgroundColor:[UIColor colorWithRed:CG(51) green:CG(51) blue:CG(51) alpha:1.0]];
        [_toggleSwitchAllButton addTarget:self action:@selector(toggleSwitchAllButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_toggleSwitchAllButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:15]];
        _toggleSwitchAllButton.layer.cornerRadius = 3.0;
        [self addSubview:_toggleSwitchAllButton];
        
    }
    
    if (!_leftShadowView) {
        _leftShadowView = [[UIView alloc] init];
        _leftShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        _leftShadowView.layer.shadowOpacity = 0.9;
        _leftShadowView.layer.shadowRadius = 1.5;
        _leftShadowView.layer.shadowOffset = CGSizeMake(1.5, 0.0);
        _leftShadowView.backgroundColor = [UIColor colorWithRed:CG(0) green:CG(0) blue:CG(0) alpha:.5];
        [self addSubview:_leftShadowView];
    }
    
    if (!_rightShadowView) {
        _rightShadowView = [[UIView alloc] init];
        _rightShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        _rightShadowView.layer.shadowOpacity = 0.9;
        _rightShadowView.layer.shadowRadius = 1.5;
        _rightShadowView.layer.shadowOffset = CGSizeMake(-1.5, 0.0);
        _rightShadowView.backgroundColor = [UIColor colorWithRed:CG(0) green:CG(0) blue:CG(0) alpha:.5];
        [self addSubview:_rightShadowView];
    }

    
    if ([_drawingSettings count] < [_allDrawingSettings count]) {
        [_toggleSwitchAllButton setTitle:@"All" forState:UIControlStateNormal];
    }
    else {
        [_toggleSwitchAllButton setTitle:@"None" forState:UIControlStateNormal];
    }
    
    _toggleSwitchAllButton.frame = CGRectMake(0.0, self.bounds.size.height - kTimelineBottomPadding + 25.0, kTimelineLeftPadding - 6.0, kTimelineToggleSwitchHeight);
    _toggleSwitchContainer.frame = CGRectMake(kTimelineLeftPadding, self.bounds.size.height - kTimelineBottomPadding + 25.0, self.bounds.size.width - kTimelineLeftPadding - kTimelineRightPadding, kTimelineToggleSwitchHeight);
    _leftShadowView.frame = CGRectMake(kTimelineLeftPadding, self.bounds.size.height - kTimelineBottomPadding + 25.0, 0.5, kTimelineToggleSwitchHeight);
    _rightShadowView.frame = CGRectMake(kTimelineLeftPadding + _toggleSwitchContainer.frame.size.width, self.bounds.size.height - kTimelineBottomPadding + 25.0, 0.5, kTimelineToggleSwitchHeight);
    
    if (_toggleSwitches == nil || [_toggleSwitches count] != [_allDrawingSettings count]) {
        for (UIView *toggleSwitch in _toggleSwitches) {
            [toggleSwitch removeFromSuperview];
        }
        self.toggleSwitches = nil;
        
        NSMutableArray *temp = [NSMutableArray array];
        for (NSDictionary *setting in _allDrawingSettings) {
            UILabel *label = [[UILabel alloc] init];
            
            label.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:15];
            label.minimumFontSize = 12.0;
            label.textAlignment = UITextAlignmentCenter;
            label.userInteractionEnabled = YES;
            label.layer.cornerRadius = 3.0;
                        
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
            recognizer.cancelsTouchesInView = YES;
            [label addGestureRecognizer:recognizer];
            [recognizer release];
            
            UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestureRecognizer:)];
            longPressRecognizer.cancelsTouchesInView = YES;
            [label addGestureRecognizer:longPressRecognizer];
            [longPressRecognizer release];
            
            [_toggleSwitchContainer addSubview:label];
            [temp addObject:label];
            [label release];
        }
        self.toggleSwitches = temp;
    }
    
    CGFloat minimumWidth = (self.bounds.size.width - kTimelineLeftPadding - kTimelineRightPadding) / 5 - 2.0;
    CGFloat proposedWidth = ((self.bounds.size.width - kTimelineLeftPadding - kTimelineRightPadding) / [_allDrawingSettings count]) - 2.0;
    CGFloat originX = 1;
    CGFloat originY = 0;
    CGFloat sizeWidth = proposedWidth < minimumWidth ? minimumWidth : proposedWidth;
    CGFloat sizeHeight = kTimelineToggleSwitchHeight;
    
    for (int i = 0; i < [_allDrawingSettings count]; i++) {
        
        NSDictionary *setting = [_allDrawingSettings objectAtIndex:i];
        UILabel *label = [_toggleSwitches objectAtIndex:i];
        
        if (CGRectIsEmpty(label.frame)) {
            label.frame = CGRectIntegral(CGRectMake(originX, originY, sizeWidth, sizeHeight));
        }
        
        if ([_hiddenDrawingSettings containsObject:setting]) {
            label.backgroundColor = [UIColor lightGrayColor];
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                label.frame = CGRectIntegral(CGRectMake(originX + 2, originY + 2, sizeWidth - 4, sizeHeight - 4));
            } completion:^(BOOL finished) {
            }];
        }
        else {
            label.backgroundColor = setting[@"color"];

            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                label.frame = CGRectIntegral(CGRectMake(originX, originY, sizeWidth, sizeHeight));
            } completion:^(BOOL finished) {
            }];
        }
        
        label.textColor = [UIColor whiteColor];// ContrastColor(label.backgroundColor);
        label.text = setting[@"title"];

        originX += sizeWidth + 2.0;
    }
    
    _toggleSwitchContainer.contentSize = CGSizeMake(originX, sizeHeight);
}


- (void)createDrawingPaths
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < [_drawingSettings count]; i++) {
        
        NSMutableArray *temp = [NSMutableArray array];
        UIBezierPath *path = [UIBezierPath bezierPath];
        [temp addObject:path];
        
        NSDictionary *setting = [_drawingSettings objectAtIndex:i];
        NSString *dataKey = setting[@"key"];
        
        NSDictionary *leftAnchorData = [_leftAnchorData valueForKey:dataKey];
        NSDictionary *rightAnchorData = [_rightAnchorData valueForKey:dataKey];
        
        NSValue *leftAnchorValue = nil;
        NSValue *rightAnchorValue = nil;
        
        CGPoint lastControlPoint;

        if (leftAnchorData) {
            CGPoint anchor = [self calculateLeftAnchorPoint:leftAnchorData andDataKey:dataKey];
            lastControlPoint = anchor;
            leftAnchorValue = [NSValue valueWithCGPoint:anchor];
            [path moveToPoint:anchor];
        }
        if (rightAnchorData) {
            CGPoint anchor = [self calculateRightAnchorPoint:rightAnchorData andDataKey:dataKey];
            rightAnchorValue = [NSValue valueWithCGPoint:anchor];
        }
        
        
        NSArray *data = [_normalizedData valueForKey:dataKey];
        
        if ([data count] > 1) {
            int factor = 1 + ([data count] / kMaximumDataPointsPerTimeLine);
            
            for (int j = 0; j < [data count]; j++) {
                NSDictionary *datum = [data objectAtIndex:j];
                double time = [datum[@"date"] doubleValue];
                double value = [datum[@"value"] doubleValue];
                
                if (j%factor == 0) {
                    UIBezierPath *circle = [UIBezierPath
                                            bezierPathWithOvalInRect:CGRectMake(time - 1.5, value - 1.5, 3.0, 3.0)];
                    circle.lineWidth = 4.0;
                    [temp addObject:circle];
                }
                
                if (j == 0) {
                    if (!leftAnchorValue) {
                        lastControlPoint = CGPointMake(time, value);
                        [path moveToPoint:CGPointMake(time, value)];
                    }
                    else {
                        if ([data count] > 1) {
                            CGPoint anchor = leftAnchorValue.CGPointValue;
                            double pTime = anchor.x;
                            double pValue = anchor.y;
                            double nTime = [[data objectAtIndex:1][@"date"] doubleValue];
                            double nValue = [[data objectAtIndex:1][@"value"] doubleValue];
                            AddCurveToPath(path, CGPointMake(time, value), NO, pTime, pValue, nTime, nValue, &lastControlPoint);
                        }
                        else if (rightAnchorValue) {
                            CGPoint anchor = leftAnchorValue.CGPointValue;
                            CGPoint anchorRight = rightAnchorValue.CGPointValue;
                            double pTime = anchor.x;
                            double pValue = anchor.y;
                            double nTime = anchorRight.x;
                            double nValue = anchorRight.y;
                            AddCurveToPath(path, CGPointMake(time, value), NO, pTime, pValue, nTime, nValue, &lastControlPoint);
                        }
                        else {
                            CGPoint anchor = leftAnchorValue.CGPointValue;
                            double pTime = anchor.x;
                            double pValue = anchor.y;
                            double nTime = time;
                            double nValue = value;
                            AddCurveToPath(path, CGPointMake(time, value), NO, pTime, pValue, nTime, nValue, &lastControlPoint);
                        }
                    }
                }
                else {
                    if (j%factor != 0) {
                        continue;
                    }
                    else if (kTimelineEnableCurve) {
                        CGPoint dataPoint = CGPointMake(time, value);
                        
                        if (j == [data count] - 1) {
                            if (!rightAnchorValue) {
                                AddCurveToPath(path, dataPoint, YES, 0, 0, 0, 0, &lastControlPoint);
                            }
                            else {
                                CGPoint anchor = [rightAnchorValue CGPointValue];
                                double pTime = [[data objectAtIndex:j - 1][@"date"] doubleValue];
                                double pValue = [[data objectAtIndex:j - 1][@"value"] doubleValue];
                                double nTime = anchor.x;
                                double nValue = anchor.y;
                                
                                AddCurveToPath(path, dataPoint, NO, pTime, pValue, nTime, nValue, &lastControlPoint);
                            }
                        }
                        else {
                            double pTime = [[data objectAtIndex:j - 1][@"date"] doubleValue];
                            double pValue = [[data objectAtIndex:j - 1][@"value"] doubleValue];
                            double nTime = [[data objectAtIndex:j + 1][@"date"] doubleValue];
                            double nValue = [[data objectAtIndex:j + 1][@"value"] doubleValue];
                            
                            AddCurveToPath(path, dataPoint, NO, pTime, pValue, nTime, nValue, &lastControlPoint);
                        }
                    }
                    else {
                        [path addLineToPoint:CGPointMake(time, value)];
                    }
                }
            }

        }
        else {
            NSDictionary *datum = [data objectAtIndex:0];
            double time = [datum[@"date"] doubleValue];
            double value = [datum[@"value"] doubleValue];
            
            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(time - 1.5, value - 1.5, 3.0, 3.0)];
            [temp addObject:path];
        }
        
        if (rightAnchorData) {
            CGPoint anchor = [rightAnchorValue CGPointValue];
            AddCurveToPath(path, anchor, YES, 0, 0, 0, 0, &lastControlPoint);
        }
        
        path.lineWidth = [setting[@"width"] intValue];
        [result setValue:temp forKey:dataKey];        
    }
    
    self.drawingPaths = result;
}

void AddCurveToPath(UIBezierPath *path, CGPoint dataPoint, bool last, double pTime, double pValue, double nTime, double nValue, CGPoint *lastControlPoint)
{
    CGPoint cp1, cp2;
    
    cp1 = *lastControlPoint;
    
        // for first and last viewpoint after/before skipped viewpoints just let the control point
        // be at the viewpoint itself - first viewpoint is handled automatically by skipping logic
    if (last) {
        cp2              = dataPoint;
        *lastControlPoint = cp2;
        
        if (cp1.x > dataPoint.x) cp1 = CGPointMake(dataPoint.x, cp1.y);
        if (cp1.x < kTimelineLeftPadding) cp1 = CGPointMake(kTimelineLeftPadding, cp1.y);
        if (cp2.x > dataPoint.x) cp2 = CGPointMake(dataPoint.x, cp2.y);
        if (cp2.x < kTimelineLeftPadding) cp2 = CGPointMake(kTimelineLeftPadding, cp2.y);
    }
    else {
        
        CGPoint previousDataPoint = CGPointMake(pTime, pValue);
        CGPoint nextDataPoint = CGPointMake(nTime, nValue);
            // Estimate the tangent of viewpoint[i] to be the line between two points,
            //    partway to viewpoint[i-1] and partway to viewpoint[i+1]
            // Project the resulting tangent line back to the viewpoint
            // Use the endpoints of the tangent as control points in a bezier curve from viewpoint to viewpoint
        CGFloat c  = 0.2; // tangent lenght must be in interval [0;1]
        CGPoint t1 = CGPointMake( dataPoint.x - ( (dataPoint.x - previousDataPoint.x) * c ),
                                 dataPoint.y - ( (dataPoint.y - previousDataPoint.y) * c ) );
        CGPoint t2 = CGPointMake( dataPoint.x + ( (nextDataPoint.x - dataPoint.x) * c ),
                                 dataPoint.y + ( (nextDataPoint.y - dataPoint.y) * c ) );
        
            // vector from viewpoint to tangent center
        CGPoint center = CGPointMake( t1.x + ( (t2.x - t1.x) / 2.0 ), t1.y + ( (t2.y - t1.y) / 2.0 ) );
        CGPoint v      = CGPointMake(center.x - dataPoint.x, center.y - dataPoint.y);
        
            // project the tangent to the viewpoint
        t1.x = t1.x - v.x;
        t1.y = t1.y - v.y;
        t2.x = t2.x - v.x;
        t2.y = t2.y - v.y;
        
            //                    CGPoint currentPoint = [path currentPoint];
            //                    [path moveToPoint:t1];
            //                    [path addLineToPoint:t2];
            //                    [path moveToPoint:currentPoint];
            //
            //                    currentPoint = [path currentPoint];
            //                    [path moveToPoint:viewPoint];
            //                    [path addLineToPoint:CGPointMake(viewPoint.x + v.x, viewPoint.y + v.y)];
            //                    [path moveToPoint:currentPoint];
        
        cp2              = t1;
        *lastControlPoint = t2;
        
        if (cp1.x > dataPoint.x) cp1 = CGPointMake(dataPoint.x, cp1.y);
        if (cp1.x < previousDataPoint.x) cp1 = CGPointMake(previousDataPoint.x, cp1.y);
        if (cp1.x < kTimelineLeftPadding) cp1 = CGPointMake(kTimelineLeftPadding, cp1.y);
        if (cp2.x > dataPoint.x) cp2 = CGPointMake(dataPoint.x, cp2.y);
        if (cp2.x < kTimelineLeftPadding) cp2 = CGPointMake(kTimelineLeftPadding, cp2.y);
        if (cp2.x < previousDataPoint.x) cp2 = CGPointMake(previousDataPoint.x, cp2.y);

    }
    
    [path addCurveToPoint:dataPoint controlPoint1:cp1 controlPoint2:cp2];

}

- (CGPoint)calculateLeftAnchorPoint:(NSDictionary *)anchorData andDataKey:(NSString *)dataKey
{
    double time = [anchorData[@"date"] doubleValue];
    double value = [anchorData[@"value"] doubleValue];
    
    
    double x1 = time;
    double y1 = value;
    
    double x0 = kTimelineLeftPadding;
    
    NSArray *normalizedDataOfKey = [_normalizedData valueForKey:dataKey];
    if ([normalizedDataOfKey count] > 0) {
        
        NSDictionary *firstNormalizedData = [normalizedDataOfKey objectAtIndex:0];
        double x2 = [firstNormalizedData[@"date"] doubleValue];
        double y2 = [firstNormalizedData[@"value"] doubleValue];
        
        double y0 = ((x0 - x1) / (x2 - x1)) * (y2 - y1) + y1;
        
        return CGPointMake(x0, y0);
    }
    else if (_rightAnchorData[dataKey]) {
        double x2 = [_rightAnchorData[dataKey][@"date"] doubleValue];
        double y2 = [_rightAnchorData[dataKey][@"value"] doubleValue];
        
        double y0 = ((x0 - x1) / (x2 - x1)) * (y2 - y1) + y1;
        
        return CGPointMake(x0, y0);
    }
    else {
        return CGPointMake(x0, y1);
    }
}

- (CGPoint)calculateRightAnchorPoint:(NSDictionary *)anchorData andDataKey:(NSString *)dataKey
{
    double time = [anchorData[@"date"] doubleValue];
    double value = [anchorData[@"value"] doubleValue];
    
    
    double x1 = time;
    double y1 = value;
    
    double x0 = self.bounds.size.width - kTimelineRightPadding;
    
    NSArray *normalizedDataOfKey = [_normalizedData valueForKey:dataKey];
    
    if ([normalizedDataOfKey count] > 0) {
        NSDictionary *lastNormalizedData = [normalizedDataOfKey lastObject];
        double x2 = [lastNormalizedData[@"date"] doubleValue];
        double y2 = [lastNormalizedData[@"value"] doubleValue];
        
        double y0 = ((x0 - x1) / (x2 - x1)) * (y2 - y1) + y1;
        
        return CGPointMake(x0, y0);
    }
    else if (_leftAnchorData[dataKey]) {
        double x2 = [_leftAnchorData[dataKey][@"date"] doubleValue];
        double y2 = [_leftAnchorData[dataKey][@"value"] doubleValue];
        
        double y0 = ((x0 - x1) / (x2 - x1)) * (y2 - y1) + y1;
        
        return CGPointMake(x0, y0);
    }
    else {
        return CGPointMake(x0, y1);
    }

}

- (void)refreshTimeLine
{
        
    for (CALayer *layer in [_graphLayers allValues]) {
        [layer removeFromSuperlayer];
    }
    
    NSMutableDictionary *temp = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < [_drawingPaths count]; i ++) {
        NSDictionary *setting = [_drawingSettings objectAtIndex:i];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = self.bounds;
        [self.layer insertSublayer:shapeLayer atIndex:0];
        [temp setValue:shapeLayer forKey:setting[@"key"]];
    }
    
    self.graphLayers = temp;
    
    for (int i = 0; i < [_drawingPaths count]; i ++) {
        
        NSDictionary *setting = [_drawingSettings objectAtIndex:i];
        NSArray *paths = [_drawingPaths valueForKey:setting[@"key"]];
        
        CGMutablePathRef combinedPath = CGPathCreateMutable();
        
        for (UIBezierPath *path in paths) {
            CGPathAddPath(combinedPath, NULL, path.CGPath);
        }
        
        CAShapeLayer *shapeLayer = [_graphLayers valueForKey:setting[@"key"]];
        
        shapeLayer.strokeColor = [setting[@"color"] CGColor];
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        shapeLayer.lineWidth = [setting[@"width"] intValue];
        shapeLayer.path = combinedPath;
        
        CGPathRelease(combinedPath);
    }
}

UIColor * ContrastColor(UIColor * color)
{
    int d = 0;
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    float red = components[0];
    float green = components[1];
    float blue = components[2];
    
    double a = 1 - ( 0.299 * red + 0.587 * green + 0.114 * blue);
    if (a < 0.5) d = 0;
    else d = 1;
    return [UIColor colorWithRed:d green:d blue:d alpha:1.0];
}


#pragma mark - Public Methods
- (void)visualizeData:(NSArray *)data startDate:(NSDate *)startDate endDate:(NSDate *)endDate settings:(NSArray *)settings
{
    NSAssert([data count] == [settings count], @"For each data array, there must be a companion setting dict");
    
    self.originalData = data;
    if (_allDrawingSettings != settings) {
        self.allDrawingSettings = settings;
        self.drawingSettings = [NSMutableArray arrayWithArray:settings];
        self.hiddenDrawingSettings = [NSMutableArray array];
    }
    _earliestDateTimeInterval = [startDate timeIntervalSince1970];
    _latestDateTimeInterval = [endDate timeIntervalSince1970];
    if (_earliestDateTimeInterval == _latestDateTimeInterval) {
        _earliestDateTimeInterval = _earliestDateTimeInterval - 86400.0;
        _latestDateTimeInterval = _latestDateTimeInterval + 86400.0;
    }
    
    NSArray *units = [settings valueForKey:@"unit"];
    if ([units count] == [settings count] || [units count] == 0) {
        NSSet *unitSet = [NSSet setWithArray:units];
        if ([unitSet count] > 1) {
            self.supportedGraphTypes = @[@(kGraphTypePercentOfChange), @(kGraphTypeActualValue)];
            if (_graphType == kGraphTypeNone) {
                self.graphType = kGraphTypePercentOfChange;
            }
            else {
                self.graphType = _graphType;
            }
        }
        else {
            self.supportedGraphTypes = @[@(kGraphTypePercentOfChange), @(kGraphTypeActualValue)];
            if (_graphType == kGraphTypeNone) {
                self.graphType = kGraphTypeActualValue;
            }
            else {
                self.graphType = _graphType;
            }
        }
    }
    else {
        self.supportedGraphTypes = @[@(kGraphTypePercentOfChange), @(kGraphTypeActualValue)];
        if (_graphType == kGraphTypeNone) {
            self.graphType = kGraphTypePercentOfChange;
        }
        else {
            self.graphType = _graphType;
        }
    }
    
    [self preprocessData];
    [self refreshGraphIfNeeded];
}


#pragma mark - Touch
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    if (CGRectContainsPoint([self graphRect], location)) {
        [self findUpdateNearestValueByLocation:location.x];
        [self updateHoverLineLabels];
    }
    
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    if (CGRectContainsPoint([self graphRect], location)) {
        [self findUpdateNearestValueByLocation:location.x];
        [self updateHoverLineLabels];
    }
    
    [super touchesEnded:touches withEvent:event];
}

#pragma mark - Actions
- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    NSInteger switchIndex = [_toggleSwitches indexOfObject:recognizer.view];
    NSDictionary *setting = [_allDrawingSettings objectAtIndex:switchIndex];
    
    if ([_hiddenDrawingSettings containsObject:setting]) {
        [_drawingSettings addObject:setting];
        [_hiddenDrawingSettings removeObject:setting];
    }
    else {
        [_hiddenDrawingSettings addObject:setting];
        [_drawingSettings removeObject:setting];
    }
    
    [self preprocessData];
    [self refreshGraphIfNeeded];

}

- (void)handleLongPressGestureRecognizer:(UILongPressGestureRecognizer *)recognizer
{
    NSInteger switchIndex = [_toggleSwitches indexOfObject:recognizer.view];
    NSDictionary *setting = [_allDrawingSettings objectAtIndex:switchIndex];
    
    [_drawingSettings removeAllObjects];
    [_drawingSettings addObject:setting];
    [_hiddenDrawingSettings addObjectsFromArray:_allDrawingSettings];
    [_hiddenDrawingSettings removeObject:setting];
    
    [self preprocessData];
    [self refreshGraphIfNeeded];
}

- (void)toggleSwitchAllButtonClicked:(id)sender
{
    if ([_drawingSettings count] < [_allDrawingSettings count]) {
        [_drawingSettings removeAllObjects];
        [_drawingSettings addObjectsFromArray:_allDrawingSettings];
        [_hiddenDrawingSettings removeAllObjects];
    }
    else {
        [_hiddenDrawingSettings removeAllObjects];
        [_hiddenDrawingSettings addObjectsFromArray:_allDrawingSettings];
        [_drawingSettings removeAllObjects];
    }
    
    [self preprocessData];
    [self refreshGraphIfNeeded];
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint location = [recognizer locationInView:self];
            _dateSelectionStart = location.x;
            if (_dateSelectionStart < kTimelineLeftPadding) _dateSelectionStart = kTimelineLeftPadding;
            if (_dateSelectionStart > self.bounds.size.width - kTimelineRightPadding) _dateSelectionStart = self.bounds.size.width - kTimelineRightPadding;
            
            if (_dateSelectionBox) {
                [_dateSelectionBox removeFromSuperlayer];
                self.dateSelectionBox = nil;
            }
            
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(_dateSelectionStart, kTimelineTopPadding, 0.5, self.bounds.size.height - kTimelineTopPadding - kTimelineBottomPadding)];
            CAShapeLayer *box = [CAShapeLayer layer];
            box.strokeColor = [UIColor lightGrayColor].CGColor;
            box.fillColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5].CGColor;
            box.path = path.CGPath;
            [self.layer addSublayer:box];
            self.dateSelectionBox = box;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (_dateSelectionBox) {
                CGPoint location = [recognizer locationInView:self];
                if (location.x > _dateSelectionStart) {
                    CGFloat endX = location.x;
                    if (endX > self.bounds.size.width - kTimelineRightPadding) endX = self.bounds.size.width - kTimelineRightPadding;
                    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(_dateSelectionStart, kTimelineTopPadding, endX - _dateSelectionStart, self.bounds.size.height - kTimelineTopPadding - kTimelineBottomPadding)];
                    _dateSelectionBox.path = path.CGPath;
                    
                    if (location.x > _dateSelectionStart + kTimelineDateSelectionMinimumPixel) {
                        _dateSelectionBox.strokeColor = [UIColor blueColor].CGColor;
                        _dateSelectionBox.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.5].CGColor;
                    }
                    else {
                        _dateSelectionBox.strokeColor = [UIColor lightGrayColor].CGColor;
                        _dateSelectionBox.fillColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5].CGColor;
                    }
                }
                else {
                    CGFloat originX = location.x;
                    if (originX < kTimelineLeftPadding) originX = kTimelineLeftPadding;
                    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(originX, kTimelineTopPadding, _dateSelectionStart - originX, self.bounds.size.height - kTimelineTopPadding - kTimelineBottomPadding)];
                    _dateSelectionBox.path = path.CGPath;
                    
                    if (_dateSelectionStart > location.x + kTimelineDateSelectionMinimumPixel) {
                        _dateSelectionBox.strokeColor = [UIColor blueColor].CGColor;
                        _dateSelectionBox.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.5].CGColor;
                    }
                    else {
                        _dateSelectionBox.strokeColor = [UIColor lightGrayColor].CGColor;
                        _dateSelectionBox.fillColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5].CGColor;
                    }
                }
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            CGPoint location = [recognizer locationInView:self];
            if (location.x > _dateSelectionStart + kTimelineDateSelectionMinimumPixel) {
                CGFloat endX = location.x;
                if (endX > self.bounds.size.width - kTimelineRightPadding) endX = self.bounds.size.width - kTimelineRightPadding;
                
                double startDateTimeInterval = ((_dateSelectionStart - kTimelineLeftPadding)/(self.bounds.size.width - kTimelineLeftPadding - kTimelineRightPadding)) * (_latestDateTimeInterval - _earliestDateTimeInterval) + _earliestDateTimeInterval;
                double endDateTimeInterval = ((endX - kTimelineLeftPadding)/(self.bounds.size.width - kTimelineLeftPadding - kTimelineRightPadding)) * (_latestDateTimeInterval - _earliestDateTimeInterval) + _earliestDateTimeInterval;
                
                [_delegate timelineGraph:self didSelectHardStartDate:[NSDate dateWithTimeIntervalSince1970:startDateTimeInterval] andHardEndDate:[NSDate dateWithTimeIntervalSince1970:endDateTimeInterval]];
                
            }
            else if (_dateSelectionStart > location.x + kTimelineDateSelectionMinimumPixel){
                CGFloat originX = location.x;
                if (originX < kTimelineLeftPadding) originX = kTimelineLeftPadding;
                
                double startDateTimeInterval = ((originX - kTimelineLeftPadding)/(self.bounds.size.width - kTimelineLeftPadding - kTimelineRightPadding)) * (_latestDateTimeInterval - _earliestDateTimeInterval) + _earliestDateTimeInterval;
                double endDateTimeInterval = ((_dateSelectionStart - kTimelineLeftPadding)/(self.bounds.size.width - kTimelineLeftPadding - kTimelineRightPadding)) * (_latestDateTimeInterval - _earliestDateTimeInterval) + _earliestDateTimeInterval;
                
                [_delegate timelineGraph:self didSelectHardStartDate:[NSDate dateWithTimeIntervalSince1970:startDateTimeInterval] andHardEndDate:[NSDate dateWithTimeIntervalSince1970:endDateTimeInterval]];
            }
            
            if (_dateSelectionBox) {
                [_dateSelectionBox removeFromSuperlayer];
                self.dateSelectionBox = nil;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark Utilities
- (NSString *)trimTrailingZeros:(NSString *)original
{
    NSString *result = original;
    
    if ([original rangeOfString:@"."].location != NSNotFound) {
        int index = (int)[result length] - 1;
        BOOL trim = NO;
        while (
               ([result characterAtIndex:index] == '0' ||
                [result characterAtIndex:index] == '.')
               &&
               index > 0)
        {
            index--;
            trim = YES;
            
            if ([result characterAtIndex:index + 1] == '.') {
                break;
            }
        }
        if (trim)
            result = [result substringToIndex: index +1];
        
    }
    
    int index = 0;
    BOOL trim = NO;
    while ([result characterAtIndex:index] == '0' && index < [result length]-1) {
        index ++;
        trim = YES;
    }
    
    if (trim) {
        result = [result substringFromIndex:index];
    }
    
    if ([result length] == 0) {
        result = @"0";
    }
    
    if ([result characterAtIndex:0] == '.') {
        result = [NSString stringWithFormat:@"0%@", result];
    }
    
    return result;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == DRTimelineGraphContext) {
        CGPoint offset = [[change valueForKey:@"new"] CGPointValue];
        CGFloat distanceFromBegin = abs(offset.x);
        CGFloat distanceFromEnd = _toggleSwitchContainer.contentSize.width > _toggleSwitchContainer.frame.size.width ? abs(_toggleSwitchContainer.contentSize.width - _toggleSwitchContainer.frame.size.width - offset.x) : 0;
        
        _leftShadowView.alpha = distanceFromBegin / 20.0 <= 1 ? distanceFromBegin / 20.0 : 1;
        _rightShadowView.alpha = distanceFromEnd / 20.0 <= 1 ? distanceFromEnd / 20.0 : 1;
    }
}
@end

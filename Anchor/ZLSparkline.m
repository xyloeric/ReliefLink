//
//  DRSparkline.m
//  ZLCommonLibrary
//
//  Created by Eric Li on 3/15/13.
//  Copyright (c) 2013 Eric Li. All rights reserved.
//


#import "ZLSparkline.h"
#import "ANCommons.h"

@interface ZLSparkline ()
{
    NSInteger _dataCount;
    BOOL _renderForPdf;
}
@property (nonatomic, retain) NSArray *normalizedData;

@property (nonatomic, retain) NSString *referenceValue;
@property (nonatomic, retain) NSNumber *normalizedRefValue;

@property (nonatomic) double maximumValue, minimumValue;

@property (nonatomic, retain) NSArray *drawingPaths;
@property (nonatomic, retain) NSArray *graphLayers;
@end

@implementation ZLSparkline

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hidden = YES;
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapRecognizer:)];
        [self addGestureRecognizer:recognizer];
        [recognizer release];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapRecognizer:)];
        [self addGestureRecognizer:recognizer];
        [recognizer release];
    }
    return self;
}

- (void)dealloc
{
    [_originalData release];
    [_normalizedData release];
    [_drawingSettings release];
    [_referenceValue release];
    [_drawingPaths release];
    [_graphLayers release];
    [_groupKey release];
    [super dealloc];
}

- (void)layoutIfNeeded
{
    [self normalizeData];
    _renderForPdf = NO;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *textColor = nil;
    if (_renderForPdf) {
        textColor = [UIColor colorWithRed:CG(77) green:CG(77) blue:CG(77) alpha:1.0];
    }
    else {
        textColor = [UIColor colorWithRed:CG(255) green:CG(255) blue:CG(255) alpha:0.8];
    }
    
    if (self.maximumValue == self.minimumValue) {
        NSString *maximumString = [NSString stringWithFormat:@"%g", _maximumValue];
        DrawMaxMinValue(context, self.bounds, CGPointMake(2, self.bounds.size.height / 2.0 + 4), [maximumString cStringUsingEncoding:NSASCIIStringEncoding], maximumString.length, textColor);
        
    }
    else {
        NSString *maximumString = [NSString stringWithFormat:@"%g", _maximumValue];
        NSString *minimumString = [NSString stringWithFormat:@"%g", _minimumValue];
        DrawMaxMinValue(context, self.bounds, CGPointMake(2, 8), [maximumString cStringUsingEncoding:NSASCIIStringEncoding], maximumString.length, textColor);
        DrawMaxMinValue(context, self.bounds, CGPointMake(2, self.bounds.size.height - 2), [minimumString cStringUsingEncoding:NSASCIIStringEncoding], minimumString.length, textColor);
    }
    
    for (int i = 0; i < [_drawingPaths count]; i++) {
        UIBezierPath *path = [_drawingPaths objectAtIndex:i];
        NSDictionary *setting = [_drawingSettings objectAtIndex:i];
        if (_renderForPdf) {
            CGContextSetStrokeColorWithColor(context, ((UIColor *)[kDRGraphBrightColorScheme objectAtIndex:i%[kDRGraphBrightColorScheme count]]).CGColor);
        }
        else {
            CGContextSetStrokeColorWithColor(context, ((UIColor *)[kDRGraphCoolColorScheme objectAtIndex:i%[kDRGraphCoolColorScheme count]]).CGColor);
        }
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
        if (_renderForPdf) {
            path.lineWidth = 1;
        }
        else {
            path.lineWidth = [setting[@"width"] intValue];
        }
        [path stroke];
    }
}



void DrawMaxMinValue (CGContextRef context, CGRect contextRect, CGPoint point, const char * text, u_int length, UIColor *textColor) // 1
{
    CGFloat w, h;
    w = contextRect.size.width;
    h = contextRect.size.height;
    
    CGContextSelectFont (context, "Verdana", 8, kCGEncodingMacRoman);
    CGContextSetCharacterSpacing (context, 1);
    CGContextSetTextDrawingMode (context, kCGTextFillStroke);
    CGAffineTransform flipTransform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0.f, contextRect.size.height),
                                                              CGAffineTransformMakeScale(1.f, -1.f));
    CGContextSetFillColorWithColor(context, textColor.CGColor);
    CGContextSetStrokeColorWithColor(context, textColor.CGColor);

    CGContextSetTextMatrix (context, flipTransform); 
    CGContextShowTextAtPoint (context, point.x, point.y, text, length);
}

void AddDashStyleToPath(UIBezierPath* thePath)
{
    float lineDash[1];
    
    lineDash[0] = 4.0;
    
    [thePath setLineDash:lineDash count:1 phase:0.0];
}

- (void)normalizeData
{
    @autoreleasepool {
        double earlistTime = DBL_MAX;
        double latestTime = DBL_MIN;
        double minimumValue = DBL_MAX;
        double maximumValue = -DBL_MAX;
        
        NSMutableArray *validData = [NSMutableArray array];
        
        int dataCount = 0;
        
        for (NSArray *dataArray in _originalData) {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
            NSMutableArray *sortedData = [[[dataArray sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy] autorelease];
            [sortDescriptor release];
            
            NSMutableArray *invalidData = [NSMutableArray array];
            
            for (NSDictionary *data in sortedData) {
                if ([data valueForKey:@"date"] && [data valueForKey:@"value"] && ![[data valueForKey:@"value"] isEqualToString:@"None"]) {
                    double time = [data[@"date"] timeIntervalSince1970];
                    double value = [data[@"value"] doubleValue];
                    
                    if (time < earlistTime) earlistTime = time;
                    
                    if (time > latestTime) latestTime = time;
                    
                    if (value < minimumValue) minimumValue = value;
                    
                    if (value > maximumValue) maximumValue = value;
                    
                }
                else {
                    [invalidData addObject:data];
                }
            }
            
            [sortedData removeObjectsInArray:invalidData];
            
            [validData addObject:sortedData];
            
            dataCount += [sortedData count];
        }
        
        _dataCount = dataCount;
        
        self.maximumValue = maximumValue;
        self.minimumValue = minimumValue;
        
        if (dataCount == 0) {
            self.hidden = YES;
        }
        else {
            self.hidden = NO;
            
            double valueSpan = maximumValue - minimumValue;
            double mean = (maximumValue + minimumValue) / 2.0;
            
            if (latestTime == earlistTime) {
                earlistTime = earlistTime - 86400.0;
                latestTime = latestTime + 86400.0;
            }
            
            double timeSpan = latestTime - earlistTime;
            
            NSMutableArray *result = [NSMutableArray array];

            for (NSArray *dataArray in validData) {
                NSMutableArray *temp = [NSMutableArray array];
                
                for (NSDictionary *data in dataArray) {
                    double time = [data[@"date"] timeIntervalSince1970];
                    double value = [data[@"value"] doubleValue];
                                        
                    double normValue = self.frame.size.height - ((self.frame.size.height / 2.0) + ((value - mean) * (valueSpan != 0 ? ((self.frame.size.height - kSparklineTopPadding - kSparklineBottomPadding) / valueSpan) : 0)));
                    double normTime = ((time - earlistTime) / timeSpan) * (self.frame.size.width - kSparklineLeftPadding - kSparklineRightPadding) + kSparklineLeftPadding;
                    
                    [temp addObject:@{@"date": @(normTime), @"value" : @(normValue)}];
                }
                
                [result addObject:temp];
            }
            
            
            self.normalizedData = result;
            
            [self createDrawingPaths];

            if (_referenceValue) {
                self.normalizedRefValue = @((1- (([_referenceValue doubleValue] - minimumValue) / valueSpan)) * (self.frame.size.height - kSparklineTopPadding - kSparklineBottomPadding) + kSparklineBottomPadding);
            }
        }
    }
}

- (void)createDrawingPaths
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (int i = 0; i < [_drawingSettings count]; i++) {
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        NSArray *data = [_normalizedData objectAtIndex:i];
        
        if ([data count] > 1) {
            int factor = 1 + ([data count] / kMaximumDataPointsPerSparkline);
            
            for (int j = 0; j < [data count]; j++) {
                NSDictionary *datum = [data objectAtIndex:j];
                double time = [datum[@"date"] doubleValue];
                double value = [datum[@"value"] doubleValue];
                
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
        }
        
        [result addObject:path];
    }
    
    self.drawingPaths = result;
}

#pragma mark -
#pragma mark Thumbnail
- (void)saveSparklineAsThumbnail
{
    _renderForPdf = YES;
    NSString *thumbnailCachePath = kGraphThumbnailCachePath;
    NSString *thumbnailPDFPath = [thumbnailCachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", _groupKey]];
    
    if (_dataCount > 0) {
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:thumbnailCachePath]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:thumbnailCachePath withIntermediateDirectories:YES attributes:nil error:&error];
            if(![[NSFileManager defaultManager] setAttributes:@{NSFileProtectionKey : NSFileProtectionComplete} ofItemAtPath:thumbnailCachePath error:&error]){
                NSLog(@"Cache file protection error %@, %@", error, [error userInfo]);
            }
            if (error) {
                NSLog(@"Error creating directory: %@", [error localizedDescription]);
            }
        }
                
        UIGraphicsBeginPDFContextToFile(thumbnailPDFPath, self.bounds, nil);
        UIGraphicsBeginPDFPage();
        [self drawLayer:self.layer inContext:UIGraphicsGetCurrentContext()];
        UIGraphicsEndPDFContext();
    }
    else {
        if (![[NSFileManager defaultManager] fileExistsAtPath:thumbnailCachePath]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:thumbnailCachePath withIntermediateDirectories:YES attributes:nil error:&error];
            if(![[NSFileManager defaultManager] setAttributes:@{NSFileProtectionKey : NSFileProtectionComplete} ofItemAtPath:thumbnailCachePath error:&error]){
                NSLog(@"Cache file protection error %@, %@", error, [error userInfo]);
            }
            if (error) {
                NSLog(@"Error creating directory: %@", [error localizedDescription]);
            }
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
        label.textAlignment = UITextAlignmentCenter;
        label.numberOfLines = 2;
        label.textColor = [UIColor darkTextColor];
        label.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:14];
        label.text = @"Not Enough Data for Visualization";
        
        UIGraphicsBeginPDFContextToFile(thumbnailPDFPath, self.bounds, nil);
        UIGraphicsBeginPDFPage();
        [label drawLayer:label.layer inContext:UIGraphicsGetCurrentContext()];
        UIGraphicsEndPDFContext();
        
        [label release];
    }
}


#pragma mark - Public Methods
- (void)visualizeData:(NSArray *)data referenceValue:(NSString *)ref withSettings:(NSArray *)settings
{
    NSAssert([data count] == [settings count], @"For each data array, there must be a companion setting dict");
    
    self.originalData = data;
    self.drawingSettings = settings;
    self.referenceValue = ref;
    [self normalizeData];
    _renderForPdf = NO;
    [self setNeedsDisplay];
}

- (void)visualizeData:(NSArray *)data withSettings:(NSArray *)settings
{
    [self visualizeData:data settings:settings groupKey:nil];
}

- (void)visualizeData:(NSArray *)data settings:(NSArray *)settings groupKey:(NSString *)groupKey
{
    NSAssert([data count] == [settings count], @"For each data array, there must be a companion setting dict");
    
    self.originalData = data;
    self.drawingSettings = settings;
    self.groupKey = groupKey;
    [self normalizeData];
    _renderForPdf = NO;
    [self setNeedsDisplay];
}

#pragma mark - Actions
- (void)handleTapRecognizer:(UITapGestureRecognizer *)recognizer
{
    [_delegate sparklineDidTap:self];
}

@end

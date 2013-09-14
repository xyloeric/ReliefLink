//
//  DRSparkline.h
//  ZLCommonLibrary
//
//  Created by Eric Li on 3/15/13.
//  Copyright (c) 2013 Eric Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLGraphSetting.h"

@class ZLSparkline;

@protocol ZLSparklineDelegate <NSObject>
- (void)sparklineDidTap:(ZLSparkline *)sparkline;
@end

@interface ZLSparkline : UIView
@property (nonatomic, assign) id<ZLSparklineDelegate> delegate;
@property (nonatomic, retain) NSArray *originalData;
@property (nonatomic, retain) NSArray *drawingSettings;
@property (nonatomic, retain) NSString *groupKey;

@property (nonatomic) DRGraphType graphType;

- (void)visualizeData:(NSArray *)data withSettings:(NSArray *)settings;
- (void)visualizeData:(NSArray *)data settings:(NSArray *)settings groupKey:(NSString *)groupKey;
- (void)saveSparklineAsThumbnail;

@end

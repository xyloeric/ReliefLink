//
//  ZLOverviewLineGraph.h
//  ZLCommonLibrary
//
//  Created by Eric Li on 3/19/13.
//  Copyright (c) 2013 Eric Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLGraphSetting.h"

@class ZLOverviewLineGraph;

@protocol ZLOverviewLineGraphDelegate <NSObject>

- (void)overviewLineGraph:(ZLOverviewLineGraph *)overviewLine didSelectdData:(NSArray *)data startDate:(NSDate *)startDate endDate:(NSDate *)endDate andSettings:(NSArray *)settings;

@optional
- (void)overviewLineGraph:(ZLOverviewLineGraph *)overviewLine didSelectHardStartDate:(NSDate *)startDate andHardEndDate:(NSDate *)endDate;
@end

@interface ZLOverviewLineGraph : UIView
@property (nonatomic, assign) id<ZLOverviewLineGraphDelegate> delegate;
@property (nonatomic) DRGraphType graphType;

- (void)visualizeData:(NSArray *)data settings:(NSArray *)settings;
- (void)setHardDateRangeWithStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;
- (void)resetHardDateRange;

@end

//
//  DRTimelineGraph.h
//  ZLCommonLibrary
//
//  Created by Eric Li on 3/19/13.
//  Copyright (c) 2013 Eric Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLGraphSetting.h"

@class ZLTimelineGraph;

@protocol ZLTimelineGraphDelegate <NSObject>
- (void)timelineGraph:(ZLTimelineGraph *)timelineGraph didSelectHardStartDate:(NSDate *)startDate andHardEndDate:(NSDate *)endDate;
- (void)timelineGraph:(ZLTimelineGraph *)timelineGraph didSelectGraphType:(DRGraphType)graphType withSupportedGraphTypes:(NSArray *)supportedGraphTypes;
@end

@interface ZLTimelineGraph : UIView
@property (nonatomic, assign) id<ZLTimelineGraphDelegate> delegate;
@property (nonatomic) DRGraphType graphType;

- (void)visualizeData:(NSArray *)data startDate:(NSDate *)startDate endDate:(NSDate *)endDate settings:(NSArray *)settings;
@end

//
//  DRGraphSetting.h
//  ZLCommonLibrary
//
//  Created by Eric Li on 4/2/13.
//  Copyright (c) 2013 Eric Li. All rights reserved.
//

#ifndef Anchor_ZLGraphSetting_h
#define Anchor_ZLGraphSetting_h

#define kMaximumDataPointsPerTimeLine 200
#define kMaximumDataPointsPerOverviewLine 500
#define kMaximumDataPointsPerSparkline 50

typedef enum {
    kGraphTypeNone,
    kGraphTypeActualValue,
    kGraphTypePercentOfChange,
}DRGraphType;

/*
 Graph Setting Keys
*/
#define kGraphSettingColorKey @"color"
#define kGraphSettingIdentifierKey @"key"
#define kGraphSettingTitleKey @"title"
#define kGraphSettingUnitKey @"unit"
#define kGraphSettingWidthKey @"width"
#define kGraphSettingDataCategory @"patch_data_category"

/*
 Graph Data Keys
*/
#define kGraphDataValueKey @"value"
#define kGraphDataTimeKey @"time"

#define kGraphThumbnailCachePath [NSString stringWithFormat:@"%@/Library/Caches/GraphThumbs/", NSHomeDirectory()]


/*
 Graph Color Schemes
*/

#define kDRGraphCoolColorScheme @[[UIColor whiteColor], \
[UIColor colorWithRed:CG(220) green:CG(220) blue:CG(220) alpha:1.0],\
[UIColor colorWithRed:CG(101) green:CG(168) blue:CG(196) alpha:1.0], \
[UIColor colorWithRed:CG(170) green:CG(206) blue:CG(226) alpha:1.0], \
[UIColor colorWithRed:CG(140) green:CG(101) blue:CG(211) alpha:1.0], \
[UIColor colorWithRed:CG(154) green:CG(147) blue:CG(236) alpha:1.0], \
[UIColor colorWithRed:CG(202) green:CG(185) blue:CG(241) alpha:1.0], \
[UIColor colorWithRed:CG(65) green:CG(179) blue:CG(247) alpha:1.0], \
[UIColor colorWithRed:CG(120) green:CG(203) blue:CG(248) alpha:1.0], \
[UIColor colorWithRed:CG(0) green:CG(173) blue:CG(206) alpha:1.0], \
[UIColor colorWithRed:CG(89) green:CG(219) blue:CG(241) alpha:1.0], \
[UIColor colorWithRed:CG(158) green:CG(231) blue:CG(250) alpha:1.0], \
[UIColor colorWithRed:CG(0) green:CG(197) blue:CG(144) alpha:1.0], \
[UIColor colorWithRed:CG(115) green:CG(235) blue:CG(174) alpha:1.0], \
[UIColor colorWithRed:CG(181) green:CG(249) blue:CG(211) alpha:1.0]]

#define kDRGraphBrightColorScheme @[[UIColor colorWithRed:CG(255) green:CG(135) blue:CG(51) alpha:1.0], \
[UIColor colorWithRed:CG(85) green:CG(145) blue:CG(225) alpha:1.0], \
[UIColor colorWithRed:CG(130) green:CG(100) blue:CG(200) alpha:1.0], \
[UIColor colorWithRed:CG(60) green:CG(180) blue:CG(185) alpha:1.0], \
[UIColor colorWithRed:CG(204) green:CG(102) blue:CG(102) alpha:1.0], \
[UIColor colorWithRed:CG(70) green:CG(170) blue:CG(40) alpha:1.0], \
[UIColor colorWithRed:CG(210) green:CG(100) blue:CG(210) alpha:1.0], \
[UIColor colorWithRed:CG(210) green:CG(135) blue:CG(85) alpha:1.0], \
[UIColor colorWithRed:CG(160) green:CG(135) blue:CG(220) alpha:1.0], \
[UIColor colorWithRed:CG(85) green:CG(195) blue:CG(245) alpha:1.0], \
[UIColor colorWithRed:CG(255) green:CG(110) blue:CG(255) alpha:1.0], \
[UIColor colorWithRed:CG(115) green:CG(205) blue:CG(90) alpha:1.0], \
[UIColor colorWithRed:CG(102) green:CG(102) blue:CG(102) alpha:1.0]]


/*
 Sparkline settings
 */
 
#define kSparklineLeftPadding 32.0
#define kSparklineRightPadding 4.0
#define kSparklineTopPadding 7.0
#define kSparklineBottomPadding 7.0
#define kSparklineMaxLineOffset 4.0
#define kSparklineMinLineOffset 4.0

#define kSparklineEnableCurve 0
/*
 Overview line settings
 */
 
#define kOverviewLineLeftPadding 5.0
#define kOverviewLineRightPadding 5.0
#define kOverviewLineTopPadding 20.0
#define kOverviewLineBottomPadding 20.0

#define kOverviewLineBoarderWidth 1.0

#define kOverviewLineEnableCurve 0
/*
Timeline settings
*/

#define kTimelineLeftPadding 32.0
#define kTimelineRightPadding 4.0
#define kTimelineTopPadding 7.0
#define kTimelineBottomPadding 20.0
#define kTimelineToggleSwitchHeight 0.0

#define kTimelineXAxisOffsetFromBottom 20.0
#define kTimelineYAxisOffsetFromLeft 20.0

#define kTimelineCoordinateColor [UIColor colorWithRed:CG(204) green:CG(204) blue:CG(204) alpha:1]
#define kTimelineTickerLabelTextColor [UIColor colorWithRed:CG(51) green:CG(51) blue:CG(51) alpha:1]
#define kTimelineHoverDateLabelTextColor [UIColor whiteColor]
#define kTimelineHoverlineColor [UIColor colorWithRed:CG(102) green:CG(153) blue:CG(204) alpha:1]

#define kTimelineDateSelectionMinimumPixel 20


#define kTimelineEnableCurve 1


#endif

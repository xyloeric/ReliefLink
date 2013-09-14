//
//  SafetyPlanningStepDelegate.h
//  ReliefLink
//
//  Created by Eric Li on 8/5/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol SafetyPlanningStepDelegate <NSObject>
- (void)safetyPlanningStepViewController:(UIViewController *)controller requestDisplayingHoveringView:(UIView *)hoverView hoveringViewType:(NSInteger)hoverType;
- (void)safetyPlanningStepViewControllerRequestHideHoveringView:(UIViewController *)controller;
@end
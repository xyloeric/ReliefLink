//
//  ANCommons.h
//  Anchor
//
//  Created by Eric Li on 7/17/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#ifndef Anchor_ANCommons_h
#define Anchor_ANCommons_h

#define kANBoarderSemiTransparentColor [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3]
#define CG(x) ((x)/255.0)
#define METERS_PER_MILE 1609.344
#define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360

#define kMapRelevantTerms @[@"suicide prevention", @"mental health", @"emergency room", @"hospital"]

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


#endif

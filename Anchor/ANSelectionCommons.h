//
//  ANSelectionCommons.h
//  Anchor
//
//  Created by Eric Li on 7/28/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#ifndef Anchor_ANSelectionCommons_h
#define Anchor_ANSelectionCommons_h

typedef enum  {
    kSelectionTypeWarningSign,
    kSelectionTypeCopingStrategy = 1,
} ANSelectionViewControllerType;

#define kWarningSignItems @[@{@"title": @"Hopelessness", @"details": @"e.g., There's no way that I can make things better"}, \
                            @{@"title": @"Feeling trapped", @"details": @"e.g., There's no way out"}, \
                            @{@"title": @"Withdrawal from family or friends", @"details": @""}, \
                            @{@"title": @"Anxiety, agitation", @"details": @""}, \
                            @{@"title": @"Sleep problems", @"details": @"e.g., Too much or too little"}, \
                            @{@"title": @"Dramatic mood changes", @"details": @""}, \
                            @{@"title": @"No reason for living", @"details": @"e.g., Life isn't worth living"}, \
                            @{@"title": @"Reckless, risk-taking behavior", @"details": @""}, \
                            @{@"title": @"Threatening to hurt or kill self", @"details": @""}, \
                            @{@"title": @"Looking for ways to kill self", @"details": @""}, \
                            @{@"title": @"Talking or writing about death", @"details": @"e.g.  dying or suicide"}, \
                            @{@"title": @"Giving away valued possessions", @"details": @"e.g., pets, books, tools"}]

#define kCopingStrategyItems @[@{@"title": @"Relaxation exercises", @"details": @"e.g. Breathing exercise available in the Resources section", @"launchOption": @"2"}, \
@{@"title": @"Mindfulness exercises", @"details": @"e.g. Mindfulness exercise available in the Resources section", @"launchOption": @"1"}, \
                               @{@"title": @"Physical activity", @"details": @"e.g. Take a walk"}, \
                               @{@"title": @"Listen to relaxing music", @"details": @"e.g. Relaxing radio available in the Resources section", @"launchOption": @"4"}, \
                               @{@"title": @"Read helpful quotes", @"details": @"e.g. Read tweets with inspirational messages from people who care", @"launchOption": @"3"}]

#define kSafetyTipItems @[@{@"title": @"Put away weapons in my household"}, @{@"title": @"Ask my friend to keep my medicine"}]

#endif

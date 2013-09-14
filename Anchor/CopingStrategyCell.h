//
//  CopingStrategyCell.h
//  ReliefLink
//
//  Created by Eric Li on 8/6/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InternalCopingStrategy.h"

@interface CopingStrategyCell : UITableViewCell
@property (nonatomic, retain) InternalCopingStrategy *internalCopingStrategy;
@end

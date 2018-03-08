//
//  ANSelectionViewController.h
//  Anchor
//
//  Created by Eric Li on 7/28/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ANSelectionViewController;

@protocol ANSelectionViewControllerDelegate <NSObject>
- (void)ANSelectionViewController:(ANSelectionViewController *)controller didSelectItem:(id)item;
@end

@interface ANSelectionViewController : UIViewController
@property (nonatomic, assign) id<ANSelectionViewControllerDelegate> delegate;

- (id)initWithType:(NSUInteger)selectionType;

@end

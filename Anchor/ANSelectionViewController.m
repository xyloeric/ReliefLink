//
//  ANSelectionViewController.m
//  Anchor
//
//  Created by Eric Li on 7/28/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ANSelectionViewController.h"
#import "ANSelectionCommons.h"
#import <QuartzCore/QuartzCore.h>
#import "ANSelectionCell.h"

@interface ANSelectionViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) ANSelectionViewControllerType selectionType;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSArray *items;

@end

@implementation ANSelectionViewController

- (id)initWithType:(NSUInteger)selectionType
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.selectionType = (ANSelectionViewControllerType)selectionType;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_tableView registerNib:[UINib nibWithNibName:@"ANSelectionCell" bundle:nil] forCellReuseIdentifier:@"ANSelectionCell"];
    
    _tableView.layer.cornerRadius = 5.0;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableView release];
    [_items release];
    [super dealloc];
}

#pragma mark - Custom Getter/Setter
- (void)setSelectionType:(ANSelectionViewControllerType)selectionType
{
    if (_selectionType != selectionType) {
        _selectionType = selectionType;
        
        switch (_selectionType) {
            case kSelectionTypeWarningSign:
                self.items = kWarningSignItems;
                break;
            case kSelectionTypeCopingStrategy:
                self.items = kCopingStrategyItems;
                break;
            default:
                break;
        }
        
        [_tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ANSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ANSelectionCell"];
    
    id item = [_items objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = [item valueForKey:@"title"];
    cell.detailLabel.text = [item valueForKey:@"details"];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [_items objectAtIndex:indexPath.row];
    [_delegate ANSelectionViewController:self didSelectItem:item];
}

@end

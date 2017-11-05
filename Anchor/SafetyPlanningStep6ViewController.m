//
//  SafetyPlanningStep6ViewController.m
//  Anchor
//
//  Created by Eric Li on 7/28/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "SafetyPlanningStep6ViewController.h"
#import "ANAddItemCell.h"
#import "ANSubtitleCell.h"
#import "ANSelectionCommons.h"
#import "ANDataStoreCoordinator.h"
#import "SafetyTip.h"
#import "ZLTextField.h"
#import "ZLTextView.h"
#import "SafetyTipCell.h"

@interface SafetyPlanningStep6ViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIView *hoverView;
@property (retain, nonatomic) IBOutlet UIView *customEditView;
@property (retain, nonatomic) IBOutlet UITableView *safetyTipSelectionTableView;

@property (nonatomic, retain) NSArray *selectionItems;
@property (nonatomic, retain) NSMutableIndexSet *selectedSelectionItems;

@property (nonatomic, retain) NSString *entityName;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (retain, nonatomic) IBOutlet ZLTextField *textField1;
@property (retain, nonatomic) IBOutlet ZLTextView *textView1;

@property (retain, nonatomic) IBOutlet UIView *editView;
@property (retain, nonatomic) IBOutlet ZLTextField *textField2;
@property (retain, nonatomic) IBOutlet ZLTextView *textView2;
@property (nonatomic, retain) SafetyTip *editingSafetyTip;
@end

@implementation SafetyPlanningStep6ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_tableView registerNib:[UINib nibWithNibName:@"ANAddItemCell" bundle:nil] forCellReuseIdentifier:@"ANAddItemCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"SafetyTipCell" bundle:nil] forCellReuseIdentifier:@"SafetyTipCell"];
    [_safetyTipSelectionTableView registerNib:[UINib nibWithNibName:@"ANSubtitleCell" bundle:nil] forCellReuseIdentifier:@"ANSubtitleCell"];
    
    self.selectionItems = kSafetyTipItems;
    self.selectedSelectionItems = [NSMutableIndexSet indexSet];
    
    self.entityName = @"SafetyTip";
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableView release];
    [_selectionItems release];
    [_selectedSelectionItems release];
    [_hoverView release];
    [_customEditView release];
    [_safetyTipSelectionTableView release];
    [_entityName release];
    [_fetchedResultsController release];
    [_textField1 release];
    [_textView1 release];
    [_editView release];
    [_textField2 release];
    [_textView2 release];
    [_editingSafetyTip release];
    [super dealloc];
}

#pragma mark - Actions
- (IBAction)saveButtonClicked:(id)sender
{
    if ([_selectedSelectionItems count] > 0) {
        [_selectedSelectionItems enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            NSDictionary *defaultItem = [_selectionItems objectAtIndex:idx];
            SafetyTip *st = [NSEntityDescription insertNewObjectForEntityForName:_entityName inManagedObjectContext:[[ANDataStoreCoordinator shared] managedObjectContext]];
            st.name = defaultItem[@"title"];
            st.title = defaultItem[@"title"];
            st.creationDate = [NSDate date];
            st.selectedFromDefault = @(YES);
        }];
        
        [[ANDataStoreCoordinator shared] saveDataStore];
    }
    
    [_delegate safetyPlanningStepViewControllerRequestHideHoveringView:self];
}

- (IBAction)cancelButtonClicked:(id)sender
{
    self.editingSafetyTip = nil;
    [_delegate safetyPlanningStepViewControllerRequestHideHoveringView:self];
}

- (IBAction)customSaveButtonClicked:(id)sender
{
    if (_textField1.text.length > 0) {
        SafetyTip *st = [NSEntityDescription insertNewObjectForEntityForName:_entityName inManagedObjectContext:[[ANDataStoreCoordinator shared] managedObjectContext]];
        st.name = _textField1.text;
        st.note = _textView1.text;
        st.title = _textField1.text;
        st.creationDate = [NSDate date];
        st.selectedFromDefault = @(NO);
        
        [[ANDataStoreCoordinator shared] saveDataStore];
    }
    
    [_delegate safetyPlanningStepViewControllerRequestHideHoveringView:self];
}

- (IBAction)editViewSaveButtonClicked:(id)sender
{
    _editingSafetyTip.title = _textField2.text;
    _editingSafetyTip.name = _textField2.text;
    _editingSafetyTip.note = _textView2.text;
    
    [[ANDataStoreCoordinator shared] saveDataStore];
    
    [_delegate safetyPlanningStepViewControllerRequestHideHoveringView:self];
}

- (IBAction)editViewDeleteButtonClicked:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Are you sure you want to delete this item? This operation cannot be undone" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [_delegate safetyPlanningStepViewControllerRequestHideHoveringView:self];
        
        [[[ANDataStoreCoordinator shared] managedObjectContext] deleteObject:_editingSafetyTip];
        self.editingSafetyTip = nil;
        
        [[ANDataStoreCoordinator shared] saveDataStore];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _tableView) {
        if (tableView.isEditing) {
            return [[self.fetchedResultsController sections] count];
        }
        else {
            return [[self.fetchedResultsController sections] count] + 1;
        }
    }
    else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView) {
        if (section < [[self.fetchedResultsController sections] count]) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
            return [sectionInfo numberOfObjects];
        }
        else {
            return 2;
        }
    }
    else {
        return [_selectionItems count];
        
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == _tableView) {
        
        if (section < [[self.fetchedResultsController sections] count]) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
            return [sectionInfo name];
        }
        else {
            return nil;
        }
    }
    else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView) {
        if (indexPath.section < [[self.fetchedResultsController sections] count]) {
            SafetyTip *st = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([st.note length] > 0) {
                return 70.0;
            }
            else {
                return 44.0;
            }
        }
        else {
            return 44.0;
        }
    }
    else {
        NSDictionary *item = [_selectionItems objectAtIndex:indexPath.row];
        if ([item[@"details"] length] > 0) {
            if (indexPath.row == 0) {
                return 77.0;
            }
            else {
                return 55.0;
            }
        }
        else {
            return 44.0;
        }
        
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView) {
        if (indexPath.section < [[_fetchedResultsController sections] count]) {
            cell.backgroundColor = [UIColor colorWithRed:0.204 green:0.345 blue:0.549 alpha:0.400];
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView) {
        if (indexPath.section < [[_fetchedResultsController sections] count]) {
            SafetyTipCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SafetyTipCell"];
            SafetyTip *st = [self.fetchedResultsController objectAtIndexPath:indexPath];
            cell.safetyTip = st;
            return cell;
        }
        else {
            ANAddItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ANAddItemCell"];
            if (indexPath.row == 0) {
                cell.titleLabel.text = @"Select Default Safety Tips";
            }
            else {
                cell.titleLabel.text = @"Add Custom Safety Tip";
            }
            
            return cell;
        }
    }
    else {
        ANSubtitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ANSubtitleCell"];
        
        
        NSDictionary *item = [_selectionItems objectAtIndex:indexPath.row];
        cell.mainTextLabel.text = item[@"title"];
        cell.secondaryTextLabel.text = item[@"details"];
        
        if ([_selectedSelectionItems containsIndex:indexPath.row]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        return cell;
        
    }
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView) {
        if (!tableView.isEditing) {
            if (indexPath.section < [[_fetchedResultsController sections] count]) {
                SafetyTip *st = [_fetchedResultsController objectAtIndexPath:indexPath];
                self.editingSafetyTip = st;
                
                _textField2.text = st.title;
                _textView2.text = st.note;
                
                [_delegate safetyPlanningStepViewController:self requestDisplayingHoveringView:_editView hoveringViewType:1];
            }
            else {
                if (indexPath.row == 0) {
                    _textField1.text = nil;
                    _textView1.text = nil;
                    [_delegate safetyPlanningStepViewController:self requestDisplayingHoveringView:_hoverView hoveringViewType:2];
                }
                else {
                    [_delegate safetyPlanningStepViewController:self requestDisplayingHoveringView:_customEditView hoveringViewType:1];
                }
            }
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    else {
        if ([_selectedSelectionItems containsIndex:indexPath.row]) {
            [_selectedSelectionItems removeIndex:indexPath.row];
        }
        else {
            [_selectedSelectionItems addIndex:indexPath.row];
        }
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}

#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:_entityName inManagedObjectContext:[[ANDataStoreCoordinator shared] managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[ANDataStoreCoordinator shared] managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    fetchedResultsController.delegate = self;
    self.fetchedResultsController = fetchedResultsController;
    
    [fetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            if (!self.searchDisplayController.isActive) {
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                    // I currently don't do anything if the search display controller is active, because it is throwing similar errors.
            }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}
@end

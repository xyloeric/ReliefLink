//
//  SafetyPlanningStep4ViewController.m
//  Anchor
//
//  Created by Eric Li on 7/28/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "SafetyPlanningStep4ViewController.h"
#import "ANAddItemCell.h"
#import "ANDataStoreCoordinator.h"
#import "PersonForHelp.h"
#import "ZLTextField.h"
#import "PersonCell.h"

@interface SafetyPlanningStep4ViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIView *customEditView;

@property (nonatomic, retain) NSString *entityName;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (retain, nonatomic) IBOutlet ZLTextField *textField1;
@property (retain, nonatomic) IBOutlet ZLTextField *textField2;
@property (retain, nonatomic) IBOutlet ZLTextField *textField3;

@property (retain, nonatomic) IBOutlet UIView *editView;
@property (retain, nonatomic) IBOutlet ZLTextField *textField4;
@property (retain, nonatomic) IBOutlet ZLTextField *textField5;
@property (retain, nonatomic) IBOutlet ZLTextField *textField6;
@property (nonatomic, retain) PersonForHelp *editingPerson;
@end

@implementation SafetyPlanningStep4ViewController

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
    [_tableView registerNib:[UINib nibWithNibName:@"PersonCell" bundle:nil] forCellReuseIdentifier:@"PersonCell"];

    self.entityName = @"PersonForHelp";
    
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
    [_customEditView release];
    [_entityName release];
    [_fetchedResultsController release];
    [_textField1 release];
    [_textField2 release];
    [_textField3 release];
    [_editView release];
    [_textField4 release];
    [_textField6 release];
    [_textField5 release];
    [_editingPerson release];
    [super dealloc];
}

#pragma mark - Actions
- (IBAction)saveButtonClicked:(id)sender
{
    if (_textField1.text.length > 0) {
        PersonForHelp *pfh = [NSEntityDescription insertNewObjectForEntityForName:_entityName inManagedObjectContext:[[ANDataStoreCoordinator shared] managedObjectContext]];
        pfh.name = _textField1.text;
        pfh.phone = _textField2.text;
        pfh.email = _textField3.text;
        pfh.title = _textField1.text;
        pfh.creationDate = [NSDate date];
        pfh.selectedFromDefault = @(NO);
        
        [[ANDataStoreCoordinator shared] saveDataStore];
    }
    
    [_delegate safetyPlanningStepViewControllerRequestHideHoveringView:self];
}

- (IBAction)cancelButtonClicked:(id)sender
{
    self.editingPerson = nil;
    [_delegate safetyPlanningStepViewControllerRequestHideHoveringView:self];
}

- (IBAction)editViewSaveButtonClicked:(id)sender
{
    _editingPerson.title = _textField4.text;
    _editingPerson.name = _textField4.text;
    _editingPerson.phone = _textField5.text;
    _editingPerson.email = _textField6.text;
    
    [[ANDataStoreCoordinator shared] saveDataStore];
    
    [_delegate safetyPlanningStepViewControllerRequestHideHoveringView:self];
}

- (IBAction)editViewDeleteButtonClicked:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Are you sure you want to delete this item? This operation cannot be undone" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [_delegate safetyPlanningStepViewControllerRequestHideHoveringView:self];
        
        [[[ANDataStoreCoordinator shared] managedObjectContext] deleteObject:_editingPerson];
        self.editingPerson = nil;
        
        [[ANDataStoreCoordinator shared] saveDataStore];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.isEditing) {
        return [[self.fetchedResultsController sections] count];
    }
    else {
        return [[self.fetchedResultsController sections] count] + 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < [[self.fetchedResultsController sections] count]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [[self.fetchedResultsController sections] count]) {
        return 44.0;
    }
    else {
        return 44.0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section < [[self.fetchedResultsController sections] count]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo name];
    }
    else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [[_fetchedResultsController sections] count]) {
        cell.backgroundColor = [UIColor colorWithRed:0.769 green:0.788 blue:0.376 alpha:0.400];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [[_fetchedResultsController sections] count]) {
        PersonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonCell"];
        PersonForHelp *pfh = [_fetchedResultsController objectAtIndexPath:indexPath];
        cell.personForHelp = pfh;
        return cell;
    }
    else {
        ANAddItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ANAddItemCell"];
        cell.titleLabel.text = @"Add Friends and Family";
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.isEditing) {
        if (indexPath.section < [[_fetchedResultsController sections] count]) {
            PersonForHelp *pfh = [_fetchedResultsController objectAtIndexPath:indexPath];
            self.editingPerson = pfh;
            
            _textField4.text = pfh.name;
            _textField5.text = pfh.phone;
            _textField6.text = pfh.email;
            [_delegate safetyPlanningStepViewController:self requestDisplayingHoveringView:_editView hoveringViewType:1];
        }
        else {
            if (indexPath.row == 0) {
                _textField1.text = nil;
                _textField2.text = nil;
                _textField3.text = nil;
                
                [_delegate safetyPlanningStepViewController:self requestDisplayingHoveringView:_customEditView hoveringViewType:1];
            }
        }
        
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
        default:
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
            [tableView reloadData];
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

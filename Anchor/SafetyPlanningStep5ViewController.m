//
//  SafetyPlanningStep5ViewController.m
//  Anchor
//
//  Created by Eric Li on 7/28/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "SafetyPlanningStep5ViewController.h"
#import "ANAddItemCell.h"
#import "ANDataStoreCoordinator.h"
#import "ProfessionalToContact.h"
#import "ZLTextField.h"
#import "ProfessionalCell.h"

@interface SafetyPlanningStep5ViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIView *professionalEditView;
@property (retain, nonatomic) IBOutlet UIView *facilityEditView;

@property (nonatomic, retain) NSString *entityName;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (retain, nonatomic) IBOutlet ZLTextField *textField1;
@property (retain, nonatomic) IBOutlet ZLTextField *textField2;
@property (retain, nonatomic) IBOutlet ZLTextField *textField3;
@property (retain, nonatomic) IBOutlet ZLTextField *textField4;
@property (retain, nonatomic) IBOutlet ZLTextField *textField5;
@property (retain, nonatomic) IBOutlet ZLTextField *textField6;

@property (retain, nonatomic) IBOutlet UIView *editView1;
@property (retain, nonatomic) IBOutlet ZLTextField *textField7;
@property (retain, nonatomic) IBOutlet ZLTextField *textField8;
@property (retain, nonatomic) IBOutlet ZLTextField *textField9;
@property (retain, nonatomic) IBOutlet UIButton *saveButton1;

@property (retain, nonatomic) IBOutlet UIView *editView2;
@property (retain, nonatomic) IBOutlet ZLTextField *textField10;
@property (retain, nonatomic) IBOutlet ZLTextField *textField11;
@property (retain, nonatomic) IBOutlet ZLTextField *textField12;
@property (retain, nonatomic) IBOutlet UIButton *saveButton2;

@property (nonatomic, retain) ProfessionalToContact *editingPtc;
@end

@implementation SafetyPlanningStep5ViewController

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
    [_tableView registerNib:[UINib nibWithNibName:@"ProfessionalCell" bundle:nil] forCellReuseIdentifier:@"ProfessionalCell"];
    
    self.entityName = @"ProfessionalToContact";
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
    [_professionalEditView release];
    [_facilityEditView release];
    [_entityName release];
    [_fetchedResultsController release];
    [_textField1 release];
    [_textField2 release];
    [_textField3 release];
    [_textField4 release];
    [_textField5 release];
    [_textField6 release];
    [_editView1 release];
    [_textField7 release];
    [_textField8 release];
    [_textField9 release];
    [_editView2 release];
    [_textField10 release];
    [_textField11 release];
    [_textField12 release];
    [_editingPtc release];
    [_saveButton2 release];
    [_saveButton1 release];
    [super dealloc];
}

#pragma mark - Actions
- (IBAction)professionalSaveButtonClicked:(id)sender
{
    if (_textField1.text.length > 0) {
        ProfessionalToContact *pfc = [NSEntityDescription insertNewObjectForEntityForName:_entityName inManagedObjectContext:[[ANDataStoreCoordinator shared] managedObjectContext]];
        pfc.name = _textField1.text;
        pfc.phone = _textField2.text;
        pfc.email = _textField3.text;
        pfc.title = _textField1.text;
        pfc.creationDate = [NSDate date];
        pfc.selectedFromDefault = @(NO);
        pfc.professionalType = @"Professional";
        
        [[ANDataStoreCoordinator shared] saveDataStore];
    }
    [_delegate safetyPlanningStepViewControllerRequestHideHoveringView:self];
}

- (IBAction)facilitySaveButtonClicked:(id)sender
{
    if (_textField4.text.length > 0) {
        ProfessionalToContact *pfc = [NSEntityDescription insertNewObjectForEntityForName:_entityName inManagedObjectContext:[[ANDataStoreCoordinator shared] managedObjectContext]];
        pfc.name = _textField4.text;
        pfc.phone = _textField5.text;
        pfc.address = _textField6.text;
        pfc.title = _textField1.text;
        pfc.creationDate = [NSDate date];
        pfc.selectedFromDefault = @(NO);
        pfc.professionalType = @"Facility";
        
        [[ANDataStoreCoordinator shared] saveDataStore];
    }
    [_delegate safetyPlanningStepViewControllerRequestHideHoveringView:self];
}


- (IBAction)cancelButtonClicked:(id)sender
{
    self.editingPtc = nil;
    [_delegate safetyPlanningStepViewControllerRequestHideHoveringView:self];
}

- (IBAction)editViewSaveButtonClicked:(id)sender
{
    if ([_editingPtc.professionalType isEqualToString:@"Professional"]) {
        _editingPtc.name = _textField7.text;
        _editingPtc.title = _textField7.text;
        _editingPtc.phone = _textField8.text;
        _editingPtc.email = _textField9.text;
        _editingPtc.professionalType = @"Professional";
    }
    else {
        _editingPtc.name = _textField10.text;
        _editingPtc.title = _textField10.text;
        _editingPtc.phone = _textField11.text;
        _editingPtc.address = _textField12.text;
        _editingPtc.professionalType = @"Facility";
    }
    
    [[ANDataStoreCoordinator shared] saveDataStore];
    
    [_delegate safetyPlanningStepViewControllerRequestHideHoveringView:self];
}

- (IBAction)editViewDeleteButtonClicked:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Are you sure you want to delete this item? This operation cannot be undone" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex]) {
        [_delegate safetyPlanningStepViewControllerRequestHideHoveringView:self];
        
        [[[ANDataStoreCoordinator shared] managedObjectContext] deleteObject:_editingPtc];
        self.editingPtc = nil;
        
        [[ANDataStoreCoordinator shared] saveDataStore];
    }
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
        return 2;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [[self.fetchedResultsController sections] count]) {
        return 44.0;
    }
    else {
        return 44.0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [[_fetchedResultsController sections] count]) {
        cell.backgroundColor = [UIColor colorWithRed:0.471 green:0.486 blue:0.780 alpha:0.400];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [[_fetchedResultsController sections] count]) {
        ProfessionalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfessionalCell"];
        
        ProfessionalToContact *ptc = [_fetchedResultsController objectAtIndexPath:indexPath];
        cell.professional = ptc;
        NSLog(@"%@ %@, %i %i", ptc.name, ptc.professionalType, indexPath.section, indexPath.row);
        return cell;
    }
    else {
        ANAddItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ANAddItemCell"];
        
        if (indexPath.row == 0) {
            cell.titleLabel.text = @"Add Clinician";
        }
        else {
            cell.titleLabel.text = @"Add Local Urgent Care Service";
        }
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.isEditing) {
        if (indexPath.section < [[_fetchedResultsController sections] count]) {
            ProfessionalToContact *ptc = [_fetchedResultsController objectAtIndexPath:indexPath];
            self.editingPtc = ptc;
            
            if ([ptc.professionalType isEqualToString:@"Professional"]) {
                _textField7.text = ptc.name;
                _textField8.text = ptc.phone;
                _textField9.text = ptc.email;
                [_delegate safetyPlanningStepViewController:self requestDisplayingHoveringView:_editView1 hoveringViewType:1];
            }
            else {
                _textField10.text = ptc.name;
                _textField11.text = ptc.phone;
                _textField12.text = ptc.address;
                [_delegate safetyPlanningStepViewController:self requestDisplayingHoveringView:_editView2 hoveringViewType:1];
            }

        }
        else {
            switch (indexPath.row) {
                case 0:
                    _textField1.text = nil;
                    _textField2.text = nil;
                    _textField3.text = nil;
                    [_delegate safetyPlanningStepViewController:self requestDisplayingHoveringView:_professionalEditView hoveringViewType:1];
                    break;
                case 1:
                    _textField4.text = nil;
                    _textField5.text = nil;
                    _textField6.text = nil;
                    [_delegate safetyPlanningStepViewController:self requestDisplayingHoveringView:_facilityEditView hoveringViewType:1];
                    break;
                default:
                    break;
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
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[ANDataStoreCoordinator shared] managedObjectContext] sectionNameKeyPath:@"professionalType" cacheName:nil];
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

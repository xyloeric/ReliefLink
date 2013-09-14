//
//  ReminderViewController.m
//  Anchor
//
//  Created by Eric Li on 7/21/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ReminderViewController.h"
#import "ANReminderEditCell.h"
#import "ANReminderCell.h"
#import "ReminderDetailViewController.h"

#import "ANDataStoreCoordinator.h"
#import "ANAddItemCell.h"
#import "ANCommons.h"

@interface ReminderViewController () <UITableViewDelegate, UITableViewDataSource, ReminderDetailViewControllerDelegate, NSFetchedResultsControllerDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIButton *editButton;
@property (retain, nonatomic) IBOutlet UIButton *addButton;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *titleHeightConstraint;
@end

@implementation ReminderViewController

- (id)init
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.detailViewIdentifier = NSStringFromClass([self class]);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        _titleHeightConstraint.constant = 64.0;
    }
    else {
        _titleHeightConstraint.constant = 44.0;
    }
    
    [_tableView registerNib:[UINib nibWithNibName:@"ANAddItemCell" bundle:nil] forCellReuseIdentifier:@"ANAddItemCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ANReminderCell" bundle:nil] forCellReuseIdentifier:@"ANReminderCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_tableView release];
    [_editButton release];
    [_addButton release];
    [_fetchedResultsController release];
    [_titleHeightConstraint release];
    [super dealloc];
}


#pragma mark - Actions
- (IBAction)menuButtonPressed:(UIButton *)sender
{
    [self.delegate ANDetailViewControllerDidClickMenuButton:self];
}

- (IBAction)homeButtonPressed:(UIButton *)sender
{
    [self.delegate ANDetailViewControllerDidClickHomeButton:self];
}

- (IBAction)addButtonPressed:(id)sender
{
    if (_tableView.isEditing) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];

        for (NSIndexPath *ip in selectedRows) {
            Reminder *reminder = [self.fetchedResultsController objectAtIndexPath:ip];
            [[ANDataStoreCoordinator shared] unscheduleNotificationRelatedToReminder:reminder];
            [context deleteObject:reminder];
        }
        
        NSError *error = nil;
        [context save:&error];
        if (error) {
            NSLog(@"Encountered Core Data Error: %@", [error localizedDescription]);
        }
    }
    else {
        [self addNewReminder];
    }
}

- (IBAction)editButtonPressed:(id)sender
{
    NSInteger sectionCount = [[self.fetchedResultsController sections] count];
    
    if (_tableView.isEditing) {
        [_editButton setTitle:@"Edit" forState:UIControlStateNormal];
        [_addButton setTitle:@"Add" forState:UIControlStateNormal];

        [_tableView setEditing:NO animated:YES];
        _tableView.allowsMultipleSelectionDuringEditing = NO;
        

        [_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionCount] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        NSMutableIndexSet *temp = [NSMutableIndexSet indexSet];
        for (int i = 0; i < sectionCount; i++) {
            [temp addIndex:i];
        }
        [_tableView reloadSections:temp withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        [_editButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_addButton setTitle:@"Delete" forState:UIControlStateNormal];
        
        _tableView.allowsMultipleSelectionDuringEditing = YES;
        [_tableView setEditing:YES animated:YES];
        
        [_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionCount] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        NSMutableIndexSet *temp = [NSMutableIndexSet indexSet];
        for (int i = 0; i < sectionCount; i++) {
            [temp addIndex:i];
        }
        [_tableView reloadSections:temp withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Helpers
- (void)addNewReminder
{
    Reminder *newReminder = [NSEntityDescription insertNewObjectForEntityForName:@"Reminder" inManagedObjectContext:[[ANDataStoreCoordinator shared] managedObjectContext]];
    newReminder.reminderType = @"Default";

    ReminderDetailViewController *vc = [[ReminderDetailViewController alloc] init];
    vc.delegate = self;
    vc.reminder = newReminder;
    vc.isNewReminder = YES;
    [self presentViewController:vc animated:YES completion:^{}];
    [vc release];
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [[_fetchedResultsController sections] count]) {
        ANReminderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ANReminderCell"];
        Reminder *reminder = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.reminder = reminder;
        cell.reminderTitleLabel.text = reminder.title;
        
        if (tableView.isEditing) {
            cell.reminderStatusImageView.image = nil;
        }
        else {
            if ([reminder.reminderScheduled boolValue]) {
                cell.reminderStatusImageView.image = [UIImage imageNamed:@"icon_checkcircle_checked"];
            }
            else {
                cell.reminderStatusImageView.image = [UIImage imageNamed:@"icon_checkcircle_unchecked"];
            }
        }

        return cell;
    }
    else {
        ANAddItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ANAddItemCell"];
        cell.titleLabel.text = @"Add Reminder";
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.isEditing) {
        if (indexPath.section < [[_fetchedResultsController sections] count]) {
            ReminderDetailViewController *vc = [[ReminderDetailViewController alloc] init];
            Reminder *reminder = [self.fetchedResultsController objectAtIndexPath:indexPath];
            vc.delegate = self;
            vc.reminder = reminder;
            vc.isNewReminder = NO;
            [self presentViewController:vc animated:YES completion:^{}];
            [vc release];
            
        }
        else {
            [self addNewReminder];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        Reminder *reminder = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[ANDataStoreCoordinator shared] unscheduleNotificationRelatedToReminder:reminder];
        [context deleteObject:reminder];
        
        NSError *error = nil;
        if (![context save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}

#pragma mark - Notification Handler
- (void)handleKeyboardWillShowNotification:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
        [_tableView setContentInset:UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)];
    }];
}

- (void)handleKeyboardWillHideNotification:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [_tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }];
}

#pragma mark - ReminderDetailViewControllerDelegate
- (void)ReminderDetailViewControllerWillDismiss:(ReminderDetailViewController *)controller
{
    
}

#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Reminder" inManagedObjectContext:[[ANDataStoreCoordinator shared] managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[ANDataStoreCoordinator shared] managedObjectContext] sectionNameKeyPath:@"reminderType" cacheName:nil];
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

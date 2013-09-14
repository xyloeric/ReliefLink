//
//  ReminderDetailViewController.m
//  Anchor
//
//  Created by Eric Li on 7/28/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ReminderDetailViewController.h"
#import "ANDataStoreCoordinator.h"
#import "ZLEditCell.h"
#import "ZLExpandableEditCell.h"
#import "ZLSwitchCell.h"
#import "ZLOneLabelCell.h"
#import "ZLTwoLabelCell.h"
#import <QuartzCore/QuartzCore.h>

@interface ReminderDetailViewController () <UITableViewDataSource, UITableViewDelegate, ZLEditCellDelegate, ZLExpandableEditCellDelegate, ZLSwitchCellDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSInteger _currentPickerType;
    NSInteger _currentRepeatType;
    NSInteger _currentReminderType;
}
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIView *dateSelectionView;
@property (retain, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (retain, nonatomic) IBOutlet UIPickerView *repeatTypePicker;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *pickerViewBottomConstraint;

@property (nonatomic, retain) UILocalNotification *currentNotification;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *titleHeightConstraint;
@end

@implementation ReminderDetailViewController

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
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        _titleHeightConstraint.constant = 64.0;
    }
    else {
        _titleHeightConstraint.constant = 44.0;
    }
    
    [_tableView registerNib:[UINib nibWithNibName:@"ZLEditCell" bundle:nil] forCellReuseIdentifier:@"ZLEditCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ZLExpandableEditCell" bundle:nil] forCellReuseIdentifier:@"ZLExpandableEditCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ZLSwitchCell" bundle:nil] forCellReuseIdentifier:@"ZLSwitchCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ZLOneLabelCell" bundle:nil] forCellReuseIdentifier:@"ZLOneLabelCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ZLTwoLabelCell" bundle:nil] forCellReuseIdentifier:@"ZLTwoLabelCell"];

}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
//    _pickerViewBottomConstraint.constant = -260;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)dealloc
{
    [_tableView release];
    [_reminder release];
    [_dateSelectionView release];
    [_datePicker release];
    [_repeatTypePicker release];
    [_pickerViewBottomConstraint release];
    [_titleHeightConstraint release];
    [super dealloc];
}

#pragma mark - Actions
- (IBAction)cancelButtonClicked:(id)sender
{
    [self.view endEditing:NO];
    
    if (_isNewReminder) {
        [[ANDataStoreCoordinator shared] unscheduleNotificationRelatedToReminder:_reminder];
        [[ANDataStoreCoordinator shared] removeManagedObject:_reminder];
        self.reminder = nil;
    }
    
    if (_delegate) {
        [_delegate ReminderDetailViewControllerWillDismiss:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)doneButtonClicked:(id)sender
{
    [self.view endEditing:NO];
    
    if ([_reminder.reminderScheduled boolValue]) {
        [[ANDataStoreCoordinator shared] scheduleNotificationForReminder:_reminder];
        [[ANDataStoreCoordinator shared] saveDataStore];
    }
    else {
        [[ANDataStoreCoordinator shared] saveDataStore];
    }
    
    if (_delegate) {
        [_delegate ReminderDetailViewControllerWillDismiss:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)pickerSaveButtonClicked:(id)sender
{
    if (!_datePicker.hidden) {
        _reminder.reminderDate = [self getRoundedDateTimeWithDate:_datePicker.date numOfMinutesAhead:0];
    }
    else if (!_repeatTypePicker.hidden) {
        if (_currentPickerType == 0) {
            _reminder.repeatType = @(_currentRepeatType);
        }
        else {
            _reminder.reminderType = [self getReminderDisplayDisplayByType:_currentReminderType];
        }
    }
    
    [[ANDataStoreCoordinator shared] scheduleNotificationForReminder:_reminder];
    
    [[ANDataStoreCoordinator shared] saveDataStore];

    [_tableView reloadData];
    
    [self hidePickerView];
}

- (IBAction)pickerCloseButtonClicked:(id)sender
{
    [self hidePickerView];
}

#pragma mark - Helpers
- (void)showPickerViewWithType:(NSInteger)selectionType
{
    switch (selectionType) {
        case 0:
            _repeatTypePicker.hidden = YES;
            _datePicker.hidden = NO;
            if (_reminder.reminderDate) {
                _datePicker.date = _reminder.reminderDate;
            }
            break;
        case 1:
            _repeatTypePicker.hidden = NO;
            _datePicker.hidden = YES;
            _currentPickerType = 0;
            [_repeatTypePicker reloadComponent:0];
            if (_reminder.repeatType) {
                _currentRepeatType = [_reminder.repeatType intValue];
                [_repeatTypePicker selectRow:_currentRepeatType inComponent:0 animated:NO];
            }
            break;
        case 2:
            _repeatTypePicker.hidden = NO;
            _datePicker.hidden = YES;
            _currentPickerType = 1;
            [_repeatTypePicker reloadComponent:0];
            if (_reminder.reminderType) {
                _currentReminderType = [self getReminderTypeByDisplay:_reminder.reminderType];
                [_repeatTypePicker selectRow:_currentReminderType inComponent:0 animated:NO];
            }
        default:
            break;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _pickerViewBottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        _dateSelectionView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        _dateSelectionView.layer.shadowRadius = 5.0;
        _dateSelectionView.layer.shadowOpacity = 0.5;
        _dateSelectionView.layer.shadowOffset = CGSizeMake(0, 0.0);
    }];
}

- (void)hidePickerView
{
    _dateSelectionView.layer.shadowColor = [UIColor clearColor].CGColor;
    _dateSelectionView.layer.shadowRadius = 0.0;
    _dateSelectionView.layer.shadowOpacity = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        _pickerViewBottomConstraint.constant = -260;
        [self.view layoutIfNeeded];
    }];
}

- (NSString *)getRepeatDisplayByType:(NSInteger)repeatType
{
    switch (repeatType) {
        case 0:
            return @"Never";
            break;
        case 1:
            return @"Every Hour";
            break;
        case 2:
            return @"Every Day";
            break;
        case 3:
            return @"Every Week";
            break;
        case 4:
            return @"Every Month";
            break;
        case 5:
            return @"Every Year";
            break;
        default:
            return nil;
            break;
    }
}

- (NSInteger)getRepeatTypeByDisplay:(NSString *)display
{
    if ([display isEqualToString:@"Never"]) {
        return 0;
    }
    else if ([display isEqualToString:@"Every Hour"]) {
        return 1;
    }
    else if ([display isEqualToString:@"Every Day"]) {
        return 2;
    }
    else if ([display isEqualToString:@"Every Week"]) {
        return 3;
    }
    else if ([display isEqualToString:@"Every Month"]) {
        return 4;
    }
    else if ([display isEqualToString:@"Every Year"]) {
        return 5;
    }
    else {
        return 0;
    }
}

- (NSString *)getReminderDisplayDisplayByType:(NSInteger)reminderType
{
    switch (reminderType) {
        case 0:
            return @"Default";
            break;
        case 1:
            return @"Medication";
            break;
        case 2:
            return @"Appointment";
            break;
        default:
            return nil;
            break;
    }
}

- (NSInteger)getReminderTypeByDisplay:(NSString *)display
{
    if ([display isEqualToString:@"Default"]) {
        return 0;
    }
    else if ([display isEqualToString:@"Medication"]) {
        return 1;
    }
    else if ([display isEqualToString:@"Appointment"]) {
        return 2;
    }
    else {
        return 0;
    }
}

- (NSDate *)getRoundedDateTimeWithDate:(NSDate *)date numOfMinutesAhead:(NSInteger)numOfMinute
{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *nowSecondComponent = [gregorian components:NSSecondCalendarUnit fromDate:date];
    
    NSInteger second = nowSecondComponent.second;
    NSInteger secondToBeSubstracted = (numOfMinute * 60) - second;
    
    NSDateComponents *secondToBeSubstractedComponents = [[NSDateComponents alloc] init];
    secondToBeSubstractedComponents.second = secondToBeSubstracted;
    NSDate *result = [gregorian dateByAddingComponents:secondToBeSubstractedComponents toDate:date options:0];
    [gregorian release];
    [secondToBeSubstractedComponents release];
    
    return result;
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 30)] autorelease];
    label.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
        //    label.backgroundColor = [_titleBar.backgroundColor colorWithAlphaComponent:0.8];
    label.textColor = [UIColor darkTextColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.contentMode = UIViewContentModeBottom;
    label.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:17];
    
    switch (section) {
        case 0:
            label.text = @"  Reminder Details";
            break;
        case 1:
            label.text = @"  Reminder Schedule";
            break;
        default:
            label.text = nil;
            break;
    }
    
    return label;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
        {
            if ([_reminder.reminderScheduled boolValue]) {
                return 3;
            }
            else {
                return 1;
            }
        }
            break;
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return 44.0;
                    break;
                case 1:
                    return 50.0;
                    break;
                case 2:
                    return 100.0;
                    break;
                default:
                    return 0;
                    break;
            }
            break;
        default:
            return 44.0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    ZLTwoLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZLTwoLabelCell"];
                    cell.titleLabel.text = @"Reminder Type";
                    cell.secondaryLabel.text = _reminder.reminderType;
                    return cell;
                }
                    break;
                case 1:
                {
                    ZLEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZLEditCell"];
                    cell.delegate = self;
                    cell.managedObject = _reminder;
                    cell.customSeparatorView.hidden = YES;
                    cell.customSeparatorViewTop.hidden = YES;
                    cell.editingKey = @"title";
                    cell.titleLabel.text = @"Reminder Title";
                    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
                    return cell;
                }
                    break;
                case 2:
                {
                    ZLExpandableEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZLExpandableEditCell"];
                    cell.delegate = self;
                    cell.managedObject = _reminder;
                    cell.customSeparatorView.hidden = YES;
                    cell.customSeparatorViewTop.hidden = YES;
                    cell.editingKey = @"note";
                    cell.titleLabel.text = @"Reminder Note";
                    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;

                    return cell;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    ZLSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZLSwitchCell"];
                    cell.delegate = self;
                    cell.titleLabel.text = @"Remind Me On a Day";
                    [cell.toggleSwitch setOn:[_reminder.reminderScheduled boolValue] ? YES : NO];
                    return cell;
                }
                    break;
                case 1:
                {
                    ZLOneLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZLOneLabelCell"];
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"EEEE, MMM d yyyy, h:mm a"];                    
                    cell.titleLabel.text = [dateFormatter stringFromDate:_reminder.reminderDate];
                    [dateFormatter release];
                    return cell;
                }
                    break;
                case 2:
                {
                    ZLTwoLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZLTwoLabelCell"];
                    cell.titleLabel.text = @"Repeat";
                    cell.secondaryLabel.text = [self getRepeatDisplayByType:[_reminder.repeatType intValue]];
                    return cell;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            [self showPickerViewWithType:0];
        }
        else if (indexPath.row == 2) {
            [self showPickerViewWithType:1];
        }
    }
    else if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self showPickerViewWithType:2];
        }
    }
    
    [self.view endEditing:NO];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (_currentPickerType == 0) {
        return 6;
    }
    else {
        return 3;
    }
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (_currentPickerType == 0) {
        return [self getRepeatDisplayByType:row];
    }
    else {
        return [self getReminderDisplayDisplayByType:row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_currentPickerType == 0) {
        _currentRepeatType = row;
    }
    else {
        _currentReminderType = row;
    }
}

#pragma mark - ZLEditCellDelegate
- (void)ZLEditCellDidStartEditing:(ZLEditCell *)cell
{
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_tableView scrollToRowAtIndexPath:[_tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    });
}

- (void)ZLEditCellRequestEndEditing:(ZLEditCell *)cell
{
    [_tableView endEditing:NO];
}

- (void)ZLEditCellDidPressReturn:(ZLEditCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSInteger rowCount = [self tableView:_tableView numberOfRowsInSection:section];
    NSInteger sectionCount = [self numberOfSectionsInTableView:_tableView];
    
    if (row < rowCount - 1) {
        ZLEditCell *cell = (ZLEditCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row+1 inSection:section]];
        [cell.textField becomeFirstResponder];
    }
    else if (section < sectionCount - 1) {
        ZLEditCell *cell = (ZLEditCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section + 1]];
        [cell.textField becomeFirstResponder];
    }
}

#pragma mark - ZLExpandableEditCellDelegate

- (void)ZLExpandableEditCellDidStartEditing:(ZLExpandableEditCell *)cell
{
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_tableView scrollToRowAtIndexPath:[_tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    });
}

- (void)ZLExpandableEditCellDidEndEditing:(ZLExpandableEditCell *)cell
{
}

- (void)ZLExpandableEditCellRequestEndEditing:(ZLExpandableEditCell *)cell
{
    [_tableView endEditing:NO];
}

#pragma mark - ZLSwitchCellDelegate
- (void)ZLSwitchCell:(ZLSwitchCell *)cell switchValueDidChange:(BOOL)value
{
    if (value == YES) {
        _reminder.reminderDate = [self getRoundedDateTimeWithDate:[NSDate date] numOfMinutesAhead:10];
        _reminder.repeatType = @(0);
        [[ANDataStoreCoordinator shared] scheduleNotificationForReminder:_reminder];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1], [NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        _reminder.reminderDate = nil;
        _reminder.repeatType = @(0);
        [[ANDataStoreCoordinator shared] unscheduleNotificationRelatedToReminder:_reminder];
        [[ANDataStoreCoordinator shared] unscheduleNotificationRelatedToReminder:_reminder];
        [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1], [NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [[ANDataStoreCoordinator shared] saveDataStore];
    
    [self hidePickerView];
    [self.view endEditing:NO];
}
@end

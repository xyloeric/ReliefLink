//
//  ZLEditCell.m
//  Anchor
//
//  Created by Eric Li on 7/26/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ZLEditCell.h"
#import "ANDataStoreCoordinator.h"

@interface ZLEditCell () <UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *textFieldLeading;

@end

@implementation ZLEditCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _textFieldLeading.constant = 135;
    
    if (![_textField.text isEqualToString:[_managedObject valueForKey:_editingKey]]) {
        [_managedObject setValue:_textField.text forKey:_editingKey];
        [[ANDataStoreCoordinator shared] saveDataStore];
    }
}

- (void)dealloc {
    [_textField release];
    [_titleLabel release];
    [_customSeparatorView release];
    [_textFieldLeading release];
    [_customSeparatorViewTop release];
    [_managedObject release];
    [_editingKey release];
    [super dealloc];
}


#pragma mark - Public Method
- (void)setEditingKey:(NSString *)editingKey
{
    if (_editingKey != editingKey) {
        [_editingKey release];
        _editingKey = [editingKey retain];
        
        _textField.text = [_managedObject valueForKey:_editingKey];
    }
}

#pragma mark - Action

- (IBAction)stopEditButtonClicked:(id)sender
{
    [_delegate ZLEditCellRequestEndEditing:self];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [_delegate ZLEditCellDidStartEditing:self];
    [UIView animateWithDuration:0.3 animations:^{
        _textFieldLeading.constant = 20;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        _textField.placeholder = _titleLabel.text;
        [_textField setNeedsDisplay];
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [_managedObject setValue:textField.text forKey:_editingKey];
    [[ANDataStoreCoordinator shared] saveDataStore];

    _textField.placeholder = nil;

    [UIView animateWithDuration:0.3 animations:^{
        _textFieldLeading.constant = 135;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [_textField setNeedsDisplay];
    }];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[ANDataStoreCoordinator shared] saveDataStore];
    
    [textField resignFirstResponder];
    
    [_delegate ZLEditCellDidPressReturn:self];
    
    return YES;
}

@end

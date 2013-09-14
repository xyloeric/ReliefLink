//
//  ANExpandableEditCell.m
//  ReliefLink
//
//  Created by Eric Li on 8/3/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "ZLExpandableEditCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ANDataStoreCoordinator.h"

@interface ZLExpandableEditCell () <UITextViewDelegate>
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *textFieldLeading;
@end

@implementation ZLExpandableEditCell

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
    [_delegate ZLExpandableEditCellRequestEndEditing:self];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [_delegate ZLExpandableEditCellDidStartEditing:self];
    [UIView animateWithDuration:0.3 animations:^{
        _textFieldLeading.constant = 20;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [_textField setNeedsDisplay];
    }];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [_managedObject setValue:textView.text forKey:_editingKey];

    [[ANDataStoreCoordinator shared] saveDataStore];

    [_delegate ZLExpandableEditCellDidEndEditing:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        _textFieldLeading.constant = 135;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [_textField setNeedsDisplay];
    }];
}


@end

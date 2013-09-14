//
//  PersonCell.m
//  ReliefLink
//
//  Created by Eric Li on 8/7/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import "PersonCell.h"
#import "ANDataStoreCoordinator.h"

@interface PersonCell ()
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *phoneButton;
@property (retain, nonatomic) IBOutlet UIButton *emailButton;

@end

@implementation PersonCell

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

- (void)dealloc {
    [_titleLabel release];
    [_phoneButton release];
    [_emailButton release];
    [_personForHelp release];
    [super dealloc];
}

- (IBAction)phoneButtonClicked:(id)sender
{
    [[ANDataStoreCoordinator shared] callPhoneNumber:_personForHelp.phone];
}

- (IBAction)emailButtonClicked:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SendEmailFromSafetyPlan" object:_personForHelp.email];
}

- (void)setPersonForHelp:(PersonForHelp *)personForHelp
{
    if (_personForHelp != personForHelp) {
        [_personForHelp release];
        _personForHelp = [personForHelp retain];
    }
    
    _titleLabel.text = _personForHelp.name;
    _phoneButton.enabled = _personForHelp.phone.length > 0 ? YES : NO;
    _emailButton.enabled = _personForHelp.email.length > 0 ? YES : NO;

}

@end

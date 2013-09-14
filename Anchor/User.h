//
//  User.h
//  Anchor
//
//  Created by Eric Li on 7/30/13.
//  Copyright (c) 2013 ericli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject
@property (nonatomic, retain) NSString * dateOfBirth;
@property (nonatomic, retain) NSString * diagnosis;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * middleName;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * primaryInsuranceId;
@property (nonatomic, retain) NSString * primaryInsuranceName;
@property (nonatomic, retain) NSString * primaryPhone;
@property (nonatomic, retain) NSString * profilePhotoPath;
@property (nonatomic, retain) NSString * psychologist;
@property (nonatomic, retain) NSString * psychiatrist;
@property (nonatomic, retain) NSString * psychologistPhone;
@property (nonatomic, retain) NSString * psychiatristPhone;
@property (nonatomic, retain) NSString * secondaryInsuranceId;
@property (nonatomic, retain) NSString * secondaryInsuranceName;
@property (nonatomic, retain) NSString * secondaryPhone;


@end

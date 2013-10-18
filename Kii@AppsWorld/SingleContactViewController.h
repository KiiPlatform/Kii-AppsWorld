//
//  SingleContactViewController.h
//  Kii@AppsWorld
//
//  Created by Chris on 10/18/13.
//  Copyright (c) 2013 Kii Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KiiObject, ContactsViewController;

@interface SingleContactViewController : UIViewController
<UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) KiiObject *userObject;

@property (nonatomic, strong) ContactsViewController *parentVC;

@property (nonatomic, strong) IBOutlet UITextField *firstName;
@property (nonatomic, strong) IBOutlet UITextField *lastName;
@property (nonatomic, strong) IBOutlet UITextField *company;
@property (nonatomic, strong) IBOutlet UITextField *emailAddress;
@property (nonatomic, strong) IBOutlet UITextField *phoneNumber;
@property (nonatomic, strong) IBOutlet UITextField *website;
@property (nonatomic, strong) IBOutlet UITextView *notes;

- (IBAction) save:(id)sender;
- (IBAction) cancel:(id)sender;

@end

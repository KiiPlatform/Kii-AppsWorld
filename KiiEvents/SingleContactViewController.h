//
//
// Copyright 2013 Kii Corporation
// http://kii.com
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
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

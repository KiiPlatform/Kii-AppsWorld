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

#import "SingleContactViewController.h"
#import "ContactsViewController.h"

#import <KiiSDK/Kii.h>
#import "KiiToolkit.h"

#define KEYBOARD_HEIGHT             216.0f
#define KEYBOARD_PADDING_HEIGHT     80.0f
#define KEYBOARD_ANIMATION_TIME     0.28f

@implementation SingleContactViewController

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [KiiAnalytics trackEvent:@"page_view" withExtras:@{@"page": @"contacts", @"sub_page": @"single_contact", @"logged_in": [NSNumber numberWithBool:[KiiUser loggedIn]]}];

}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if(_userObject != nil) {
        _firstName.text = [_userObject getObjectForKey:@"firstName"];
        _lastName.text = [_userObject getObjectForKey:@"lastName"];
        _company.text = [_userObject getObjectForKey:@"company"];
        _emailAddress.text = [_userObject getObjectForKey:@"emailAddress"];
        _phoneNumber.text = [_userObject getObjectForKey:@"phoneNumber"];
        _website.text = [_userObject getObjectForKey:@"website"];
        _notes.text = [_userObject getObjectForKey:@"notes"];
    }
}

// this method is called when the textfields are brought in or
// removed from focus. it will shift the view such that the textfield
// is nicely centered and not hidden by the keyboard
- (void) shiftView:(UIView*)textField
{
    CGAffineTransform t = CGAffineTransformIdentity;
    
    // if the textfield is not nil, that means we're not force-hiding
    if(textField != nil) {
        
        // get the coordinates of the view and the maximum Y origin component we will allow
        CGFloat offset = textField.frame.origin.y + textField.frame.size.height + KEYBOARD_PADDING_HEIGHT;
        CGFloat maximum = self.view.frame.size.height - KEYBOARD_HEIGHT;
        
        // the view would be hidden or not in acceptable range, we need to slide the view
        if(offset > maximum) {
            t = CGAffineTransformMakeTranslation(0, maximum - offset);
        }
    }
    
    // if there was a change made, make it a nice animated change
    if(!CGAffineTransformEqualToTransform(t, self.view.transform)) {
    
        // perform the animation
        [UIView animateWithDuration:KEYBOARD_ANIMATION_TIME
                         animations:^{
                             self.view.transform = t;
                         }];
    }
    
}


- (IBAction) save:(id)sender
{
    KiiObject *contact = _userObject;
    if(contact == nil) {
        contact = [[[KiiUser currentUser] bucketWithName:BUCKET_CONTACTS] createObject];
    }

    [contact setObject:_firstName.text forKey:@"firstName"];
    [contact setObject:_lastName.text forKey:@"lastName"];
    [contact setObject:_company.text forKey:@"company"];
    [contact setObject:_emailAddress.text forKey:@"emailAddress"];
    [contact setObject:_phoneNumber.text forKey:@"phoneNumber"];
    [contact setObject:_website.text forKey:@"website"];
    [contact setObject:_notes.text forKey:@"notes"];
    
    [KTLoader showLoader:@"Saving Contact..."];
    [contact saveWithBlock:^(KiiObject *object, NSError *error) {
        if(error == nil) {
            
            [KTLoader showLoader:@"Contact saved!"
                        animated:TRUE
                   withIndicator:KTLoaderIndicatorSuccess
                 andHideInterval:KTLoaderDurationAuto];
            
            if(_userObject == nil) {
                [_parentVC refreshQuery];                
            }
            
            [self dismissViewControllerAnimated:TRUE completion:nil];
        }
        
        else {
            
            [KTLoader showLoader:@"Error Saving!"
                        animated:TRUE
                   withIndicator:KTLoaderIndicatorError
                 andHideInterval:KTLoaderDurationAuto];
            
        }
    }];

}

- (IBAction) cancel:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

#pragma mark - UITextField delegate methods

// one of the textfields is being edited
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    
    // shift the view (if needed) so the textview is fully visible
    [self shiftView:textField];
}

// the user has hit the 'next' or 'done' button
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self shiftView:nil];
    
    return FALSE;
}

#pragma mark - UITextViewDelegate
- (void) textViewDidBeginEditing:(UITextView *)textView
{
    [self shiftView:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self shiftView:nil];
        return NO;
    }
    
    return YES;
}

@end

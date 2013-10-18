//
//  SingleContactViewController.m
//  Kii@AppsWorld
//
//  Created by Chris on 10/18/13.
//  Copyright (c) 2013 Kii Corporation. All rights reserved.
//

#import "SingleContactViewController.h"
#import "ContactsViewController.h"

#import <KiiSDK/Kii.h>
#import "KiiToolkit.h"

#define KEYBOARD_HEIGHT             216.0f
#define KEYBOARD_PADDING_HEIGHT     80.0f
#define KEYBOARD_ANIMATION_TIME     0.28f

@implementation SingleContactViewController

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
    CGRect frame = CGRectZero;
    
    // if the textfield is not nil, that means we're not force-hiding
    if(textField != nil) {
        
        // get the coordinates of the view and the maximum Y origin component we will allow
        CGFloat offset = textField.frame.origin.y + textField.frame.size.height + KEYBOARD_PADDING_HEIGHT;
        CGFloat maximum = self.view.frame.size.height - KEYBOARD_HEIGHT;
        
        // the view would be hidden or not in acceptable range, we need to slide the view
        if(offset > maximum) {
            
            // set the frame to a safe, centered position
            frame = self.view.frame;
            frame.origin.y = maximum - offset;
        }
    }
    
    // if the view hasn't been changed so far - it needs to be moved back to its default position
    if(CGRectEqualToRect(frame, CGRectZero) && self.view.frame.origin.y != 0) {
        frame = self.view.frame;
        frame.origin.y = 0;
    }
    
    // if there was a change made, make it a nice animated change
    if(!CGRectEqualToRect(frame, CGRectZero)) {
        
        // perform the animation
        [UIView animateWithDuration:KEYBOARD_ANIMATION_TIME
                         animations:^{
                             self.view.frame = frame;
                         }];
    }
    
}


- (IBAction) save:(id)sender
{
    KiiObject *contact = _userObject;
    if(contact == nil) {
        contact = [[[KiiUser currentUser] bucketWithName:@"contacts"] createObject];
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

//
//  ContactsViewController.m
//  Kii@AppsWorld
//
//  Created by Chris on 10/10/13.
//  Copyright (c) 2013 Kii Corporation. All rights reserved.
//

#import "ContactsViewController.h"
#import "SingleContactViewController.h"
#import <KiiSDK/Kii.h>
#import "KiiToolkit.h"

@implementation ContactsViewController

- (IBAction) addContact:(id)sender
{
    if([KiiUser loggedIn]) {
        // push the view controller with the session information
        SingleContactViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SingleContactViewController"];
        vc.parentVC = self;
        vc.navigationItem.title = @"Add Contact";
        [self.navigationController presentViewController:vc animated:TRUE completion:nil];
    } else {
        
        [KTAlert showAlert:KTAlertTypeToast
               withMessage:@"Log in to start storing contacts!"
               andDuration:KTAlertDurationLong];

    }
}

// the user hit the top-left edit/done button to turn the table editing on/off
- (IBAction) toggleEditing:(id)sender
{
    // set the editing mode to its opposite (toggle)
    [self.tableView setEditing:!self.tableView.isEditing animated:TRUE];
    
    // update the button in the top toolbar
    UIBarButtonSystemItem item = (self.tableView.isEditing) ? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit;
    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:item target:self action:@selector(toggleEditing:)];
    [self.navigationItem setRightBarButtonItem:edit animated:TRUE];
    
    // hide the '+' button
    if(self.tableView.isEditing) {
        [self.navigationItem setLeftBarButtonItem:nil animated:TRUE];
    } else {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContact:)];
        [self.navigationItem setLeftBarButtonItem:addButton animated:TRUE];
    }

}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // this defines the query
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    [query sortByAsc:@"firstName"];
    self.query = query;
    self.autoHandleErrors = FALSE;
    
    // and this defines the bucket
    self.bucket = [[KiiUser currentUser] bucketWithName:BUCKET_CONTACTS];
    
    // we also want to refresh the table with the latest query and bucket
    [self refreshQuery];
}

- (UITableViewCell*) tableView:(UITableView *)tableView
              cellForKiiObject:(KiiObject *)object
                   atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MyCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:identifier];
    
    // set our label based on the KiiObject value
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [object getObjectForKey:@"firstName"], [object getObjectForKey:@"lastName"]];
    cell.detailTextLabel.text = [object getObjectForKey:@"email"];
    
    return cell;
}

- (void) deleteObject:(int)index
{
    // show a loading message
    [KTLoader showLoader:@"Deleting object..."];
    
    // get a reference to the selected KiiObject
    KiiObject *object = [self kiiObjectAtIndex:index];
    
    // remove the object asynchronously
    [object deleteWithBlock:^(KiiObject *deletedObject, NSError *error) {
        
        // check for an error (successful request if error == nil)
        if(error == nil) {
            
            [KTLoader showLoader:@"Object deleted!"
                        animated:TRUE
                   withIndicator:KTLoaderIndicatorSuccess
                 andHideInterval:KTLoaderDurationAuto];
            
            // reload our table
            [self refreshQuery];
            
        }
        
        // there was an error with the request
        else {
            
            // tell the user
            [KTLoader showLoader:@"Error deleting object"
                        animated:TRUE
                   withIndicator:KTLoaderIndicatorError
                 andHideInterval:KTLoaderDurationAuto];
            
            // tell the console
            NSLog(@"Error deleting object: %@", error.description);
        }
        
    }];
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // push the view controller with the session information
    SingleContactViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SingleContactViewController"];
    vc.userObject = [self kiiObjectAtIndex:indexPath.row];
    vc.navigationItem.title = @"Edit Contact";
    [self.navigationController presentViewController:vc animated:TRUE completion:nil];
}

// this table supports editing, so handle delete requests
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // this should always be true in this app
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteObject:indexPath.row];
    }
}

- (void) tableDidStartLoading
{
    [KTLoader showLoader:@"Loading My Contacts..."];
}

- (void) tableDidFinishLoading:(NSError *)error
{
    if(error == nil) {
        [KTLoader hideLoader];
    } else {
        [KTLoader showLoader:@"Unable to load!"
                    animated:TRUE
               withIndicator:KTLoaderIndicatorError
             andHideInterval:KTLoaderDurationAuto];
    }
}

@end

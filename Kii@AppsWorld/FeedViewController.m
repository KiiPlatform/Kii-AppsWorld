//
//  FeedViewController.m
//  Kii@AppsWorld
//
//  Created by Chris on 10/10/13.
//  Copyright (c) 2013 Kii Corporation. All rights reserved.
//

#import "FeedViewController.h"

@implementation FeedViewController

- (IBAction) takePhoto:(id)sender
{
    BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];

    int cancelIndex = hasCamera ? 2 : 1;
    
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.title = @"Choose Source";
    sheet.delegate = self;
    sheet.cancelButtonIndex = cancelIndex;
    
    if(hasCamera) {
        [sheet addButtonWithTitle:@"Camera"];
    }
    
    [sheet addButtonWithTitle:@"Gallery"];
    [sheet addButtonWithTitle:@"Cancel"];
    
    [sheet showFromTabBar:self.tabBarController.tabBar];

}

- (void) cancelMessage:(id)sender
{
    
    // change the buttons
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                           target:self
                                                                           action:@selector(composeMessage:)];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                          target:self
                                                                          action:@selector(takePhoto:)];
    [_navItem setRightBarButtonItem:right];
    [_navItem setLeftBarButtonItem:left];

    _navItem.title = @"Live Feed";
    _composeView.text = @"";
    _composeView.hidden = TRUE;
    
    [_composeView resignFirstResponder];
}

- (void) postMessage:(id)sender
{
    NSLog(@"Post: %@", _composeView.text);
    
    [self cancelMessage:sender];
}

- (IBAction) composeMessage:(id)sender
{
    // show the compose view
    _composeView.hidden = FALSE;
    [_composeView becomeFirstResponder];
    
    // change the buttons
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                           target:self
                                                                           action:@selector(postMessage:)];

    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                          target:self
                                                                          action:@selector(cancelMessage:)];

    [_navItem setRightBarButtonItem:right];
    [_navItem setLeftBarButtonItem:left];
    
    [_navItem setTitle:@"Create a Post"];

}

#pragma mark - UIActionSheetDelegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    if(buttonIndex != actionSheet.cancelButtonIndex) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = TRUE;
        
        if(hasCamera && buttonIndex == 0) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        [self presentViewController:picker animated:TRUE completion:nil];
    }

}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // show loading loader
    
    NSLog(@"Info: %@", info);
    
//    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
//    NSLog(@"IMG: %@", img);
    
    // scale it down
    
    [picker dismissViewControllerAnimated:TRUE completion:^{
        // show upload loader and upload
    }];
    
}
@end

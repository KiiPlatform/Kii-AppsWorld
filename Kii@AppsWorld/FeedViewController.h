//
//  FeedViewController.h
//  Kii@AppsWorld
//
//  Created by Chris on 10/10/13.
//  Copyright (c) 2013 Kii Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedViewController : UIViewController
<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet UITextView *composeView;
@property (nonatomic, strong) IBOutlet UINavigationItem *navItem;

- (IBAction) takePhoto:(id)sender;
- (IBAction) composeMessage:(id)sender;

@end

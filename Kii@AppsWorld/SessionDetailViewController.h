//
//  SessionDetailViewController.h
//  Kii@AppsWorld
//
//  Created by Chris on 10/17/13.
//  Copyright (c) 2013 Kii Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SessionDetailViewController : UIViewController

@property (nonatomic, strong) NSDictionary *category;
@property (nonatomic, strong) NSDictionary *session;

@property (nonatomic, strong) IBOutlet UIScrollView *contentView;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *declineButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *confirmButton;

@property (nonatomic, strong) IBOutlet UITextView *composeView;

- (IBAction) confirmAttendance:(id)sender;
- (IBAction) declineAttendance:(id)sender;

@end

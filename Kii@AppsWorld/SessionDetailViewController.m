//
//  SessionDetailViewController.m
//  Kii@AppsWorld
//
//  Created by Chris on 10/17/13.
//  Copyright (c) 2013 Kii Corporation. All rights reserved.
//

#import "SessionDetailViewController.h"

#import "KiiToolkit.h"

#define PADDING     20

@interface SessionDetailViewController() {
    UIActivityIndicatorView *_commentIndicator;
}

@end

@implementation SessionDetailViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
}

- (void) shareSession:(id)sender
{
    NSString *myString = [NSString stringWithFormat:@"Check out this session at AppsWorld: \"%@\". It's taking place in the %@ at %@ hours.", [_session objectForKey:@"title"], [_category objectForKey:@"name"], [_session objectForKey:@"startTimeString"]];
    NSArray* dataToShare = @[myString];
    
    UIActivityViewController *av = [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                                                     applicationActivities:nil];
    [self presentViewController:av animated:YES completion:nil];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"SESSION INFO";
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                 target:self
                                                                                 action:@selector(shareSession:)];
    self.navigationItem.rightBarButtonItem = shareButton;
    
    NSLog(@"Category: %@", _category);
    NSLog(@"Session: %@", _session);
    
    UILabel *categoryName = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, PADDING, 320-PADDING*2, 30)];
    categoryName.text = [[_category objectForKey:@"name"] uppercaseString];
    categoryName.font = [UIFont boldSystemFontOfSize:18.0f];
    categoryName.textColor = [UIColor colorWithHex:[_category objectForKey:@"color"]];
    categoryName.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:categoryName];
    
    UILabel *sessionName = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, categoryName.frame.origin.y + categoryName.frame.size.height, 320-PADDING*2, 30)];
    sessionName.text = [_session objectForKey:@"title"];
    sessionName.font = [UIFont boldSystemFontOfSize:18.0f];
    sessionName.textColor = [UIColor blackColor];
    sessionName.numberOfLines = 100;
    sessionName.lineBreakMode = NSLineBreakByWordWrapping;
    sessionName.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:sessionName];
    
    // adjust the height as needed
    CGSize maximumLabelSize = CGSizeMake(sessionName.frame.size.width, FLT_MAX);
    CGSize expectedLabelSize = [sessionName.text sizeWithFont:sessionName.font constrainedToSize:maximumLabelSize lineBreakMode:sessionName.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = sessionName.frame;
    newFrame.size.height = expectedLabelSize.height;
    sessionName.frame = newFrame;

    
    
    
    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, sessionName.frame.origin.y + sessionName.frame.size.height + PADDING/2, 320-PADDING*2, 30)];
    description.text = [_session objectForKey:@"description"];
    description.font = [UIFont systemFontOfSize:13.0f];
    description.textColor = [UIColor darkGrayColor];
    description.numberOfLines = 1000;
    description.lineBreakMode = NSLineBreakByWordWrapping;
    description.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:description];
    
    // adjust the height as needed
    maximumLabelSize = CGSizeMake(description.frame.size.width, FLT_MAX);
    expectedLabelSize = [description.text sizeWithFont:description.font constrainedToSize:maximumLabelSize lineBreakMode:description.lineBreakMode];
    
    //adjust the label the the new height.
    newFrame = description.frame;
    newFrame.size.height = expectedLabelSize.height;
    description.frame = newFrame;
    
    
    
    UILabel *commentHeader = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, description.frame.origin.y + description.frame.size.height + PADDING, 320-PADDING*2, 30)];
    commentHeader.text = @"COMMENTS";
    commentHeader.font = [UIFont boldSystemFontOfSize:18.0f];
    commentHeader.textColor = [UIColor colorWithHex:[_category objectForKey:@"color"]];
    commentHeader.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:commentHeader];

    _commentIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _commentIndicator.center = CGPointMake(160, commentHeader.frame.origin.y + commentHeader.frame.size.height + PADDING);
    _commentIndicator.hidesWhenStopped = TRUE;
    [_contentView addSubview:_commentIndicator];
    [_commentIndicator startAnimating];
    
    // update the content size
    _contentView.contentSize = CGSizeMake(320, _commentIndicator.frame.origin.y + _commentIndicator.frame.size.height + PADDING);
    
    // dynamically load the comments
    

}


- (IBAction) confirmAttendance:(id)sender
{
    NSLog(@"Confirmed");
}

- (IBAction) declineAttendance:(id)sender
{
    NSLog(@"Declined");
}

@end

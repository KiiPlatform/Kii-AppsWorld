//
//  SessionDetailViewController.m
//  Kii@AppsWorld
//
//  Created by Chris on 10/17/13.
//  Copyright (c) 2013 Kii Corporation. All rights reserved.
//

#import "SessionDetailViewController.h"

#import "KiiToolkit.h"
#import <KiiSDK/Kii.h>

#define PADDING     20

@interface SessionDetailViewController() {
    UIActivityIndicatorView *_commentIndicator;
    UILabel *_noCommentLabel;
    
    NSString *_attendingURI;
}

@end

@implementation SessionDetailViewController

- (void) refreshContentSize
{
    // get the last view height
    CGFloat lowestView = 0;
    for(UIView *v in _contentView.subviews) {
        if([v isKindOfClass:[UILabel class]]) {
            if(v.frame.origin.y + v.frame.size.height > lowestView) {
                lowestView = v.frame.origin.y + v.frame.size.height;
            }
        }
    }

    // update the content size
    _contentView.contentSize = CGSizeMake(320, lowestView + PADDING);
}

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

- (void) writeComment:(KiiObject*)comment
{
    if(_noCommentLabel != nil) {
        [_noCommentLabel removeFromSuperview];
        _noCommentLabel = nil;
    }
    
    if(_commentIndicator != nil) {
        [_commentIndicator removeFromSuperview];
        _commentIndicator = nil;
    }
    
    // get the lowest view here
    CGFloat lowestView = 0;
    for(UIView *v in _contentView.subviews) {
        if([v isKindOfClass:[UILabel class]]) {
            if(v.frame.origin.y + v.frame.size.height > lowestView) {
                lowestView = v.frame.origin.y + v.frame.size.height;
                NSLog(@"Lowest view: %@", v);
            }
        }
    }
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, lowestView+PADDING/2, 320-2*PADDING, 20)];
    name.font = [UIFont boldSystemFontOfSize:16.0f];
    name.text = [comment getObjectForKey:@"username"];
    name.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:name];
    
    NSLog(@"Nameview: %@", name);
    
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, name.frame.size.height + name.frame.origin.y, 320-2*PADDING, 15)];
    time.font = [UIFont systemFontOfSize:12.0f];
    time.text = [[comment created] timeAgo:FALSE];
    time.textColor = [UIColor grayColor];
    time.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:time];
    
    UILabel *commentText = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, time.frame.size.height + time.frame.origin.y, 320-2*PADDING, 20)];
    commentText.font = [UIFont systemFontOfSize:14.0f];
    commentText.text = [comment getObjectForKey:@"comment"];
    commentText.textColor = [UIColor blackColor];
    commentText.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:commentText];
    
    [self refreshContentSize];
}

- (void) cancelComment:(id)sender
{
    // change the buttons
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                           target:self
                                                                           action:@selector(shareSession:)];
    
    [self.navigationItem setRightBarButtonItem:right];
    [self.navigationItem setLeftBarButtonItem:nil];
    
    self.navigationItem.title = @"SESSION INFO";
    _composeView.text = @"";
    _composeView.hidden = TRUE;
    
    [_composeView resignFirstResponder];
}

- (void) postComment:(id)sender
{
    KiiObject *obj = [[Kii bucketWithName:BUCKET_COMMENTS] createObject];
    [obj setObject:[_session objectForKey:@"uri"] forKey:@"session"];
    [obj setObject:[KiiUser currentUser].username forKey:@"username"];
    [obj setObject:_composeView.text forKey:@"comment"];
    
    NSLog(@"Posting: %@", [obj dictionaryValue]);
    
    [KTLoader showLoader:@"Posting Comment..."];
    [obj saveWithBlock:^(KiiObject *object, NSError *error) {
        
        [KTLoader hideLoader];
        
        if(error == nil) {
            
            // create the topic
            NSString *topicName = [NSString stringWithFormat:@"%@-comment",[_session objectForKey:@"uuid"]];
            NSLog(@"Creating topic of name: %@", topicName);
            KiiTopic *topic = [Kii topicWithName:topicName];

            KiiAPNSFields *apnsFields = [KiiAPNSFields createFields];
//            [apnsFields setSound:@"alert"];
//            [apnsFields setBadge:[NSNumber numberWithInt:1]];
//            [apnsFields setSpecificData:@{@"sound": @"alert"}];
            
            NSString *alertBody = [NSString stringWithFormat:@"New comment on: %@", [_session objectForKey:@"title"]];
            NSLog(@"AlertBody: %@", alertBody);
//            [apnsFields setAlertBody:alertBody];
//            [apnsFields setSound:@"alert"];
            KiiPushMessage *message = [KiiPushMessage composeMessageWithAPNSFields:apnsFields andGCMFields:nil];
            [topic sendMessage:message withBlock:^(KiiTopic *topic, NSError *error) {
                NSLog(@"Sent message: %@", error);
            }];
            
            // either way, subscribe
            [KiiPushSubscription subscribe:topic withBlock:^(KiiPushSubscription *subscription, NSError *error) {
                NSLog(@"Subscribed: %@", error);
            }];

            // write the comment
            [self writeComment:object];
            
            // show success
            [KTLoader showLoader:@"Posted!" animated:TRUE withIndicator:KTLoaderIndicatorSuccess];
        } else {
            [KTLoader showLoader:@"Error!" animated:TRUE withIndicator:KTLoaderIndicatorError];
        }

        [self cancelComment:sender];
    }];
}

- (void) addComment:(id)sender
{
    NSLog(@"Add comment");
    
    if([KiiUser loggedIn]) {
        // show the compose view
        _composeView.hidden = FALSE;
        [_composeView becomeFirstResponder];
        
        // change the buttons
        UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                               target:self
                                                                               action:@selector(postComment:)];
        
        UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                              target:self
                                                                              action:@selector(cancelComment:)];
        
        [self.navigationItem setRightBarButtonItem:right];
        [self.navigationItem setLeftBarButtonItem:left];
        
        [self.navigationItem setTitle:@"Add Comment"];
    } else {
        [KTAlert showAlert:KTAlertTypeToast
               withMessage:@"Log in to post comments!"
               andDuration:KTAlertDurationLong];
    }
    
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
    
    
    UIButton *addComment = [UIButton buttonWithType:UIButtonTypeContactAdd];
    addComment.center = CGPointMake(290, commentHeader.center.y);
    [addComment addTarget:self action:@selector(addComment:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:addComment];

    _commentIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _commentIndicator.center = CGPointMake(160, commentHeader.frame.origin.y + commentHeader.frame.size.height + PADDING);
    _commentIndicator.hidesWhenStopped = TRUE;
    [_contentView addSubview:_commentIndicator];
    [_commentIndicator startAnimating];
    
    [self refreshContentSize];
    
    // dynamically load the status if they're logged in
    if([KiiUser loggedIn]) {
        KiiBucket *bucket = [Kii bucketWithName:BUCKET_ATTENDING];
        KiiClause *clause1 = [KiiClause equals:@"user" value:[KiiUser currentUser].uuid];
        KiiClause *clause2 = [KiiClause equals:@"session" value:[_session objectForKey:@"uuid"]];
        KiiQuery *query = [KiiQuery queryWithClause:[KiiClause and:clause1, clause2, nil]];
        [bucket executeQuery:query
                   withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
                       if(error == nil) {
                           
                           _confirmButton.enabled = TRUE;

                           if([results count] > 0) {
                               _confirmButton.title = @"No, I won't be going";

                               KiiObject *o = [results lastObject];
                               _attendingURI = o.objectURI;
                           
                           } else {
                               _confirmButton.title = @"Yes, I will be going";
                           }
                           
                       } else {
                           // keep buttons disabled
                           _confirmButton.enabled = FALSE;
                       }
                       [_loadingStatus stopAnimating];
                   }];
    }
    
    // otherwise, disable the button
    else {
        _confirmButton.title = @"Log in to subscribe";
        _confirmButton.enabled = FALSE;
        [_loadingStatus stopAnimating];
    }

    
    // dynamically load the comments
    KiiBucket *bucket = [Kii bucketWithName:BUCKET_COMMENTS];
    KiiClause *clause = [KiiClause equals:@"session" value:[_session objectForKey:@"uri"]];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    [query sortByAsc:@"_created"];
    [bucket executeQuery:query
               withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
                   
                   [_commentIndicator stopAnimating];
                   
                   int commentCount = 0;
                   if(error == nil) {
                       
                       // write out the comments
                       for(KiiObject *comment in results) {
                           [self writeComment:comment];
                           ++commentCount;
                       }
                       
                   }
                   
                   if(commentCount == 0) {
                       
                       // show 'no comments'
                       _noCommentLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, _commentIndicator.frame.origin.y, 320-PADDING*2, 20)];
                       _noCommentLabel.text = @"No comments yet";
                       _noCommentLabel.textColor = [UIColor grayColor];
                       _noCommentLabel.textAlignment = NSTextAlignmentCenter;
                       _noCommentLabel.font = [UIFont italicSystemFontOfSize:14.f];
                       [_contentView addSubview:_noCommentLabel];
                       
                       [self refreshContentSize];
                   }
               }];

}


- (IBAction) confirmAttendance:(id)sender
{
    if([KiiUser loggedIn]) {
        
        [KTLoader showLoader:@"Saving..."];
        
        // need to create an 'attending' object
        if(_attendingURI == nil) {
            
            KiiBucket *bucket = [Kii bucketWithName:BUCKET_ATTENDING];
            KiiObject *o = [bucket createObject];
            [o setObject:[KiiUser currentUser].uuid forKey:@"user"];
            [o setObject:[_session objectForKey:@"uuid"] forKey:@"session"];
            [o setObject:[_session objectForKey:@"title"] forKey:@"session_title"];
            [o setObject:[_session objectForKey:@"track"] forKey:@"session_track"];
            [o saveWithBlock:^(KiiObject *object, NSError *error) {
                if(error == nil) {
                    
                    _confirmButton.title = @"No, I won't be going";
                    _attendingURI = object.objectURI;
                    
                    // subscribe to comments
                    NSString *topicName = [NSString stringWithFormat:@"%@-comment",[_session objectForKey:@"uuid"]];
                    KiiTopic *topic = [Kii topicWithName:topicName];
                    [KiiPushSubscription subscribe:topic withBlock:^(KiiPushSubscription *subscription, NSError *error) {
                        NSLog(@"Subscribed to comments: %@", error);
                    }];
                    
                    // subscribe to session
                    KiiTopic *sessionTopic = [Kii topicWithName:[_session objectForKey:@"uuid"]];
                    [KiiPushSubscription subscribe:sessionTopic withBlock:^(KiiPushSubscription *subscription, NSError *error) {
                        NSLog(@"Subscribed to session: %@", error);
                    }];
                    
                    [KTLoader showLoader:@"Confirmed!"
                                animated:TRUE
                           withIndicator:KTLoaderIndicatorSuccess
                         andHideInterval:KTLoaderDurationAuto];
                    
                } else {
                    [KTLoader showLoader:@"Error Saving"
                                animated:TRUE
                           withIndicator:KTLoaderIndicatorError
                         andHideInterval:KTLoaderDurationAuto];
                }
            }];
            
        }
        
        else {

            // remove the session from cloud
            KiiObject *o = [KiiObject objectWithURI:_attendingURI];
            [o deleteWithBlock:^(KiiObject *object, NSError *error) {
                if(error == nil) {
                    
                    _confirmButton.title = @"Yes, I will be going";
                    _attendingURI = nil;

                    // un-subscribe from comments
                    NSString *topicName = [NSString stringWithFormat:@"%@-comment",[_session objectForKey:@"uuid"]];
                    KiiTopic *topic = [Kii topicWithName:topicName];
                    [KiiPushSubscription unsubscribe:topic withBlock:^(KiiPushSubscription *subscription, NSError *error) {
                        NSLog(@"unsubscribed from comments: %@", error);
                    }];
                    
                    // unsubscribe from session
                    KiiTopic *sessionTopic = [Kii topicWithName:[_session objectForKey:@"uuid"]];
                    [KiiPushSubscription unsubscribe:sessionTopic withBlock:^(KiiPushSubscription *subscription, NSError *error) {
                        NSLog(@"unsubscribed to session: %@", error);
                    }];
                    

                    [KTLoader showLoader:@"Declined"
                                animated:TRUE
                           withIndicator:KTLoaderIndicatorError
                         andHideInterval:KTLoaderDurationAuto];
                    
                } else {
                    [KTLoader showLoader:@"Error Saving"
                                animated:TRUE
                           withIndicator:KTLoaderIndicatorError
                         andHideInterval:KTLoaderDurationAuto];
                }
            }];

        
        }

    }
}

@end

//
//  WelcomeViewController.m
//  Kii@AppsWorld
//
//  Created by Chris on 10/21/13.
//  Copyright (c) 2013 Kii Corporation. All rights reserved.
//

#import "WelcomeViewController.h"

#import <KiiSDK/Kii.h>
#import "KiiToolkit.h"

@implementation WelcomeViewController

- (void) showTabView
{
    // show the tab view
    UITabBarController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MainTabController"];
    [self presentViewController:vc animated:TRUE completion:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"kii-token"];
    
    if([KiiUser loggedIn]) {
        [self showTabView];
    }
    
    else if(token != nil) {
        
        [KTLoader showLoader:@"Logging In..."];
        [KiiUser authenticateWithToken:token andBlock:^(KiiUser *user, NSError *error) {
            if(error == nil) {
                [self showTabView];
                [KTLoader hideLoader];
            } else {
                [KTLoader showLoader:@"Error!"
                            animated:TRUE
                       withIndicator:KTLoaderIndicatorError
                     andHideInterval:KTLoaderDurationAuto];
            }
        }];

    }
    
}

- (IBAction) signIn:(id)sender
{
    KTLoginViewController *vc = [[KTLoginViewController alloc] init];
    [self presentViewController:vc animated:TRUE completion:nil];
}

@end

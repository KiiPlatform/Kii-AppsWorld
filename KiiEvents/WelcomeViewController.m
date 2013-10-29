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

- (void) continueWithLogin
{
    // Enable push with DevelopmentMode
    [Kii enableAPNSWithDevelopmentMode:NO
                  andNotificationTypes:(UIRemoteNotificationTypeBadge |
                                        UIRemoteNotificationTypeSound |
                                        UIRemoteNotificationTypeAlert)];
    
    [self showTabView];
    
    // see if we exist
    KiiBucket *bucket = [[KiiUser currentUser] bucketWithName:BUCKET_CONTACTS];
    
    // if it's their first time
    int openCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"openCount"];
    if(openCount == 0) {
        
        // load in our contact info
        
        KiiObject *chris = [bucket createObject];
        [chris setObject:@"Chris" forKey:@"firstName"];
        [chris setObject:@"Beauchamp" forKey:@"lastName"];
        [chris setObject:@"Kii" forKey:@"company"];
        [chris setObject:@"chris.beauchamp@kii.com" forKey:@"emailAddress"];
        [chris setObject:@"http://kii.com" forKey:@"website"];
        [chris setObject:@"Mobile app guru & engineer for Kii Cloud" forKey:@"notes"];
        [chris saveWithBlock:nil];
        
        KiiObject *phani = [bucket createObject];
        [phani setObject:@"Phani" forKey:@"firstName"];
        [phani setObject:@"Pandrangi" forKey:@"lastName"];
        [phani setObject:@"Kii" forKey:@"company"];
        [phani setObject:@"phani.pandrangi@kii.com" forKey:@"emailAddress"];
        [phani setObject:@"http://kii.com" forKey:@"website"];
        [phani setObject:@"Lead product manager at Kii Cloud" forKey:@"notes"];
        [phani saveWithBlock:nil];
        
        KiiObject *german = [bucket createObject];
        [german setObject:@"German" forKey:@"firstName"];
        [german setObject:@"Viscuso" forKey:@"lastName"];
        [german setObject:@"Kii" forKey:@"company"];
        [german setObject:@"german.viscuso@kii.com" forKey:@"emailAddress"];
        [german setObject:@"http://kii.com" forKey:@"website"];
        [german setObject:@"Mobile app guru & evangelist for Kii Cloud" forKey:@"notes"];
        [german saveWithBlock:nil];
        
    }

    [[NSUserDefaults standardUserDefaults] setInteger:openCount+1 forKey:@"openCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"kii-token"];
    
    if([KiiUser loggedIn]) {
        [self continueWithLogin];
    }
    
    else if(token != nil) {
        
        [KTLoader showLoader:@"Logging In..."];
        [KiiUser authenticateWithToken:token andBlock:^(KiiUser *user, NSError *error) {
            if(error == nil) {
                [KTLoader hideLoader];
                [self continueWithLogin];
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

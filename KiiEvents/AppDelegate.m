//
//  AppDelegate.m
//  Kii@AppsWorld
//
//  Created by Chris on 10/7/13.
//  Copyright (c) 2013 Kii Corporation. All rights reserved.
//

#import "AppDelegate.h"
#import <KiiSDK/Kii.h>

#import "KiiToolkit.h"

@implementation AppDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != alertView.cancelButtonIndex) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://events.kii.com/events/appsworld-london-2013/app"]];
    }
}

- (void) checkForUpdate
{
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSLog(@"Current version: %@", currentVersion);
    
    // set this
    [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"version-number"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    KiiBucket *bucket = [Kii bucketWithName:@"versions"];
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    [query sortByDesc:@"_created"];
    [query setLimit:1];
    [bucket executeQuery:query
               withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
                   if(error == nil) {
                       
                       for(KiiObject *o in results) {
                           
                           NSString *latestVersion = [o getObjectForKey:@"version_number"];
                           NSLog(@"Latest version: %@", latestVersion);
                           
                           if(![currentVersion isEqualToString:latestVersion]) {
                               UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Update!"
                                                                            message:@"There's a new update available :) It's quick and free to download - check it out!"
                                                                           delegate:self
                                                                  cancelButtonTitle:@"Cancel"
                                                                  otherButtonTitles:@"Download", nil];
                               [av show];
                           }
                           
                       }
                       
                   }
               }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.backgroundColor = [UIColor whiteColor];

    [Kii beginWithID:@"894902db"
              andKey:@"a3323c113244e1a7879a80256f2e933e"];

    [KiiAnalytics beginWithID:@"894902db"
                       andKey:@"a3323c113244e1a7879a80256f2e933e"];
    
    NSString *model = [[UIDevice currentDevice] model];
    NSString *sysVersion = [[UIDevice currentDevice] systemVersion];
    NSString *locale = [[NSLocale preferredLanguages] objectAtIndex:0];
    [KiiAnalytics trackEvent:@"launch" withExtras:@{@"model": model, @"system_version": sysVersion, @"locale": locale}];
    
    
    KiiUser *user = [KiiUser userWithUsername:@"myUser"
                                  andPassword:@"myPassword"];
    
    [user performRegistrationWithBlock:^(KiiUser *user, NSError *error) {
        if(error == nil ) {
            // registration was successful
        } else {
            // something bad happened!
        }
    }];
    

    // check for updates
    [self checkForUpdate];
    
    return YES;
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [Kii setAPNSDeviceToken:deviceToken];
    
    [KiiPushInstallation installWithBlock:^(KiiPushInstallation *installation, NSError *error) {
        if(error == nil) {
            NSLog(@"Push installed!");
        } else {
            NSLog(@"Error installing push: %@", error);
        }
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
}

+ (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


@end
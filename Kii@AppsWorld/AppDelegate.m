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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.backgroundColor = [UIColor whiteColor];

    [Kii beginWithID:@"fa71e7e2"
              andKey:@"70577e03f949a31615ecd8c1241fcee8"];
    
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"kii-token"];
    if(token != nil) {
        
        [KiiUser authenticateWithToken:token andBlock:^(KiiUser *user, NSError *error) {
            NSLog(@"Authenticated with token");
        }];
        
    }

    
//    NSError *err;
//    [KiiUser authenticateSynchronous:@"chris" withPassword:@"password" andError:&err];
//    NSLog(@"Logged in user %@ ? %@", [KiiUser currentUser].uuid, err);
    
    return YES;
}
							
@end

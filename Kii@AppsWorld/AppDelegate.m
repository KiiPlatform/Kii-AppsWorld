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
    
    [Kii beginWithID:@"fa71e7e2"
              andKey:@"70577e03f949a31615ecd8c1241fcee8"];

    return YES;
}
							
@end

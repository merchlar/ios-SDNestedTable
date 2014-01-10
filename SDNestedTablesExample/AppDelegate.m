//
//  AppDelegate.m
//  SDNestedTablesExample
//
//  Created by Daniele De Matteis on 21/05/2012.
//  Copyright (c) 2012 Daniele De Matteis. All rights reserved.
//

#import "AppDelegate.h"
#import "ExampleNestedTablesViewController.h"
#import <Parse/Parse.h>

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [Parse setApplicationId:@"KlEY7oBc4M78XYmmQH6hY0HSX8MVK2You8VYgCUQ"
                  clientKey:@"KRJzH78w9O4LS9EbBY17ceCvCb6NMeWPuhBMO4We"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    ExampleNestedTablesViewController *nestedNav = [[ExampleNestedTablesViewController alloc] init];
    self.window.rootViewController = nestedNav;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end

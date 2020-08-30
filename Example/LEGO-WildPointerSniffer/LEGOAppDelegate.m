//
//  LEGOAppDelegate.m
//  LEGO-WildPointerSniffer
//
//  Created by 564008993@qq.com on 08/30/2020.
//  Copyright (c) 2020 564008993@qq.com. All rights reserved.
//

#import "LEGOAppDelegate.h"
#import "LEGOWildPointerSnifferC.h"
#import "LEGOWildPointerSnifferOC.h"

@implementation LEGOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    
//        [LEGOWildPointerSnifferOC registerSniffer];
        
        registerSniffer();
        
        UIView *testObj = [[UIView alloc] init];
        NSLog(@"testObj=%@",testObj);
        
        [testObj release];
        
        for (int i = 0; i < 5000; i ++) {
            UIView *testView= [[UIView alloc] initWithFrame:CGRectMake(0,200,500, 60)];
            NSLog(@"testView=%@",testView);
         }
        
        NSLog(@"testObj=%@",testObj);
    
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

//
//  AppDelegate.m
//  jspatch
//
//  Created by 杨相伟 on 16/5/30.
//  Copyright © 2016年 yangxiangwei. All rights reserved.
//

#import "AppDelegate.h"
#import <JSPatch/JSPatch.h>

@interface AppDelegate ()

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    [JSPatch setupLogger:^(NSString *log) {
//        NSLog(@"JSPatch:%@",log);
//    }];
//    [JSPatch setupCallback:^(JPCallbackType type, NSDictionary *data, NSError *error) {
//        NSLog(@"%@",data);
//        for (int i=0; i<[data allValues].count; i++) {
//            id value = [[data allValues] objectAtIndex:i];
//            if ([value isKindOfClass:[NSData class]]) {
//                NSString *str = [[NSString alloc] initWithData:(NSData *)value encoding:NSUTF8StringEncoding];
//                NSLog(@"%@",str);
//            }
//        } 
//    }];
    
//    [JSPatch testScriptInBundle];
    [JSPatch startWithAppKey:@"69ea8f2196bf4f54"];
    
//    if (DEBUG) {
//        [JSPatch setupDevelopment];
//    }
//    [JSPatch setupUserData:@{@"userId": @"1008670", @"location": @"guangdong"}];
//    [JSPatch sync];
    
  
 
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

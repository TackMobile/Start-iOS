//
//  AppDelegate.m
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"

@implementation AppDelegate
@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    notActive = NO;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [TestFlight takeOff:@"8c164a2e084013eae880e49cf6a4e005_NTU1MTAyMDEyLTAzLTIyIDE4OjE2OjE5LjAzNzQ2OA"];

    self.viewController = [[MasterViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        [self.viewController switchAlarmWithIndex:[[localNotification.userInfo objectForKey:@"alarmIndex"] intValue]];
    }
    
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
        
    notActive = YES;
    [self.viewController scheduleLocalNotifications];
    [self.viewController saveAlarms];
    
    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you.
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
            //bool anySet = NO;
            for (AlarmView *alarm in self.viewController.alarms) {
                if (alarm.isSet && floorf([[alarm.alarmInfo objectForKey:@"date"] timeIntervalSinceNow]) < .5) {
                    if (!alarm.countdownEnded) {
                        [alarm alarmCountdownEnded];
                        [self.viewController switchAlarmWithIndex:alarm.index];
                    }
                }
                /*if (alarm.isSet)
                    anySet = YES;*/
            }
            /*if (anySet && (!reOpenAppNotif || [[reOpenAppNotif fireDate] compare:[NSDate date]] == NSOrderedDescending)) {
                NSLog(@"rescheduling");
                if (reOpenAppNotif)
                    [[UIApplication sharedApplication] cancelLocalNotification:reOpenAppNotif];
                reOpenAppNotif = [[UILocalNotification alloc] init];
                reOpenAppNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:60];
                reOpenAppNotif.alertBody = @"Start needs to be in foreground for alarms to function";
                [[UIApplication sharedApplication] scheduleLocalNotification:reOpenAppNotif];
            }*/
        }
        
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    notActive = NO;
    application.applicationIconBadgeNumber = 0;
    
    if (reOpenAppNotif)
        [[UIApplication sharedApplication] cancelLocalNotification:reOpenAppNotif];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Cancel any scheduled LocalNotifications
    notActive = NO;
    for ( UILocalNotification *notif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        [[UIApplication sharedApplication] cancelLocalNotification:notif];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self.viewController scheduleLocalNotificationsForDump];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"error: %@", error);
}

@end

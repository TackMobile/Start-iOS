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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[MasterViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    // respond to a localnotification being opened
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        [self.viewController switchAlarmWithIndex:[[localNotification.userInfo objectForKey:@"alarmIndex"] intValue]];
        [self.viewController respondedToLocalNot];
    }
    return YES;
}

// when the app is kept in the foreground, this is fired
- (void)applicationWillResignActive:(UIApplication *)application
{
    
    [self.viewController saveAlarms];
    [self.viewController scheduleLocalNotificationsForActiveState:YES];
    
    
    // not sure if we need this background task handler
    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you.
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {

            for (AlarmView *alarm in self.viewController.alarms) {
                if (alarm.isSet && floorf([[alarm getDate] timeIntervalSinceNow]) < .5) {
                    if (!alarm.countdownEnded) {
                        [alarm alarmCountdownEnded];
                        [self.viewController switchAlarmWithIndex:alarm.index];
                    }
                }
            }
        }
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.viewController scheduleLocalNotificationsForActiveState:NO];
    [self.viewController saveAlarms];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Cancel any scheduled LocalNotifications
    for ( UILocalNotification *notif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        [[UIApplication sharedApplication] cancelLocalNotification:notif];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self.viewController respondedToLocalNot];
}

@end

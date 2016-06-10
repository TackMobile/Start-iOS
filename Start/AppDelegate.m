//
//  AppDelegate.m
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"

#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_OS_9_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  if (IS_OS_7_OR_LATER) {
    CGRect mainScreen = [[UIScreen mainScreen] bounds];
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, statusBarFrame.size.height, mainScreen.size.width, mainScreen.size.height)];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
  } else {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  }
  
  self.viewController = [[MasterViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
  self.window.rootViewController = self.viewController;
  [self.window makeKeyAndVisible];
  
  // Respond to a localnotification being opened
  UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
  if (localNotification) {
    [self.viewController switchAlarmWithIndex:[[localNotification.userInfo objectForKey:@"alarmIndex"] intValue]];
    [self.viewController respondedToLocalNot];
  }
  return YES;
}

// When the app is kept in the foreground, this is fired
- (void)applicationWillResignActive:(UIApplication *)application {
  
  [self.viewController saveAlarms];
  [self.viewController scheduleLocalNotificationsForActiveState:YES];
  
  // Not sure if we need this background task handler
  self.bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
    // Clean up any unfinished task business by marking where you stopped or ending the task outright.
    [application endBackgroundTask:self.bgTask];
    self.bgTask = UIBackgroundTaskInvalid;
  }];
  
  // Start the long-running task and return immediately.
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    while ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
      
      for (AlarmView *alarm in self.viewController.alarms) {
        if (alarm.isSet && floorf([[alarm getDate] timeIntervalSinceNow]) < .5) {
          if (!alarm.countdownEnded) {
            [alarm alarmCountdownEnded];
            [self.viewController switchAlarmWithIndex:alarm.alarmIndex];
          }
        }
      }
    }
    [application endBackgroundTask:self.bgTask];
    self.bgTask = UIBackgroundTaskInvalid;
  });
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  [self.viewController scheduleLocalNotificationsForActiveState:NO];
  [self.viewController saveAlarms];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  
  // Cancel any scheduled LocalNotifications
  for (UILocalNotification *notif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
    [[UIApplication sharedApplication] cancelLocalNotification:notif];
  }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
  [self.viewController respondedToLocalNot];
}

@end

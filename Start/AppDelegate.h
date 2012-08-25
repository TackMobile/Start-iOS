//
//  AppDelegate.h
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 TackMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestFlight.h"

@class MasterViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    bool notActive;
    UILocalNotification *reOpenAppNotif;
    unsigned int bgTask;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MasterViewController *viewController;

@end

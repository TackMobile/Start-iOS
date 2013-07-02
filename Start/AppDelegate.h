//
//  AppDelegate.h
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 Tack Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MasterViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    unsigned int bgTask;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MasterViewController *viewController;

@end

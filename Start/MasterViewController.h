//
//  ViewController.h
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AlarmView.h"
#import "SelectAlarmView.h"
#import "PListModel.h"
#import "MusicPlayer.h"
#import "SettingsView.h"

@interface MasterViewController : UIViewController <SelectAlarmViewDelegate, AlarmViewDelegate, AVAudioPlayerDelegate, SettingsViewDelegate>

@property (nonatomic, strong) NSMutableArray *alarms;

- (void)saveAlarms;
- (void)scheduleLocalNotificationsForActiveState:(bool)isActive;
- (void)respondedToLocalNot;

- (void)alarmAdded;
- (void)songPlayingTick:(NSTimer *)timer;

@end

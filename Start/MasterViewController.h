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

enum SwitchAlarmDirection {
    SwitchAlarmNext = -1,
    SwitchAlarmNone,
    SwitchAlarmPrev
};

@interface MasterViewController : UIViewController <SelectAlarmViewDelegate, AlarmViewDelegate, AVAudioPlayerDelegate> {
    
    CGRect prevAlarmRect;
    CGRect currAlarmRect;
    float asideOffset;
    
    int currAlarmIndex;
    
    int shouldSwitch;
}

//extern const float Spacing;

@property (nonatomic, strong) SettingsView *settingsView;
@property (nonatomic, strong) MusicPlayer *musicPlayer;
@property (nonatomic, strong) NSMutableArray *alarms;
@property (nonatomic, strong) SelectAlarmView *selectAlarmView;
@property (nonatomic, strong) PListModel *pListModel;
@property (nonatomic, strong) NSTimer *tickTimer;

@property (nonatomic, strong) UIButton *addButton;

- (void) saveAlarms;
- (void) scheduleLocalNotifications;
- (void) scheduleLocalNotificationsForDump;
- (void) respondedToLocalNot;

- (void) alarmAdded;
- (void) updateAlarmViews:(NSTimer *)timer;
- (void) songPlayingTick:(NSTimer *)timer;
- (void) alarmView:(AlarmView *)alarmView draggedWithXVel:(float)xVel;
- (void) alarmView:(AlarmView *)alarmView stoppedDraggingWithX:(float)x;

@end

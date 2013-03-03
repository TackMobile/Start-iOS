//
//  AlarmView.h
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SelectSongView.h"
#import "SelectActionView.h"
#import "SelectDurationView.h"
#import "SelectedTimeView.h"
#import "PListModel.h"
#import "CountdownView.h"
#import "MusicManager.h"
#import "RadialGradientView.h"
#import "MusicPlayer.h"

#import "StopwatchViewController.h"

@class AlarmView;

@protocol AlarmViewDelegate <NSObject>
- (MusicPlayer *)getMusicPlayer;

-(PListModel *)getPListModel;
-(void) alarmView:(AlarmView *)alarmView draggedWithXVel:(float)xVel;
-(void) alarmView:(AlarmView *)alarmView stoppedDraggingWithX:(float)x;
-(void) alarmViewOpeningMenuWithPercent:(float)percent;
-(void) alarmViewClosingMenuWithPercent:(float)percent;

-(void) durationViewWithIndex:(int)index draggedWithPercent:(float)percent;

-(bool)alarmViewPinched:(AlarmView *)alarmView;
-(void)alarmViewUpdated;
-(void)alarmCountdownEnded:(AlarmView *)alarmView;
@end

enum AlarmViewShouldSet {
    AlarmViewShouldSet = 0,
    AlarmViewShouldUnSet,
    AlarmViewShouldStopwatch,
    AlarmViewShouldNone
};

@interface AlarmView : UIView <SelectDurationViewDelegate, SelectSongViewDelegate, SelectActionViewDelegate> {    
    CGRect selectedTimeRect;
    CGRect selectDurRect;
    CGRect selectSongRect;
    CGRect selectActionRect;
    CGRect alarmSetDurRect;
    CGRect stopwatchModeDurRect;
    CGRect countdownRect;
    CGRect stopwatchRect;
    CGRect radialRect;
//  CGRect bgImageRect;
    
    MusicManager *musicManager;
    
    int shouldSet;
    
    bool pickingSong;
    bool pickingAction;
    bool cancelTouch;
    bool isSnoozing;
    
    bool _countdownEnded;
    
    UIView *durationMaskView;
    
    CAGradientLayer *toolbarGradient;
    
}
extern const float Spacing;

@property (nonatomic, strong) id<AlarmViewDelegate> delegate;
@property CGRect newRect;
@property bool isSet;
@property bool isTiming;
@property bool countdownEnded;

@property bool isStopwatchMode;
@property bool isTimerMode;
@property bool isSnoozing;
@property int index;

@property (nonatomic, strong) NSMutableDictionary *alarmInfo;

@property (nonatomic, strong) RadialGradientView *radialGradientView;

//@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIImageView *patternOverlay;
@property (nonatomic, strong) UIImageView *toolbarImage;
@property (nonatomic, strong) UIImageView *selectAlarmBg;


@property (nonatomic, strong) SelectSongView *selectSongView;
@property (nonatomic, strong) SelectActionView *selectActionView;
@property (nonatomic, strong) SelectDurationView *selectDurationView;
@property (nonatomic, strong) SelectedTimeView *selectedTimeView;
@property (nonatomic, strong) CountdownView *countdownView;
@property (nonatomic, strong) StopwatchViewController *stopwatchViewController;

@property (nonatomic, strong) UILabel *deleteLabel;

- (void) shiftedFromActiveByPercent:(float)percent;
- (void) updateProperties;

- (void) viewWillAppear;
- (bool) canMove;
- (void) alarmCountdownEnded;
- (id) initWithFrame:(CGRect)frame index:(int)aIndex delegate:(id<AlarmViewDelegate>)aDelegate alarmInfo:(NSDictionary *)theAlarmInfo;
- (NSDate *)getDate;

- (bool) countdownEnded;
- (void) setCountdownEnded:(bool)newVal;

@end

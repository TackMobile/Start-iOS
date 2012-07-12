//
//  AlarmView.h
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectSongView.h"
#import "SelectActionView.h"
#import "SelectDurationView.h"
#import "CountdownTimer.h"
#import "SelectedTimeView.h"
#import "PListModel.h"
#import "CountdownView.h"
#import "MusicManager.h"

@class AlarmView;

@protocol AlarmViewDelegate <NSObject>

-(PListModel *)getPListModel;
-(void) alarmView:(AlarmView *)alarmView draggedWithXVel:(float)xVel;
-(void) alarmView:(AlarmView *)alarmView stoppedDraggingWithX:(float)x;
-(void) alarmViewOpeningMenuWithPercent:(float)percent;
-(void) alarmViewClosingMenuWithPercent:(float)percent;

-(void) durationViewWithIndex:(int)index draggedWithPercent:(float)percent;
@end

enum AlarmViewShouldSet {
    AlarmViewShouldSet = 0,
    AlarmViewShouldUnSet,
    AlarmViewShouldNone
};

@interface AlarmView : UIView <CountdownTimerDelegate, SelectDurationViewDelegate, SelectSongViewDelegate, SelectActionViewDelegate> {    
    CGRect selectedTimeRect;
    CGRect selectDurRect;
    CGRect selectSongRect;
    CGRect selectActionRect;
    CGRect alarmSetDurRect;
    CGRect countdownRect;
    
    MusicManager *musicManager;
    
    int shouldSet;
    
    bool pickingSong;
    bool pickingAction;
    bool cancelTouch;
}
@property (nonatomic, strong) id<AlarmViewDelegate> delegate;
@property CGRect newRect;
@property bool isSet;
@property int index;

@property (nonatomic, strong) NSMutableDictionary *alarmInfo;

@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIImageView *toolbarImage;

@property (nonatomic, strong) SelectSongView *selectSongView;
@property (nonatomic, strong) SelectActionView *selectActionView;
@property (nonatomic, strong) SelectDurationView *selectDurationView;
@property (nonatomic, strong) SelectedTimeView *selectedTimeView;
@property (nonatomic, strong) CountdownView *countdownView;

@property (nonatomic, strong) CountdownTimer *countdownTimer;

- (void) updateProperties;
- (void) viewWillAppear;
- (bool) canMove;
- (id) initWithFrame:(CGRect)frame index:(int)aIndex delegate:(id<AlarmViewDelegate>)aDelegate alarmInfo:(NSDictionary *)theAlarmInfo;

@end

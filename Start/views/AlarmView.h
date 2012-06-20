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

@interface AlarmView : UIView <CountdownTimerDelegate, SelectDurationViewDelegate> {
    CGRect selectedTimeRect;
}

@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIImageView *toolbarImage;

@property (nonatomic, strong) SelectSongView *selectSongView;
@property (nonatomic, strong) SelectActionView *selectActionView;
@property (nonatomic, strong) SelectDurationView *selectDurationView;
@property (nonatomic, strong) SelectedTimeView *selectedTimeView;

@property (nonatomic, strong) CountdownTimer *countdownTimer;

@end

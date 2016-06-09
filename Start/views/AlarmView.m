//
//  AlarmView.m
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 TackMobile. All rights reserved.
//

#import "AlarmView.h"
#import "LocalizedStrings.h"
#import "Constants.h"

@implementation AlarmView

const float Spacing = 0.0f;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    shouldSet = AlarmViewShouldNone;
    [self setClipsToBounds:YES];
    pickingSong = NO;
    pickingAction = NO;
    cancelTouch = NO;
    _countdownEnded = NO;
    _isSnoozing = NO;
    hasLoaded = NO;
    
    musicManager = [[MusicManager alloc] init];
    PListModel *pListModel = [_delegate getPListModel];
    
    // Views
    CGSize bgImageSize = CGSizeMake(520, 480);
    CGRect frameRect = [[UIScreen mainScreen] applicationFrame];
    
    radialRect = CGRectMake((self.frame.size.width-bgImageSize.width)/2, 0, bgImageSize.width, frameRect.size.height);
    
    CGRect toolBarRect = CGRectMake(0, 0, self.frame.size.width, 135);
    selectSongRect = CGRectMake(Spacing-16, 0, frameRect.size.width-65, 80);
    selectActionRect = CGRectMake(Spacing+frameRect.size.width-50, 0, 50, 70);
    selectDurRect = CGRectMake(Spacing, [UIScreen mainScreen].applicationFrame.size.height/2 - frameRect.size.width/2.25, frameRect.size.width, frameRect.size.width);
    alarmSetDurRect = CGRectOffset(selectDurRect, 0, -120);
    stopwatchModeDurRect = CGRectOffset(selectDurRect, 0, 150);
    
    stopwatchRect = (CGRect){CGPointZero, self.frame.size};
    selectedTimeRect = CGRectExtendFromPoint(CGRectCenter(selectDurRect), 65, 65);
    CGRect durationMaskRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    countdownRect = CGRectMake(Spacing, alarmSetDurRect.origin.y+alarmSetDurRect.size.height, frameRect.size.width, self.frame.size.height - (alarmSetDurRect.origin.y+alarmSetDurRect.size.height) - 65); //alarm clock countdown label
    CGRect deleteLabelRect = CGRectMake(Spacing, 12, frameRect.size.width, 70);
    CGRect selectAlarmRect = CGRectMake(0, self.frame.size.height-50, self.frame.size.width, 50);
    
    _radialGradientView = [[RadialGradientView alloc] initWithFrame:radialRect]; //radial background
    
    _toolbarImage = [[UIImageView alloc] initWithFrame:toolBarRect];
    _selectSongView = [[SelectSongView alloc] initWithFrame:selectSongRect delegate:self presetSongs:[pListModel getPresetSongs]];
    _selectActionView = [[SelectActionView alloc] initWithFrame:selectActionRect delegate:self actions:[pListModel getActions]];
    _selectDurationView = [[SelectDurationView alloc] initWithFrame:selectDurRect delegate:self]; //dial
    _selectedTimeView = [[SelectedTimeView alloc] initWithFrame:selectedTimeRect]; //clock in middle of dial
    _countdownView = [[CountdownView alloc] initWithFrame:countdownRect];
    durationMaskView = [[UIView alloc] initWithFrame:durationMaskRect];
    _stopwatchViewController = [[StopwatchViewController alloc] init];
    [_stopwatchViewController.view setFrame:stopwatchRect];
    _deleteLabel = [[UILabel alloc] initWithFrame:deleteLabelRect];
    _selectAlarmBg = [[UIImageView alloc] initWithFrame:selectAlarmRect];
    
    [_selectAlarmBg setImage:[UIImage imageNamed:@"bottom-fade"]];
    
    [self addSubview:_radialGradientView];
    [self addSubview:_countdownView];
    [self addSubview:_stopwatchViewController.view];
    [self addSubview:durationMaskView];
    [durationMaskView addSubview:_selectDurationView];
    [self addSubview:_selectSongView];
    [self addSubview:_selectActionView];
    [self addSubview:_selectedTimeView];
    [self addSubview:_deleteLabel];
    
    _deleteLabel.font = [UIFont fontWithName:StartFontName.roboto size:30];
    _deleteLabel.backgroundColor = [UIColor clearColor];
    _deleteLabel.textColor = [UIColor whiteColor];
    _deleteLabel.alpha = 0;
    _deleteLabel.textAlignment = NSTextAlignmentCenter;
    _deleteLabel.numberOfLines = 0;
    _deleteLabel.text = [LocalizedStrings pinchToDelete];
    
    _patternOverlay.image = [UIImage imageNamed:@"grid"];
    
    // pinch to delete
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(alarmPinched:)];
    [self addGestureRecognizer:pinch];
    
    // initial properties
    [_selectedTimeView updateDate:[_selectDurationView getDate] part:SelectDurationNoHandle];
    _toolbarImage.image = [UIImage imageNamed:@"toolbarBG"];
    self.backgroundColor = [UIColor blackColor];
    _countdownView.alpha = 0;
    _stopwatchViewController.view.alpha = 0;
    _patternOverlay.alpha = 0;
    _toolbarImage.alpha = 0;
    _selectAlarmBg.alpha = 0;
    CGRect selectActionTableViewRect = CGRectMake(0, 0, frameRect.size.width-75, self.frame.size.height);
    _selectActionView.actionTableView.frame = selectActionTableViewRect;
    
    toolbarGradient = [CAGradientLayer layer];
    NSArray *gradientColors = @[
                                (id)[[UIColor clearColor] CGColor],
                                (id)[[UIColor whiteColor] CGColor]
                                ];
    
    float topFadeHeight = (toolBarRect.size.height-10)/self.frame.size.height;
    
    NSArray *gradientLocations = @[
                                   [NSNumber numberWithFloat:0.05f],
                                   [NSNumber numberWithFloat:topFadeHeight]
                                   ];
    
    [toolbarGradient setColors:gradientColors];
    [toolbarGradient setLocations:gradientLocations];
    [toolbarGradient setFrame:durationMaskRect];
    [durationMaskView.layer setMask:toolbarGradient];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame index:(NSInteger)aIndex delegate:(id<AlarmViewDelegate>)aDelegate alarmInfo:(NSDictionary *)theAlarmInfo {
  _alarmIndex = aIndex;
  _delegate = aDelegate;
  
  self = [self initWithFrame:frame];
  
  if (theAlarmInfo) {
    _alarmInfo = [[NSMutableDictionary alloc] initWithDictionary:theAlarmInfo];
  } else {
    _alarmInfo = nil;
  }
  return self;
}

- (void)alert:(NSString *)message {
  UILabel *alertLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.frame, 0, self.frame.size.height * 1/2)];
  alertLabel.text = message;
  [self addSubview:alertLabel];
  
  [UIView animateWithDuration:.5 delay:2 options:0 animations:^{
    alertLabel.alpha = 0;
  } completion:^(BOOL finished) {
    [alertLabel removeFromSuperview];
  }];
}

- (void)viewWillAppear {
  // Init the picker's stuff
  NSNumber *no = [NSNumber numberWithBool:NO];            // false
  NSNumber *defaultDur = [NSNumber numberWithInt:30*60+(6*60*60)];   // 6:30
  NSNumber *noID = [NSNumber numberWithInt:-1];
  
  NSDictionary *alarmInfoTemplate = [NSDictionary dictionaryWithObjectsAndKeys:
                                     no,              @"isTimerMode",
                                     no,              @"isStopwatchMode",
                                     no,              @"isSet",
                                     [NSDate date],   @"dateSet",
                                     [NSDate date],   @"dateAlarmPicked",
                                     [NSDate date],   @"stopwatchDateBegan",
                                     defaultDur,      @"alarmDuration",
                                     defaultDur,      @"timerDuration",
                                     noID,            @"songID",
                                     noID,            @"themeID",
                                     @"",             @"actionTitle", nil];
  
  if (!self.alarmInfo) {
    self.alarmInfo = alarmInfoTemplate.mutableCopy;
    
  } else {
    // Extend AlarmTemplate with values already in alarmInfo
    NSMutableDictionary *extendedInfoTemplate = alarmInfoTemplate.mutableCopy;
    
    // isTimerMode, isStopeatchMode, isSet
    [self extendKey:@"isTimerMode" fromDict:self.alarmInfo toDict:extendedInfoTemplate];
    [self extendKey:@"isStopwatchMode" fromDict:self.alarmInfo toDict:extendedInfoTemplate];
    [self extendKey:@"isSet" fromDict:self.alarmInfo toDict:extendedInfoTemplate];
    
    // dateSet
    [self extendKey:@"dateSet" fromDict:self.alarmInfo toDict:extendedInfoTemplate];
    
    // dateAlarmPicked
    if (![self extendKey:@"dateAlarmPicked" fromDict:self.alarmInfo toDict:extendedInfoTemplate]) {
      if ([self.alarmInfo objectForKey:@"dateSet"])
      [extendedInfoTemplate setObject:[self.alarmInfo objectForKey:@"dateSet"] forKey:@"dateAlarmPicked"];
      else
      [extendedInfoTemplate setObject:[NSDate date] forKey:@"dateAlarmPicked"];
    }
    
    // stopwatchDateBegan
    [self extendKey:@"stopwatchDateBegan" fromDict:self.alarmInfo toDict:extendedInfoTemplate];
    
    // alarmDuration
    if (![self extendKey:@"alarmDuration" fromDict:self.alarmInfo toDict:extendedInfoTemplate]) {
      // if we can't extend it, check for depreciated keys
      
      float secondsSinceMidnight = -1; // get the old amount of secondsSinceMidnight
      
      if ([self.alarmInfo objectForKey:@"secondsSinceMidnight"]) // secondsSinceMidnight is depreciated
      secondsSinceMidnight = [[self.alarmInfo objectForKey:@"secondsSinceMidnight"] floatValue];
      else if ([self.alarmInfo objectForKey:@"date"])
      secondsSinceMidnight = [[self secondsSinceMidnightWithDate:(NSDate *)[self.alarmInfo objectForKey:@"date"]] floatValue];
      
      // convert secondsSinceMidnight to a duration from the dateSet
      float setSecondsSinceMidnight = [[self secondsSinceMidnightWithDate:[self.alarmInfo objectForKey:@"dateSet"]] floatValue];
      float alarmDuration;
      
      if (setSecondsSinceMidnight > secondsSinceMidnight) {
        alarmDuration = (secondsSinceMidnight + 24*60*60)-setSecondsSinceMidnight;
      } else {
        alarmDuration = secondsSinceMidnight-setSecondsSinceMidnight;
      }
      
      // save the new duration
      [extendedInfoTemplate setObject:[NSNumber numberWithFloat:alarmDuration] forKey:@"alarmDuration"];
    }
    
    // timerDuration &  songID & themeID
    [self extendKey:@"timerDuration" fromDict:self.alarmInfo toDict:extendedInfoTemplate];
    [self extendKey:@"songID" fromDict:self.alarmInfo toDict:extendedInfoTemplate];
    [self extendKey:@"themeID" fromDict:self.alarmInfo toDict:extendedInfoTemplate];
    
    // actionTitle
    if (![self extendKey:@"actionTitle" fromDict:self.alarmInfo toDict:extendedInfoTemplate]) {
      // check for depreciated actionID
      if ([self.alarmInfo objectForKey:@"actionID"]) {
        int actionID = [[self.alarmInfo objectForKey:@"actionID"] intValue];
        [extendedInfoTemplate setObject:[self.selectActionView actionTitleWithID:actionID] forKey:@"actionTitle"];
      }
    }
    
    // snooze (not in template because it is deleted upon being unset
    if ([self extendKey:@"snoozeAlarm" fromDict:self.alarmInfo toDict:extendedInfoTemplate]) {
      self.isSnoozing = YES;
    }
    
    self.alarmInfo = extendedInfoTemplate;
  }
  
  if ([self.alarmInfo objectForKey:@"snoozeAlarm"])
  self.isSnoozing = YES;
  
  // update local variables and views
  if ([[self.alarmInfo objectForKey:@"isSet"] boolValue])
  self.isSet = YES;
  
  
  if ([[self.alarmInfo objectForKey:@"isTimerMode"] boolValue]) {
    [self enterTimerMode]; // sets isTimerMode
    if (self.isSet)
    [self.selectDurationView beginTiming];
  } else {
    [self enterAlarmMode];
  }
  //[selectDurationView setSecondsFromZero:[self getSecondsFromMidnight]];
  
  
  [self.selectSongView selectCellWithID:[self.alarmInfo objectForKey:@"songID"]];
  [self.selectActionView selectActionWithTitle:[self.alarmInfo objectForKey:@"actionTitle"]];
  [self updateThemeWithArtwork:nil];
  
  if ([[self.alarmInfo objectForKey:@"isStopwatchMode"] boolValue]) {
    self.isStopwatchMode = YES;
    [self.selectDurationView compressByRatio:0 animated:YES];
    [self.selectedTimeView setAlpha:0];
  }
  
  [self durationDidEndChanging:self.selectDurationView];
  [self animateSelectDurToRest];
  hasLoaded = YES;
}

#pragma mark - utility functions

- (bool)extendKey:(NSString *)key fromDict:(NSDictionary *)fromDict toDict:(NSMutableDictionary *)toDict {
  if ([fromDict objectForKey:key]) {
    [toDict setObject:[fromDict objectForKey:key] forKey:key];
    return YES;
  }
  return NO;
}

- (bool)canMove {
  return !(pickingSong || pickingAction);
}

- (void)alarmCountdownEnded {
  if (!self.countdownEnded && self.isSet) {
    self.countdownEnded = YES;
    [self.delegate alarmCountdownEnded:self];
    if (!self.isTimerMode)
    [self.selectedTimeView showSnooze];
  }
}

- (void)alarmCountdownEndedIsActive:(bool)isActive {
  if (!self.countdownEnded && self.isSet) {
    self.countdownEnded = YES;
    [self.delegate alarmCountdownEnded:self];
    if (!self.isTimerMode)
    [self.selectedTimeView showSnooze];
  }
}

- (NSDate *)getDate {
  NSDate *theDate;
  if (self.isTimerMode) {
    if (self.isSet) {
      // add timer duration to date set and get seconds since midnight
      theDate = [[self.alarmInfo objectForKey:@"dateSet"]
                 dateByAddingTimeInterval:[[self.alarmInfo objectForKey:@"timerDuration"] floatValue]];
    } else {
      theDate = [[NSDate date] dateByAddingTimeInterval:
                 [[self.alarmInfo objectForKey:@"timerDuration"] floatValue]];
    }
  } else {
    if (self.isSnoozing) {
      theDate = [self.alarmInfo objectForKey:@"snoozeAlarm"];
      
    } else {
      theDate = [[self.alarmInfo objectForKey:@"dateAlarmPicked"]
                 dateByAddingTimeInterval:[[self.alarmInfo objectForKey:@"alarmDuration"] floatValue]];
    }
  }
  return theDate;
}

#pragma mark - functionality
- (void)enterTimerMode {
  self.isTimerMode = YES;
  [self.alarmInfo setObject:[NSNumber numberWithBool:YES] forKey:@"isTimerMode"];
  
  int seconds = [[self.alarmInfo objectForKey:@"timerDuration"] intValue];
  [self.selectDurationView enterTimerModeWithSeconds:seconds];
  [self.selectedTimeView enterTimerMode];
  
  // update selectedTime View
  [self.selectedTimeView updateDuration:seconds part:self.selectDurationView.handleSelected];
}

- (void)enterAlarmMode {
  self.isTimerMode = NO;
  [self.alarmInfo setObject:[NSNumber numberWithBool:NO] forKey:@"isTimerMode"];
  
  int seconds = [self getSecondsFromMidnight];
  [self.selectDurationView exitTimerModeWithSeconds:seconds];
  [self.selectedTimeView enterAlarmMode];
  
  [self.selectedTimeView updateDate:[self getDate] part:self.selectDurationView.handleSelected];
}

- (void)setCountdownEnded:(bool)newVal {
  [self.alarmInfo setObject:[NSNumber numberWithBool:newVal] forKey:@"countdownEnded"];
  _countdownEnded = newVal;
}

- (bool)countdownEnded {
  return _countdownEnded;
}

#pragma mark - Touches
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  
  CGPoint touchLoc = [touch locationInView:self];
  CGPoint prevTouchLoc = [touch previousLocationInView:self];
  
  CGSize touchVel = CGSizeMake(touchLoc.x-prevTouchLoc.x, touchLoc.y-prevTouchLoc.y);
  
  // Check if dragging between alarms
  if (pickingSong || pickingAction) {
    if (fabs(touchVel.width) > 15) {
      if (touchVel.width < 0 && pickingSong) {
        [self.selectSongView quickSelectCell];
      } else {
        [self.selectActionView quickSelectCell];
      }
      cancelTouch = YES;
      if ([self.selectDurationView draggingOrientation] == SelectDurationDraggingHoriz)
      [self.selectDurationView setDraggingOrientation:SelectDurationDraggingCancel];
    }
  }
  if (fabs(touchVel.width) > fabs(touchVel.height) && !cancelTouch)
  if ([self.delegate respondsToSelector:@selector(alarmView:draggedWithXVel:)])
  [self.delegate alarmView:self draggedWithXVel:touchVel.width];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  cancelTouch = NO;
  if ([self.delegate respondsToSelector:@selector(alarmView:stoppedDraggingWithX:)])
  [self.delegate alarmView:self stoppedDraggingWithX:self.frame.origin.x];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self touchesEnded:touches withEvent:event];
}

-(void)alarmPinched:(UIPinchGestureRecognizer *)pinchRecog {
  if (![self canMove])
  return;
  
  [self.selectDurationView touchesCancelled:nil withEvent:nil];
  if (pinchRecog.state == UIGestureRecognizerStateBegan) {
    [self.selectSongView setAlpha:0];
    [self.selectActionView setAlpha:0];
    [self.deleteLabel setAlpha:1];
    
  } else if (pinchRecog.state == UIGestureRecognizerStateChanged) {
    [self.selectDurationView setAlpha:0];
    if (pinchRecog.scale > 1)
    pinchRecog.scale = 1;
    float scale = .8 + .2 * (1-(3 * (1-pinchRecog.scale)));
    
    if (self.isSet)
    self.countdownView.alpha = scale;
    
    self.selectDurationView.alpha = scale;
    self.selectedTimeView.alpha = scale;
    
    if (!self.isStopwatchMode)
    [self.selectDurationView compressByRatio:scale animated:NO];
    
  } else if (pinchRecog.state == UIGestureRecognizerStateEnded) {
    if (pinchRecog.scale < .7) {
      if ([self.delegate respondsToSelector:@selector(alarmViewPinched:)] )
      if ([self.delegate alarmViewPinched:self]) {
        if (!self.isStopwatchMode)
        [self.selectDurationView compressByRatio:0 animated:YES];
        return;
      }
    }
    if (!self.isStopwatchMode) {
      [self addSubview:self.selectSongView];
      [self addSubview:self.selectActionView];
    }
    [self.deleteLabel setAlpha:0];
    [self.selectSongView setAlpha:1];
    [self.selectActionView setAlpha:1];
    
    if (!self.isStopwatchMode)
    [self.selectDurationView compressByRatio:1 animated:YES];
    
    [UIView animateWithDuration:.2 animations:^{
      [self.selectDurationView setAlpha:1];
      if (!self.isStopwatchMode)
      [self.selectedTimeView setAlpha:1];
      if (self.isSet)
      self.countdownView.alpha = 1;
    } completion:nil];
  }
}

#pragma mark - Posiitoning/Drawing

// Parallax
- (void)shiftedFromActiveByPercent:(float)percent {
  if (pickingSong || pickingAction)
  return;
  
  float screenWidth = self.frame.size.width;
  
  float durPickOffset =       200 * percent;
  float countDownOffset =     120 * percent;
  float songPickOffset =      100 * percent;
  float actionPickOffset =    75 * percent;
  float backgroundOffset =    (self.radialGradientView.frame.size.width - screenWidth)/2 * percent;
  
  CGRect shiftedDurRect = CGRectOffset([self currRestedSelecDurRect], durPickOffset, 0);
  CGRect shiftedCountdownRect = CGRectOffset(countdownRect, countDownOffset, 0);
  CGRect shiftedStopwatchRect = CGRectOffset(stopwatchRect, countDownOffset, 0);
  CGRect shiftedSongRect = CGRectOffset(selectSongRect, songPickOffset, 0);
  CGRect shiftedActionRect = CGRectOffset(selectActionRect, actionPickOffset, 0);
  CGRect shiftedRadialRect = CGRectOffset(radialRect, backgroundOffset, 0);
  
  [self.selectDurationView setFrame:shiftedDurRect];
  [self.selectedTimeView setCenter:self.selectDurationView.center];
  [self.countdownView setFrame:shiftedCountdownRect];
  [self.stopwatchViewController.view setFrame:shiftedStopwatchRect];
  [self.selectSongView setFrame:shiftedSongRect];
  [self.selectActionView setFrame:shiftedActionRect];
  [self.radialGradientView setFrame:shiftedRadialRect];
}

- (void)menuOpenWithPercent:(float)percent {
  [self.radialGradientView setAlpha:1.0f-(.8/(1.0f/percent))];
  if ([self.delegate respondsToSelector:@selector(alarmViewOpeningMenuWithPercent:)])
  [self.delegate alarmViewOpeningMenuWithPercent:percent];
}

- (void)menuCloseWithPercent:(float)percent {
  if (percent==1)
  [self.radialGradientView setAlpha:1];
  else
  [self.radialGradientView setAlpha:(.8/(1.0f/percent))];
  
  if ([self.delegate respondsToSelector:@selector(alarmViewClosingMenuWithPercent:)])
  [self.delegate alarmViewClosingMenuWithPercent:percent];
}

- (void)updateThemeWithArtwork:(UIImage *)artwork {
  int themeID = [(NSNumber *)[self.alarmInfo objectForKey:@"themeID"] intValue];
  
  if (themeID == -1) // convert default theme to 0
  themeID = 0; // future: rendomize theme
  
  NSDictionary *theme;
  if (themeID < 7 && themeID > -1) { // preset theme
    theme = [musicManager getThemeWithID:themeID];
    artwork = [theme objectForKey:@"bgImg"];
    [self.radialGradientView setInnerColor:[theme objectForKey:@"bgInnerColor"] outerColor:[theme objectForKey:@"bgOuterColor"]];
    [self.toolbarImage setAlpha:0];
    [self.selectAlarmBg setAlpha:0];
    [self.patternOverlay setAlpha:0];
    [self.selectDurationView updateTheme:theme];
  } else {
    [self.toolbarImage setAlpha:1];
    [self.selectAlarmBg setAlpha:1];
    theme = [musicManager getThemeForSongID:[self.alarmInfo objectForKey:@"songID"]];
    [self.selectDurationView updateTheme:theme];
    [self.radialGradientView setInnerColor:[theme objectForKey:@"bgInnerColor"] outerColor:[theme objectForKey:@"bgOuterColor"]];
    [self.toolbarImage setAlpha:0];
  }
}

- (void)updateProperties {
  if (!self.countdownEnded && hasLoaded) {
    // Ensure that alarm date is in the future
    if (!self.isTimerMode && !self.isSet) { // unset alarm mode
      
      // Make sure alarm is in future
      while ([[self getDate] timeIntervalSinceNow] < 0) {
        NSDate *newDate = [(NSDate *)[self.alarmInfo objectForKey:@"dateAlarmPicked"] dateByAddingTimeInterval:86400] ;
        [self.alarmInfo setObject:newDate forKey:@"dateAlarmPicked"];
      }
      
      // Make sure alarm is not too far in future (time-travel bugfix)
      while ([[self getDate] timeIntervalSinceNow] > 86400) {
        NSDate *newDate = [(NSDate *)[self.alarmInfo objectForKey:@"dateAlarmPicked"] dateByAddingTimeInterval:-86400] ;
        [self.alarmInfo setObject:newDate forKey:@"dateAlarmPicked"];
      }
      
    }
    
    // Check to see if it will go off
    if (floorf([[self getDate] timeIntervalSinceNow]) < .5) {
      [self alarmCountdownEnded];
      
    }
    [self.countdownView updateWithDate:[self getDate]];
    
  } else {
    // Update with current date so it will flash 00:00
    [self.countdownView updateWithDate:[NSDate date]];
  }
  
  if (self.isStopwatchMode)
  [self.stopwatchViewController updateWithDate:[self.alarmInfo objectForKey:@"stopwatchDateBegan"]];
}

- (CGRect)currRestedSelecDurRect {
  if (self.isSet) {
    return alarmSetDurRect;
  } else if (self.isStopwatchMode) {
    return stopwatchModeDurRect;
  } else {
    return selectDurRect;
  }
}

- (void)displayToastWithText:(NSString *)text {
  // Flash timer message
  UILabel *toast = [[UILabel alloc] initWithFrame:(CGRect){(CGPoint){0,10}, {self.frame.size.width, 50}}];
  [toast setTextAlignment:NSTextAlignmentCenter];
  [toast setText:text];
  [toast setAlpha:0];
  [self addSubview:toast];
  
  [UIView animateWithDuration:.2 animations:^{
    [toast setAlpha:.8];
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:1 delay:.5 options:0 animations:^{
      [toast setAlpha:0];
    } completion:^(BOOL finished) {
      [toast removeFromSuperview];
    }];
  }];
}

#pragma mark - SelectSongViewDelegate

- (id)getDelegateMusicPlayer {
  return [self.delegate getMusicPlayer];
}

- (BOOL)expandSelectSongView {
  if (pickingAction || self.countdownEnded) //does not allow user to press and expand select sound view when the alarm is going off to prevent accidental touch when the user is trying to press snooze
  {
    return NO;
  }
  
  pickingSong = YES;
  
  CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;
  
  CGRect newSelectSongRect = CGRectMake(Spacing, selectSongRect.origin.y, screenSize.width, self.frame.size.height);
  CGRect selectDurPushedRect = CGRectOffset(self.selectDurationView.frame, self.selectSongView.frame.size.width, 0);
  CGRect selectActionPushedRect = CGRectOffset(self.selectActionView.frame, 90, 0);
  CGRect countdownPushedRect = CGRectOffset(self.countdownView.frame, self.selectSongView.frame.size.width, 0);
  CGRect timerPushedRect = CGRectOffset(stopwatchRect, self.selectSongView.frame.size.width, 0);
  
  [UIView animateWithDuration:.2 animations:^{
    [self menuOpenWithPercent:1];
    
    self.selectSongView.frame = newSelectSongRect;
    
    self.selectDurationView.frame = selectDurPushedRect;
    self.selectDurationView.alpha = .6;
    
    self.selectedTimeView.center = self.selectDurationView.center;
    self.selectedTimeView.alpha = .6;
    
    self.selectActionView.frame = selectActionPushedRect;
    self.selectActionView.alpha = .6;
    
    [self.countdownView setFrame:countdownPushedRect];
    [self.countdownView setAlpha:self.isSet?.6:0];
    
    self.stopwatchViewController.view.frame = timerPushedRect;
    self.stopwatchViewController.view.alpha = self.isStopwatchMode?.6:0;
  }];
  
  return YES;
}

- (void)compressSelectSong {
  pickingSong = NO;
  
  // Compress the songSelectView
  [UIView animateWithDuration:.2 animations:^{
    [self menuCloseWithPercent:1];
    self.selectSongView.frame = selectSongRect;
    
    self.selectDurationView.frame =  [self currRestedSelecDurRect];
    self.selectDurationView.alpha = 1;
    
    self.selectedTimeView.center = self.selectDurationView.center;
    if (!self.isStopwatchMode) {
      self.selectedTimeView.alpha = 1;
    }
    self.selectActionView.frame = selectActionRect;
    self.selectActionView.alpha = 1;
    
    self.countdownView.frame = countdownRect;
    self.countdownView.alpha = self.isSet?1:0;
    
    self.stopwatchViewController.view.frame = stopwatchRect;
    self.stopwatchViewController.view.alpha = self.isStopwatchMode?1:0;
  }];
}

- (void)songSelected:(NSNumber *)persistentMediaItemID withArtwork:(UIImage *)artwork theme:(NSNumber *)themeID {
  // Save the song ID
  [self.alarmInfo setObject:persistentMediaItemID forKey:@"songID"];
  [self.alarmInfo setObject:themeID forKey:@"themeID"];
  
  [self updateThemeWithArtwork:artwork];
}

- (void)musicWarningTapped:(id)button {
  [(UIView *)button removeFromSuperview];
}

#pragma mark - SelectActionViewDelegate
- (BOOL)expandSelectActionView {
  if (pickingAction || self.countdownEnded) //does not allow you to press and expand select action view while the alarm is going off to prevent accidental touches if the user is trying to press snooze
  {
    return NO;
  }
  pickingAction = YES;
  
  CGRect newSelectActionRect = CGRectMake(75+Spacing, 0, [[UIScreen mainScreen] applicationFrame].size.width-75, self.frame.size.height);
  CGRect selectDurPushedRect = CGRectOffset(self.selectDurationView.frame, -newSelectActionRect.size.width, 0);
  CGRect selectSongPushedRect = CGRectOffset(self.selectSongView.frame, -self.selectSongView.frame.size.width + Spacing, 0);
  CGRect countdownPushedRect = CGRectOffset(self.countdownView.frame, -newSelectActionRect.size.width, 0);
  CGRect stopwatchPushedRect = CGRectOffset(stopwatchRect, -newSelectActionRect.size.width, 0);
  
  [UIView animateWithDuration:.2 animations:^{
    [self menuOpenWithPercent:1];
    [self.selectActionView setFrame:newSelectActionRect];
    
    [self.selectDurationView setFrame:selectDurPushedRect];
    [self.selectDurationView setAlpha:.9];
    
    [self.selectedTimeView setCenter:self.selectDurationView.center];
    [self.selectedTimeView setAlpha:.9];
    
    [self.selectSongView setFrame:selectSongPushedRect];
    
    [self.selectSongView setAlpha:.9];
    
    [self.countdownView setFrame:countdownPushedRect];
    [self.countdownView setAlpha:self.isSet?.6:0];
    
    [self.stopwatchViewController.view setFrame:stopwatchPushedRect];
    [self.stopwatchViewController.view setAlpha:self.isStopwatchMode?.6:0];
  }];
  
  return YES;
}

- (void)actionSelected:(NSString *)actionTitle {
  pickingAction = NO;
  
  // Save the song ID
  [self.alarmInfo setObject:actionTitle forKey:@"actionTitle"];
  
  // Compress the selectActionView
  [UIView animateWithDuration:.2 animations:^{
    [self menuCloseWithPercent:1];
    [self.selectActionView setFrame:selectActionRect];
    
    [self.selectDurationView setFrame:[self currRestedSelecDurRect]];
    [self.selectDurationView setAlpha:1];
    
    [self.selectedTimeView setCenter:self.selectDurationView.center];
    if (!self.isStopwatchMode)
    [self.selectedTimeView setAlpha:1];
    
    [self.selectSongView setFrame:selectSongRect];
    [self.selectSongView setAlpha:1];
    
    [self.countdownView setFrame:countdownRect];
    [self.countdownView setAlpha:self.isSet?1:0];
    
    [self.stopwatchViewController.view setFrame:stopwatchRect];
    [self.stopwatchViewController.view setAlpha:self.isStopwatchMode?1:0];
  }];
}

#pragma mark - SelectDurationViewDelegate

- (void)durationDidChange:(SelectDurationView *)selectDuration {
  // update selected time label
  if (!self.isTimerMode) {
    [self.selectedTimeView updateDate:[selectDuration getDate] part:selectDuration.handleSelected];
  } else {
    [self.selectedTimeView updateDuration:[selectDuration getSecondsFromZero] part:selectDuration.handleSelected];
  }
}

- (void)durationDidBeginChanging:(SelectDurationView *)selectDuration {
  CGRect belowSelectedTimeRect;
  CGRect newSelectedTimeRect;
  
  newSelectedTimeRect = (CGRect){ {self.selectedTimeView.frame.origin.x,
    (selectDurRect.origin.y - self.selectedTimeView.frame.size.height)/2 +5}, self.selectedTimeView.frame.size};
  belowSelectedTimeRect = CGRectOffset(newSelectedTimeRect, 0, 15);
  
  if (self.isTimerMode) {
    newSelectedTimeRect = CGRectOffset(newSelectedTimeRect, 0, 10);
  }
  
  // Animate selectedTimeView to toolbar
  [UIView animateWithDuration:.1 animations:^{
    [self.selectedTimeView setAlpha:0];
  } completion:^(BOOL finished) {
    [self.selectedTimeView setFrame:belowSelectedTimeRect];
    [UIView animateWithDuration:.07 animations:^{
      [self.selectedTimeView setFrame:newSelectedTimeRect];
      if (!self.isStopwatchMode)
      [self.selectedTimeView setAlpha:1];
      if ([selectDuration handleSelected] != SelectDurationNoHandle) {
        [self.selectSongView setAlpha:.2];
        [self.selectActionView setAlpha:.2];
        [self.radialGradientView setAlpha:.6];
      }
    }];
  }];
  
  if (self.isTimerMode) {
    [self.selectedTimeView updateDuration:[selectDuration getSecondsFromZero]
                                     part:selectDuration.handleSelected];
  } else {
    [self.selectedTimeView updateDate:[selectDuration getDate] part:selectDuration.handleSelected];
  }
}

- (void)durationDidEndChanging:(SelectDurationView *)selectDuration {
  self.selectedTimeView.alpha = 0;
  [self.selectedTimeView setCenter:(CGPoint){ self.selectDurationView.center.x, self.selectDurationView.center.y + 10}];
  
  if (self.isTimerMode) {
    NSTimeInterval intervalSelected = [selectDuration getSecondsFromZero];
    
    [self.alarmInfo setObject:[NSNumber numberWithFloat:intervalSelected] forKey:@"timerDuration"];
    
    // Update selectedTime View
    [self.selectedTimeView updateDuration:intervalSelected part:selectDuration.handleSelected];
    
  } else {
    float duration;
    NSTimeInterval intervalSelected = [selectDuration getSecondsFromZero];
    float nowSeconds = [[self secondsSinceMidnightWithDate:[NSDate date]] floatValue];
    
    // Create a duration value out of dateSet and secondsFromZero on the duration picker
    if (intervalSelected > nowSeconds) {
      duration = intervalSelected-nowSeconds;
    }
    else if (self.isSet) {
      duration = 0;
    } else {
      duration = (86400-nowSeconds)+intervalSelected;
    }
    
    NSDate *currentDate = [NSDate date];
    
    // Round to nearest minute (exclude seconds)
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger calendarUnits = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *dateComps = [calendar components:calendarUnits fromDate:currentDate];
    [dateComps setSecond:0];
    currentDate = [calendar dateFromComponents:dateComps];
    
    // save when the duration was set and its duration
    if (!self.isSet) {
      [self.alarmInfo setObject:currentDate forKey:@"dateAlarmPicked"];
      [self.alarmInfo setObject:[NSNumber numberWithFloat:duration] forKey:@"alarmDuration"];
    }
    
    [self.selectedTimeView updateDate:[selectDuration getDate] part:selectDuration.handleSelected];
  }
  
  // Animate selectedTimeView back to durationView
  [UIView animateWithDuration:.1 animations:^{
    [self.selectedTimeView setCenter:self.selectDurationView.center];
    if (!self.isStopwatchMode)
    [self.selectedTimeView setAlpha:1];
    [self.selectSongView setAlpha:1];
    [self.selectActionView setAlpha:1];
    [self.radialGradientView setAlpha:1];
  } completion:^(BOOL finished) {
    if (!CGPointEqualToPoint(self.selectedTimeView.center, self.selectDurationView.center))
    [self durationDidEndChanging:selectDuration];
  }];
  
  if (!self.isTimerMode)
  if ([self.delegate respondsToSelector:@selector(alarmViewUpdated)])
  [self.delegate alarmViewUpdated];
}

- (void)durationViewTapped:(SelectDurationView *)selectDuration {
  // If selecting song/action, compress the song
  if (pickingSong)
  [self.selectSongView quickSelectCell];
  if (pickingAction)
  [self.selectActionView quickSelectCell];
  if (self.countdownEnded) {
    if (!self.isTimerMode) {
      self.countdownEnded = NO;
      self.isSnoozing = YES;
      NSTimeInterval snoozeTime = [[[NSUserDefaults standardUserDefaults] objectForKey:StartUserDefaultKey.snoozeTime] intValue] * 60.0f; // get the snooze duration from preferences
      NSDate *snoozeDate = [[NSDate alloc] initWithTimeIntervalSinceNow:snoozeTime];
      [self.alarmInfo setObject:snoozeDate forKey:@"snoozeAlarm"]; // set an alarm for a time in the future
      [selectDuration setSecondsFromZeroWithNumber:[self secondsSinceMidnightWithDate:snoozeDate]];
      [self.selectedTimeView updateDate:snoozeDate part:SelectDurationNoHandle];
      [[self.delegate getMusicPlayer] stop];
    }
  }
}

- (void)durationViewCoreTapped:(SelectDurationView *)selectDuration {
  if (!pickingAction && !pickingSong && !self.isSet && !self.isTimerMode && !self.isStopwatchMode) {
    // Go into timer mode
    [self enterTimerMode];
  } else if (self.isTimerMode && !self.isSet) {
    [self enterAlarmMode];
  }
}

- (BOOL)durationViewSwiped:(UISwipeGestureRecognizerDirection)direction {
  if (pickingSong && direction == UISwipeGestureRecognizerDirectionLeft)
  [self.selectSongView quickSelectCell];
  else if (pickingAction && direction == UISwipeGestureRecognizerDirectionRight)
  [self.selectActionView quickSelectCell];
  else
  return NO;
  return YES;
}

- (void)durationViewDraggedWithYVel:(float)yVel {
  if (pickingSong || pickingAction)
  return;
  
  CGRect newDurRect;
  CGRect proposedFrame = CGRectOffset(self.selectDurationView.frame, 0, yVel);
  
  // Make the picker stop in the middle if it was in timer mode OR if it was set.
  if ((proposedFrame.origin.y >= selectDurRect.origin.y && self.isSet) || (proposedFrame.origin.y <= selectDurRect.origin.y && self.isStopwatchMode))
  newDurRect = selectDurRect;
  
  // Can't go any lower than the stopwatch mode rect
  else if (proposedFrame.origin.y >= stopwatchModeDurRect.origin.y)
  newDurRect = stopwatchModeDurRect;
  
  // Can't go any higher than the alarmSet rect
  else if (proposedFrame.origin.y <= alarmSetDurRect.origin.y)
  newDurRect = alarmSetDurRect;
  
  // Can't go low if timer mode
  else if (self.isSet && proposedFrame.origin.y >= selectDurRect.origin.y)
  newDurRect = selectDurRect;
  else
  newDurRect = proposedFrame;
  
  // checking for a swipe
  if (fabsf(yVel) > 15) {
    if (yVel < 0) {
      if (self.isStopwatchMode){
        shouldSet = AlarmViewShouldUnSet;
      } else {
        shouldSet = AlarmViewShouldSet;
      }
    } else {
      if (self.isSet){
        shouldSet = AlarmViewShouldUnSet;
      } else if (!self.isTimerMode) {
        shouldSet = AlarmViewShouldStopwatch;
      }
    }
    
  } else if ((shouldSet == AlarmViewShouldSet && yVel > 0) || (shouldSet == AlarmViewShouldUnSet && yVel < 0) || (shouldSet == AlarmViewShouldStopwatch && yVel < 0))
  shouldSet = AlarmViewShouldNone;
  
  // Compress the durationSelector if duration selector is below original position
  if (newDurRect.origin.y > selectDurRect.origin.y) {
    float currDist = stopwatchModeDurRect.origin.y - newDurRect.origin.y;
    float fullDist = stopwatchModeDurRect.origin.y - selectDurRect.origin.y;
    [self.selectDurationView compressByRatio:currDist/fullDist animated:NO];
  }
  
  [self.selectDurationView setFrame:newDurRect];
  
  // Keep the inner text centered with time picker
  [self.selectedTimeView setCenter:self.selectDurationView.center];
  
  if (![[self subviews] containsObject:self.selectSongView])
  [self addSubview:self.selectSongView];
  if (![[self subviews] containsObject:self.selectActionView])
  [self addSubview:self.selectActionView];
  
  if ([self.delegate respondsToSelector:@selector(durationViewWithIndex:draggedWithPercent:)]) {
    float percentDragged = (self.selectDurationView.frame.origin.y - selectDurRect.origin.y) / 150;
    [self.delegate durationViewWithIndex:self.alarmIndex draggedWithPercent:-percentDragged];
    
    // Fade in stopwatch, fade out alarm functions
    [self.countdownView setAlpha:-percentDragged];
    [self.selectedTimeView setAlpha:1-percentDragged];
    [self.selectSongView setAlpha:1-percentDragged];
    [self.selectActionView setAlpha:1-percentDragged];
    [self.selectSongView.showCell.artistLabel setAlpha:1.3+percentDragged];
    
    [self.stopwatchViewController.view setAlpha:percentDragged];
  }
}

- (void)durationViewStoppedDraggingWithY:(float)y {
  // This is when the dial is finished moving up or down.
  // future TODO: put this is own method
  if (pickingSong || pickingAction) {
    return;
  }
  bool setAlarm = NO;
  bool startStopwatchMode = NO;
  
  if (shouldSet == AlarmViewShouldNone) {
    if (self.selectDurationView.frame.origin.y > (selectDurRect.origin.y + stopwatchModeDurRect.origin.y )/2) {
      shouldSet = AlarmViewShouldStopwatch;
    } else if (self.selectDurationView.frame.origin.y > (selectDurRect.origin.y + alarmSetDurRect.origin.y )/2) {
      shouldSet = AlarmViewShouldUnSet;
    } else {
      shouldSet = AlarmViewShouldSet;
    }
  }
  
  if (shouldSet == AlarmViewShouldSet) {
    setAlarm = YES;
    [self.selectSongView.showCell.artistLabel setAlpha:0.3];
    
  } else if (shouldSet == AlarmViewShouldUnSet) {
    setAlarm = NO;
    [self.selectSongView.cell.artistLabel setAlpha:1];
    // when the user turns off the alarm when the alarm is sounding
    if (self.countdownEnded || self.isSnoozing) { // stop and launch countdown aciton
      if (self.isSnoozing) {
        [self.alarmInfo removeObjectForKey:@"snoozeAlarm"];
        self.isSnoozing = NO;
      }
      self.countdownEnded = NO;
      NSURL *openURL = [NSURL URLWithString:[[self.selectActionView.actions objectAtIndex:[self.selectActionView actionIDWithTitle:self.alarmInfo[@"actionTitle"]]] objectForKey:@"url"]]; //gets URL of selected action from alarmInfo dictionary.
      [self.selectDurationView setSecondsFromZeroWithNumber:[NSNumber numberWithInt:[self getSecondsFromMidnight]]];
      [[self.delegate getMusicPlayer] stop];
      [[UIApplication sharedApplication] openURL:openURL]; //opens the url
      if (!self.isTimerMode)
      [self.selectedTimeView updateDate:[self.selectDurationView getDate] part:self.selectDurationView.handleSelected];
    }
  } else if (shouldSet == AlarmViewShouldStopwatch
             || self.selectDurationView.frame.origin.y > (selectDurRect.origin.y + stopwatchModeDurRect.origin.y )/2) {
    setAlarm = NO;
    startStopwatchMode = YES;
  }
  
  // Reset the stopwatch if it is new
  if (!self.isStopwatchMode && startStopwatchMode) {
    [self.alarmInfo setObject:[NSDate date] forKey:@"stopwatchDateBegan"];
  } else if (!startStopwatchMode && self.isStopwatchMode) {
    // Zero out the timer
    [self.alarmInfo setObject:[NSDate date] forKey:@"stopwatchDateBegan"];
    [self updateProperties];
  }
  
  if (self.isTimerMode) {
    if (!self.isSet && setAlarm) {
      [self.alarmInfo setObject:[NSDate date] forKey:@"dateSet"];
      [self.selectDurationView beginTiming];
    } else if (self.isSet && !setAlarm) {
      [self.selectDurationView stopTiming];
      [[self.delegate getMusicPlayer] stop];
      for ( UILocalNotification *notif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        [[UIApplication sharedApplication] cancelLocalNotification:notif];
      }
    }
    self.isSet = setAlarm;
  } else {
    if (!self.isSet && setAlarm) {
      [self.alarmInfo setObject:[NSDate date] forKey:@"dateSet"];
    } else if (self.isSet && !setAlarm) {
      [self.alarmInfo removeObjectForKey:@"dateSet"];
      [[self.delegate getMusicPlayer] stop];
      for ( UILocalNotification *notif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        [[UIApplication sharedApplication] cancelLocalNotification:notif];
      }
    }
    self.isSet = setAlarm;
  }
  
  self.isStopwatchMode = startStopwatchMode;
  
  [self.selectDurationView compressByRatio:self.isStopwatchMode?0:1 animated:YES];
  
  // Save the set bool
  [self.alarmInfo setObject:[NSNumber numberWithBool:self.isSet] forKey:@"isSet"];
  [self.alarmInfo setObject:[NSNumber numberWithBool:self.isStopwatchMode] forKey:@"isStopwatchMode"];
  
  shouldSet = AlarmViewShouldNone;
  
  [self animateSelectDurToRest];
  if ([self.delegate respondsToSelector:@selector(alarmViewUpdated)]) {
    [self.delegate alarmViewUpdated];
  }
}

- (bool)shouldLockPicker {
  return (self.isSet || self.isStopwatchMode || ![self canMove]);
}

- (NSDate *)getDateBegan {
  // For the timer
  return [self.alarmInfo objectForKey:@"dateSet"];
}

#pragma mark - Animation

- (void)animateSelectDurToRest {
  
  CGRect newFrame = [self currRestedSelecDurRect];
  
  if ([self.delegate respondsToSelector:@selector(durationViewWithIndex:draggedWithPercent:)]) {
    [self.delegate durationViewWithIndex:self.alarmIndex draggedWithPercent:((self.isSet)?1:self.isStopwatchMode?-1:0)];
  }
  float alpha1;
  
  alpha1 = (self.isSet?1:0);
  
  float alpha2 = (self.isStopwatchMode)?0:1;
  
  if (alpha2 == 1 && !self.isTimerMode) {
    if (![[self subviews] containsObject:self.selectSongView])
    [self addSubview:self.selectSongView];
    if (![[self subviews] containsObject:self.selectActionView])
    [self addSubview:self.selectActionView];
  }
  
  [UIView animateWithDuration:.2 animations:^{
    [self.selectDurationView setFrame:newFrame];
    self.selectedTimeView.center = self.selectDurationView.center;
    
    // Animate fade of countdowntimer & such
    self.countdownView.alpha = alpha1;
    self.stopwatchViewController.view.alpha = 1-alpha2;
    self.selectSongView.alpha = alpha2;
    self.selectActionView.alpha = alpha2;
    self.selectedTimeView.alpha = alpha2;
  } completion:^(BOOL finished) {
    if (alpha2 == 0) {
      [self.selectActionView removeFromSuperview];
      [self.selectSongView removeFromSuperview];
    }
  }];
}

#pragma mark - Utilities

CGRect CGRectExtendFromPoint(CGPoint p1, float dx, float dy) {
  return CGRectMake(p1.x-dx, p1.y-dy, dx*2, dy*2);
}

CGPoint CGRectCenter(CGRect rect) {
  return CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
}

- (int)getSecondsFromMidnight {
  return [[self secondsSinceMidnightWithDate:[self getDate]] intValue];
}

- (NSDate *)dateTodayWithSecondsFromMidnight:(NSNumber *)seconds {
  int duration = [seconds intValue];
  
  int days = duration / (60 * 60 * 24);
  duration -= days * (60 * 60 * 24);
  int hour = duration / (60 * 60);
  duration -= hour * (60 * 60);
  int minute = duration / 60;
  
  NSCalendar *cal = [NSCalendar currentCalendar];
  [cal setTimeZone:[NSTimeZone systemTimeZone]];
  
  NSDateComponents *components = [cal components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
  [components setTimeZone:[cal timeZone]];
  
  [components setHour:hour];
  [components setMinute:minute];
  [components setSecond:1];
  components.day += days;
  
  return [cal dateFromComponents:components];
}

- (NSNumber *)secondsSinceMidnightWithDate:(NSDate *)date {
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *dateComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:(NSDate *)date];
  
  NSNumber *secondsSinceMidnight = @(dateComponents.minute*60 + dateComponents.hour*3600);
  return secondsSinceMidnight;
}

@end

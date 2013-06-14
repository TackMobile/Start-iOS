//
//  AlarmView.m
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 TackMobile. All rights reserved.
//

#import "AlarmView.h"

@implementation AlarmView

@synthesize delegate, index, isSet, isStopwatchMode, countdownEnded, isTimerMode, newRect, isSnoozing;
@synthesize alarmInfo;
@synthesize radialGradientView, /*backgroundImage,*/ patternOverlay, toolbarImage;
@synthesize selectSongView, selectActionView, selectDurationView, selectedTimeView, deleteLabel;
@synthesize countdownView, selectAlarmBg, stopwatchViewController;

const float Spacing = 0.0f;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        shouldSet = AlarmViewShouldNone;
        [self setClipsToBounds:YES];
        pickingSong = NO;
        pickingAction = NO;
        cancelTouch = NO;
        countdownEnded = NO;
        isSnoozing = NO;
        hasLoaded = NO;
        
        musicManager = [[MusicManager alloc] init];
        PListModel *pListModel = [delegate getPListModel];
        
        // Views
        CGSize bgImageSize = CGSizeMake(520, 480);
        CGRect frameRect = [[UIScreen mainScreen] applicationFrame];
         
        
        // bgImageRect = 
        radialRect = CGRectMake((self.frame.size.width-bgImageSize.width)/2, 0, bgImageSize.width, frameRect.size.height);
        //radialRect = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.origin.y, [UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height);
        
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
        
        // backgroundImage = [[UIImageView alloc] initWithFrame:bgImageRect];
        radialGradientView = [[RadialGradientView alloc] initWithFrame:radialRect]; //radial background
        
        
        
        //patternOverlay = [[UIImageView alloc] initWithFrame:radialGradientRect];
        toolbarImage = [[UIImageView alloc] initWithFrame:toolBarRect];
        selectSongView = [[SelectSongView alloc] initWithFrame:selectSongRect delegate:self presetSongs:[pListModel getPresetSongs]];
        selectActionView = [[SelectActionView alloc] initWithFrame:selectActionRect delegate:self actions:[pListModel getActions]];
        selectDurationView = [[SelectDurationView alloc] initWithFrame:selectDurRect delegate:self]; //dial
        selectedTimeView = [[SelectedTimeView alloc] initWithFrame:selectedTimeRect]; //clock in middle of dial
        countdownView = [[CountdownView alloc] initWithFrame:countdownRect];
        durationMaskView = [[UIView alloc] initWithFrame:durationMaskRect];
        stopwatchViewController = [[StopwatchViewController alloc] init];
        [stopwatchViewController.view setFrame:stopwatchRect];
        deleteLabel = [[UILabel alloc] initWithFrame:deleteLabelRect];
        selectAlarmBg = [[UIImageView alloc] initWithFrame:selectAlarmRect];
        
        [selectAlarmBg setImage:[UIImage imageNamed:@"bottom-fade"]];
        
        //[self addSubview:backgroundImage];
        [self addSubview:radialGradientView];
        //[self addSubview:patternOverlay];
        //[self addSubview:selectAlarmBg];
        [self addSubview:countdownView];
        [self addSubview:stopwatchViewController.view];
        [self addSubview:durationMaskView];
        [durationMaskView addSubview:selectDurationView];
        //[self addSubview:toolbarImage];
        [self addSubview:selectSongView];
        [self addSubview:selectActionView];
        [self addSubview:selectedTimeView];
        [self addSubview:deleteLabel];
        
        [deleteLabel setFont:[UIFont fontWithName:@"Roboto" size:30]];
        [deleteLabel setBackgroundColor:[UIColor clearColor]]; [deleteLabel setTextColor:[UIColor whiteColor]];
        [deleteLabel setAlpha:0];
        [deleteLabel setTextAlignment:NSTextAlignmentCenter];
        [deleteLabel setNumberOfLines:0];
        [deleteLabel setText:@"Pinch to Delete"];
                
        [patternOverlay setImage:[UIImage imageNamed:@"grid"]];
                
        // pinch to delete
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(alarmPinched:)];
        [self addGestureRecognizer:pinch];
        
        // initial properties
        [selectedTimeView updateDate:[selectDurationView getDate] part:SelectDurationNoHandle];
        [toolbarImage setImage:[UIImage imageNamed:@"toolbarBG"]];
        //[backgroundImage setImage:[UIImage imageNamed:@"epsilon"]];
        [self setBackgroundColor:[UIColor blackColor]];
        [countdownView setAlpha:0];
        [stopwatchViewController.view setAlpha:0];
        [patternOverlay setAlpha:0];
        [toolbarImage setAlpha:0];
        [selectAlarmBg setAlpha:0];
        CGRect selectActionTableViewRect = CGRectMake(0, 0, frameRect.size.width-75, self.frame.size.height);
        [selectActionView.actionTableView setFrame:selectActionTableViewRect];
        
        // add gradient mask to countdownMaskView
        toolbarGradient = [CAGradientLayer layer];
        NSArray *gradientColors = [NSArray arrayWithObjects:
                                   (id)[[UIColor clearColor] CGColor],
                                   (id)[[UIColor whiteColor] CGColor],
                                   /*(id)[[UIColor whiteColor] CGColor],
                                   (id)[[UIColor clearColor] CGColor],*/ nil];
        
        float topFadeHeight = (toolBarRect.size.height-10)/self.frame.size.height;
        //float bottomFadeHeight = 1 - (selectAlarmRect.size.height/self.frame.size.height);
        
        NSArray *gradientLocations = [NSArray arrayWithObjects:
                                      [NSNumber numberWithFloat:0.05f],
                                      [NSNumber numberWithFloat:topFadeHeight],
                                      /*[NSNumber numberWithFloat:bottomFadeHeight],
                                      [NSNumber numberWithFloat:1.0f-.05f],*/ nil];
        
        [toolbarGradient setColors:gradientColors];
        [toolbarGradient setLocations:gradientLocations];
        [toolbarGradient setFrame:durationMaskRect];
        [durationMaskView.layer setMask:toolbarGradient];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame index:(int)aIndex delegate:(id<AlarmViewDelegate>)aDelegate alarmInfo:(NSDictionary *)theAlarmInfo {
    index = aIndex;
    delegate = aDelegate;

    self = [self initWithFrame:frame];
    
    if (theAlarmInfo)
        alarmInfo = [[NSMutableDictionary alloc] initWithDictionary:theAlarmInfo];
    else
        alarmInfo = nil;
    
    return self;
}

- (void) alert:(NSString *)message {
    UILabel *alertLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.frame, 0, self.frame.size.height * 1/2)];
    alertLabel.text = message;
    [self addSubview:alertLabel];
    
    [UIView animateWithDuration:.5 delay:2 options:nil animations:^{
        alertLabel.alpha = 0;
    } completion:^(BOOL finished) {
        [alertLabel removeFromSuperview];
    }];
    
}

- (void) viewWillAppear {
    // init the picker's stuff
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
    
    if (!alarmInfo) {
        alarmInfo = [NSMutableDictionary dictionaryWithDictionary:alarmInfoTemplate];
        
        /*
        [selectDurationView setSecondsFromZeroWithNumber:[alarmInfo objectForKey:@"secondsSinceMidnight"]];
        [selectSongView selectCellWithID:[NSNumber numberWithInt:-1]];
         */
        
    } else {
        
        NSLog(@"alarmInfo start: %@", alarmInfo);
        
        // extend AlarmTemplate with values already in alarmInfo
        NSMutableDictionary *extendedInfoTemplate = [NSMutableDictionary dictionaryWithDictionary:alarmInfoTemplate];
    
        // isTimerMode, isStopeatchMode, isSet
        [self extendKey:@"isTimerMode" fromDict:alarmInfo toDict:extendedInfoTemplate];
        [self extendKey:@"isStopwatchMode" fromDict:alarmInfo toDict:extendedInfoTemplate];
        [self extendKey:@"isSet" fromDict:alarmInfo toDict:extendedInfoTemplate];
        
        // dateSet
        [self extendKey:@"dateSet" fromDict:alarmInfo toDict:extendedInfoTemplate];
        
        // dateAlarmPicked
        if (![self extendKey:@"dateAlarmPicked" fromDict:alarmInfo toDict:extendedInfoTemplate]) {
            [extendedInfoTemplate setObject:[alarmInfo objectForKey:@"dateSet"] forKey:@"dateAlarmPicked"];
        }
        
        // stopwatchDateBegan
        [self extendKey:@"stopwatchDateBegan" fromDict:alarmInfo toDict:extendedInfoTemplate];
        
        // alarmDuration
        if (![self extendKey:@"alarmDuration" fromDict:alarmInfo toDict:extendedInfoTemplate]) { 
            // if we can't extend it, check for depreciated keys
            
            float secondsSinceMidnight = -1; // get the old amount of secondsSinceMidnight
            
            if ([alarmInfo objectForKey:@"secondsSinceMidnight"]) // secondsSinceMidnight is depreciated
                secondsSinceMidnight = [[alarmInfo objectForKey:@"secondsSinceMidnight"] floatValue];
            else if ([alarmInfo objectForKey:@"date"])
                secondsSinceMidnight = [[self secondsSinceMidnightWithDate:(NSDate *)[alarmInfo objectForKey:@"date"]] floatValue];
            
            // convert secondsSinceMidnight to a duration from the dateSet
            float setSecondsSinceMidnight = [[self secondsSinceMidnightWithDate:[alarmInfo objectForKey:@"dateSet"]] floatValue];
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
        [self extendKey:@"timerDuration" fromDict:alarmInfo toDict:extendedInfoTemplate];
        [self extendKey:@"songID" fromDict:alarmInfo toDict:extendedInfoTemplate];
        [self extendKey:@"themeID" fromDict:alarmInfo toDict:extendedInfoTemplate];
        
        // actionTitle
        if (![self extendKey:@"actionTitle" fromDict:alarmInfo toDict:extendedInfoTemplate]) {
            // check for depreciated actionID
            if ([alarmInfo objectForKey:@"actionID"]) {
                int actionID = [[alarmInfo objectForKey:@"actionID"] intValue];
                [extendedInfoTemplate setObject:[selectActionView actionTitleWithID:actionID] forKey:@"actionTitle"];
            }
        }
        
        // snooze (not in template because it is deleted upon being unset
        if ([self extendKey:@"snoozeAlarm" fromDict:alarmInfo toDict:extendedInfoTemplate])
            isSnoozing = YES;
        
        alarmInfo = extendedInfoTemplate;
        

        // TALK ABOUT MYSELF
        NSLog(@"alarmInfo end: %@", alarmInfo);

    }
    
    if ([alarmInfo objectForKey:@"snoozeAlarm"])
        isSnoozing = YES;
    
    // update local variables and views
    if ([[alarmInfo objectForKey:@"isSet"] boolValue])
        isSet = YES;
    
    
    if ([[alarmInfo objectForKey:@"isTimerMode"] boolValue]) {
        [self enterTimerMode]; // sets isTimerMode
        if (isSet)
            [selectDurationView beginTiming];
    } else {
        [self enterAlarmMode];
    }
    //[selectDurationView setSecondsFromZero:[self getSecondsFromMidnight]];
    
    
    [selectSongView selectCellWithID:[alarmInfo objectForKey:@"songID"]];
    [selectActionView selectActionWithTitle:[alarmInfo objectForKey:@"actionTitle"]];
    [self updateThemeWithArtwork:nil];
    
    if ([[alarmInfo objectForKey:@"isStopwatchMode"] boolValue]) {
        isStopwatchMode = YES;
        [selectDurationView compressByRatio:0 animated:YES];
        [selectedTimeView setAlpha:0];
    }
    
    [self durationDidEndChanging:selectDurationView];
    [self animateSelectDurToRest];

    hasLoaded = YES;

}

#pragma mark - utility functions

- (bool) extendKey:(NSString *)key fromDict:(NSDictionary *)fromDict toDict:(NSMutableDictionary *)toDict {
    if ([fromDict objectForKey:key]) {
        [toDict setObject:[fromDict objectForKey:key] forKey:key];
        return YES;
    }
    return NO;
}

- (bool) canMove {
    return !(pickingSong || pickingAction);
}

- (void) alarmCountdownEnded {
    NSLog(@"countdownended\n%@", alarmInfo);
    
    if (!countdownEnded && isSet) {
        countdownEnded = YES;
        [delegate alarmCountdownEnded:self];
        if (!isTimerMode)
            [selectedTimeView showSnooze];
        //NSLog(@"showSnooze");
    }
}

- (void) alarmCountdownEndedIsActive:(bool)isActive {
    NSLog(@"countdownended\n%@", alarmInfo);
    
    if (!countdownEnded && isSet) {
        countdownEnded = YES;
        [delegate alarmCountdownEnded:self];
        if (!isTimerMode)
            [selectedTimeView showSnooze];
        //NSLog(@"showSnooze");
    }
}

- (NSDate *) getDate {
    
    NSDate *theDate;
    if (isTimerMode)
        if (isSet)
            // add timer duration to date set and get seconds since midnight
            theDate = [[alarmInfo objectForKey:@"dateSet"]
                        dateByAddingTimeInterval:[[alarmInfo objectForKey:@"timerDuration"] floatValue]];
        else
            theDate = [[NSDate date] dateByAddingTimeInterval:
                       [[alarmInfo objectForKey:@"timerDuration"] floatValue]];
    else {
        if (isSnoozing) {
            theDate = [alarmInfo objectForKey:@"snoozeAlarm"];
            
        } else {
            theDate = [[alarmInfo objectForKey:@"dateAlarmPicked"]
                           dateByAddingTimeInterval:[[alarmInfo objectForKey:@"alarmDuration"] floatValue]];
        }

    }
    
    return theDate;
    
}

#pragma mark - saved user variables



#pragma mark - functionality
- (void) enterTimerMode {
    isTimerMode = YES;
    [alarmInfo setObject:[NSNumber numberWithBool:YES] forKey:@"isTimerMode"];
    
    int seconds = [[alarmInfo objectForKey:@"timerDuration"] intValue];
    [selectDurationView enterTimerModeWithSeconds:seconds];
    [selectedTimeView enterTimerMode];
    
    // update selectedTime View
    [selectedTimeView updateDuration:seconds part:selectDurationView.handleSelected];
    
    //[durationMaskView.layer setMask:nil];
}

- (void) enterAlarmMode {
    isTimerMode = NO;
    [alarmInfo setObject:[NSNumber numberWithBool:NO] forKey:@"isTimerMode"];
    
    int seconds = [self getSecondsFromMidnight];
    [selectDurationView exitTimerModeWithSeconds:seconds];
    [selectedTimeView enterAlarmMode];
    
    [selectedTimeView updateDate:[self getDate] part:selectDurationView.handleSelected];
    
}

- (void) setCountdownEnded:(bool)newVal {
    [alarmInfo setObject:[NSNumber numberWithBool:newVal] forKey:@"countdownEnded"];
    _countdownEnded = newVal;
    
}

- (bool) countdownEnded {
    return _countdownEnded;
}

#pragma mark - Touches
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {    
    UITouch *touch = [touches anyObject];
    
    CGPoint touchLoc = [touch locationInView:self];
    CGPoint prevTouchLoc = [touch previousLocationInView:self];
    
    CGSize touchVel = CGSizeMake(touchLoc.x-prevTouchLoc.x, touchLoc.y-prevTouchLoc.y);
    
    // check if dragging between alarms
    if (pickingSong || pickingAction) {
        if (fabsf(touchVel.width) > 15) {
            if (touchVel.width < 0 && pickingSong) {
                [selectSongView quickSelectCell];
            } else {
                [selectActionView quickSelectCell];
            }
            cancelTouch = YES;
            if ([selectDurationView draggingOrientation] == SelectDurationDraggingHoriz)
                [selectDurationView setDraggingOrientation:SelectDurationDraggingCancel];
        }
    }
    if (fabsf(touchVel.width) > fabsf(touchVel.height) && !cancelTouch)
        if ([delegate respondsToSelector:@selector(alarmView:draggedWithXVel:)])
            [delegate alarmView:self draggedWithXVel:touchVel.width];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    cancelTouch = NO;
    if ([delegate respondsToSelector:@selector(alarmView:stoppedDraggingWithX:)])
        [delegate alarmView:self stoppedDraggingWithX:self.frame.origin.x];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

-(void)alarmPinched:(UIPinchGestureRecognizer *)pinchRecog {
    if (![self canMove])
        return;
    
    [selectDurationView touchesCancelled:nil withEvent:nil];
    if (pinchRecog.state == UIGestureRecognizerStateBegan) {

        [selectSongView setAlpha:0];
        [selectActionView setAlpha:0];
        [deleteLabel setAlpha:1];

    } else if (pinchRecog.state == UIGestureRecognizerStateChanged) {
        [selectDurationView setAlpha:0];
        if (pinchRecog.scale > 1)
            pinchRecog.scale = 1;
        float scale = .8 + .2 * (1-(3 * (1-pinchRecog.scale)));
        
        
        if (isSet)
            countdownView.alpha = scale;
        
        selectDurationView.alpha = scale;
        selectedTimeView.alpha = scale;
        
        if (!isStopwatchMode)
            [selectDurationView compressByRatio:scale animated:NO];
        
        
    } else if (pinchRecog.state == UIGestureRecognizerStateEnded) {
        if (pinchRecog.scale < .7) {
            if ([delegate respondsToSelector:@selector(alarmViewPinched:)] )
                if ([delegate alarmViewPinched:self]) {
                    if (!isStopwatchMode)
                        [selectDurationView compressByRatio:0 animated:YES];
                    return;
                }
        }
        if (!isStopwatchMode) {
            [self addSubview:selectSongView];
            [self addSubview:selectActionView];
        }
        [deleteLabel setAlpha:0];
        [selectSongView setAlpha:1];
        [selectActionView setAlpha:1];

        if (!isStopwatchMode)
            [selectDurationView compressByRatio:1 animated:YES];
        
        [UIView animateWithDuration:.2 animations:^{
            [selectDurationView setAlpha:1];
            if (!isStopwatchMode)
                [selectedTimeView setAlpha:1];
            if (isSet)
                countdownView.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark - Posiitoning/Drawing

// parallax
- (void) shiftedFromActiveByPercent:(float)percent {
    if (pickingSong || pickingAction)
        return;
    
    float screenWidth = self.frame.size.width;
    
    float durPickOffset =       200 * percent;
    float countDownOffset =     120 * percent;
    float songPickOffset =      100 * percent;
    float actionPickOffset =    75 * percent;
    float backgroundOffset =    (radialGradientView.frame.size.width - screenWidth)/2 * percent;
    
    CGRect shiftedDurRect = CGRectOffset([self currRestedSelecDurRect], durPickOffset, 0);
    CGRect shiftedCountdownRect = CGRectOffset(countdownRect, countDownOffset, 0);
    CGRect shiftedStopwatchRect = CGRectOffset(stopwatchRect, countDownOffset, 0);
    CGRect shiftedSongRect = CGRectOffset(selectSongRect, songPickOffset, 0);
    CGRect shiftedActionRect = CGRectOffset(selectActionRect, actionPickOffset, 0);
    CGRect shiftedRadialRect = CGRectOffset(radialRect, backgroundOffset, 0);
    
    [selectDurationView setFrame:shiftedDurRect];
    [selectedTimeView setCenter:selectDurationView.center];
    [countdownView setFrame:shiftedCountdownRect];
    [stopwatchViewController.view setFrame:shiftedStopwatchRect];
    [selectSongView setFrame:shiftedSongRect];
    [selectActionView setFrame:shiftedActionRect];
    [radialGradientView setFrame:shiftedRadialRect];
}
- (void) menuOpenWithPercent:(float)percent {
    [radialGradientView setAlpha:1.0f-(.8/(1.0f/percent))];
    if ([delegate respondsToSelector:@selector(alarmViewOpeningMenuWithPercent:)])
        [delegate alarmViewOpeningMenuWithPercent:percent];
}

- (void) menuCloseWithPercent:(float)percent {
    if (percent==1)
        [radialGradientView setAlpha:1];
    else 
        [radialGradientView setAlpha:(.8/(1.0f/percent))];
    
    if ([delegate respondsToSelector:@selector(alarmViewClosingMenuWithPercent:)])
        [delegate alarmViewClosingMenuWithPercent:percent];
}

- (void) updateThemeWithArtwork:(UIImage *)artwork {
    int themeID = [(NSNumber *)[alarmInfo objectForKey:@"themeID"] intValue];
    
    if (themeID == -1) // convert default theme to 0
        themeID = 0; // future: rendomize theme
    
    NSDictionary *theme;
    if (themeID < 7 && themeID > -1) { // preset theme
        theme = [musicManager getThemeWithID:themeID];
        artwork = [theme objectForKey:@"bgImg"];
        [radialGradientView setInnerColor:[theme objectForKey:@"bgInnerColor"] outerColor:[theme objectForKey:@"bgOuterColor"]];
        [toolbarImage setAlpha:0];
        [selectAlarmBg setAlpha:0];
        [patternOverlay setAlpha:0];
        [selectDurationView updateTheme:theme];
    } else {
        [toolbarImage setAlpha:1];
        [selectAlarmBg setAlpha:1];
        theme = [musicManager getThemeForSongID:[alarmInfo objectForKey:@"songID"]];
        [selectDurationView updateTheme:theme];
        [radialGradientView setInnerColor:[theme objectForKey:@"bgInnerColor"] outerColor:[theme objectForKey:@"bgOuterColor"]];
        [toolbarImage setAlpha:0];
    }
    /*if (artwork) {
        // fade in the background 
        UIImageView *oldBg = [[UIImageView alloc] initWithImage:backgroundImage.image];
        [oldBg setFrame:backgroundImage.frame];
        [oldBg setAlpha:1];
        [backgroundImage setImage:artwork];
        [self insertSubview:oldBg aboveSubview:backgroundImage];
        [UIView animateWithDuration:.35 animations:^{
            [oldBg setAlpha:0];
        } completion:^(BOOL finished) {
            [oldBg removeFromSuperview];
        }];
    }*/
   // else // no theme
        //theme = [musicManager getThemeForSongID:[alarmInfo objectForKey:@"songID"]];
}

- (void) updateProperties {
    if (!countdownEnded && hasLoaded) {
        // ensure that alarm date is in the future
        
        if (!isTimerMode && !isSet) { // unset alarm mode
            
            
            // make sure alarm is in future
            while ([[self getDate] timeIntervalSinceNow] < 0) {
                NSDate *newDate = [(NSDate *)[alarmInfo objectForKey:@"dateAlarmPicked"] dateByAddingTimeInterval:86400] ;
                [alarmInfo setObject:newDate forKey:@"dateAlarmPicked"];
            }
            
            // make sure alarm is not too far in future (time-travel bugfix)
            while ([[self getDate] timeIntervalSinceNow] > 86400) {
                NSDate *newDate = [(NSDate *)[alarmInfo objectForKey:@"dateAlarmPicked"] dateByAddingTimeInterval:-86400] ;
                [alarmInfo setObject:newDate forKey:@"dateAlarmPicked"];
            }
        
        }
        // check to see if it will go off
        
        if (floorf([[self getDate] timeIntervalSinceNow]) < .5) {
            [self alarmCountdownEnded];
            
        }
        
        [countdownView updateWithDate:[self getDate]];
        
        //if (selectDurationView.handleSelected == SelectDurationNoHandle) {
        //    if (!isTimerMode)
        //        [selectDurationView setSecondsFromZeroWithNumber:[self secondsSinceMidnightWithDate:[self getDate]]];
        //}

    } else {
        // update with current date so it will flash 00:00
        [countdownView updateWithDate:[NSDate date]];
    }
    
    if (isStopwatchMode)
        [stopwatchViewController updateWithDate:[alarmInfo objectForKey:@"stopwatchDateBegan"]];
}

- (CGRect) currRestedSelecDurRect {
    if (isSet)
        return alarmSetDurRect;
    else if (isStopwatchMode)
        return stopwatchModeDurRect;
    else
        return selectDurRect;
}

- (void) displayToastWithText:(NSString *)text {
    // flash timer message
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
-(id) getDelegateMusicPlayer {
    return [delegate getMusicPlayer];
}
-(BOOL) expandSelectSongView {
    if (pickingAction || countdownEnded) //does not allow user to press and expand select sound view when the alarm is going off to prevent accidental touch when the user is trying to press snooze
    {
        return NO;}
    
    pickingSong = YES;
        
    CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;
    
    CGRect newSelectSongRect = CGRectMake(Spacing, selectSongRect.origin.y, screenSize.width, self.frame.size.height);
    CGRect selectDurPushedRect = CGRectOffset(selectDurationView.frame, selectSongView.frame.size.width, 0);
    CGRect selectActionPushedRect = CGRectOffset(selectActionView.frame, 90, 0);
    CGRect countdownPushedRect = CGRectOffset(countdownView.frame, selectSongView.frame.size.width, 0);
    CGRect timerPushedRect = CGRectOffset(stopwatchRect, selectSongView.frame.size.width, 0);

    
    [UIView animateWithDuration:.2 animations:^{
        [self menuOpenWithPercent:1];
        
        [selectSongView setFrame:newSelectSongRect];
        
        [selectDurationView setFrame:selectDurPushedRect];
        [selectDurationView setAlpha:.6];
        
        [selectedTimeView setCenter:selectDurationView.center];
        [selectedTimeView setAlpha:.6];
        
        [selectActionView setFrame:selectActionPushedRect];
        [selectActionView setAlpha:.6];
        
        [countdownView setFrame:countdownPushedRect];
        [countdownView setAlpha:isSet?.6:0];
        
        [stopwatchViewController.view setFrame:timerPushedRect];
        [stopwatchViewController.view setAlpha:isStopwatchMode?.6:0];
    }];
        
    return YES;
}
-(void) compressSelectSong {
    pickingSong = NO;

    // compress the songSelectView
    [UIView animateWithDuration:.2 animations:^{
        [self menuCloseWithPercent:1];
        [selectSongView setFrame:selectSongRect];
        
        
        
        [selectDurationView setFrame:[self currRestedSelecDurRect]];
        [selectDurationView setAlpha:1];
        
        [selectedTimeView setCenter:selectDurationView.center];
        if (!isStopwatchMode)
            [selectedTimeView setAlpha:1];
        
        [selectActionView setFrame:selectActionRect];
        [selectActionView setAlpha:1];
        
        [countdownView setFrame:countdownRect];
        [countdownView setAlpha:isSet?1:0];
        
        [stopwatchViewController.view setFrame:stopwatchRect];
        [stopwatchViewController.view setAlpha:isStopwatchMode?1:0];
    }];
}
     
-(void) songSelected:(NSNumber *)persistentMediaItemID withArtwork:(UIImage *)artwork theme:(NSNumber *)themeID {    
    // save the song ID
    [alarmInfo setObject:persistentMediaItemID forKey:@"songID"];
    [alarmInfo setObject:themeID forKey:@"themeID"];
    
    /* display modal if they havent picked music b4
    if ([persistentMediaItemID intValue] > 0 || [persistentMediaItemID intValue] < -1) {
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"hasPickedSongBefore"] boolValue]) {
            
            UIButton *warningMsg = [UIButton buttonWithType:UIButtonTypeCustom] ;
            [warningMsg setImage:[UIImage imageNamed:@"intro-lock.png"] forState:UIControlStateNormal];
            [warningMsg addTarget:self action:@selector(musicWarningTapped:) forControlEvents:UIControlEventTouchUpInside];
            [warningMsg sizeToFit];
            
            CGRect warningRect = (CGRect){{(self.frame.size.width-warningMsg.frame.size.width)/2,
                (self.frame.size.height-warningMsg.frame.size.height)/2}, warningMsg.frame.size};
            [warningMsg setFrame:warningRect];
            
            // testing
            [warningMsg setBackgroundColor:[UIColor colorWithWhite:0 alpha:.5]];
            
            // animate it in
            
            [self addSubview:warningMsg];

        }
    }*/

    
    [self updateThemeWithArtwork:artwork];
}

- (void) musicWarningTapped:(id)button {
    [(UIView *)button removeFromSuperview];
}

#pragma mark - SelectActionViewDelegate
-(BOOL) expandSelectActionView {
    if (pickingAction /*|| isSnoozing*/ || countdownEnded) //does not allow you to press and expand select action view while the alarm is going off to prevent accidental touches if the user is trying to press snooze
        return NO;
    
    pickingAction = YES;
    
    CGRect newSelectActionRect = CGRectMake(75+Spacing, 0, [[UIScreen mainScreen] applicationFrame].size.width-75, self.frame.size.height);
    CGRect selectDurPushedRect = CGRectOffset(selectDurationView.frame, -newSelectActionRect.size.width, 0);
    CGRect selectSongPushedRect = CGRectOffset(selectSongView.frame, -selectSongView.frame.size.width + Spacing, 0);
    CGRect countdownPushedRect = CGRectOffset(countdownView.frame, -newSelectActionRect.size.width, 0);
    CGRect stopwatchPushedRect = CGRectOffset(stopwatchRect, -newSelectActionRect.size.width, 0);

    
    [UIView animateWithDuration:.2 animations:^{
        [self menuOpenWithPercent:1];
        [selectActionView setFrame:newSelectActionRect];
        
        [selectDurationView setFrame:selectDurPushedRect];
        [selectDurationView setAlpha:.9];
        
        [selectedTimeView setCenter:selectDurationView.center];
        [selectedTimeView setAlpha:.9];
        
        [selectSongView setFrame:selectSongPushedRect];

        [selectSongView setAlpha:.9];
        
        [countdownView setFrame:countdownPushedRect];
        [countdownView setAlpha:isSet?.6:0];
        
        [stopwatchViewController.view setFrame:stopwatchPushedRect];
        [stopwatchViewController.view setAlpha:isStopwatchMode?.6:0];
    }];
    
    
    
    return YES;
}

-(void) actionSelected:(NSString *)actionTitle {
    pickingAction = NO;
    
    // save the song ID
    [alarmInfo setObject:actionTitle forKey:@"actionTitle"];
    
    // compress the selectActionView
    [UIView animateWithDuration:.2 animations:^{
        [self menuCloseWithPercent:1];
        [selectActionView setFrame:selectActionRect];
        
        [selectDurationView setFrame:[self currRestedSelecDurRect]];
        [selectDurationView setAlpha:1];
        
        [selectedTimeView setCenter:selectDurationView.center];
        if (!isStopwatchMode)
            [selectedTimeView setAlpha:1];
        
        [selectSongView setFrame:selectSongRect];
        [selectSongView setAlpha:1];
        
        [countdownView setFrame:countdownRect];
        [countdownView setAlpha:isSet?1:0];
        
        [stopwatchViewController.view setFrame:stopwatchRect];
        [stopwatchViewController.view setAlpha:isStopwatchMode?1:0];
    }];
}

#pragma mark - SelectDurationViewDelegate
-(void) durationDidChange:(SelectDurationView *)selectDuration {    
    // update selected time label
    if (!isTimerMode)
        [selectedTimeView updateDate:[selectDuration getDate] part:selectDuration.handleSelected];
    else
        [selectedTimeView updateDuration:[selectDuration getSecondsFromZero]
                                    part:selectDuration.handleSelected];
}

-(void) durationDidBeginChanging:(SelectDurationView *)selectDuration {
    CGRect belowSelectedTimeRect;
    CGRect newSelectedTimeRect;

    
    newSelectedTimeRect = (CGRect){ {selectedTimeView.frame.origin.x,
        (selectDurRect.origin.y - selectedTimeView.frame.size.height)/2 +5}, selectedTimeView.frame.size};
    belowSelectedTimeRect = CGRectOffset(newSelectedTimeRect, 0, 15);
    
    if (isTimerMode)
        newSelectedTimeRect = CGRectOffset(newSelectedTimeRect, 0, 10);
    

    
    // animate selectedTimeView to toolbar
    [UIView animateWithDuration:.1 animations:^{
        [selectedTimeView setAlpha:0];
    } completion:^(BOOL finished) {
        [selectedTimeView setFrame:belowSelectedTimeRect];
        [UIView animateWithDuration:.07 animations:^{
            [selectedTimeView setFrame:newSelectedTimeRect];
            if (!isStopwatchMode)
                [selectedTimeView setAlpha:1];
            if ([selectDuration handleSelected] != SelectDurationNoHandle) {
                [selectSongView setAlpha:.2];
                [selectActionView setAlpha:.2];
                [radialGradientView setAlpha:.6];
            }
        }];
    }];
    
    if (isTimerMode)
        [selectedTimeView updateDuration:[selectDuration getSecondsFromZero]
                                    part:selectDuration.handleSelected];
    else
        [selectedTimeView updateDate:[selectDuration getDate] part:selectDuration.handleSelected];
}

-(void) durationDidEndChanging:(SelectDurationView *)selectDuration {
    [selectedTimeView setAlpha:0];
    [selectedTimeView setCenter:(CGPoint){ selectDurationView.center.x, selectDurationView.center.y + 10}];

    
    if (isTimerMode) {
        NSTimeInterval intervalSelected = [selectDuration getSecondsFromZero];

        [alarmInfo setObject:[NSNumber numberWithFloat:intervalSelected] forKey:@"timerDuration"];
        
        // update selectedTime View
        [selectedTimeView updateDuration:intervalSelected part:selectDuration.handleSelected];
    } else {
        float duration;
        NSTimeInterval intervalSelected = [selectDuration getSecondsFromZero];
        float nowSeconds = [[self secondsSinceMidnightWithDate:[NSDate date]] floatValue];
            
        // create a duration value out of dateSet and secondsFromZero on the duration picker
        if (intervalSelected > nowSeconds)
            duration = intervalSelected-nowSeconds;
        else if (isSet)
            duration = 0;
        else
            duration = (86400-nowSeconds)+intervalSelected;
        
        NSDate *currentDate = [NSDate date];
        
        // round to nearest minute (exclude seconds)
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger calendarUnits = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
        NSDateComponents *dateComps = [calendar components:calendarUnits fromDate:currentDate];
        [dateComps setSecond:0];
        currentDate = [calendar dateFromComponents:dateComps];
        
        // save when the duration was set and its duration
        if (!isSet) {
            [alarmInfo setObject:currentDate forKey:@"dateAlarmPicked"];
            [alarmInfo setObject:[NSNumber numberWithFloat:duration] forKey:@"alarmDuration"];
        }

        [selectedTimeView updateDate:[selectDuration getDate] part:selectDuration.handleSelected];
    }
    
    // animate selectedTimeView back to durationView
    [UIView animateWithDuration:.1 animations:^{
        [selectedTimeView setCenter:selectDurationView.center];
        if (!isStopwatchMode)
            [selectedTimeView setAlpha:1];
        [selectSongView setAlpha:1];
        [selectActionView setAlpha:1];
        [radialGradientView setAlpha:1];
    } completion:^(BOOL finished) {
        if (!CGPointEqualToPoint(selectedTimeView.center, selectDurationView.center))
            [self durationDidEndChanging:selectDuration];
    }];
    
    if (!isTimerMode)
        if ([delegate respondsToSelector:@selector(alarmViewUpdated)])
            [delegate alarmViewUpdated];
}

-(void) durationViewTapped:(SelectDurationView *)selectDuration {
    // if selecting song/action, compress the song
    if (pickingSong)
        [selectSongView quickSelectCell];
    if (pickingAction)
        [selectActionView quickSelectCell];
    if (countdownEnded) {
        if (!isTimerMode) {
            countdownEnded = NO;
            isSnoozing = YES;
            NSTimeInterval snoozeTime = [[[NSUserDefaults standardUserDefaults] objectForKey:@"snoozeTime"] intValue] * 60.0f; // get the snooze duration from preferences
            //NSTimeInterval testSnoozeTime = 1 * 60.0f;
            NSDate *snoozeDate = [[NSDate alloc] initWithTimeIntervalSinceNow:snoozeTime];
            [alarmInfo setObject:snoozeDate forKey:@"snoozeAlarm"]; // set an alarm for a time in the future
            [selectDuration setSecondsFromZeroWithNumber:[self secondsSinceMidnightWithDate:snoozeDate]];
            [selectedTimeView updateDate:snoozeDate part:SelectDurationNoHandle];
            [[delegate getMusicPlayer] stop];
        }
    }
}

-(void) durationViewCoreTapped:(SelectDurationView *)selectDuration {
    if (!pickingAction && !pickingSong && !isSet && !isTimerMode && !isStopwatchMode) {
        // go into timer mode
        [self enterTimerMode];
    } else if (isTimerMode && !isSet) {
        [self enterAlarmMode];
    }

}


-(BOOL) durationViewSwiped:(UISwipeGestureRecognizerDirection)direction {
    if (pickingSong && direction == UISwipeGestureRecognizerDirectionLeft)
        [selectSongView quickSelectCell];
    else if (pickingAction && direction == UISwipeGestureRecognizerDirectionRight)
        [selectActionView quickSelectCell];
    else
        return NO;
    return YES;
}


-(void) durationViewDraggedWithYVel:(float)yVel {
    if (pickingSong || pickingAction)
        return;
    
    CGRect newDurRect;
    CGRect proposedFrame = CGRectOffset(selectDurationView.frame, 0, yVel);
    
    // make the picker stop in the middle if it was in timer mode OR if it was set.
    if ((proposedFrame.origin.y >= selectDurRect.origin.y && isSet)
        || (proposedFrame.origin.y <= selectDurRect.origin.y && isStopwatchMode))
        newDurRect = selectDurRect;
    // cant go any lower than the stopwatch mode rect
    else if (proposedFrame.origin.y >= stopwatchModeDurRect.origin.y)
        newDurRect = stopwatchModeDurRect;
    // cent go any higher than the alarmSet rect
    else if (proposedFrame.origin.y <= alarmSetDurRect.origin.y)
        newDurRect = alarmSetDurRect;
    // cant go low if timer mode
    else if (isSet && proposedFrame.origin.y >= selectDurRect.origin.y)
        newDurRect = selectDurRect;
    else
        newDurRect = proposedFrame;
    
    // checking for a swipe
    if (fabsf(yVel) > 15) {
        if (yVel < 0) {
            if (isStopwatchMode){
                shouldSet = AlarmViewShouldUnSet;
            }
            else{
                
                shouldSet = AlarmViewShouldSet;
            }
        } else {
            if (isSet){
                shouldSet = AlarmViewShouldUnSet;
            }
            else if (!isTimerMode) {
                shouldSet = AlarmViewShouldStopwatch;
            }
        }
        
    } else if ((shouldSet == AlarmViewShouldSet && yVel > 0) || (shouldSet == AlarmViewShouldUnSet && yVel < 0) || (shouldSet == AlarmViewShouldStopwatch && yVel < 0))
        shouldSet = AlarmViewShouldNone;
    
    // compress the durationSelector if duration selector is below original position
    if (newDurRect.origin.y > selectDurRect.origin.y) {
        float currDist = stopwatchModeDurRect.origin.y - newDurRect.origin.y;
        float fullDist = stopwatchModeDurRect.origin.y - selectDurRect.origin.y;
        [selectDurationView compressByRatio:currDist/fullDist animated:NO];
    }
    
    [selectDurationView setFrame:newDurRect];
    // keep the inner text centered with time picker
    [selectedTimeView setCenter:selectDurationView.center];
    
    if (![[self subviews] containsObject:selectSongView])
        [self addSubview:selectSongView];
    if (![[self subviews] containsObject:selectActionView])
        [self addSubview:selectActionView];
    
    if ([delegate respondsToSelector:@selector(durationViewWithIndex:draggedWithPercent:)]) {
        float percentDragged = (selectDurationView.frame.origin.y - selectDurRect.origin.y) / 150;
        [delegate durationViewWithIndex:index draggedWithPercent:-percentDragged];
        // fade in stopwatch, fade out alarm functions
        [countdownView setAlpha:-percentDragged];
        [selectedTimeView setAlpha:1-percentDragged];
        [selectSongView setAlpha:1-percentDragged];
        [selectActionView setAlpha:1-percentDragged];
        [selectSongView.showCell.artistLabel setAlpha:1.3+percentDragged];
        
        [stopwatchViewController.view setAlpha:percentDragged];
    }
}

-(void) durationViewStoppedDraggingWithY:(float)y { // this is when the dial is finished moving up or down.
    // future: put this is own method
   // [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    if (pickingSong || pickingAction)
        return;
    
    bool setAlarm = NO;
    bool startStopwatchMode = NO;
    
    if (shouldSet == AlarmViewShouldNone) {
        if (selectDurationView.frame.origin.y > (selectDurRect.origin.y + stopwatchModeDurRect.origin.y )/2) {
            shouldSet = AlarmViewShouldStopwatch;
        } else if (selectDurationView.frame.origin.y > (selectDurRect.origin.y + alarmSetDurRect.origin.y )/2) {
            shouldSet = AlarmViewShouldUnSet;
        } else {
            shouldSet = AlarmViewShouldSet;
        }
    }

    
    if (shouldSet == AlarmViewShouldSet) {
        setAlarm = YES;
        [selectSongView.showCell.artistLabel setAlpha:0.3];
        
    } else if (shouldSet == AlarmViewShouldUnSet) {
        setAlarm = NO;
        [selectSongView.cell.artistLabel setAlpha:1];
        // when the user turns off the alarm when the alarm is sounding
        if (countdownEnded || isSnoozing) { // stop and launch countdown aciton
            if (isSnoozing) {
                [alarmInfo removeObjectForKey:@"snoozeAlarm"];
                isSnoozing = NO;
            }
            countdownEnded = NO;
            NSURL *openURL = [NSURL URLWithString:[[selectActionView.actions objectAtIndex:[selectActionView actionIDWithTitle: [alarmInfo objectForKey:@"actionTitle"] ]] objectForKey:@"url"]]; //gets URL of selected action from alarmInfo dictionary.
            [selectDurationView setSecondsFromZeroWithNumber:[NSNumber numberWithInt:[self getSecondsFromMidnight]]];
            [[delegate getMusicPlayer] stop];
            [[UIApplication sharedApplication] openURL:openURL]; //opens the url
            if (!isTimerMode)
                //[selectedTimeView updateDuration:[selectDurationView getDuration] part:selectDurationView.handleSelected];  // not needed any more
                [selectedTimeView updateDate:[selectDurationView getDate] part:selectDurationView.handleSelected];
        }
    } else if (shouldSet == AlarmViewShouldStopwatch
             || selectDurationView.frame.origin.y > (selectDurRect.origin.y + stopwatchModeDurRect.origin.y )/2) {
        setAlarm = NO;
        startStopwatchMode = YES;
    }
        
    // reset the stopwatch if it is new
    if (!isStopwatchMode && startStopwatchMode) {
        [alarmInfo setObject:[NSDate date] forKey:@"stopwatchDateBegan"];
    } else if (!startStopwatchMode && isStopwatchMode) {
        // zero out the timer
        [alarmInfo setObject:[NSDate date] forKey:@"stopwatchDateBegan"];
        [self updateProperties];
    }
    
    if (isTimerMode) {
        if (!isSet && setAlarm) {
            [alarmInfo setObject:[NSDate date] forKey:@"dateSet"];
            [selectDurationView beginTiming];
        } else if (isSet && !setAlarm) {
            [selectDurationView stopTiming];
            [[delegate getMusicPlayer] stop];
            for ( UILocalNotification *notif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
                [[UIApplication sharedApplication] cancelLocalNotification:notif];
            }
        }
        isSet = setAlarm;
    } else {
        if (!isSet && setAlarm) {
            [alarmInfo setObject:[NSDate date] forKey:@"dateSet"];
        } else if (isSet && !setAlarm) {
            [alarmInfo removeObjectForKey:@"dateSet"];
            [[delegate getMusicPlayer] stop];
            for ( UILocalNotification *notif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
                [[UIApplication sharedApplication] cancelLocalNotification:notif];
            }
        }
        isSet = setAlarm;
    }
    
    isStopwatchMode = startStopwatchMode;
    
    [selectDurationView compressByRatio:isStopwatchMode?0:1 animated:YES];
    
    // save the set bool
    [alarmInfo setObject:[NSNumber numberWithBool:isSet] forKey:@"isSet"];
    [alarmInfo setObject:[NSNumber numberWithBool:isStopwatchMode] forKey:@"isStopwatchMode"];
    
    shouldSet = AlarmViewShouldNone;
    
    [self animateSelectDurToRest];
    if ([delegate respondsToSelector:@selector(alarmViewUpdated)])
        [delegate alarmViewUpdated];
}

-(bool) shouldLockPicker {
    return (isSet || isStopwatchMode || ![self canMove]);
}
-(NSDate *)getDateBegan { // for the timer
    return [alarmInfo objectForKey:@"dateSet"];
}

#pragma mark - Animation
- (void) animateSelectDurToRest {
    
    CGRect newFrame = [self currRestedSelecDurRect];
    
    if ([delegate respondsToSelector:@selector(durationViewWithIndex:draggedWithPercent:)])
        [delegate durationViewWithIndex:index draggedWithPercent:((isSet)?1:isStopwatchMode?-1:0)];
    
    float alpha1;
    
    alpha1 = (isSet?1:0);
    
    float alpha2 = (isStopwatchMode)?0:1;
    
    if (alpha2 == 1 && !isTimerMode) {
        if (![[self subviews] containsObject:selectSongView])
            [self addSubview:selectSongView];
        if (![[self subviews] containsObject:selectActionView])
            [self addSubview:selectActionView];
    }
    
    [UIView animateWithDuration:.2 animations:^{
        [selectDurationView setFrame:newFrame];
        [selectedTimeView setCenter:selectDurationView.center];
        // animate fade of countdowntimer & such
        [countdownView setAlpha:alpha1];
        [stopwatchViewController.view setAlpha:1-alpha2];
        [selectSongView setAlpha:alpha2];
        [selectActionView setAlpha:alpha2];
        [selectedTimeView setAlpha:alpha2];
    } completion:^(BOOL finished) {
        if (alpha2 == 0) {
            [selectActionView removeFromSuperview];
            [selectSongView removeFromSuperview];
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

- (int) getSecondsFromMidnight {
    
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
    
    
    NSNumber *secondsSinceMidnight = [NSNumber numberWithInt:dateComponents.minute*60 + dateComponents.hour*3600];
    return secondsSinceMidnight;
}

@end

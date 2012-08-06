//
//  AlarmView.m
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 TackMobile. All rights reserved.
//

#import "AlarmView.h"

@implementation AlarmView
@synthesize delegate, index, isSet, isTimerMode, newRect;
@synthesize alarmInfo;
@synthesize backgroundImage, patternOverlay, toolbarImage;
@synthesize selectSongView, selectActionView, selectDurationView, selectedTimeView, deleteLabel;
@synthesize countdownView, timerView, selectAlarmBg;

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
        
        musicManager = [[MusicManager alloc] init];
        PListModel *pListModel = [delegate getPListModel];
        
        // Views
        CGSize bgImageSize = CGSizeMake(520, 480);
        CGRect frameRect = [[UIScreen mainScreen] applicationFrame];
        float offset = 20;
        
        bgImageRect = CGRectMake((self.frame.size.width-bgImageSize.width)/2, (self.frame.size.height-bgImageSize.height)/2, bgImageSize.width, bgImageSize.height);
        CGRect toolBarRect = CGRectMake(0, 0, self.frame.size.width, 135);
        selectSongRect = CGRectMake(offset-22, 0, frameRect.size.width-75, 80);
        selectActionRect = CGRectMake(offset+frameRect.size.width-50, 0, 50, 80);
        selectDurRect = CGRectMake(offset, self.frame.size.height-frameRect.size.width-45, frameRect.size.width, frameRect.size.width);
        alarmSetDurRect = CGRectOffset(selectDurRect, 0, -150);
        timerModeDurRect = CGRectOffset(selectDurRect, 0, 150);
        selectedTimeRect = CGRectExtendFromPoint(CGRectCenter(selectDurRect), 65, 65);
        CGRect durationMaskRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        countdownRect = CGRectMake(offset, alarmSetDurRect.origin.y+alarmSetDurRect.size.height, frameRect.size.width, self.frame.size.height - (alarmSetDurRect.origin.y+alarmSetDurRect.size.height) - 65);
        timerRect = CGRectMake(offset, timerModeDurRect.origin.y-countdownRect.size.height, frameRect.size.width, countdownRect.size.height);
        CGRect deleteLabelRect = CGRectMake(offset, 0, frameRect.size.width, 70);
        CGRect selectAlarmRect = CGRectMake(0, self.frame.size.height-50, self.frame.size.width, 50);
        
        backgroundImage = [[UIImageView alloc] initWithFrame:bgImageRect];
        patternOverlay = [[UIImageView alloc] initWithFrame:bgImageRect];
        toolbarImage = [[UIImageView alloc] initWithFrame:toolBarRect];
        selectSongView = [[SelectSongView alloc] initWithFrame:selectSongRect delegate:self presetSongs:[pListModel getPresetSongs]];
        selectActionView = [[SelectActionView alloc] initWithFrame:selectActionRect delegate:self actions:[pListModel getActions]];
        selectDurationView = [[SelectDurationView alloc] initWithFrame:selectDurRect delegate:self];
        durImageView = [[UIImageView alloc] init];
        selectedTimeView = [[SelectedTimeView alloc] initWithFrame:selectedTimeRect];
        countdownView = [[CountdownView alloc] initWithFrame:countdownRect];
        UIView *durationMaskView = [[UIView alloc] initWithFrame:durationMaskRect];
        timerView = [[TimerView alloc] initWithFrame:timerRect];
        deleteLabel = [[UILabel alloc] initWithFrame:deleteLabelRect];
        selectAlarmBg = [[UIView alloc] initWithFrame:selectAlarmRect];
        
        [self addSubview:backgroundImage];
        [self addSubview:patternOverlay];
        [self addSubview:selectAlarmBg];
        [self addSubview:countdownView];
        [self addSubview:timerView];
        [self addSubview:durationMaskView];
            [durationMaskView addSubview:selectDurationView];
        [self addSubview:durImageView];
        [self addSubview:toolbarImage];
        [self addSubview:selectSongView];
        [self addSubview:selectActionView];
        [self addSubview:selectedTimeView];
        [self addSubview:deleteLabel];
        
        [deleteLabel setFont:[UIFont fontWithName:@"Roboto" size:30]];
        [deleteLabel setBackgroundColor:[UIColor clearColor]]; [deleteLabel setTextColor:[UIColor whiteColor]];
        [deleteLabel setAlpha:0];
        [deleteLabel setTextAlignment:UITextAlignmentCenter];
        [deleteLabel setNumberOfLines:0];
        [deleteLabel setText:@"Pinch to Delete"];
        
        [selectAlarmBg setBackgroundColor:[UIColor colorWithWhite:0 alpha:.5]];
        
        [patternOverlay setImage:[UIImage imageNamed:@"overlayPattern"]];
        
        [durImageView setAlpha:0];
        [durImageView setUserInteractionEnabled:NO];
        
        // pinch to delete
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(alarmPinched:)];
        [self addGestureRecognizer:pinch];
        
        // initial properties
        [selectedTimeView updateTimeInterval:[selectDurationView getTimeInterval] part:SelectDurationNoHandle];
        [toolbarImage setImage:[UIImage imageNamed:@"toolbarBG"]];
        [backgroundImage setImage:[UIImage imageNamed:@"noAlbumImage"]];
        [self setBackgroundColor:[UIColor blackColor]];
        [countdownView setAlpha:0];
        [timerView setAlpha:0];
        [patternOverlay setAlpha:0];
        CGRect selectActionTableViewRect = CGRectMake(0, 0, frameRect.size.width-75, self.frame.size.height);
        [selectActionView.actionTableView setFrame:selectActionTableViewRect];
        
        // add gradient mask to countdownMaskView
        CAGradientLayer *gradient = [CAGradientLayer layer];
        NSArray *gradientColors = [NSArray arrayWithObjects:
                                   (id)[[UIColor clearColor] CGColor],
                                   (id)[[UIColor whiteColor] CGColor],
                                   (id)[[UIColor whiteColor] CGColor],
                                   (id)[[UIColor clearColor] CGColor], nil];
        
        float topFadeHeight = toolBarRect.size.height/self.frame.size.height;
        float bottomFadeHeight = 1 - (selectAlarmRect.size.height/self.frame.size.height);
        
        NSArray *gradientLocations = [NSArray arrayWithObjects:
                                      [NSNumber numberWithFloat:0.05f],
                                      [NSNumber numberWithFloat:topFadeHeight],
                                      [NSNumber numberWithFloat:bottomFadeHeight],
                                      [NSNumber numberWithFloat:1.0f-.05f], nil];
        
        [gradient setColors:gradientColors];
        [gradient setLocations:gradientLocations];
        [gradient setFrame:durationMaskRect];
        [durationMaskView.layer setMask:gradient];
        [durationMaskView.layer setMasksToBounds:YES];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame index:(int)aIndex delegate:(id<AlarmViewDelegate>)aDelegate alarmInfo:(NSDictionary *)theAlarmInfo {
    if (theAlarmInfo)
        alarmInfo = [[NSMutableDictionary alloc] initWithDictionary:theAlarmInfo];
    else
        alarmInfo = nil;
    index = aIndex;
    delegate = aDelegate;
    return [self initWithFrame:frame];
}

- (void) viewWillAppear {
    // init the picker's stuff
    if (!alarmInfo) {
        NSArray *infoKeys = [[NSArray alloc] initWithObjects:@"date", @"songID", @"actionID", @"isSet", @"themeID", @"isTimerMode", @"timerDateBegan", nil];
        NSArray *infoObjects = [[NSArray alloc] initWithObjects:[NSDate dateWithTimeIntervalSinceNow:77777], [NSNumber numberWithInt:0],[NSNumber numberWithInt:0], [NSNumber numberWithBool:NO], [NSNumber numberWithInt:-1], [NSNumber numberWithBool:NO], [NSDate date], nil];
        alarmInfo = [[NSMutableDictionary alloc] initWithObjects:infoObjects forKeys:infoKeys];
        [selectDurationView setDate:[alarmInfo objectForKey:@"date"]];
    } else {
        // init the duration picker & theme & action & song
        // select duration
        [selectDurationView setDate:[alarmInfo objectForKey:@"date"]];
        // select song
        [selectSongView selectCellWithID:(NSNumber *)[alarmInfo objectForKey:@"songID"]];
        // select action
        [selectActionView selectActionWithID:(NSNumber *)[alarmInfo objectForKey:@"actionID"]];
        // set isSet
        if ([(NSNumber *)[alarmInfo objectForKey:@"isSet"] boolValue]) {
            isSet = YES;
        }
        if ([(NSNumber *)[alarmInfo objectForKey:@"isTimerMode"] boolValue]) {
            isTimerMode = YES;
        }
        [self animateSelectDurToRest];
    }
}

- (bool) canMove {
    return !(pickingSong || pickingAction);
}

- (void) alarmCountdownEnded {
    if (!countdownEnded && isSet) {
        // play music
        [selectSongView.musicPlayer playSongWithID:[alarmInfo objectForKey:@"songID"] vibrate:YES];
        countdownEnded = YES;
    }
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
    if (pinchRecog.velocity < 0 && pinchRecog.state == UIGestureRecognizerStateBegan) {
        [durImageView setAlpha:0];

        [UIView animateWithDuration:.2 animations:^{
            [selectSongView setAlpha:0];
            [selectActionView setAlpha:0];
            [deleteLabel setAlpha:1];
        }];
        // compress the duration picker!
        UIGraphicsBeginImageContext(selectDurationView.bounds.size);
        [selectDurationView.layer renderInContext:UIGraphicsGetCurrentContext()];
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), selectedTimeView.frame.origin.x-selectDurationView.frame.origin.x,
                              selectedTimeView.frame.origin.y-selectDurationView.frame.origin.y);
        [selectedTimeView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *durImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [durImageView setImage:durImage];
        [durImageView sizeToFit];
        [durImageView setCenter:selectDurationView.center];
        // switch out the duration picker with a fake!
        [selectDurationView setAlpha:0];
        [selectedTimeView setAlpha:0];
        [durImageView setAlpha:1];
    } else if (pinchRecog.state == UIGestureRecognizerStateChanged) {
        [selectDurationView setAlpha:0];
        if (pinchRecog.scale > 1)
            pinchRecog.scale = 1;
        float scale = 1-(.1 * (1-pinchRecog.scale));
        float cScale = 1-(3 * (1-pinchRecog.scale));
        CGSize selectDurSize = selectDurationView.frame.size;
        if (isSet)
            countdownView.alpha = cScale;
        
        CGSize compressedDurSize =CGSizeMake(scale*selectDurSize.width, scale*selectDurSize.height);
        durImageView.frame = CGRectInset([self currRestedSelecDurRect], selectDurSize.width-compressedDurSize.width, selectDurSize.height-compressedDurSize.height);
        durImageView.alpha = scale;
        
    } else {
        if (pinchRecog.scale < .7) {
            if ([delegate respondsToSelector:@selector(alarmViewPinched:)] )
                if ([delegate alarmViewPinched:self])
                    return;
        }
        [UIView animateWithDuration:.2 animations:^{
            [durImageView setFrame:selectDurationView.frame];
            [selectSongView setAlpha:1];
            [selectActionView setAlpha:1];
            [deleteLabel setAlpha:0];
            if (isSet)
                countdownView.alpha = 1;
        } completion:^(BOOL finished) {
            [selectDurationView setAlpha:1];
            [selectedTimeView setAlpha:1];
            [durImageView setAlpha:0];
        }];
    }
}

#pragma mark - Posiitoning/Drawing
// parallax shiz
- (void) shiftedFromActiveByPercent:(float)percent {
    if (pickingSong || pickingAction)
        return;
    
    float screenWidth = self.frame.size.width;
    
    float durPickOffset =       200 * percent;
    float countDownOffset =     260 * percent;
    float songPickOffset =      100 * percent;
    float actionPickOffset =    75 * percent;
    float backgroundOffset =    (bgImageRect.size.width - screenWidth)/2 * percent;
    
    CGRect shiftedDurRect = CGRectOffset([self currRestedSelecDurRect], durPickOffset, 0);
    CGRect shiftedCountdownRect = CGRectOffset(countdownRect, countDownOffset, 0);
    CGRect shiftedTimerRect = CGRectOffset(timerRect, countDownOffset, 0);
    CGRect shiftedSongRect = CGRectOffset(selectSongRect, songPickOffset, 0);
    CGRect shiftedActionRect = CGRectOffset(selectActionRect, actionPickOffset, 0);
    CGRect shiftedBgImgRect = CGRectOffset(bgImageRect, backgroundOffset, 0);
    
    [selectDurationView setFrame:shiftedDurRect];
    [selectedTimeView setCenter:selectDurationView.center];
    [countdownView setFrame:shiftedCountdownRect];
    [timerView setFrame:shiftedTimerRect];
    [selectSongView setFrame:shiftedSongRect];
    [selectActionView setFrame:shiftedActionRect];
    [backgroundImage setFrame:shiftedBgImgRect];
}
- (void) menuOpenWithPercent:(float)percent {
    [backgroundImage setAlpha:1.0f-(.8/(1.0f/percent))];
    if ([delegate respondsToSelector:@selector(alarmViewOpeningMenuWithPercent:)])
        [delegate alarmViewOpeningMenuWithPercent:percent];
}

- (void) menuCloseWithPercent:(float)percent {
    if (percent==1)
        [backgroundImage setAlpha:1];
    else 
        [backgroundImage setAlpha:(.8/(1.0f/percent))];
    
    if ([delegate respondsToSelector:@selector(alarmViewClosingMenuWithPercent:)])
        [delegate alarmViewClosingMenuWithPercent:percent];
}

- (void) updateThemeWithArtwork:(UIImage *)artwork {
    int themeID = [(NSNumber *)[alarmInfo objectForKey:@"themeID"] intValue];
    NSDictionary *theme;
    if (themeID < 6 && themeID > -1) { // preset theme
        theme = [musicManager getThemeWithID:themeID];
        artwork = [theme objectForKey:@"bgImg"];
        [toolbarImage setAlpha:0];
        [selectAlarmBg setAlpha:0];
        [patternOverlay setAlpha:0];
        [selectDurationView updateTheme:theme];
    } else {
        [toolbarImage setAlpha:1];
        [selectAlarmBg setAlpha:1];
        [patternOverlay setAlpha:1];
        theme = [musicManager getThemeWithID:6];
        [selectDurationView updateTheme:theme];
    }
    if (artwork) {
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
    }
   // else // no theme
        //theme = [musicManager getThemeForSongID:[alarmInfo objectForKey:@"songID"]];
}

- (void) updateProperties {
    // make sure the date is in future
    while ([(NSDate *)[alarmInfo objectForKey:@"date"] timeIntervalSinceNow] < 0)
        [alarmInfo setObject:[NSDate dateWithTimeInterval:86400 sinceDate:[alarmInfo objectForKey:@"date"]] forKey:@"date"];
    
    // check to see if it will go off
    if (isSet && floorf([[alarmInfo objectForKey:@"date"] timeIntervalSinceNow]) < .5)
        [self alarmCountdownEnded];
    
    if (selectDurationView.handleSelected == SelectDurationNoHandle)
        [selectDurationView setDate:[alarmInfo objectForKey:@"date"]];
    
    [countdownView updateWithDate:[alarmInfo objectForKey:@"date"]];
    if (isTimerMode)
        [timerView updateWithDate:[alarmInfo objectForKey:@"timerDateBegan"]];
}

- (CGRect) currRestedSelecDurRect {
    if (isSet)
        return alarmSetDurRect;
    else if (isTimerMode)
        return timerModeDurRect;
    else
        return selectDurRect;
}

#pragma mark - SelectSongViewDelegate
-(BOOL) expandSelectSongView {
    if (pickingAction)
        return NO;
    
    pickingSong = YES;
        
    CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;
    
    CGRect newSelectSongRect = CGRectMake(20, selectSongRect.origin.y, screenSize.width, self.frame.size.height);
    CGRect selectDurPushedRect = CGRectOffset(selectDurationView.frame, selectSongView.frame.size.width, 0);
    CGRect selectActionPushedRect = CGRectOffset(selectActionView.frame, 90, 0);
    CGRect countdownPushedRect = CGRectOffset(countdownView.frame, selectSongView.frame.size.width, 0);
    CGRect timerPushedRect = CGRectOffset(timerRect, selectSongView.frame.size.width, 0);

    
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
        
        [timerView setFrame:timerPushedRect];
        [timerView setAlpha:isTimerMode?.6:0];
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
        [selectedTimeView setAlpha:1];
        
        [selectActionView setFrame:selectActionRect];
        [selectActionView setAlpha:1];
        
        [countdownView setFrame:countdownRect];
        [countdownView setAlpha:isSet?1:0];
        
        [timerView setFrame:timerRect];
        [timerView setAlpha:isTimerMode?1:0];
    }];
}
     
-(void) songSelected:(NSNumber *)persistentMediaItemID withArtwork:(UIImage *)artwork theme:(NSNumber *)themeID {    
    // save the song ID
    [alarmInfo setObject:persistentMediaItemID forKey:@"songID"];
    [alarmInfo setObject:themeID forKey:@"themeID"];
    
    [self updateThemeWithArtwork:artwork];
}

#pragma mark - SelectActionViewDelegate
-(BOOL) expandSelectActionView {
    if (pickingSong)
        return NO;
    pickingAction = YES;
    
    CGRect newSelectActionRect = CGRectMake(75+20, 0, [[UIScreen mainScreen] applicationFrame].size.width-75, self.frame.size.height);
    CGRect selectDurPushedRect = CGRectOffset(selectDurationView.frame, -newSelectActionRect.size.width, 0);
    CGRect selectSongPushedRect = CGRectOffset(selectSongView.frame, -selectSongView.frame.size.width + 30, 0);
    CGRect countdownPushedRect = CGRectOffset(countdownView.frame, -newSelectActionRect.size.width, 0);
    CGRect timerPushedRect = CGRectOffset(timerRect, -newSelectActionRect.size.width, 0);

    
    [UIView animateWithDuration:.2 animations:^{
        [self menuOpenWithPercent:1];
        [selectActionView setFrame:newSelectActionRect];
        
        [selectDurationView setFrame:selectDurPushedRect];
        [selectDurationView setAlpha:.9];
        
        [selectedTimeView setCenter:selectDurationView.center];
        [selectedTimeView setAlpha:9];
        
        [selectSongView setFrame:selectSongPushedRect];
        [selectSongView setAlpha:.9];
        
        [countdownView setFrame:countdownPushedRect];
        [countdownView setAlpha:isSet?.6:0];
        
        [timerView setFrame:timerPushedRect];
        [timerView setAlpha:isTimerMode?.6:0];
    }];
    
    
    
    return YES;
}

-(void) actionSelected:(NSNumber *)actionID {
    pickingAction = NO;
    
    // save the song ID
    [alarmInfo setObject:actionID forKey:@"actionID"];
    
    // compress the selectActionView
    [UIView animateWithDuration:.2 animations:^{
        [self menuCloseWithPercent:1];
        [selectActionView setFrame:selectActionRect];
        
        [selectDurationView setFrame:[self currRestedSelecDurRect]];
        [selectDurationView setAlpha:1];
        
        [selectedTimeView setCenter:selectDurationView.center];
        [selectedTimeView setAlpha:1];
        
        [selectSongView setFrame:selectSongRect];
        [selectSongView setAlpha:1];
        
        [countdownView setFrame:countdownRect];
        [countdownView setAlpha:isSet?1:0];
        
        [timerView setFrame:timerRect];
        [timerView setAlpha:isTimerMode?1:0];
    }];
}


#pragma mark - CountdownTimerDelegate
- (void) countdown:(id)countdown tickWithDate:(NSDate *)date {
    
}
- (void) countdownEnded:(id)countdown {
    
}

#pragma mark - SelectDurationViewDelegate
-(void) durationDidChange:(SelectDurationView *)selectDuration {
    NSDate *dateSelected = [NSDate dateWithTimeIntervalSinceNow:[selectDuration getTimeInterval]];
    // zero the minute
    NSTimeInterval time = round([dateSelected timeIntervalSinceNow] / 60.0) * 60.0;
    [selectDuration setTimeInterval:time];
    
    // update selected time
    [selectedTimeView updateTimeInterval:[selectDuration getTimeInterval] part:selectDuration.handleSelected];
}

-(void) durationDidBeginChanging:(SelectDurationView *)selectDuration {
    CGRect newSelectedTimeRect = CGRectMake(selectedTimeView.frame.origin.x, -20, selectedTimeView.frame.size.width, selectedTimeView.frame.size.height);
    CGRect belowSelectedTimeRect = CGRectOffset(newSelectedTimeRect, 0, 15);
    
    // animate selectedTimeView to toolbar
    [UIView animateWithDuration:.1 animations:^{
        [selectedTimeView setAlpha:0];
    } completion:^(BOOL finished) {
        [selectedTimeView setFrame:belowSelectedTimeRect];
        [UIView animateWithDuration:.07 animations:^{
            [selectedTimeView setFrame:newSelectedTimeRect];
            [selectedTimeView setAlpha:1];
            if ([selectDuration handleSelected] != SelectDurationNoHandle) {
                [selectSongView setAlpha:.3];
                [selectActionView setAlpha:.3];
                [backgroundImage setAlpha:.6];
            }
        }];
    }];
    [selectedTimeView updateTimeInterval:[selectDuration getTimeInterval] part:selectDuration.handleSelected];
}

-(void) durationDidEndChanging:(SelectDurationView *)selectDuration {
     // save the time selected
     NSDate *dateSelected = [NSDate dateWithTimeIntervalSinceNow:[selectDuration getTimeInterval]];
     // zero the minute
    
    NSTimeInterval time = round([dateSelected timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    dateSelected = [NSDate dateWithTimeIntervalSinceReferenceDate:time];

    [alarmInfo setObject:dateSelected forKey:@"date"];
    
    // update selectedTime View
    [selectedTimeView updateTimeInterval:[selectDuration getTimeInterval] part:selectDuration.handleSelected];
    
    // animate selectedTimeView back to durationView
    [UIView animateWithDuration:.07 animations:^{
        CGRect belowSelectedTimeRect = CGRectOffset([selectedTimeView frame], 0, 15);
        
        [selectedTimeView setAlpha:0];
        [selectedTimeView setFrame:belowSelectedTimeRect];
        
        [selectSongView setAlpha:1];
        [selectActionView setAlpha:1];
        [backgroundImage setAlpha:1];
    } completion:^(BOOL finished) {
        [selectedTimeView setCenter:selectDurationView.center];
        [UIView animateWithDuration:.1 animations:^{
             [selectedTimeView setAlpha:1];
        }];
    }];
    if ([delegate respondsToSelector:@selector(alarmViewUpdated)])
        [delegate alarmViewUpdated];
}

-(void) durationViewTapped:(SelectDurationView *)selectDuration {
    // if selecting song/action, compress the song
    if (pickingSong)
        [selectSongView quickSelectCell];
    if (pickingAction)
        [selectActionView quickSelectCell];
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
    
    CGRect newDurRect = selectDurRect;
    CGRect proposedFrame = CGRectOffset(selectDurationView.frame, 0, yVel);
        
    if ((proposedFrame.origin.y >= selectDurRect.origin.y && isSet)
        || (proposedFrame.origin.y <= selectDurRect.origin.y && isTimerMode))
        newDurRect = selectDurRect;
    else if (proposedFrame.origin.y >= timerModeDurRect.origin.y)
        newDurRect = timerModeDurRect;
    else if (proposedFrame.origin.y <= alarmSetDurRect.origin.y)
        newDurRect = alarmSetDurRect;
    else
        newDurRect = proposedFrame;
    
    if (fabsf(yVel) > 15) {
        if (yVel < 0) {
            if (isTimerMode)
                shouldSet = AlarmViewShouldUnSet;
            else
                shouldSet = AlarmViewShouldSet;
        } else {
            if (isSet)
                shouldSet = AlarmViewShouldUnSet;
            else
                shouldSet = AlarmViewShouldTimer;
        }
        
    } else if ((shouldSet == AlarmViewShouldSet && yVel > 0) || (shouldSet == AlarmViewShouldUnSet && yVel < 0) || (shouldSet == AlarmViewShouldTimer && yVel < 0))
        shouldSet = AlarmViewShouldNone;
    
    [selectDurationView setFrame:newDurRect];
    [selectedTimeView setCenter:selectDurationView.center];
    
    if ([delegate respondsToSelector:@selector(durationViewWithIndex:draggedWithPercent:)]) {
        float percentDragged = (selectDurationView.frame.origin.y - selectDurRect.origin.y) / 150;
        [delegate durationViewWithIndex:index draggedWithPercent:-percentDragged];
        // fade in countdowntimer
        NSLog(@"%f", percentDragged);
        [countdownView setAlpha:-percentDragged];
        [selectedTimeView setAlpha:1-percentDragged];
        [timerView setAlpha:percentDragged];
    }
}

-(void) durationViewStoppedDraggingWithY:(float)y {
    // future: put this is own method
    
    if (pickingSong || pickingAction)
        return;
    
    if (countdownEnded) {
        countdownEnded = NO;
        [selectSongView.musicPlayer stop];
        // LAUNCH ACTION;
    }
    
    bool set = NO;
    bool timer = NO;
    if (shouldSet == AlarmViewShouldSet
        || selectDurationView.frame.origin.y < (selectDurRect.origin.y + alarmSetDurRect.origin.y )/2)
        set = YES;
    else if (shouldSet == AlarmViewShouldUnSet)
        set = NO;
    else if (shouldSet == AlarmViewShouldTimer
             || selectDurationView.frame.origin.y > (selectDurRect.origin.y + timerModeDurRect.origin.y )/2) {
        set = NO;
        timer = YES;
    }
    
    // reset the timer if it is new
    if (!isTimerMode && timer) {
        [alarmInfo setObject:[NSDate date] forKey:@"timerDateBegan"];
    } else if (!timer && isTimerMode) {
        // zero out the timer
        [alarmInfo setObject:[NSDate date] forKey:@"timerDateBegan"];
        [self updateProperties];
    }

    isSet = set;
    isTimerMode = timer;
        
    // save the set bool
    [alarmInfo setObject:[NSNumber numberWithBool:isSet] forKey:@"isSet"];
    [alarmInfo setObject:[NSNumber numberWithBool:isTimerMode] forKey:@"isTimerMode"];
    
    shouldSet = AlarmViewShouldNone;
    [self animateSelectDurToRest];
    if ([delegate respondsToSelector:@selector(alarmViewUpdated)])
        [delegate alarmViewUpdated];
}

-(bool) shouldLockPicker {
    return (isSet || isTimerMode || ![self canMove]);
}

#pragma mark - Animation
- (void) animateSelectDurToRest {
    
    CGRect newFrame = selectDurRect;
    if (isSet) 
        newFrame = alarmSetDurRect;
    else if (isTimerMode)
        newFrame = timerModeDurRect;
    
    if ([delegate respondsToSelector:@selector(durationViewWithIndex:draggedWithPercent:)])
        [delegate durationViewWithIndex:index draggedWithPercent:(isSet?1:isTimerMode?-1:0)];
    
    [UIView animateWithDuration:.2 animations:^{
        [selectDurationView setFrame:newFrame];
        [selectedTimeView setCenter:selectDurationView.center];
        // animate fade of countdowntimer & such
        [countdownView setAlpha:(isSet?1:0)];
        [timerView setAlpha:(isTimerMode?1:0)];
        [selectedTimeView setAlpha:(isTimerMode)?0:1];

    }];  
}

#pragma mark - Utilities

CGRect CGRectExtendFromPoint(CGPoint p1, float dx, float dy) {
    return CGRectMake(p1.x-dx, p1.y-dy, dx*2, dy*2);
}

CGPoint CGRectCenter(CGRect rect) {
    return CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
}

@end

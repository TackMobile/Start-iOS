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
@synthesize backgroundImage, toolbarImage;
@synthesize selectSongView, selectActionView, selectDurationView, selectedTimeView, deleteLabel;
@synthesize countdownView, countdownTimer, selectAlarmBg;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        shouldSet = AlarmViewShouldNone;
        [self setClipsToBounds:YES];
        pickingSong = NO;
        pickingAction = NO;
        cancelTouch = NO;
        
        musicManager = [[MusicManager alloc] init];
        PListModel *pListModel = [delegate getPListModel];
        
        // Views
        CGSize bgImageSize = CGSizeMake(520, 480);
        
        bgImageRect = CGRectMake((self.frame.size.width-bgImageSize.width)/2, (self.frame.size.height-bgImageSize.height)/2, bgImageSize.width, bgImageSize.height);
        CGRect toolBarRect = CGRectMake(0, 0, self.frame.size.width, 135);
        selectSongRect = CGRectMake(-22, 0, self.frame.size.width-75, 80);
        selectActionRect = CGRectMake(self.frame.size.width-60, 0, 60, 80);
        selectDurRect = CGRectMake(0, self.frame.size.height-self.frame.size.width-45, self.frame.size.width, self.frame.size.width);
        alarmSetDurRect = CGRectOffset(selectDurRect, 0, -150);
        timerModeDurRect = CGRectOffset(selectDurRect, 0, 150);
        selectedTimeRect = CGRectExtendFromPoint(CGRectCenter(selectDurRect), 65, 65);
        countdownRect = CGRectMake(0, alarmSetDurRect.origin.y+alarmSetDurRect.size.height, self.frame.size.width, self.frame.size.height - (alarmSetDurRect.origin.y+alarmSetDurRect.size.height) - 65);
        CGRect deleteLabelRect = CGRectMake(0, 0, self.frame.size.width, 70);
        CGRect selectAlarmRect = CGRectMake(0, self.frame.size.height-50, self.frame.size.width, 50);
        
        backgroundImage = [[UIImageView alloc] initWithFrame:bgImageRect];
        toolbarImage = [[UIImageView alloc] initWithFrame:toolBarRect];
        selectSongView = [[SelectSongView alloc] initWithFrame:selectSongRect delegate:self presetSongs:[pListModel getPresetSongs]];
        selectActionView = [[SelectActionView alloc] initWithFrame:selectActionRect delegate:self actions:[pListModel getActions]];
        selectDurationView = [[SelectDurationView alloc] initWithFrame:selectDurRect delegate:self];
        selectedTimeView = [[SelectedTimeView alloc] initWithFrame:selectedTimeRect];
        countdownView = [[CountdownView alloc] initWithFrame:countdownRect];
        deleteLabel = [[UILabel alloc] initWithFrame:deleteLabelRect];
        selectAlarmBg = [[UIView alloc] initWithFrame:selectAlarmRect];
        
        [self addSubview:backgroundImage];
        [self addSubview:selectAlarmBg];
        [self addSubview:countdownView];
        [self addSubview:selectDurationView];
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
        
        // pinch to delete
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(alarmPinched:)];
        [self addGestureRecognizer:pinch];
        
        [selectedTimeView updateTimeInterval:[selectDurationView getTimeInterval] part:SelectDurationNoHandle];
        [toolbarImage setImage:[UIImage imageNamed:@"toolbarBG"]];
        [backgroundImage setImage:[UIImage imageNamed:@"noAlbumImage"]];
        [self setBackgroundColor:[UIColor blackColor]];
        [countdownView setAlpha:0];
        
        CGRect selectActionTableViewRect = CGRectMake(0, 0, self.frame.size.width-75, self.frame.size.height);
        [selectActionView.actionTableView setFrame:selectActionTableViewRect];
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
        NSArray *infoKeys = [[NSArray alloc] initWithObjects:@"date", @"songID", @"actionID", @"isSet", @"themeID", @"isTimerMode", @"timerStarted", nil];
        NSArray *infoObjects = [[NSArray alloc] initWithObjects:[NSDate date], [NSNumber numberWithInt:0],[NSNumber numberWithInt:0], [NSNumber numberWithBool:NO], [NSNumber numberWithInt:-1], [NSNumber numberWithBool:NO], [NSDate date], nil];
        alarmInfo = [[NSMutableDictionary alloc] initWithObjects:infoObjects forKeys:infoKeys];
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
            [self animateSelectDurToRest];

        }
    }
}

- (bool) canMove {
    return !(pickingSong || pickingAction);
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
    
    if (pinchRecog.velocity < 0 && pinchRecog.state == UIGestureRecognizerStateBegan) {
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
        durImageView = [[UIImageView alloc] initWithImage:durImage];
        [durImageView setCenter:selectDurationView.center];
        // switch out the duration picker with a fake!
        [selectDurationView setAlpha:0];
        [selectedTimeView setAlpha:0];
        [self insertSubview:durImageView aboveSubview:selectDurationView];
    } else if (pinchRecog.state == UIGestureRecognizerStateChanged) {
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
            [durImageView removeFromSuperview];
        }];
    }
    
    
    /*
    if (((pinchRecog.velocity < 0 && pinchRecog.state == UIGestureRecognizerStateBegan)
         || (pinchRecog.state == UIGestureRecognizerStateChanged && pinchRecog.scale <= 1.0))) {
        float scale = (powf(pinchRecog.scale, 2) >= 0)?powf(pinchRecog.scale, 2):0;
        [deleteLabel setAlpha:1-scale];
        if (isSet) {
            [countdownView setAlpha:scale];
        }
        [selectDurationView setAlpha:scale];
        [toolbarImage setAlpha:scale];
        [selectSongView setAlpha:scale];
        [selectActionView setAlpha:scale];
        [selectedTimeView setAlpha:scale];
    } else if (pinchRecog.state == UIGestureRecognizerStateEnded) {
        if (pinchRecog.scale < .7) {
            if ([delegate respondsToSelector:@selector(alarmViewPinched:)] )
                if ([delegate alarmViewPinched:self])
                    return;
        }
        [UIView animateWithDuration:.2 animations:^{
            [deleteLabel setAlpha:0];
            if (isSet) {
                [countdownView setAlpha:1];
            }
            [selectDurationView setAlpha:1];
            [toolbarImage setAlpha:1];
            [selectSongView setAlpha:1];
            [selectActionView setAlpha:1];
            [selectedTimeView setAlpha:1];
        }];
    }*/
    
    /*if (((pinchRecog.velocity < 0 && pinchRecog.state == UIGestureRecognizerStateBegan)
        || (pinchRecog.state == UIGestureRecognizerStateChanged && pinchRecog.scale <= 1.0))
        && [delegate respondsToSelector:@selector(alarmViewPinched:scale:state:)] ) {
        [delegate alarmViewPinched:self scale:pinchRecog.scale state:pinchRecog.state];
    }*/
}

#pragma mark - Posiitoning/Drawing
// parallax shiz
- (void) shiftedFromActiveByPercent:(float)percent {
    if (pickingSong || pickingAction)
        return;
    
    float screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    
    float durPickOffset =       200 * percent;
    float songPickOffset =      100 * percent;
    float actionPickOffset =    75 * percent;
    float backgroundOffset =    (bgImageRect.size.width - screenWidth)/2 * percent;
    
    CGRect shiftedDurRect = CGRectOffset([self currRestedSelecDurRect], durPickOffset, 0);
    CGRect shiftedCountdownRect = CGRectOffset(countdownRect, durPickOffset, 0);
    CGRect shiftedSongRect = CGRectOffset(selectSongRect, songPickOffset, 0);
    CGRect shiftedActionRect = CGRectOffset(selectActionRect, actionPickOffset, 0);
    CGRect shiftedBgImgRect = CGRectOffset(bgImageRect, backgroundOffset, 0);
    
    [selectDurationView setFrame:shiftedDurRect];
    [selectedTimeView setCenter:selectDurationView.center];
    [countdownView setFrame:shiftedCountdownRect];
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
        [selectDurationView updateTheme:theme];
    } else {
        [toolbarImage setAlpha:1];
        [selectAlarmBg setAlpha:1];
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
    
    [selectDurationView setDate:[alarmInfo objectForKey:@"date"]];
    [countdownView updateWithDate:[alarmInfo objectForKey:@"date"]];
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
    
    CGRect newSelectSongRect = CGRectMake(0, selectSongRect.origin.y, screenSize.width, self.frame.size.height);
    CGRect selectDurPushedRect = CGRectOffset(selectDurationView.frame, selectSongView.frame.size.width, 0);
    CGRect selectActionPushedRect = CGRectOffset(selectActionView.frame, 90, 0);
    CGRect countdownPushedRect = CGRectOffset(countdownView.frame, selectSongView.frame.size.width-50, 0);
    
    [UIView animateWithDuration:.2 animations:^{
        [self menuOpenWithPercent:1];
        
        [selectSongView setFrame:newSelectSongRect];
        
        [selectDurationView setFrame:selectDurPushedRect];
        [selectDurationView setAlpha:.9];
        
        [selectedTimeView setCenter:selectDurationView.center];
        [selectedTimeView setAlpha:.9];
        
        [selectActionView setFrame:selectActionPushedRect];
        [selectActionView setAlpha:.9];
        
        [countdownView setFrame:countdownPushedRect];
        [countdownView setAlpha:isSet?.6:0];
    }];
        
    return YES;
}
-(void) compressSelectSong {
    pickingSong = NO;

    // compress the songSelectView
    [UIView animateWithDuration:.2 animations:^{
        [self menuCloseWithPercent:1];
        [selectSongView setFrame:selectSongRect];
        
        if (isSet)
            [selectDurationView setFrame:alarmSetDurRect];
        else
            [selectDurationView setFrame:selectDurRect];
        [selectDurationView setAlpha:1];
        
        [selectedTimeView setCenter:selectDurationView.center];
        [selectedTimeView setAlpha:1];
        
        [selectActionView setFrame:selectActionRect];
        [selectActionView setAlpha:1];
        
        [countdownView setFrame:countdownRect];
        [countdownView setAlpha:isSet?1:0];
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
    
    CGRect newSelectActionRect = CGRectMake(75, 0, self.frame.size.width-75, self.frame.size.height);
    CGRect selectDurPushedRect = CGRectOffset(selectDurationView.frame, -newSelectActionRect.size.width, 0);
    CGRect selectSongPushedRect = CGRectOffset(selectSongView.frame, -selectSongView.frame.size.width + 30, 0);
    CGRect countdownPushedRect = CGRectOffset(countdownView.frame, -selectSongView.frame.size.width+50, 0);

    
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
        
        if (isSet)
            [selectDurationView setFrame:alarmSetDurRect];
        else
            [selectDurationView setFrame:selectDurRect];
        [selectDurationView setAlpha:1];
        
        [selectedTimeView setCenter:selectDurationView.center];
        [selectedTimeView setAlpha:1];
        
        [selectSongView setFrame:selectSongRect];
        [selectSongView setAlpha:1];
        
        [countdownView setFrame:countdownRect];
        [countdownView setAlpha:isSet?1:0];
    }];
}


#pragma mark - CountdownTimerDelegate
- (void) countdown:(id)countdown tickWithDate:(NSDate *)date {
    
}
- (void) countdownEnded:(id)countdown {
    
}

#pragma mark - SelectDurationViewDelegate
-(void) durationDidChange:(SelectDurationView *)selectDuration {
    // update selectedTimeView
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
        float percentDragged = (alarmSetDurRect.origin.y + selectDurationView.frame.origin.y) / (selectDurRect.origin.y - alarmSetDurRect.origin.y)-.2;
        [delegate durationViewWithIndex:index draggedWithPercent:-percentDragged];
        // fade in countdowntimer
        [countdownView setAlpha:-percentDragged];
    }
}
-(void) durationViewStoppedDraggingWithY:(float)y {
    if (pickingSong || pickingAction)
        return;
    
    bool set = NO;
    bool timer = NO;
    if (shouldSet == AlarmViewShouldSet)
        set = YES;
    else if (shouldSet == AlarmViewShouldUnSet)
        set = NO;
    else if (shouldSet == AlarmViewShouldTimer) {
        set = NO;
        timer = YES;
    } else if (selectDurationView.frame.origin.y < (selectDurRect.origin.y + alarmSetDurRect.origin.y )/2) // more than halfway to setting
        set = YES;
    else if (selectDurationView.frame.origin.y > (selectDurRect.origin.y + timerModeDurRect.origin.y )/2) { // moret han halfway to timer mode
        set = NO;
        timer = YES;
    }
    
    isSet = set;
    isTimerMode = timer;
    
    // save the set bool
    [alarmInfo setObject:[NSNumber numberWithBool:isSet] forKey:@"isSet"];
    [alarmInfo setObject:[NSNumber numberWithBool:isTimerMode] forKey:@"isTimerMode"];
    
    shouldSet = AlarmViewShouldNone;
    [self animateSelectDurToRest];
}

-(bool) shouldLockPicker {
    return (isSet || ![self canMove]);
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
        // animate fade of countdowntimer
        [countdownView setAlpha:(isSet?1:0)];
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

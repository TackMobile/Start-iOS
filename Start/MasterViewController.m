//
//  ViewController.m
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 TackMobile. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController ()
@end

@implementation MasterViewController
@synthesize alarms, musicPlayer, settingsView;
@synthesize pListModel, selectAlarmView, tickTimer;

- (void)viewDidLoad
{    
    [super viewDidLoad];
	alarms = [[NSMutableArray alloc] init];
    // get the saved alarm index
    NSNumber *savedAlarmIndex = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"currAlarmIndex"];
    currAlarmIndex = (savedAlarmIndex)?[savedAlarmIndex intValue]:1;
    shouldSwitch = SwitchAlarmNone;
    pListModel = [[PListModel alloc] init];
    
    // views
    CGRect frameRect = [[UIScreen mainScreen] applicationFrame];
    CGRect selectAlarmRect = CGRectMake(0, frameRect.size.height-50, frameRect.size.width, 50);

    currAlarmRect = CGRectMake(-Spacing, 0, frameRect.size.width+(Spacing*2), frameRect.size.height);
    prevAlarmRect = CGRectOffset(currAlarmRect, -frameRect.size.width-Spacing, 0);
    asideOffset = frameRect.size.width+Spacing;

    selectAlarmView = [[SelectAlarmView alloc] initWithFrame:selectAlarmRect delegate:self];
    musicPlayer = [[MusicPlayer alloc] init];
    [musicPlayer addTargetForSampling:self selector:@selector(songPlayingTick:)];
    settingsView = [[SettingsView alloc] initWithFrame:CGRectOffset(frameRect, 0, -frameRect.origin.y)];
    
    [self.view addSubview:settingsView];
    [self.view addSubview:selectAlarmView];
    // init the alams that were stored
    NSArray *userAlarms = [pListModel getAlarms];
    if ([userAlarms count]>0) {
        for (NSDictionary *alarmInfo in userAlarms) {
            [selectAlarmView addAlarmAnimated:NO];
            [self addAlarmWithInfo:alarmInfo switchTo:NO];
        }
        [self switchAlarmWithIndex:currAlarmIndex];
    } else {
        // add first alarm
        [selectAlarmView addAlarmAnimated:NO];
        [self addAlarmWithInfo:nil switchTo:NO];
        [self switchAlarmWithIndex:currAlarmIndex];
    }
    
    [self beginTick];
}

- (void) beginTick {
    tickTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(updateAlarmViews:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:tickTimer forMode:NSDefaultRunLoopMode];
}
- (void) pauseTick {
    [tickTimer invalidate];
}

- (void) saveAlarms {
    // save alarms
    NSLog(@"saving alarms...");
    NSMutableArray *alarmsData = [[NSMutableArray alloc] init];
    for (AlarmView *alarm in alarms)
        [alarmsData addObject:[NSDictionary dictionaryWithDictionary:alarm.alarmInfo]];
    
    [pListModel saveAlarms:alarmsData];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:currAlarmIndex] forKey:@"currAlarmIndex"];
}

- (void) updateAlarmViews:(NSTimer *)timer {
    for (AlarmView *alarmView in alarms) {
        [alarmView updateProperties];
    }
}

- (void) scheduleLocalNotifications {
    for (AlarmView *alarmView in alarms) {
        NSDictionary *alarmInfo = [alarmView alarmInfo];
        if ([(NSNumber *)[alarmInfo objectForKey:@"isSet"] boolValue]) {
            UILocalNotification *notif = [[UILocalNotification alloc] init];
            NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      [NSNumber numberWithInt:alarmView.index], @"alarmIndex", nil];
            notif.fireDate = [alarmInfo objectForKey:@"date"];
            // notif.soundName = ;
            notif.alertBody = @"Alarm Triggered";
            notif.userInfo = userInfo;
            [[UIApplication sharedApplication] scheduleLocalNotification:notif];
        }
    }
}

- (void) addAlarmWithInfo:(NSDictionary *)alarmInfo switchTo:(BOOL)switchToAlarm {    
    currAlarmIndex = [alarms count];
    AlarmView *newAlarm = [[AlarmView alloc] initWithFrame:prevAlarmRect index:currAlarmIndex delegate:self alarmInfo:alarmInfo];
    [alarms addObject:newAlarm];
    [self.view insertSubview:newAlarm atIndex:1];
    [self updateGradients];
    if (switchToAlarm)
        [self switchAlarmWithIndex:currAlarmIndex];
    [newAlarm viewWillAppear];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// used when deleting an alarm
-(void) updateAlarmIndexes {
    for (int i=[alarms count]-1; i>=0; i--)
        [[alarms objectAtIndex:i] setIndex:i];
}

- (void) updateGradients {
    return;
    /*
    for (AlarmView *alarmView in alarms) {
        float percent = Spacing/alarmView.frame.size.width;
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        NSArray *gradientColors;
        if (alarmView.index == 0 )
            gradientColors = [NSArray arrayWithObjects:
                               (id)[[UIColor clearColor] CGColor],
                               //(id)[[UIColor colorWithWhite:1 alpha:.1] CGColor],
                               (id)[[UIColor blackColor] CGColor],
                               (id)[[UIColor blackColor] CGColor],
                               //(id)[[UIColor colorWithWhite:1 alpha:.1] CGColor],
                               (id)[[UIColor clearColor] CGColor], nil];
        else
            gradientColors = [NSArray arrayWithObjects:
                              (id)[[UIColor clearColor] CGColor],
                              //(id)[[UIColor colorWithWhite:1 alpha:.1] CGColor],
                              (id)[[UIColor blackColor] CGColor],
                              (id)[[UIColor blackColor] CGColor],
                              //(id)[[UIColor colorWithWhite:1 alpha:1] CGColor],
                              (id)[[UIColor blackColor] CGColor], nil];
        
        NSArray *gradientLocations = [NSArray arrayWithObjects:
                                      [NSNumber numberWithFloat:0.0f],
                                      //[NSNumber numberWithFloat:percent*.2],
                                      [NSNumber numberWithFloat:percent],
                                      [NSNumber numberWithFloat:1-percent],
                                      //[NSNumber numberWithFloat:1-(.2*percent)],
                                      [NSNumber numberWithFloat:1.0f], nil];
        
        [gradient setColors:gradientColors];
        [gradient setLocations:gradientLocations];
        [gradient setFrame:CGRectMake(0, 0, currAlarmRect.size.width, currAlarmRect.size.height)];
        [gradient setStartPoint:CGPointMake(0, .5)];
        [gradient setEndPoint:CGPointMake(1, .5)];
        [alarmView.layer setMask:gradient];
        [alarmView.layer setMasksToBounds:YES];
    }*/
}

#pragma mark - Touches
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (currAlarmIndex < [alarms count])
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self.view];
    CGPoint prevLoc = [touch previousLocationInView:self.view];
    CGSize velocity = CGSizeMake(loc.x-prevLoc.x, loc.y-prevLoc.y);
    
    if (velocity.width < -10)
        [self switchAlarmWithIndex:[alarms count]-1];
}

#pragma mark - Positioning & SelectAlarmViewDelegate
- (void) switchAlarmWithIndex:(int)index {
    
    shouldSwitch = SwitchAlarmNone;
        
    if (index < 0 || index > [alarms count])
        index = currAlarmIndex;
    
    float currOffset;
    if (currAlarmIndex < [alarms count]) {
        AlarmView *currAlarm = [alarms objectAtIndex:currAlarmIndex];
        currOffset = currAlarm.frame.origin.x + Spacing;
    } else {
        currOffset = 0;
    }
    
    float screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;

    float animOffset = (index-currAlarmIndex)*(asideOffset) - currOffset;
    
    for (AlarmView *alarmView in alarms) {
        CGRect newAlarmRect = CGRectOffset(currAlarmRect, ((currAlarmIndex - alarmView.index)*(asideOffset) + currOffset) , 0);
        CGRect animateToRect = CGRectOffset(newAlarmRect, animOffset, 0);
        
        [alarmView setFrame:newAlarmRect];
        [alarmView setNewRect:animateToRect];
        
        [alarmView shiftedFromActiveByPercent:(newAlarmRect.origin.x+Spacing)/screenWidth];

    }
    
    currAlarmIndex = index;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:currAlarmIndex] forKey:@"currAlarmIndex"];
    
    if (index < [alarms count])
        [selectAlarmView makeAlarmActiveAtIndex:currAlarmIndex];
    
    [self animateAlarmsToNewRect];
    [self saveAlarms];
}

- (void) animateAlarmsToNewRect {
    float screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    
    CGRect footerRect;
    if (currAlarmIndex == [alarms count]) {
        footerRect = CGRectMake([(AlarmView *)[alarms objectAtIndex:[alarms count]-1] newRect].origin.x, 
                               selectAlarmView.frame.origin.y,
                               selectAlarmView.frame.size.width,
                               selectAlarmView.frame.size.height);
    } else {
        footerRect = CGRectMake(0, 
                               selectAlarmView.frame.origin.y,
                               selectAlarmView.frame.size.width,
                               selectAlarmView.frame.size.height);
    }
    [UIView animateWithDuration:.15 animations:^{
        [selectAlarmView setFrame:footerRect];
        for (AlarmView *alarmView in alarms) {
            [alarmView setFrame:alarmView.newRect];
            [alarmView shiftedFromActiveByPercent:(alarmView.newRect.origin.x+Spacing)/screenWidth];
        }
    }];
}

#pragma mark - AlarmViewDelegate
-(PListModel *)getPListModel {
    return pListModel;
}
-(MusicPlayer *)getMusicPlayer {
    return musicPlayer;
}

- (void) alarmView:(AlarmView *)alarmView draggedWithXVel:(float)xVel {   
    if (![alarmView canMove])
        return;
    
    int alarmIndex = alarmView.index;
    
    if (fabsf(xVel) > 15) {
        if (xVel < 0)
            shouldSwitch = SwitchAlarmNext;
        else 
            shouldSwitch = SwitchAlarmPrev;
    } else if ((xVel < 0 && shouldSwitch == SwitchAlarmPrev) || (xVel > 0 && shouldSwitch == SwitchAlarmNext)) {
            shouldSwitch = SwitchAlarmNone;
    }

    CGRect alarmRect = CGRectOffset(alarmView.frame, xVel, 0);
    // reduce vel if on edges
    if ((alarmRect.origin.x > 0 && currAlarmIndex==-1) 
        || (alarmRect.origin.x < 0 && currAlarmIndex == 0))
        alarmRect = CGRectOffset(alarmRect, -xVel*4/5, 0);
    
    CGRect leftAlarmRect = CGRectOffset(alarmRect, -asideOffset, 0);
    CGRect rightAlarmRect = CGRectOffset(alarmRect, asideOffset, 0);
    
    float screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    
    if (alarmIndex > 0) {
        [[alarms objectAtIndex:alarmIndex-1] setFrame:rightAlarmRect];
        [[alarms objectAtIndex:alarmIndex-1] shiftedFromActiveByPercent:(rightAlarmRect.origin.x+Spacing)/screenWidth];
    } 
    if (alarmIndex < [alarms count]-1) {
        [[alarms objectAtIndex:alarmIndex+1] setFrame:leftAlarmRect];
        [[alarms objectAtIndex:alarmIndex+1] shiftedFromActiveByPercent:(leftAlarmRect.origin.x+Spacing)/screenWidth];
    }
    
    // make selectalarmview float off with alarm
    float xOrigin = 0;
    if (alarmView.index == [alarms count]-1 && alarmRect.origin.x > 0) {
        xOrigin = alarmRect.origin.x;
    }
    
    CGRect footerRect = CGRectMake(xOrigin, 
                                   selectAlarmView.frame.origin.y,
                                   selectAlarmView.frame.size.width,
                                   selectAlarmView.frame.size.height);
    [selectAlarmView setFrame:footerRect];
    
    
    [alarmView setFrame:alarmRect];
    [alarmView shiftedFromActiveByPercent:(alarmRect.origin.x+Spacing)/screenWidth];
}

- (void) alarmView:(AlarmView *)alarmView stoppedDraggingWithX:(float)x {

    int alarmIndex = alarmView.index;
    
    if (fabsf(x) > currAlarmRect.size.width / 2) {
        if (x < 0)
            [self switchAlarmWithIndex:alarmIndex-1];
        else
            [self switchAlarmWithIndex:alarmIndex+1];
    } else if (shouldSwitch != SwitchAlarmNone) {
        [self switchAlarmWithIndex:alarmIndex + shouldSwitch];
    } else {
        [self switchAlarmWithIndex:currAlarmIndex];
    }
}

-(void) durationViewWithIndex:(int)index draggedWithPercent:(float)percent {
    [selectAlarmView makeAlarmSetAtIndex:index percent:percent];
}

- (void) alarmViewOpeningMenuWithPercent:(float)percent {
    [selectAlarmView setAlpha:1-percent];
}
- (void) alarmViewClosingMenuWithPercent:(float)percent {
    [selectAlarmView setAlpha:percent];
}
-(bool)alarmViewPinched:(AlarmView *)alarmView {
    if ([alarms count] < 2)
        return false;
    
    [alarms removeObject:alarmView];
    [selectAlarmView deleteAlarm:alarmView.index];
    [self updateAlarmIndexes];
    
    [UIView animateWithDuration:.15 animations:^{
        [alarmView setAlpha:0];
    } completion:^(BOOL finished) {
        [alarmView removeFromSuperview];
    }];
    [self updateGradients];
    [self saveAlarms];
    return true;
}
-(void)alarmViewUpdated {
    [self saveAlarms];
}

-(void)alarmCountdownEnded:(AlarmView *)alarmView {
    [self switchAlarmWithIndex:alarmView.index];
    [musicPlayer playSongWithID:[alarmView.alarmInfo objectForKey:@"songID"] vibrate:YES];
}

-(void)songPlayingTick:(NSTimer *)timer {
    for (AlarmView *alarm in alarms)
        [alarm.selectSongView songPlayingTick:musicPlayer];
}

#pragma mark - SelectAlarmViewDelegate
- (void) alarmAdded {
    //TFLog(@"delegate alarm added");
    [selectAlarmView addAlarmAnimated:YES];
    //TFLog(@"animated alarm add succesful");
    [self addAlarmWithInfo:nil switchTo:YES];
    //TFLog(@"added alarm with info");
}

@end

/*
 UIImage* first = [UIImage imageNamed:@"Oceanside"];
 UIImage* second = [UIImage imageNamed:@"NightSky"];
 CGSize sizeToSet;
 int mergeArea = 200;
 sizeToSet.width = first.size.width + second.size.width - mergeArea;
 sizeToSet.height = first.size.height;
 
 UIGraphicsBeginImageContext(sizeToSet);
 
 [first drawAtPoint:CGPointMake(0, 0)];
 [second drawAtPoint:CGPointMake(first.size.width - mergeArea, 0) blendMode:kCGBlendModeXOR alpha:1.0f];
 
 UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
 [imageView setCenter:self.view.center];
 [imageView setImage:UIGraphicsGetImageFromCurrentImageContext()];
 
 UIGraphicsEndImageContext();
 
 [[self view]addSubview:imageView];
 */
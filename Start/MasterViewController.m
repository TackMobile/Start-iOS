//
//  ViewController.m
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController ()
@end

@implementation MasterViewController
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

    currAlarmRect = CGRectMake(0, 0, frameRect.size.width, frameRect.size.height);
    prevAlarmRect = CGRectOffset(currAlarmRect, -frameRect.size.width, 0);
    nextAlarmRect = CGRectOffset(currAlarmRect, frameRect.size.width, 0);

    selectAlarmView = [[SelectAlarmView alloc] initWithFrame:selectAlarmRect delegate:self];
    
    [self.view addSubview:selectAlarmView];

    // init the alams that were stored
    NSArray *userAlarms = [pListModel getAlarms];
    if ([userAlarms count]>0) {
        for (NSDictionary *alarmInfo in userAlarms) {
            [selectAlarmView addAlarmAnimated:NO];
            [self addAlarmWithInfo:alarmInfo switchTo:NO];
        }
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
}

- (void) updateAlarmViews:(NSTimer *)timer {
    for (AlarmView *alarmView in alarms) {
        [alarmView updateProperties];
    }
}

- (void) scheduleLocalNotifications {
    /*for (AlarmView *alarmView in alarms) {
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
    }*/
}

- (void) addAlarmWithInfo:(NSDictionary *)alarmInfo switchTo:(BOOL)switchToAlarm {    
    currAlarmIndex = [alarms count];
    AlarmView *newAlarm = [[AlarmView alloc] initWithFrame:prevAlarmRect index:currAlarmIndex delegate:self alarmInfo:alarmInfo];
    [alarms addObject:newAlarm];
    [self.view insertSubview:newAlarm atIndex:0];
    if (switchToAlarm)
        [self switchAlarmWithIndex:currAlarmIndex];
    [newAlarm viewWillAppear];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Positioning & SelectAlarmViewDelegate
- (void) switchAlarmWithIndex:(int)index {
    shouldSwitch = SwitchAlarmNone;
        
    if (index < 0 || index >= [alarms count])
        index = currAlarmIndex;
    
    AlarmView *currAlarm = [alarms objectAtIndex:currAlarmIndex];
    float currOffset = currAlarm.frame.origin.x;
    float animOffset = (index-currAlarmIndex)*currAlarmRect.size.width - currOffset;
    
    float screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    
    for (AlarmView *alarmView in alarms) {
        CGRect newAlarmRect = CGRectOffset(currAlarmRect, (currAlarmIndex - alarmView.index)*currAlarmRect.size.width + currOffset, 0);
        CGRect animateToRect = CGRectOffset(newAlarmRect, animOffset, 0);
        
        [alarmView setFrame:newAlarmRect];
        [alarmView setNewRect:animateToRect];
        
        [alarmView shiftedFromActiveByPercent:newAlarmRect.origin.x/screenWidth];

    }
    
    currAlarmIndex = index;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:currAlarmIndex] forKey:@"currAlarmIndex"];
    [selectAlarmView makeAlarmActiveAtIndex:currAlarmIndex];
    
    [self animateAlarmsToNewRect];
}

- (void) animateAlarmsToNewRect {
    float screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    [UIView animateWithDuration:.2 animations:^{
        for (AlarmView *alarmView in alarms) {
            [alarmView setFrame:alarmView.newRect];
            [alarmView shiftedFromActiveByPercent:alarmView.newRect.origin.x/screenWidth];
        }
    }];
}

#pragma mark - AlarmViewDelegate
-(PListModel *)getPListModel {
    return pListModel;
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
    if ((alarmRect.origin.x > 0 && currAlarmIndex==[alarms count]-1) 
        || (alarmRect.origin.x < 0 && currAlarmIndex == 0))
        alarmRect = CGRectOffset(alarmRect, -xVel*4/5, 0);
    
    CGRect leftAlarmRect = CGRectOffset(alarmRect, -alarmRect.size.width, 0);
    CGRect rightAlarmRect = CGRectOffset(alarmRect, alarmRect.size.width, 0);
    
    float screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    
    if (alarmIndex > 0) {
        [[alarms objectAtIndex:alarmIndex-1] setFrame:rightAlarmRect];
        [[alarms objectAtIndex:alarmIndex-1] shiftedFromActiveByPercent:rightAlarmRect.origin.x/screenWidth];
    } 
    if (alarmIndex < [alarms count]-1) {
        [[alarms objectAtIndex:alarmIndex+1] setFrame:leftAlarmRect];
        [[alarms objectAtIndex:alarmIndex+1] shiftedFromActiveByPercent:leftAlarmRect.origin.x/screenWidth];
    }
    
    [alarmView setFrame:alarmRect];
    [alarmView shiftedFromActiveByPercent:alarmRect.origin.x/screenWidth];
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


#pragma mark - SelectAlarmViewDelegate
- (void) alarmAdded {
    [selectAlarmView addAlarmAnimated:YES];
    [self addAlarmWithInfo:nil switchTo:YES];
}

@end
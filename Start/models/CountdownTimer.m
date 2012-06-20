//
//  CountdownTimer.m
//  Start
//
//  Created by Nick Place on 5/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CountdownTimer.h"

@implementation CountdownTimer
@synthesize delegate = _delegate;

- (id) initWithDate:(NSDate *)date delegate:(id<CountdownTimerDelegate>)delegate {
    if ((self = [super init]) != nil) {
        if (delegate != nil)
            self.delegate = delegate;
        if (date != nil)
            return [self setDate:date];
    }
    return self;
}

- (id) initWithDelegate:(id<CountdownTimerDelegate>)delegate {
    if ((self = [super init]) != nil) {
        if (delegate != nil)
            self.delegate = delegate;
    }
    return self;
}

- (id) setDate:(NSDate *)date {
    if (date == nil)
        return nil;
    else {
        // save the date
        finishDate = date;
        
        /* set a new notification
        if (finishNotification.fireDate != finishDate) {
            // remove previoius notification
            for ( UILocalNotification *notif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
                [[UIApplication sharedApplication] cancelLocalNotification:notif];
            }
            
            // set the new notification
            UILocalNotification *newAlarmNotification = [[UILocalNotification alloc] init];
            newAlarmNotification.fireDate = finishDate;
            newAlarmNotification.soundName = @"alarm.wav";
            newAlarmNotification.alertBody = @"Alarm!";
            // userInfo to show that we can pass custom events, for alarms/ids etc
            newAlarmNotification.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"Wake Up", @"wakeButton", nil];
            finishNotification = newAlarmNotification;
            [[UIApplication sharedApplication] scheduleLocalNotification:finishNotification];
        }*/
        
        // begin the ticker
        tickTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(countdownTick:) userInfo:nil repeats:YES];
    }
    return self;
}

- (id)cancel {
    finishDate = nil;
    [tickTimer invalidate];
    for ( UILocalNotification *notif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        [[UIApplication sharedApplication] cancelLocalNotification:notif];
    }
    return self;
}

- (void) countdownTick:(NSTimer *)theTimer {
    if (finishDate == nil)
        return [tickTimer invalidate];
    
    NSTimeInterval secondsRemaining = [finishDate timeIntervalSinceDate:[NSDate date]];
    
    // call delegate tick
    if ([self.delegate respondsToSelector:@selector(countdown:tickWithDate:)])
        [self.delegate countdown:self tickWithDate:finishDate];
    
    if (secondsRemaining <= 0) {
        finishDate = nil;
        [tickTimer invalidate];
        
        // call delegate countdown ended
        if ([self.delegate respondsToSelector:@selector(countdownEnded:)])
            [self.delegate countdownEnded:self];
    }
}

- (bool) isTicking {
    return [tickTimer isValid];
}




@end

//
//  CountdownTimer.h
//  Start
//
//  Created by Nick Place on 5/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CountdownTimerDelegate <NSObject>
- (void) countdown:(id)countdown tickWithDate:(NSDate *)date;
- (void) countdownEnded:(id)countdown;
@end;

@interface CountdownTimer : NSObject {
    NSDate *finishDate;
    UILocalNotification *finishNotification;
    NSTimer *tickTimer;
}

@property (nonatomic, strong) id<CountdownTimerDelegate> delegate;

- (id) initWithDate:(NSDate *)date delegate:(id<CountdownTimerDelegate>)delegate;
- (id) initWithDelegate:(id<CountdownTimerDelegate>)delegate;

- (id) setDate:(NSDate *)date;
- (id) cancel;
- (bool) isTicking;

@end

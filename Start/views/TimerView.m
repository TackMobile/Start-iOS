//
//  TimerView.m
//  Start
//
//  Created by Nick Place on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TimerView.h"

@implementation TimerView
@synthesize timerLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect labelRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        
        timerLabel = [[UILabel alloc] initWithFrame:labelRect];
        
        [self addSubview:timerLabel];
        
        UIFont *timerFont = [UIFont fontWithName:@"Roboto-Thin" size:80];
        [timerLabel setTextAlignment:UITextAlignmentCenter];
        [timerLabel setTextColor:[UIColor whiteColor]];
        [timerLabel setBackgroundColor:[UIColor clearColor]];
        [timerLabel setFont:timerFont];
        
    }
    return self;
}

- (void) updateWithDate:(NSDate *)newDate {
    //update the timer label
    int secRemaining = (int)floor([[NSDate date] timeIntervalSinceDate:newDate] + .5);
    int hours = secRemaining / 3600;
    int minutes = secRemaining / 60 - hours * 60;
    int seconds = secRemaining - minutes * 60 - hours * 3600;
    
    [timerLabel setText:[NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds]];
}

@end

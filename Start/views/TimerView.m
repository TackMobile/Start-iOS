//
//  TimerView.m
//  Start
//
//  Created by Nick Place on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TimerView.h"
#import "Constants.h"

@interface TimerView()

@property (nonatomic, strong) UILabel *timerLabel;

@end

@implementation TimerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect labelRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        
        _timerLabel = [[UILabel alloc] initWithFrame:labelRect];
        
        [self addSubview:_timerLabel];
        
        UIFont *timerFont = [UIFont fontWithName:StartFontName.robotoThin size:80];
        [_timerLabel setTextAlignment:NSTextAlignmentCenter];
        [_timerLabel setTextColor:[UIColor whiteColor]];
        [_timerLabel setBackgroundColor:[UIColor clearColor]];
        [_timerLabel setFont:timerFont];
        
        [_timerLabel setText:@"00:00:00"];
    }
    return self;
}

- (void) updateWithDate:(NSDate *)newDate {
    //update the timer label
    int secRemaining = (int)floor([[NSDate date] timeIntervalSinceDate:newDate] + .5);
    int hours = secRemaining / 3600;
    int minutes = secRemaining / 60 - hours * 60;
    int seconds = secRemaining - minutes * 60 - hours * 3600;
    
    self.timerLabel.text = [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds];
}

@end

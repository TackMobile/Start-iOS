//
//  CountdownView.m
//  Start
//
//  Created by Nick Place on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CountdownView.h"

@implementation CountdownView
@synthesize countdownLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect labelRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        
        countdownLabel = [[UILabel alloc] initWithFrame:labelRect];
                
        [self addSubview:countdownLabel];
        
        UIFont *countdownFont = [UIFont fontWithName:@"Roboto-Thin" size:80];
        //[countdownLabel setTextAlignment:NSTextAlignmentCenter];
        [countdownLabel setTextAlignment:NSTextAlignmentCenter];
        [countdownLabel setTextColor:[UIColor whiteColor]];
        [countdownLabel setBackgroundColor:[UIColor clearColor]];
        [countdownLabel setFont:countdownFont];
        
        shouldFlash = NO;
        
        // testing
        [countdownLabel setText:@"00:00:00"];
     }
    return self;
}

- (void) updateWithDate:(NSDate *)newDate {
    //update the countdown label
    int secRemaining = (int)floor([newDate timeIntervalSinceDate:[NSDate date]] + .5);
    
    if (secRemaining <= 0) {
        secRemaining = 0;
        if (!shouldFlash) {
            shouldFlash = YES;
            [self startFlashing];
        }
    } else
        shouldFlash = NO;
    
    int hours = secRemaining / 3600;
    int minutes = secRemaining / 60 - hours * 60;
    int seconds = secRemaining - minutes * 60 - hours * 3600;
    
    [countdownLabel setText:[NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds]];
}

- (void) startFlashing {
    [UIView animateWithDuration:.25 delay:.6 options:0 animations:^{
        [countdownLabel setAlpha:0];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.05 delay:.1 options:0 animations:^{
            [countdownLabel setAlpha:1];
        } completion:^(BOOL finished) {
            if (shouldFlash)
                [self startFlashing];
        }];
       
    }];
}

@end

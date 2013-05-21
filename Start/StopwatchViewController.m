//
//  StopwatchViewController.m
//  Start
//
//  Created by Nick Place on 12/18/12.
//
//

#import "StopwatchViewController.h"

@interface StopwatchViewController ()

@end

@implementation StopwatchViewController
@synthesize timerLabel, pausedLabel, timerView;

- (id)init
{
    self = [super init];
    if (self) {
        timerLabel = [[UILabel alloc] init];
        pausedLabel = [[UILabel alloc] init];
        
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    CGRect timerLabelRect = CGRectMake(0, 100, self.view.frame.size.width, 100);
    CGRect pauseLabelRect = CGRectMake(0, 200, self.view.frame.size.width, 70);

    timerLabel.frame = timerLabelRect;
        
    UIFont *timerFont = [UIFont fontWithName:@"Roboto-Thin" size:80];
    [timerLabel setTextAlignment:NSTextAlignmentCenter];
    [timerLabel setTextColor:[UIColor whiteColor]];
    [timerLabel setBackgroundColor:[UIColor clearColor]];
    [timerLabel setFont:timerFont];
    
    [timerLabel setText:@"00:00:00"];
    
    // paused label
    pausedLabel.frame = pauseLabelRect;
    UIFont *pauseFont = [UIFont fontWithName:@"Roboto-Thin" size:25];
    [pausedLabel setTextAlignment:NSTextAlignmentCenter];
    [pausedLabel setTextColor:[UIColor whiteColor]];
    [pausedLabel setBackgroundColor:[UIColor clearColor]];
    [pausedLabel setFont:pauseFont];
    pausedLabel.alpha = 0;
    pausedLabel.numberOfLines = 0;
    [pausedLabel setText:@"Paused.\nTap again to reset"];
    
    // add them
    [self.view addSubview:pausedLabel];
    [self.view addSubview:timerLabel];
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

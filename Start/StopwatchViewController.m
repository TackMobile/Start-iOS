//
//  StopwatchViewController.m
//  Start
//
//  Created by Nick Place on 12/18/12.
//
//

#import "StopwatchViewController.h"
#import "LocalizedStrings.h"
#import "Constants.h"

@interface StopwatchViewController ()

@property (strong, nonatomic) TimerView *timerView;
@property (nonatomic, strong) UILabel *pausedLabel;
@property (nonatomic, strong) UILabel *timerLabel;

@end

@implementation StopwatchViewController

- (id)init
{
    self = [super init];
    if (self) {
        _timerLabel = [[UILabel alloc] init];
        _pausedLabel = [[UILabel alloc] init];
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    CGRect timerLabelRect = CGRectMake(0, 100, self.view.frame.size.width, 100);
    CGRect pauseLabelRect = CGRectMake(0, 200, self.view.frame.size.width, 70);

    self.timerLabel.frame = timerLabelRect;
        
    UIFont *timerFont = [UIFont fontWithName:StartFontName.robotoThin size:80];
    [self.timerLabel setTextAlignment:NSTextAlignmentCenter];
    [self.timerLabel setTextColor:[UIColor whiteColor]];
    [self.timerLabel setBackgroundColor:[UIColor clearColor]];
    [self.timerLabel setFont:timerFont];
    
    [self.timerLabel setText:@"00:00:00"];
    
    // paused label
    self.pausedLabel.frame = pauseLabelRect;
    UIFont *pauseFont = [UIFont fontWithName:StartFontName.robotoThin size:25];
    [self.pausedLabel setTextAlignment:NSTextAlignmentCenter];
    [self.pausedLabel setTextColor:[UIColor whiteColor]];
    [self.pausedLabel setBackgroundColor:[UIColor clearColor]];
    [self.pausedLabel setFont:pauseFont];
    self.pausedLabel.alpha = 0;
    self.pausedLabel.numberOfLines = 0;
    self.pausedLabel.text = [LocalizedStrings timerPaused];
    
    // add them
    [self.view addSubview:_pausedLabel];
    [self.view addSubview:_timerLabel];
}

- (void) updateWithDate:(NSDate *)newDate {
    //update the timer label
    int secRemaining = (int)floor([[NSDate date] timeIntervalSinceDate:newDate] + .5);
    int hours = secRemaining / 3600;
    int minutes = secRemaining / 60 - hours * 60;
    int seconds = secRemaining - minutes * 60 - hours * 3600;
    
    [self.timerLabel setText:[NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds]];
}

@end

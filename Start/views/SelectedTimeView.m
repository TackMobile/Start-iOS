//
//  SelectedTimeView.m
//  Start
//
//  Created by Nick Place on 6/18/12.
//  Copyright (c) 2012 TackMobile. All rights reserved.
//

#import "SelectedTimeView.h"

@implementation SelectedTimeView
@synthesize editingPart, date, editingPartIndicator;
@synthesize timeLabel, meridiemLabel,snoozeLabel, timerModeLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:NO];
        date = [[NSDate alloc] init];
        
        // Views
        UIFont *timeLabelFont = [UIFont fontWithName:@"Roboto-Thin" size:50];
        UIFont *mdLabelFont = [UIFont fontWithName:@"Roboto-Thin" size:26];
        UIFont *snoozeLabelFont = [UIFont fontWithName:@"Roboto-This" size:35];
        
        toast = [[UILabel alloc] initWithFrame:(CGRect){(CGPoint){0,10}, {self.frame.size.width, 50}}];
        timeLabel = [[UILabel alloc] init];
        meridiemLabel = [[UILabel alloc] init];
        snoozeLabel = [[UILabel alloc] init];
        editingPartIndicator = [[UIView alloc] init];
        
        [timeLabel setTextAlignment:NSTextAlignmentCenter];
        [timeLabel setTextColor:[UIColor whiteColor]];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [timeLabel setFont:timeLabelFont];
        
        [timerModeLabel setTextAlignment:NSTextAlignmentCenter];
        [timerModeLabel setTextColor:[UIColor whiteColor]];
        [timerModeLabel setBackgroundColor:[UIColor clearColor]];
        [timerModeLabel setFont:timeLabelFont];
        
        [meridiemLabel setTextAlignment:NSTextAlignmentCenter];
        [meridiemLabel setTextColor:[UIColor whiteColor]];
        [meridiemLabel setBackgroundColor:[UIColor clearColor]];
        [meridiemLabel setFont:mdLabelFont];
        
        [snoozeLabel setTextAlignment:NSTextAlignmentCenter];
        [snoozeLabel setTextColor:[UIColor whiteColor]];
        [snoozeLabel setBackgroundColor:[UIColor clearColor]];
        [snoozeLabel setLineBreakMode:NSLineBreakByCharWrapping];
        snoozeLabel.numberOfLines = 0;
        [snoozeLabel setAlpha:0];
        [snoozeLabel setText:@"TAP TO SNOOZE"];
        [snoozeLabel setFont:snoozeLabelFont];
        
        [toast setText:@""];
        
        [toast setAlpha:0];
        [toast setBackgroundColor:[UIColor clearColor]];
        [toast setTextColor:[UIColor whiteColor]];
        
        [editingPartIndicator setBackgroundColor:[UIColor whiteColor]];
        [toast setTextAlignment:NSTextAlignmentCenter];
        
        [self addSubview:timeLabel];
        [self addSubview:meridiemLabel];
        [self addSubview:snoozeLabel];
        [self addSubview:editingPartIndicator];
        [self addSubview:toast];
        
        [self layoutSubviews];
        // TESTING
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGSize timeLabelSize = [[timeLabel text] sizeWithFont:[timeLabel font]];
    CGSize mdLabelSize = [[meridiemLabel text] sizeWithFont:[meridiemLabel font]];
    CGSize snoozeLabelSize = [[snoozeLabel text] sizeWithFont:[snoozeLabel font] constrainedToSize:CGSizeMake(self.frame.size.width, self.frame.size.height)];
    
    
    CGRect timeLabelRect;
    if (timerMode || mdLabelSize.width == 0.0f) {
        timeLabelRect = CGRectMake((self.frame.size.width - timeLabelSize.width)/2, (self.frame.size.height-timeLabelSize.height)/2, timeLabelSize.width, timeLabelSize.height);

    } else {
        timeLabelRect = CGRectMake((self.frame.size.width - timeLabelSize.width)/2, (self.frame.size.height-timeLabelSize.height)/2 - 5, timeLabelSize.width, timeLabelSize.height);

    }
    CGRect meridiemLabelRect = CGRectMake((self.frame.size.width - mdLabelSize.width)/2, timeLabelRect.origin.y+timeLabelSize.height-3, mdLabelSize.width, mdLabelSize.height);
    CGRect snoozeLabelRect = CGRectMake((self.frame.size.width-snoozeLabelSize.width)/2, (self.frame.size.height - snoozeLabelSize.height)/2, snoozeLabelSize.width, snoozeLabelSize.height);
    
    [timeLabel setFrame:timeLabelRect];
    [meridiemLabel setFrame:meridiemLabelRect];
    [snoozeLabel setFrame:snoozeLabelRect];
}

#pragma mark - Drawing

- (void) showSnooze {
    [snoozeLabel setAlpha:1];
    [timeLabel setAlpha:0];
    [meridiemLabel setAlpha:0];
}

- (void) enterTimerMode {
    timerMode = YES;
    [meridiemLabel removeFromSuperview];
    
    [self setTitleWithText:@"TIMER"];
}
- (void) exitTimerMode {
    timerMode = NO;
    [self addSubview:meridiemLabel];
    
    [self setTitleWithText:@""];
}

- (void) setTitleWithText:(NSString *)text {
    // flash timer message
    [toast setAlpha:0];
    [toast setText:text];

    
    [UIView animateWithDuration:.1 animations:^{
        [toast setAlpha:1];
        [toast setFrame:(CGRect){CGPointZero, toast.frame.size}];
        
    } completion:^(BOOL finished) {

    }];
    
}



//when user drags handle this method is called
- (void) updateDate:(NSDate *)newDate part:(int)partEditing {//when snooze is tapped this method is called    
    [snoozeLabel setAlpha:0];
    [timeLabel setAlpha:1];
    [meridiemLabel setAlpha:1];

    // format & save the date
    date = newDate;

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[dateFormatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[dateFormatter PMSymbol]];
    BOOL is24h = (amRange.location == NSNotFound && pmRange.location == NSNotFound); //detects to see if user setting is on 24hour or not
  
    NSString *hourFormat;
    
    if (!is24h) {
        hourFormat = @"h";
        
        [dateFormatter setDateFormat:@"h:mm"];
        [timeLabel setText:[dateFormatter stringFromDate:date]];
        
        [dateFormatter setDateFormat:@"a"];
        [meridiemLabel setText:[dateFormatter stringFromDate:date]];
    }
    
    if (is24h) {
        hourFormat = @"HH";

        [dateFormatter setDateFormat:@"HH:mm"];
        [timeLabel setText:[dateFormatter stringFromDate:date]];
    }
   
    [self layoutSubviews];
    
    // change the partIndicator
    [dateFormatter setDateFormat:hourFormat];
    CGSize hourSize = [[dateFormatter stringFromDate:date] sizeWithFont:[timeLabel font]];
    CGSize colonSize = [@":" sizeWithFont:[timeLabel font]];
    [dateFormatter setDateFormat:@"mm"];
    CGSize minSize = [[dateFormatter stringFromDate:date] sizeWithFont:[timeLabel font]];
    
    float indicatorXOffset = 0;
    float indicatorWidth = 0;
    switch (partEditing) {
        case SelectedTimeEditingHour:
            indicatorWidth = hourSize.width;
            break;
            
        case SelectedTimeEditingMinute:
            indicatorXOffset = hourSize.width + colonSize.width;
            indicatorWidth = minSize.width;
            
        default:
            break;
    }
    CGRect labelRect = timeLabel.frame;
    CGRect editingPartRect = CGRectMake(labelRect.origin.x + indicatorXOffset, labelRect.origin.y + labelRect.size.height-6, indicatorWidth, 1);
    [editingPartIndicator setFrame:editingPartRect];
}

- (void) updateDuration:(NSTimeInterval)duration part:(int)partEditing  {
    int days = duration / (60 * 60 * 24);
    duration -= days * (60 * 60 * 24);
    int hours = duration / (60 * 60);
    duration -= hours * (60 * 60);
    int minutes = duration / 60;
	
    NSString *durString = [NSString stringWithFormat:@"%02d:%02d", hours, minutes];
    
    [timeLabel setText:durString];
    
    [self layoutSubviews];
    
    // change the partIndicator
    CGSize hourSize = [[NSString stringWithFormat:@"%02d", hours] sizeWithFont:[timeLabel font]];
    CGSize colonSize = [@":" sizeWithFont:[timeLabel font]];
    CGSize minSize = [[NSString stringWithFormat:@"%02d", minutes] sizeWithFont:[timeLabel font]];
    
    float indicatorXOffset = 0;
    float indicatorWidth = 0;
    switch (partEditing) {
        case SelectedTimeEditingHour:
            indicatorWidth = hourSize.width;
            break;
            
        case SelectedTimeEditingMinute:
            indicatorXOffset = hourSize.width + colonSize.width;
            indicatorWidth = minSize.width;
            
        default:
            break;
    }
    CGRect labelRect = timeLabel.frame;
    CGRect editingPartRect = CGRectMake(labelRect.origin.x + indicatorXOffset, labelRect.origin.y + labelRect.size.height-6, indicatorWidth, 1);
    [editingPartIndicator setFrame:editingPartRect];

}



@end

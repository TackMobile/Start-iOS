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
@synthesize timeLabel, meridiemLabel,snoozeLabel;

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
        
        timeLabel = [[UILabel alloc] init];
        meridiemLabel = [[UILabel alloc] init];
        snoozeLabel = [[UILabel alloc] init];
        editingPartIndicator = [[UIView alloc] init];
        
        [timeLabel setTextAlignment:NSTextAlignmentCenter];
        [timeLabel setTextColor:[UIColor whiteColor]];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [timeLabel setFont:timeLabelFont];
        
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
        
        [editingPartIndicator setBackgroundColor:[UIColor whiteColor]];
        
        [self addSubview:timeLabel];
        [self addSubview:meridiemLabel];
        [self addSubview:snoozeLabel];
        [self addSubview:editingPartIndicator];
        
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
    
    CGRect timeLabelRect = CGRectMake((self.frame.size.width - timeLabelSize.width)/2, (self.frame.size.height-timeLabelSize.height)/2 - 5, timeLabelSize.width, timeLabelSize.height);
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

- (void) updateDate:(NSDate *)newDate part:(int)partEditing {//when snooze is tapped this method is called
    [snoozeLabel setAlpha:0]; //make snooze label invisbile
    [timeLabel setAlpha:1]; //make time label visible
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
  
    if (!is24h) {
        [dateFormatter setDateFormat:@"h:mm"];
        [timeLabel setText:[dateFormatter stringFromDate:date]];
        
        [dateFormatter setDateFormat:@"a"];
        [meridiemLabel setText:[dateFormatter stringFromDate:date]];
    }
    
    if (is24h) {
        [dateFormatter setDateFormat:@"HH:mm"];
        [timeLabel setText:[dateFormatter stringFromDate:date]];
    }
   
  
    
   
    
    [self layoutSubviews];
    
    // change the partIndicator
    [dateFormatter setDateFormat:@"h"];
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


@end

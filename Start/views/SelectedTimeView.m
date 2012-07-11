//
//  SelectedTimeView.m
//  Start
//
//  Created by Nick Place on 6/18/12.
//  Copyright (c) 2012 TackMobile. All rights reserved.
//

#import "SelectedTimeView.h"

@implementation SelectedTimeView
@synthesize editingPart, timeInterval, editingPartIndicator;
@synthesize timeLabel, meridiemLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:NO];
        date = [[NSDate alloc] init];
        
        // Views
        UIFont *timeLabelFont = [UIFont fontWithName:@"Roboto-Thin" size:50];
        UIFont *mdLabelFont = [UIFont fontWithName:@"Roboto-Thin" size:26];
        
        timeLabel = [[UILabel alloc] init];
        meridiemLabel = [[UILabel alloc] init];
        editingPartIndicator = [[UIView alloc] init];
        
        [timeLabel setTextAlignment:UITextAlignmentCenter];
        [timeLabel setTextColor:[UIColor whiteColor]];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [timeLabel setFont:timeLabelFont];
        
        [meridiemLabel setTextAlignment:UITextAlignmentCenter];
        [meridiemLabel setTextColor:[UIColor whiteColor]];
        [meridiemLabel setBackgroundColor:[UIColor clearColor]];
        [meridiemLabel setFont:mdLabelFont];
        
        [editingPartIndicator setBackgroundColor:[UIColor whiteColor]];
        
        [self addSubview:timeLabel];
        [self addSubview:meridiemLabel];
        [self addSubview:editingPartIndicator];
        
        [self layoutSubviews];
        // TESTING
    }
    return self;
}

- (void) layoutSubviews {
    CGSize timeLabelSize = [[timeLabel text] sizeWithFont:[timeLabel font]];
    CGSize mdLabelSize = [[meridiemLabel text] sizeWithFont:[meridiemLabel font]];
    
    CGRect timeLabelRect = CGRectMake((self.frame.size.width - timeLabelSize.width)/2, (self.frame.size.height-timeLabelSize.height)/2 - 5, timeLabelSize.width, timeLabelSize.height);
    CGRect meridiemLabelRect = CGRectMake((self.frame.size.width - mdLabelSize.width)/2, timeLabelRect.origin.y+timeLabelSize.height-3, mdLabelSize.width, mdLabelSize.height);
    
    [timeLabel setFrame:timeLabelRect];
    [meridiemLabel setFrame:meridiemLabelRect];
}

#pragma mark - Drawing

- (void) updateTimeInterval:(NSTimeInterval)newTimeInterval part:(int)partEditing {
    // save the interval
    timeInterval = newTimeInterval;
    
    // format the date
   date = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"US/Mountain"]];
    
    // update&position the label
    [dateFormatter setDateFormat:@"h:mm"];
    [timeLabel setText:[dateFormatter stringFromDate:date]];
    
    [dateFormatter setDateFormat:@"a"];
    [meridiemLabel setText:[dateFormatter stringFromDate:date]];
    
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

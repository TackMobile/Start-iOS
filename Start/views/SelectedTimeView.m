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
        CGRect timeLabelRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2);
        CGRect meridiemLabelRect = CGRectMake(0, self.frame.size.width/4, self.frame.size.width, self.frame.size.width/2);
        CGRect editingPartRect = CGRectMake(0, 0, 0, 0);
        
        timeLabel = [[UILabel alloc] initWithFrame:timeLabelRect];
        meridiemLabel = [[UILabel alloc] initWithFrame:meridiemLabelRect];
        editingPartIndicator = [[UIView alloc] initWithFrame:editingPartRect];
        
        [timeLabel setTextAlignment:UITextAlignmentCenter];
        [timeLabel setTextColor:[UIColor whiteColor]];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [meridiemLabel setTextAlignment:UITextAlignmentCenter];
        [meridiemLabel setTextColor:[UIColor whiteColor]];
        [meridiemLabel setBackgroundColor:[UIColor clearColor]];
        [editingPartIndicator setBackgroundColor:[UIColor whiteColor]];
        
        [self addSubview:timeLabel];
        [self addSubview:meridiemLabel];
        [self addSubview:editingPartIndicator];
                
        // TESTING
    }
    return self;
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
    CGSize labelSize = [timeLabel.text sizeWithFont:[timeLabel font]];
    CGRect labelRect = CGRectMake(floorf((self.frame.size.width-labelSize.width)/2), (self.frame.size.height/2-labelSize.height)/2, labelSize.width, labelSize.height);
    timeLabel.frame = labelRect;
    
    [dateFormatter setDateFormat:@"a"];
    [meridiemLabel setText:[dateFormatter stringFromDate:date]];
    
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
    CGRect editingPartRect = CGRectMake(labelRect.origin.x + indicatorXOffset, labelRect.origin.y + labelRect.size.height, indicatorWidth, 3);
    [editingPartIndicator setFrame:editingPartRect];
}


@end

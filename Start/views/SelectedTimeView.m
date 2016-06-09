//
//  SelectedTimeView.m
//  Start
//
//  Created by Nick Place on 6/18/12.
//  Copyright (c) 2012 TackMobile. All rights reserved.
//

#import "SelectedTimeView.h"
#import "Constants.h"
#import "LocalizedStrings.h"

@implementation SelectedTimeView
@synthesize editingPart, date, editingPartIndicator;
@synthesize timeLabel, meridiemLabel,snoozeLabel, timerModeLabel;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setUserInteractionEnabled:NO];
    date = [[NSDate alloc] init];
    
    // Views
    UIFont *timeLabelFont = [UIFont fontWithName:StartFontName.robotoThin size:50];
    UIFont *mdLabelFont = [UIFont fontWithName:StartFontName.robotoThin size:26];
    UIFont *snoozeLabelFont = [UIFont fontWithName:StartFontName.robotoThin size:30];
    UIFont *toastFont = [UIFont fontWithName:StartFontName.robotoThin size:18];
    
    toast = [[UILabel alloc] initWithFrame:(CGRect){(CGPoint){0,0}, {self.frame.size.width, 55}}];
    timeLabel = [UILabel new];
    meridiemLabel = [UILabel new];
    snoozeLabel = [UILabel new];
    timerModeLabel = [UILabel new];
    editingPartIndicator = [UIView new];
    
    NSArray *views = @[ toast, timeLabel, timerModeLabel, meridiemLabel, snoozeLabel, ];
    for (UILabel *label in views) {
      label.textAlignment = NSTextAlignmentCenter;
      label.textColor = [UIColor whiteColor];
      label.backgroundColor = [UIColor clearColor];
    }
    
    [timeLabel setFont:timeLabelFont];
    
    [timerModeLabel setFont:timeLabelFont];
    
    [meridiemLabel setFont:mdLabelFont];
    
    [snoozeLabel setLineBreakMode:NSLineBreakByCharWrapping];
    snoozeLabel.numberOfLines = 0;
    [snoozeLabel setAlpha:0];
    snoozeLabel.text = [LocalizedStrings tapToSnooze];
    [snoozeLabel setFont:snoozeLabelFont];
    
    toast.text = [LocalizedStrings alarm];
    [toast setFont:toastFont];
    
    [editingPartIndicator setBackgroundColor:[UIColor whiteColor]];
    
    [self addSubview:timeLabel];
    [self addSubview:meridiemLabel];
    [self addSubview:snoozeLabel];
    [self addSubview:editingPartIndicator];
    [self addSubview:toast];
    
    [self layoutSubviews];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  CGSize timeLabelSize = [timeLabel.text sizeWithAttributes:@{NSFontAttributeName: timeLabel.font}];
  CGSize mdLabelSize = [meridiemLabel.text sizeWithAttributes:@{NSFontAttributeName: meridiemLabel.font}];
  CGRect rect = [snoozeLabel.text boundingRectWithSize:CGSizeMake(self.frame.size.width, self.frame.size.height)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName: snoozeLabel.font}
                                               context:nil];
  CGSize snoozeLabelSize = rect.size;
  
  CGRect timeLabelRect = CGRectMake((self.frame.size.width - timeLabelSize.width)/2, (self.frame.size.height - timeLabelSize.height)/2, timeLabelSize.width, timeLabelSize.height);
  
  CGRect meridiemLabelRect = CGRectMake((self.frame.size.width - mdLabelSize.width)/2, timeLabelRect.origin.y+timeLabelSize.height-7, mdLabelSize.width, mdLabelSize.height);
  CGRect snoozeLabelRect = CGRectMake((self.frame.size.width-snoozeLabelSize.width)/2, (self.frame.size.height - snoozeLabelSize.height)/2, snoozeLabelSize.width, snoozeLabelSize.height);
  timeLabel.frame = timeLabelRect;
  meridiemLabel.frame = meridiemLabelRect;
  snoozeLabel.frame = snoozeLabelRect;
}

#pragma mark - Drawing

- (void)showSnooze {
  [snoozeLabel setAlpha:1];
  [toast setAlpha:0];
  [timeLabel setAlpha:0];
  [meridiemLabel setAlpha:0];
}

- (void)enterTimerMode {
  timerMode = YES;
  [meridiemLabel removeFromSuperview];
  
  [self setTitleWithText:[LocalizedStrings timer]];
}
- (void)enterAlarmMode {
  timerMode = NO;
  [self addSubview:meridiemLabel];
  
  [self setTitleWithText:[LocalizedStrings alarm]];
}

- (void)setTitleWithText:(NSString *)text {
  // Flash timer message
  [toast setAlpha:0];
  [toast setText:text];
  
  [UIView animateWithDuration:.1 animations:^{
    [toast setAlpha:1];
    [toast setFrame:(CGRect){CGPointZero, toast.frame.size}];
    
  } completion:^(BOOL finished) {
  }];
}

// When user drags handle this method is called
- (void)updateDate:(NSDate *)newDate part:(int)partEditing {
  // When snooze is tapped this method is called
  [snoozeLabel setAlpha:0];
  [toast setAlpha:1];
  [timeLabel setAlpha:1];
  [meridiemLabel setAlpha:1];
  
  // Format & save the date
  date = newDate;
  static NSDateFormatter *dateFormatter = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateStyle = NSDateFormatterNoStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
  });
  NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
  NSRange amRange = [dateString rangeOfString:[dateFormatter AMSymbol]];
  NSRange pmRange = [dateString rangeOfString:[dateFormatter PMSymbol]];
  
  // Detects to see if user setting is on 24hour or not
  BOOL is24h = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
  
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
  
  // Change the partIndicator
  [dateFormatter setDateFormat:hourFormat];
  CGSize hourSize = [[dateFormatter stringFromDate:date] sizeWithAttributes:@{NSFontAttributeName: timeLabel.font}];
  CGSize colonSize = [@":" sizeWithAttributes:@{NSFontAttributeName: timeLabel.font}];
  [dateFormatter setDateFormat:@"mm"];
  CGSize minSize = [[dateFormatter stringFromDate:date] sizeWithAttributes:@{NSFontAttributeName: timeLabel.font}];
  
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

- (void)updateDuration:(NSTimeInterval)duration part:(int)partEditing  {
  int days = duration / (60 * 60 * 24);
  duration -= days * (60 * 60 * 24);
  int hours = duration / (60 * 60);
  duration -= hours * (60 * 60);
  int minutes = duration / 60;
  
  NSString *durString = [NSString stringWithFormat:@"%02d:%02d", hours, minutes];
  
  [timeLabel setText:durString];
  
  [self layoutSubviews];
  
  // Change the partIndicator
  CGSize hourSize = [[NSString stringWithFormat:@"%02d", hours] sizeWithAttributes:@{NSFontAttributeName: timeLabel.font}];
  CGSize colonSize = [@":" sizeWithAttributes:@{NSFontAttributeName: timeLabel.font}];
  CGSize minSize = [[NSString stringWithFormat:@"%02d", minutes] sizeWithAttributes:@{NSFontAttributeName: timeLabel.font}];
  
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

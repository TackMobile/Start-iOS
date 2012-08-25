//
//  SelectedTimeView.h
//  Start
//
//  Created by Nick Place on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

enum SelectedTimeEditingPart {
    SelectedTimeEditingNone = 0,
    SelectedTimeEditingMinute,
    SelectedTimeEditingHour
};

@interface SelectedTimeView : UIView {
    NSDate *date;
}

@property int editingPart;
@property NSTimeInterval timeInterval;

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *meridiemLabel;
@property (nonatomic, strong) UILabel *snoozeLabel;
@property (nonatomic, strong) UIView *editingPartIndicator;

- (void) showSnooze;
- (void) updateTimeInterval:(NSTimeInterval)newTimeInterval part:(int)partEditing;

@end
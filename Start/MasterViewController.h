//
//  ViewController.h
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmView.h"
#import "SelectAlarmView.h"

@interface MasterViewController : UIViewController <SelectAlarmViewDelegate> {
    NSMutableArray *alarms;
    
    CGRect newAlarmRect;
    CGRect currAlarmRect;
    CGRect nextAlarmRect;
}

@property (nonatomic, strong) SelectAlarmView *selectAlarmView;

- (void) alarmAdded;

@end

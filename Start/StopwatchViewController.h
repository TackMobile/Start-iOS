//
//  StopwatchViewController.h
//  Start
//
//  Created by Nick Place on 12/18/12.
//
//

#import <UIKit/UIKit.h>
#import "TimerView.h"

@interface StopwatchViewController : UIViewController {
}

@property (strong, nonatomic)     TimerView *timerView;

@property (nonatomic, strong) UILabel *pausedLabel;
@property (nonatomic, strong) UILabel *timerLabel;

- (void) updateWithDate:(NSDate *)newDate;

@end

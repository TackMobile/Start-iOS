//
//  SelectAlarmView.h
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestFlight.h"

@protocol SelectAlarmViewDelegate <NSObject>
- (void) alarmAdded;
- (void) switchAlarmWithIndex:(int)index;
@end

@interface SelectAlarmView : UIView {
    int numAlarms;
    NSMutableArray *alarmButtons;
    
    float restedY;
}

@property (nonatomic, strong) id<SelectAlarmViewDelegate> delegate;

@property (nonatomic, strong) UIView *alarmContainer;
@property (nonatomic, strong) UIButton *plusButton;

- (void) plusButtonTapped:(id)button;


- (void) deleteAlarm:(int)index;

- (void) makeAlarmActiveAtIndex:(int)index;
- (void) makeAlarmSetAtIndex:(int)index percent:(float)percent;
- (void) addAlarmAnimated:(bool)animated;

- (void) arrangeButtons;

- (id) initWithFrame:(CGRect)frame delegate:(id<SelectAlarmViewDelegate>)aDelegate;
@end

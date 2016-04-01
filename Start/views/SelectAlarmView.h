//
//  SelectAlarmView.h
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectAlarmViewDelegate <NSObject>
- (void) alarmAdded;
- (void) switchAlarmWithIndex:(NSInteger)index;
@end

@interface SelectAlarmView : UIView

@property (nonatomic, strong) id<SelectAlarmViewDelegate> delegate;

- (void) deleteAlarm:(NSInteger)index;
- (void) makeAlarmActiveAtIndex:(NSInteger)index;
- (void) makeAlarmSetAtIndex:(NSInteger)index percent:(float)percent;
- (void) addAlarmAnimated:(bool)animated;
- (id) initWithFrame:(CGRect)frame delegate:(id<SelectAlarmViewDelegate>)aDelegate;
- (void)plusButtonTapped:(id)button;

@end

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
- (void) switchAlarmWithIndex:(int)index;
@end

@interface SelectAlarmView : UIView

@property (nonatomic, strong) id<SelectAlarmViewDelegate> delegate;

- (void) deleteAlarm:(int)index;
- (void) makeAlarmActiveAtIndex:(int)index;
- (void) makeAlarmSetAtIndex:(int)index percent:(float)percent;
- (void) addAlarmAnimated:(bool)animated;
- (id) initWithFrame:(CGRect)frame delegate:(id<SelectAlarmViewDelegate>)aDelegate;

@end

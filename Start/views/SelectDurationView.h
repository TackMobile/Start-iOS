//
//  SelectDurationView.h
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class SelectDurationView;

@protocol SelectDurationViewDelegate <NSObject>
-(void) durationDidChange:(SelectDurationView *)selectDuration;
-(void) durationDidBeginChanging:(SelectDurationView *)selectDuration;
-(void) durationDidEndChanging:(SelectDurationView *)selectDuration;
-(void) durationViewTapped:(SelectDurationView *)selectDuration;

-(void) durationViewDraggedWithYVel:(float)yVel;
-(void) durationViewStoppedDraggingWithY:(float)y;

-(bool) shouldLockPicker;
@end

enum SelectDurationHandleSelected {
    SelectDurationNoHandle = 0,
    SelectDurationOuterHandle,
    SelectDurationInnerHandle,
    SelectDurationCenterHandle
};
enum SelectDurationDraggingOrientation {
    SelectDurationDraggingNone = 0,
    SelectDurationDraggingVert,
    SelectDurationDraggingHoriz,
    SelectDurationDraggingCancel
};

@interface SelectDurationView : UIView {    
    float outerRadius;
    float innerRadius;
    float centerRadius;
    
    float outerStartAngle;
    float innerStartAngle;
    
    float prevOuterAngle;
        
    CGRect originalFrame;
        
    CGPoint center;
    
    bool changing;
    bool isTimerMode;
    
    NSDate *_date;
}
@property int handleSelected;
@property int draggingOrientation;
@property (nonatomic, strong) NSDictionary *theme;

@property float outerAngle;
@property float innerAngle;

@property (strong, nonatomic) id<SelectDurationViewDelegate> delegate;

-(void) updateTheme:(NSDictionary *)newTheme;
//-(void) setTimeInterval:(NSTimeInterval)timeInterval;
-(void) setDate:(NSDate *)date;
-(NSDate *) getDate;
-(void)updateTimerTick:(NSTimer *)timer;
-(void)update;
- (void) setTimerMode:(BOOL)on;
-(id) initWithFrame:(CGRect)frame delegate:(id<SelectDurationViewDelegate>)aDelegate;

@end

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
-(void) durationViewCoreTapped:(SelectDurationView *)selectDuration;

-(void) durationViewDraggedWithYVel:(float)yVel;
-(void) durationViewStoppedDraggingWithY:(float)y;

-(bool) shouldLockPicker;
-(NSDate *)getDateBegan;
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
    
    float origOuterRadius;
    float origInnerRadius;

    float outerStartAngle;
    float innerStartAngle;
    
    float prevOuterAngle;
        
    CGRect originalFrame;
        
    CGPoint center;
    
    bool changing;
    bool isStopwatchMode;
    bool isTimerMode;
    bool isTiming;
    
    NSDate *_date;
    NSDate *_timerBeganDate;
    NSTimeInterval timerDuration;
    
    // LAYERS
    CAShapeLayer *centerLayer;
    CALayer *innerLayer;
        CAShapeLayer *innerFill;
        CAShapeLayer *innerHandle;
        CAShapeLayer *innerRing;
    CALayer *outerLayer;
        CAShapeLayer *outerFill;
        CAShapeLayer *outerHandle;
        CAShapeLayer *outerRing;



}
@property int handleSelected;
@property int draggingOrientation;
@property (nonatomic, strong) NSDictionary *theme;

@property float outerAngle;
@property float innerAngle;

@property (strong, nonatomic) id<SelectDurationViewDelegate> delegate;

-(void) updateTheme:(NSDictionary *)newTheme;
- (void) setDuration:(NSTimeInterval)duration ;
-(void) setDate:(NSDate *)date;
-(NSDate *) getDate;
- (NSTimeInterval)getDuration;

-(void)updateTimerTick:(NSTimer *)timer;
-(void)update;

- (void) compressByRatio:(float)ratio;
- (void) animateCompressByRatio:(float)ratio;

- (void) setStopwatchMode:(NSNumber *)on;

- (void) enterTimerMode;
- (void) exitTimerMode;
- (void) beginTiming;
- (void) stopTiming;



-(id) initWithFrame:(CGRect)frame delegate:(id<SelectDurationViewDelegate>)aDelegate;

@end

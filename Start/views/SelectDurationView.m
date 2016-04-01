//
//  SelectDurationView.m
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 TackMobile. All rights reserved.
//

#import "SelectDurationView.h"

@implementation SelectDurationView
@synthesize handleSelected, draggingOrientation, theme;
@synthesize innerAngle, outerAngle;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        handleSelected = SelectDurationNoHandle;
        draggingOrientation = SelectDurationDraggingNone;
        changing = NO;
        isStopwatchMode = NO;
        switchingModes = NO;
        disableUpdateAngles = NO;
        _date = [NSDate date];
        _secondsSinceMidnight = 0;
        prevOuterAngle = 0;
        outerAngle = innerAngle = outerStartAngle = innerStartAngle = 0;
        
        originalFrame = frame;
        
        // LAYERS
        centerLayer = [[CAShapeLayer alloc] init];
        
        [self.layer addSublayer:centerLayer];
        
        // default theme
        theme = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                 [UIColor colorWithWhite:1 alpha:1],@"outerRingColor",
                 [UIColor colorWithWhite:1 alpha:1],@"innerRingColor",
                 [UIColor colorWithWhite:1 alpha:.4],@"outerColor",
                 [UIColor colorWithWhite:1 alpha:.5],@"innerColor",
                 [UIColor clearColor],@"outerFillColor",
                 [UIColor clearColor],@"innerFillColor",
                 [UIColor colorWithWhite:0 alpha:.6],@"centerColor",
                 [UIColor whiteColor],@"outerHandleColor",
                 [UIColor whiteColor],@"innerHandleColor",
                 [UIImage imageNamed:@"squares"],@"bgImg",
                 nil];
        
        // set the picker sizes
        origOuterRadius = outerRadius = 143;
        origInnerRadius = innerRadius = 101;
        centerRadius = 65;
                
        center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self initializeLayers];
        
        // update date timer
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimerTick:) userInfo:nil repeats:YES];
        //[self update]; //testing
        
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame delegate:(id<SelectDurationViewDelegate>)aDelegate {
    delegate = aDelegate;
    return [self initWithFrame:frame];
}

#pragma mark - Touches
- (bool) disabled {
    if ([delegate respondsToSelector:@selector(shouldLockPicker)])
        return [delegate shouldLockPicker];
    return NO;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {     
    UITouch *touch = [touches anyObject];
    
    CGPoint touchLoc = [touch locationInView:self];
    touchLoc = CGPointMake(touchLoc.x - center.x, touchLoc.y - center.y); // touch relative to center
    float distToTouch = sqrtf(powf(touchLoc.x, 2) + powf(touchLoc.y,2));
    float angleToTouch = [self angleFromVector:touchLoc];
        
    // test to see if touch is in range of any handles
    if (distToTouch < centerRadius) {
        handleSelected = SelectDurationCenterHandle;
    } else if (distToTouch <= innerRadius && [self touchAngle:angleToTouch isWithinAngle:innerAngle]) {
        handleSelected = SelectDurationInnerHandle;
    } else if (distToTouch > innerRadius && distToTouch <= outerRadius && [self touchAngle:angleToTouch isWithinAngle:outerAngle]) {
        handleSelected = SelectDurationOuterHandle;
    } else {
        handleSelected = SelectDurationNoHandle;
    }
    
    if (handleSelected == SelectDurationOuterHandle || handleSelected == SelectDurationInnerHandle) {
        if ([self disabled]) {
            handleSelected = SelectDurationNoHandle;
            return;
        }
        changing = YES;
        
        if ([delegate respondsToSelector:@selector(durationDidBeginChanging:)])
            [delegate durationDidBeginChanging:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    CGPoint touchLoc = [touch locationInView:self];
    CGSize touchVel;
    
    touchLoc = CGPointMake(touchLoc.x - center.x, touchLoc.y - center.y); // touch relative to center
    float angleToTouch = [self angleFromVector:touchLoc];
    
    // change angle of circles based handle selected
    if (handleSelected == SelectDurationOuterHandle) {
        [self setSnappedOuterAngle:angleToTouch checkForNext:YES];
        
    } else if (handleSelected == SelectDurationInnerHandle) {
        [self setSnappedInnerAngle:angleToTouch];
        
    } else if (handleSelected == SelectDurationCenterHandle || handleSelected == SelectDurationNoHandle) {
        // touchLoc need to be in parent because picker will be moving
        CGPoint parentTouchLoc = [touch locationInView:self.superview];
        CGPoint parentPrevTouchLoc = [touch previousLocationInView:self.superview];
        touchVel = CGSizeMake(parentTouchLoc.x-parentPrevTouchLoc.x, parentTouchLoc.y-parentPrevTouchLoc.y);
        
        if (draggingOrientation == SelectDurationDraggingNone) {
            if (fabs(touchVel.width) > fabs(touchVel.height))
                draggingOrientation = SelectDurationDraggingHoriz;
            else if (fabs(touchVel.height) > fabs(touchVel.width))
                draggingOrientation = SelectDurationDraggingVert;
            else 
                draggingOrientation = SelectDurationDraggingNone;
        }
        if (draggingOrientation == SelectDurationDraggingHoriz) {
            [(UIView *)delegate touchesMoved:touches withEvent:event];
        } else if (draggingOrientation == SelectDurationDraggingVert) {
            if ([delegate respondsToSelector:@selector(durationViewDraggedWithYVel:)])
                [delegate durationViewDraggedWithYVel:touchVel.height];
        }
    }
    
    if (handleSelected == SelectDurationOuterHandle || handleSelected == SelectDurationInnerHandle) {
        if ([delegate respondsToSelector:@selector(durationDidChange:)])
            [delegate durationDidChange:self];
    }
        
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _secondsSinceMidnight = (int)[self getSecondsFromZero];
    changing = NO;

    if ([[touches anyObject] tapCount] > 0) {
        if (handleSelected == SelectDurationCenterHandle)
            if ([delegate respondsToSelector:@selector(durationViewCoreTapped:)])
                [delegate durationViewCoreTapped:self];
        
        if ([delegate respondsToSelector:@selector(durationViewTapped:)])
            [delegate durationViewTapped:self];
    }
    
    if (draggingOrientation == SelectDurationDraggingHoriz || draggingOrientation == SelectDurationDraggingCancel)
        [(UIView *)delegate touchesEnded:touches withEvent:event];
    else if (draggingOrientation == SelectDurationDraggingVert)
        if ([delegate respondsToSelector:@selector(durationViewStoppedDraggingWithY:)])
            [delegate durationViewStoppedDraggingWithY:self.frame.origin.y];
    
    if (handleSelected != SelectDurationNoHandle && handleSelected != SelectDurationCenterHandle) {
        handleSelected = SelectDurationNoHandle;
        if ([delegate respondsToSelector:@selector(durationDidEndChanging:)])
            [delegate durationDidEndChanging:self];
    } else {
        handleSelected = SelectDurationNoHandle;
    }
    
    draggingOrientation = SelectDurationDraggingNone;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - functionality
- (void) enterTimerModeWithSeconds:(int)seconds {
    switchingModes = YES;
    isTimerMode = YES;
    outerStartAngle = 0;
    innerStartAngle = 0;
    

    // save the current inner handle positions
    float saveInnerEnd = innerFill.endAngle;
    float saveOuterEnd = outerFill.endAngle;
    
    // change innerAngle and outerAngle
    [self setSecondsFromZero:seconds];
    
    // adjust for correct animation rotation
    if (innerFill.startAngle > saveInnerEnd) {
        innerStartAngle = M_PI * 2;
    } else {
        innerStartAngle = 0;
    }
    if (outerFill.startAngle > saveOuterEnd) {
        outerStartAngle = M_PI * 2;
    } else {
        outerStartAngle = 0;
    }
    
    innerFill.shouldAnimate = outerFill.shouldAnimate = YES;
    waitingForAnimToEnd = YES;
    innerFill.startAngle = innerStartAngle;
    outerFill.startAngle = outerStartAngle;
    
    // switching modes set to no in animationdidend
    
}
- (void) exitTimerModeWithSeconds:(int)seconds {
    switchingModes = YES;
    isTimerMode = NO;
    
    //float saveInnerStart = innerFill.startAngle;
    //float saveOuterStart = outerFill.startAngle;

    disableUpdateAngles = YES;
    [self update];
    disableUpdateAngles = NO;
    
    [self setSecondsFromZero:seconds];
    
    innerFill.shouldAnimate = outerFill.shouldAnimate = NO;
    
    if (innerStartAngle > innerAngle)
        innerFill.startAngle = 0;
    else
        innerFill.startAngle = M_PI * 2;
    
    if (outerStartAngle > outerAngle)
        outerFill.startAngle = 0;
    else
        outerFill.startAngle = M_PI * 2;
    
    [self update];
    
    switchingModes = NO;
    
}
- (void) beginTiming {
    timerDuration = [self getSecondsFromZero];
    
    if ([delegate respondsToSelector:@selector(getDateBegan)])
        _timerBeganDate = [delegate getDateBegan];
    else
        _timerBeganDate = [NSDate date];
    
    isTiming = YES;
}
- (void) stopTiming {
    isTiming = NO;
    [self setSecondsFromZero:timerDuration];
    [self update];
}


#pragma mark - Properties
- (void) compressByRatio:(float)ratio animated:(bool)animated { // 1 is expanded and 0 is compressed
    outerRadius = centerRadius + (ratio * (origOuterRadius - centerRadius));
    innerRadius = centerRadius + (ratio * (origInnerRadius - centerRadius));
    
    innerFill.shouldAnimate = outerFill.shouldAnimate = animated;
    innerFill.innerRadius = centerRadius;
    innerFill.outerRadius = innerRadius;
    outerFill.innerRadius = innerRadius;
    outerFill.outerRadius = outerRadius;

}

- (void) setStopwatchMode:(BOOL)on {
    isStopwatchMode = on;
    //[self compressByRatio:isStopwatchMode?0:1];
    //[self updateLayersAnimated:YES];
}
- (void) updateTheme:(NSDictionary *)newTheme {
    theme = newTheme;
    [self updateLayers];
}

- (void) updateTimerTick:(NSTimer *)timer {
    if (!switchingModes && handleSelected == SelectDurationNoHandle)
        [self update];
}

- (void) update {
    // begin angles updated for normal mode. handles updated when a timer is set
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    
    NSInteger nowMinute = dateComponents.minute;
    NSInteger nowHour = dateComponents.hour;
    
    if (isTimerMode) {
        if (isTiming) {
            // move handles closer to zero
            [self setSecondsFromZero:(int)[[NSDate dateWithTimeInterval:timerDuration sinceDate:_timerBeganDate] timeIntervalSinceNow]];
        }
    } else {
        float newInnerStartAngle = nowHour * (M_PI*2)/24;
        float newOuterStartAngle = nowMinute * (M_PI*2)/60;
        
        [self setSnappedInnerStartAngle:newInnerStartAngle];
        [self setSnappedOuterStartAngle:newOuterStartAngle];
    }
    
}

- (void) setSecondsFromZeroWithNumber:(NSNumber *)seconds {
    [self setSecondsFromZero:[seconds intValue]];
}

- (void) setSecondsFromZero:(int)seconds {
    
    if (seconds < 0 && !isTimerMode)
        seconds = 86400+seconds;
    
    if (!isTiming) {
        if (isTimerMode)
            timerDuration = seconds;
        else
            _secondsSinceMidnight = seconds;
    }
    
    int duration = seconds;
    
    int days = duration / (60 * 60 * 24);
    duration -= days * (60 * 60 * 24);
    int hours = duration / (60 * 60);
    duration -= hours * (60 * 60);
    int minutes = duration / 60;
    
    float newInnerAngle = hours * (M_PI*2)/24;
    float newOuterAngle = minutes * (M_PI*2)/60;
    
    [self setSnappedOuterAngle:newOuterAngle checkForNext:NO];
    [self setSnappedInnerAngle:newInnerAngle];
}

- (void) addSeconds:(int)seconds {
    [self setSecondsFromZero:[self getSecondsFromZero] + seconds];
}

- (float) getSecondsFromZero {
    int min = (int)roundf(outerAngle/(M_PI*2/60));
    int hour = (int)roundf(innerAngle/(M_PI*2/24));
    
    return min*60+hour*3600;
}
-(NSNumber *) getNumberSecondsFromZero {    
    return [NSNumber numberWithFloat:[self getSecondsFromZero]];
}

-(NSDate *) getDate {
    int min = (int)roundf(outerAngle/(M_PI*2/60));
    int hour = (int)roundf(innerAngle/(M_PI*2/24));
    int day = 0;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    
    dateComponents.day += day;
    dateComponents.hour = hour;
    dateComponents.minute = min;
    dateComponents.second = .5;
    
    return [gregorian dateFromComponents:dateComponents];
}



/*
- (void) setDuration:(NSTimeInterval)duration {
    if (duration < 0.0)
        duration = 0.0;
    
    int days = duration / (60 * 60 * 24);
    duration -= days * (60 * 60 * 24);
    int hours = duration / (60 * 60);
    duration -= hours * (60 * 60);
    int minutes = duration / 60;
    
    float oldInnerAngle = innerAngle;
    float oldOuterAngle = outerAngle;
    
    float newInnerAngle = hours * (M_PI*2)/24;
    float newOuterAngle = minutes * (M_PI*2)/60;
        
    [self setSnappedOuterAngle:newOuterAngle checkForNext:NO];
    [self setSnappedInnerAngle:newInnerAngle];
    
    if (!switchingModes) {
        outerFill.shouldAnimate = innerFill.shouldAnimate = NO;
        outerFill.startAngle = innerFill.startAngle = 0;
    }
    
    if ((oldInnerAngle != innerAngle) || (oldOuterAngle != outerAngle))
        [self updateLayersAnimated:YES];
}*/
/*
-(void) setSecondsSinceMidnight:(NSNumber *)seconds {
    _secondsSinceMidnight = [seconds intValue];
    [self update];
}*/
/*
-(NSNumber *) getSecondsSinceMidnight {
    int min = (int)roundf(outerAngle/(M_PI*2/60));
    int hour = (int)roundf(innerAngle/(M_PI*2/24));
    
    return [NSNumber numberWithInt:min*60+hour*3600];
}
-(void) addSeconds:(int)seconds {
    int nowSeconds = [[self getSecondsSinceMidnight] intValue];
    [self setSecondsSinceMidnight:[NSNumber numberWithInt:nowSeconds+seconds]];
}*/


#pragma mark - picker angles

-(void) setSnappedOuterAngle:(float)angle checkForNext:(bool)shouldCheck {
    // round the angle
    float roundedAngle = roundf(angle/(M_PI*2/60)) * (M_PI*2/60);
    
    float beforeLim = (M_PI * 2.0f) * (3.0f/4.0f);
    float afterLim = (M_PI * 2.0f) * (1.0f/4.0f);
    
    // make sure we are moving the correct handle
    if (handleSelected != SelectDurationNoHandle && shouldCheck) {
        if (prevOuterAngle > beforeLim && roundedAngle < afterLim) {
            NSLog(@"next hour");
            outerAngle = prevOuterAngle = roundedAngle;
            [self addSeconds:3600];
            /*outerAngle = prevOuterAngle = roundedAngle;
            [self setSnappedInnerAngle:innerAngle +  (M_PI*2/60)];
            [self updateLayersAnimated:YES];
            return;*/
            
            /*outerAngle = prevOuterAngle = roundedAngle;
            if (isTimerMode)
                [self setDuration:[self getDuration]+3600];
            else
                [self addSeconds:3600];
            
            return;*/

        } else if (roundedAngle > beforeLim && prevOuterAngle < afterLim) {
            
            // make sure that we cant go into negative seconds
            if (!isTimerMode || innerAngle > 0) {
                NSLog(@"previous hour");
                outerAngle = prevOuterAngle = roundedAngle;
                [self addSeconds:-3600];
                /*outerAngle = prevOuterAngle = roundedAngle;
                if (isTimerMode)
                    [self setDuration:[self getDuration]-3600];
                else
                    [self addSeconds:-3600];*/
                /*outerAngle = prevOuterAngle = roundedAngle;
                [self setSnappedInnerAngle:innerAngle -  (M_PI*2/60)];
                return;*/
            }

        }
    }
    
    outerAngle = prevOuterAngle = roundedAngle;
    
    if (!disableUpdateAngles) {
        outerFill.shouldAnimate = (handleSelected == SelectDurationOuterHandle)?NO:YES;
        outerFill.endAngle = outerAngle;
    }
    
}
-(void) setSnappedInnerAngle:(float)angle {
    // round the angle
    float roundedAngle = roundf(angle/(M_PI*2/24)) * (M_PI*2/24);
    
    
    /*while (roundedAngle > M_PI * 2)
        roundedAngle = roundedAngle - (M_PI * 2);
    
    while (roundedAngle < 0)
        roundedAngle = roundedAngle + (M_PI * 2);*/
    
    innerAngle = roundedAngle;
    if (!disableUpdateAngles) {
        if (innerFill.endAngle == 0 || [self shouldFixAngle:innerFill.endAngle]) {
            innerFill.shouldAnimate = NO;
            if (innerAngle < M_PI)
                innerFill.endAngle = 0;
            else
                innerFill.endAngle = M_PI * 2;
        }
        if (!switchingModes && ( innerAngle == 0 || [self shouldFixAngle:innerAngle])) {
            if (innerFill.endAngle < M_PI)
                innerAngle = 0;
            else
                innerAngle = M_PI * 2;
        }
        innerFill.shouldAnimate = (handleSelected == SelectDurationInnerHandle)?NO:YES;
        innerFill.endAngle = innerAngle;
    }

}

-(void) setSnappedOuterStartAngle:(float)angle {
    float roundedAngle = roundf(angle/(M_PI*2/60)) * (M_PI*2/60);
    outerStartAngle = roundedAngle;
    if (!disableUpdateAngles) {
        //outerFill.shouldAnimate = NO;
        //outerFill.startAngle = [self shouldFixAngle:outerFill.startAngle]?0:outerFill.startAngle;
        
        outerFill.shouldAnimate = YES;
        outerFill.startAngle = outerStartAngle;
    }
}

-(void) setSnappedInnerStartAngle:(float)angle {
    float roundedAngle = roundf(angle/(M_PI*2/24)) * (M_PI*2/24);
    innerStartAngle = roundedAngle;
    
    if (!disableUpdateAngles) {
        //innerFill.shouldAnimate = NO;
        //innerFill.startAngle = [self shouldFixAngle:innerFill.startAngle]?0:innerFill.startAngle;
        
        innerFill.shouldAnimate = YES;
        innerFill.startAngle = innerStartAngle;
    }
}

- (bool) touchAngle:(float)touchAngle isWithinAngle:(float)angle {
    float padding = DEGREES_TO_RADIANS(15);
    float leftAngle = angle - padding;
    float rightAngle = angle + padding;
    
    if (leftAngle < 0)
        leftAngle = leftAngle + M_PI * 2;
    if (rightAngle > (M_PI * 2))
        rightAngle = rightAngle - (M_PI * 2);
    
    return ((touchAngle >= leftAngle && touchAngle <= leftAngle + 2*padding) ||
            (touchAngle <= rightAngle && touchAngle >= rightAngle- 2*padding));
    
}

#pragma mark - Util

- (bool) shouldFixAngle:(float)angle {
    return (angle > 6.2 && angle < M_PI*2+.1);
}

- (float) angleFromVector:(CGPoint)vector {
    float angle = atanf(vector.y / vector.x) - DEGREES_TO_RADIANS(-90);
    
    // fix for values on the left half of the circle
    if (vector.x < 0)
        angle += M_PI;
    if (angle < 0)
        angle += M_PI * 2;
    
    // check if angle is M_PI*2
    if (angle > 6.2 && angle < M_PI * 2) {
        NSLog(@"Angle is %f. being brought to zero.", angle);
        angle = 0;
    }
    
    return angle;
}

- (CGPoint) vectorFromAngle:(float)angle distance:(float)distance origin:(CGPoint)origin {
    CGPoint vector;
    angle = angle + DEGREES_TO_RADIANS(-90);
    vector.y = roundf( distance * sinf( angle ) );
    vector.x = roundf( distance * cosf( angle ) );
    return (CGPoint){vector.x + origin.x, vector.y + origin.y};
}

#pragma mark - caanimation delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag && waitingForAnimToEnd) {
        waitingForAnimToEnd = NO;
        switchingModes = NO;
    }
}


#pragma mark - Drawing
/* THEME FORMAT:
     NSMutableDictionary *theme = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 [UIColor blackColor],@"outerRingColor",
                                 [UIColor blackColor],@"innerRingColor",
                                 [UIColor blackColor],@"outerColor",
                                 [UIColor blackColor],@"outerFillColor",
                                 [UIColor blackColor],@"innerColor",
                                 [UIColor blackColor],@"innerFillColor",
                                 [UIColor blackColor],@"centerColor",
                                 [UIColor blackColor],@"outerHandleColor",
                                 [UIColor blackColor],@"innerHandleColor",
                                 [UIImage imageNamed:@"squares"], @"bgImg",
                                 nil]; 
 */

- (void) initializeLayers {
    innerFill = [[RingFillShapeLayer alloc] init];
    outerFill = [[RingFillShapeLayer alloc] init];
    
    outerFill.ringName = @"OUTER FILL";
    innerFill.ringName = @"INNER FILL";
    
    innerFill.animDelegate = self;
    outerFill.animDelegate = self;

    [self.layer addSublayer:innerFill];
    [self.layer addSublayer:outerFill];
    
    // draw the center circle which doesn't change
    CGRect centerCircleRect = CGRectMake(-centerRadius, -centerRadius, centerRadius*2, centerRadius*2);
    UIBezierPath *centerCirclePath = [UIBezierPath bezierPathWithOvalInRect:centerCircleRect];
    centerLayer.path = centerCirclePath.CGPath;
    centerLayer.fillColor = [[theme objectForKey:@"centerColor"] CGColor];
    
    // POSITION
    CGRect layerFrame = (CGRect){CGPointZero, self.frame.size};
    CGPoint layerAnchor = CGPointZero;
    
    innerFill.frame = outerFill.frame = innerLayer.frame = outerLayer.frame = centerLayer.frame = layerFrame;
    centerLayer.anchorPoint = layerAnchor;
    
    innerFill.contentsScale = outerFill.contentsScale = 2.0;
    
    
    // original values
    innerFill.innerRadius = centerRadius;
    innerFill.outerRadius = innerRadius;
    innerFill.startAngle = innerStartAngle;
    innerFill.endAngle = innerAngle;
    
    outerFill.innerRadius = innerRadius;
    outerFill.outerRadius = outerRadius;
    outerFill.startAngle = outerStartAngle;
    outerFill.endAngle = outerAngle;
    
    [self update];
    [self updateLayers];

}

- (void)updateLayers {
    // updates the colors
    
    innerFill.ringFillColor = [theme objectForKey:@"innerColor"];
    innerFill.handleColor = [theme objectForKey:@"innerHandleColor"];
    innerFill.ringStrokeColor = [theme objectForKey:@"innerRingColor"];
    
    outerFill.ringFillColor = [theme objectForKey:@"outerColor"];
    outerFill.handleColor = [theme objectForKey:@"outerHandleColor"];
    outerFill.ringStrokeColor = [theme objectForKey:@"outerRingColor"];
        
    centerLayer.fillColor = [[theme objectForKey:@"centerColor"] CGColor];
}

- (void)drawRect:(CGRect)rect
{
    [self updateLayers];
    return;
}

#pragma mark - cg functions

CGPoint CGRectGetCenter(CGRect rect) {
    return CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
}

@end

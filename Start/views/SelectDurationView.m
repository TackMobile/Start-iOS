//
//  SelectDurationView.m
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 TackMobile. All rights reserved.
//

#define DEGREES_TO_RADIANS(degrees) ((M_PI * degrees)/ 180)
#import "SelectDurationView.h"

//#import <QuartzCore/QuartzCore.h>

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
        _date = [NSDate date];
        prevOuterAngle = 0;
        outerAngle = innerAngle = 0;
        
        originalFrame = frame;
        
        // LAYERS
        centerLayer = [[CAShapeLayer alloc] init];
        innerLayer = [[CALayer alloc] init];
        outerLayer = [[CALayer alloc] init];
        
        [self.layer addSublayer:outerLayer];
        [self.layer addSublayer:innerLayer];
        [self.layer addSublayer:centerLayer];
        [self initializeLayers];
        
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
    CGPoint prevTouchLoc = [touch previousLocationInView:self];
    CGSize touchVel = CGSizeMake(touchLoc.x-prevTouchLoc.x, touchLoc.y-prevTouchLoc.y);
    
    touchLoc = CGPointMake(touchLoc.x - center.x, touchLoc.y - center.y); // touch relative to center
    float angleToTouch = [self angleFromVector:touchLoc];
    
    // change angle of circles based handle selected
    if (handleSelected == SelectDurationOuterHandle) {
        [self setSnappedOuterAngle:angleToTouch];
        [self updateLayers];
        
    } else if (handleSelected == SelectDurationInnerHandle) {
        [self setSnappedInnerAngle:angleToTouch];
        [self updateLayers];
        
    } else if (handleSelected == SelectDurationCenterHandle || handleSelected == SelectDurationNoHandle) {
        // touchLoc need to be in parent because picker will be moving
        CGPoint parentTouchLoc = [touch locationInView:self.superview];
        CGPoint parentPrevTouchLoc = [touch previousLocationInView:self.superview];
        touchVel = CGSizeMake(parentTouchLoc.x-parentPrevTouchLoc.x, parentTouchLoc.y-parentPrevTouchLoc.y);
        
        if (draggingOrientation == SelectDurationDraggingNone) {
            if (fabsf(touchVel.width) > fabsf(touchVel.height))
                draggingOrientation = SelectDurationDraggingHoriz;
            else if (fabsf(touchVel.height) > fabsf(touchVel.width))
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
    _date = [self getDate];
    changing = NO;

    if ([[touches anyObject] tapCount] > 0)
        if ([delegate respondsToSelector:@selector(durationViewTapped:)])
            [delegate durationViewTapped:self];
    
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
- (void) enterTimerMode {
    isTimerMode = YES;
    outerAngle = 0;
    innerAngle = 0;
    outerStartAngle = 0;
    innerStartAngle = 0;
    [self updateLayers];
}
- (void) exitTimerMode {
    isTimerMode = NO;
    [self updateLayers];
}

#pragma mark - Properties
- (void) compressByRatio:(float)ratio {
    /*outerRadius = centerRadius + (ratio * (origOuterRadius - centerRadius));
    innerRadius = centerRadius + (ratio * (origInnerRadius - centerRadius));
    outerRing.opacity = ratio;
    innerRing.opacity = ratio;
    
    [self updateLayers];*/

}
- (void) animateCompressByRatio:(float)ratio {
    /*CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 0.0, 0.0)];
    animation.repeatCount = 1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = 1;
    [outerLayer addAnimation:animation forKey:@"transform.scale"];
    NSLog(@"%f, %f", outerRing.frame.size.width, outerRing.frame.size.height);*/
    
    // temporary fix
    
    CABasicAnimation *fillAnimation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    fillAnimation.duration = 0.2f;
    if (ratio == 0) {
        fillAnimation.fromValue = (id)[[UIColor clearColor] CGColor];
        fillAnimation.toValue = (id)outerFill.fillColor;
    } else {
        fillAnimation.toValue = (id)[[UIColor clearColor] CGColor];
        fillAnimation.fromValue = (id)outerFill.fillColor;
    }
    fillAnimation.removedOnCompletion = NO;
    fillAnimation.fillMode = kCAFillModeForwards;

    [outerRing addAnimation:fillAnimation forKey:@"fillColorAnimation"];
    
    CABasicAnimation *clearAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    clearAnimation.duration = 0.2f;
    if (ratio == 0) {
        clearAnimation.fromValue = [NSNumber numberWithFloat: 1.0f];
        clearAnimation.toValue = [NSNumber numberWithFloat: 0.0f];
    } else {
        clearAnimation.toValue = [NSNumber numberWithFloat: 1.0f];
        clearAnimation.fromValue = [NSNumber numberWithFloat: 0.0f];
    }
    clearAnimation.removedOnCompletion = NO;
    clearAnimation.fillMode = kCAFillModeForwards;
    
    [innerFill addAnimation:clearAnimation forKey:@"opacityAnimation"];
    [innerHandle addAnimation:clearAnimation forKey:@"opacityAnimation"];
    [outerHandle addAnimation:clearAnimation forKey:@"opacityAnimation"];
    [outerFill addAnimation:clearAnimation forKey:@"opacityAnimation"];

}

- (void) setStopwatchMode:(NSNumber *)on {
    isStopwatchMode = [on boolValue];
    [self updateLayers];
}
- (void) updateTheme:(NSDictionary *)newTheme {
    theme = newTheme;
    [self updateLayers];
}

- (void) updateAngles {
    
}

-(NSTimeInterval) getDuration {
    int min = (int)roundf(outerAngle/(M_PI*2/60));
    int hour = (int)roundf(innerAngle/(M_PI*2/24));
    return hour*3600 + min*60;
}

-(NSDate *) getDate {
    int min = (int)roundf(outerAngle/(M_PI*2/60));
    int hour = (int)roundf(innerAngle/(M_PI*2/24));
    int day = 0;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    
    /*if (dateComponents.hour >= 12) {
        hour+=12;
        if (hour < dateComponents.hour)
            hour+=12;
    }
    if (hour > 24) {
        day++;
        hour -= 24;
    }*/
    
    /*if (min == 60) {
        min=0;
        hour++;
    }*/
    
    dateComponents.day += day;
    dateComponents.hour = hour;
    dateComponents.minute = min;
    dateComponents.second = .5;
    
    //NSLog(@"%i, %i, %i, %i", day, hour, min, 0);
    return [gregorian dateFromComponents:dateComponents];
}


- (void) updateTimerTick:(NSTimer *)timer {
    if (handleSelected != SelectDurationNoHandle)
        return;
    [self update];
}

- (void) update {
    if (isTimerMode)
        return;
        
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:_date];
    
    int minute = dateComponents.minute;
    int hour = dateComponents.hour;
    int second = dateComponents.second;
        
    float newInnerAngle = hour * (M_PI*2)/24;
    float newOuterAngle = minute * (M_PI*2)/60;
    
    float saveInnerAngle = innerAngle;
    float saveOuterAngle = outerAngle;
    
    [self setSnappedOuterAngle:newOuterAngle];
    [self setSnappedInnerAngle:newInnerAngle];
    
    // start handles
    dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];

    minute = dateComponents.minute;
    hour = dateComponents.hour;
    second = dateComponents.second;
    
    float newInnerStartAngle = hour * (M_PI*2)/24;
    float newOuterStartAngle = minute * (M_PI*2)/60;
    
    float saveInnerStartAngle = innerStartAngle;
    float saveOuterStartAngle = outerStartAngle;
    
    [self setSnappedOuterStartAngle:newOuterStartAngle];
    [self setSnappedInnerStartAngle:newInnerStartAngle];
    
    
    if ((innerAngle != saveInnerAngle) || (outerAngle != saveOuterAngle)
        || (innerStartAngle != saveInnerStartAngle) || (outerStartAngle != saveOuterStartAngle))
        [self updateLayers];
}

- (void) setDate:(NSDate *)date {
    // select duration
    _date = date;
    [self update];
}

#pragma mark - angles

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

-(void) setSnappedOuterAngle:(float)angle {
    float roundedAngle = roundf(angle/(M_PI*2/60)) * (M_PI*2/60);
    roundedAngle = (roundedAngle == M_PI*2 )? 0 :roundedAngle;

    float beforeLim = (M_PI * 2.0f) * (3.0f/4.0f);
    float afterLim = (M_PI * 2.0f) * (1.0f/4.0f);
    
    if (prevOuterAngle > beforeLim && roundedAngle < afterLim) { // next hour
        NSLog(@"next");
        outerAngle = prevOuterAngle = roundedAngle;
        [self setDate:[[self getDate] dateByAddingTimeInterval:3600]];
        return;

    } else if (roundedAngle > beforeLim && prevOuterAngle < afterLim) { // prev hour
        NSLog(@"prev");
        outerAngle = prevOuterAngle = roundedAngle;
        [self setDate:[[self getDate] dateByAddingTimeInterval:-3600]];
        return;
    }
    outerAngle = prevOuterAngle = roundedAngle;
}
-(void) setSnappedInnerAngle:(float)angle {
    float roundedAngle = roundf(angle/(M_PI*2/24)) * (M_PI*2/24);
    roundedAngle = roundedAngle==(M_PI*2)?0:roundedAngle;
    innerAngle = roundedAngle;
}

-(void) setSnappedOuterStartAngle:(float)angle {
    float roundedAngle = roundf(angle/(M_PI*2/60)) * (M_PI*2/60);
    outerStartAngle = roundedAngle;
}
-(void) setSnappedInnerStartAngle:(float)angle {
    float roundedAngle = roundf(angle/(M_PI*2/24)) * (M_PI*2/24);
    innerStartAngle = roundedAngle;
}


#pragma mark - Util
- (float) angleFromVector:(CGPoint)vector {
    float angle = atanf(vector.y / vector.x) - DEGREES_TO_RADIANS(-90);
    
    // fix for values on the left half of the circle
    if (vector.x < 0)
        angle += M_PI;
    if (angle < 0)
        angle += M_PI * 2;
    
    return angle;
}

- (CGPoint) vectorFromAngle:(float)angle distance:(float)distance origin:(CGPoint)origin {
    CGPoint vector;
    angle = angle + DEGREES_TO_RADIANS(-90);
    vector.y = roundf( distance * sinf( angle ) );
    vector.x = roundf( distance * cosf( angle ) );
    return CGPointAddPoint(vector, origin);
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
    innerFill = [[CAShapeLayer alloc] init];
    innerHandle = [[CAShapeLayer alloc] init];
    innerRing = [[CAShapeLayer alloc] init];
    outerFill = [[CAShapeLayer alloc] init];
    outerHandle = [[CAShapeLayer alloc] init];
    outerRing = [[CAShapeLayer alloc] init];

    [innerLayer addSublayer:innerFill];
    [innerLayer addSublayer:innerHandle];
    [innerLayer addSublayer:innerRing];
    
    [outerLayer addSublayer:outerFill];
    [outerLayer addSublayer:outerHandle];
    [outerLayer addSublayer:outerRing];
    
    CGRect layerFrame = (CGRect){CGPointZero, self.frame.size};
    CGPoint layerAnchor = CGRectGetCenter(outerLayer.frame);
    
    innerLayer.frame = outerLayer.frame =centerLayer.frame = layerFrame;
    innerLayer.anchorPoint = outerLayer.anchorPoint = centerLayer.anchorPoint = layerAnchor;
    
    [self updateLayers];

}

- (void)updateLayers {
    
    // Step 1: create the paths ---------------------------------
    
    float startAngle = DEGREES_TO_RADIANS(-90);
    
    CGRect centerCircleRect = CGRectMake(-centerRadius, -centerRadius, centerRadius*2, centerRadius*2);
    CGRect innerRingRect = CGRectMake(-innerRadius, -innerRadius, innerRadius*2, innerRadius*2);
    CGRect outerRingRect = CGRectMake(-outerRadius, -outerRadius, outerRadius*2, outerRadius*2);



    // OUTER CIRCLE
    UIBezierPath *outerCirclePath = [UIBezierPath bezierPath];
    if (isStopwatchMode) {
        [outerCirclePath addArcWithCenter:CGPointZero radius:innerRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];
        [outerCirclePath addArcWithCenter:CGPointZero radius:outerRadius startAngle:M_PI*2 endAngle:0 clockwise:NO];
    } else {
        [outerCirclePath addArcWithCenter:CGPointZero radius:innerRadius startAngle:outerStartAngle+startAngle endAngle:outerAngle+startAngle clockwise:YES];
        [outerCirclePath addArcWithCenter:CGPointZero radius:outerRadius startAngle:outerAngle+startAngle endAngle:outerStartAngle+startAngle clockwise:NO];
    }
    
    // OUTER HANDLE
    UIBezierPath *outerHandlePath = [UIBezierPath bezierPath];
    [outerHandlePath moveToPoint:[self vectorFromAngle:outerAngle distance:innerRadius origin:CGPointZero]];
    [outerHandlePath addLineToPoint:[self vectorFromAngle:outerAngle distance:outerRadius origin:CGPointZero]];

     
    // INNER CIRCLE
    UIBezierPath *innerCirclePath = [UIBezierPath bezierPath];
    if (isStopwatchMode) {
        [innerCirclePath addArcWithCenter:CGPointZero radius:centerRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];
        [innerCirclePath addArcWithCenter:CGPointZero radius:innerRadius startAngle:M_PI*2 endAngle:0 clockwise:NO];
    } else {
        [innerCirclePath addArcWithCenter:CGPointZero radius:centerRadius startAngle:innerStartAngle+startAngle endAngle:innerAngle+startAngle clockwise:YES];
        [innerCirclePath addArcWithCenter:CGPointZero radius:innerRadius startAngle:innerAngle+startAngle endAngle:innerStartAngle+startAngle clockwise:NO];
    }
    
    // INNER HANDLE
    UIBezierPath *innerHandlePath = [UIBezierPath bezierPath];
    [innerHandlePath moveToPoint:[self vectorFromAngle:innerAngle distance:centerRadius origin:CGPointZero]];
    [innerHandlePath addLineToPoint:[self vectorFromAngle:innerAngle distance:innerRadius origin:CGPointZero]];

    
    // CENTER CIRCLE
    UIBezierPath *centerCirclePath = [UIBezierPath bezierPathWithOvalInRect:centerCircleRect];
    
    // RINGS
    UIBezierPath *innerRingPath = [UIBezierPath bezierPathWithOvalInRect:innerRingRect];
    UIBezierPath *outerRingPath = [UIBezierPath bezierPathWithOvalInRect:outerRingRect];
    

    // Step 2: update layers and fill the paths ---------------------------------

    outerFill.path = outerCirclePath.CGPath;
    outerFill.fillColor = [[theme objectForKey:@"outerColor"] CGColor];
    
    outerHandle.path = outerHandlePath.CGPath;
    outerHandle.lineWidth = 2.0;
    outerHandle.strokeColor = [[theme objectForKey:@"outerHandleColor"] CGColor];
    
    outerRing.path = outerRingPath.CGPath;
    outerRing.lineWidth = 1.0;
    outerRing.fillColor = [[UIColor clearColor] CGColor];
    outerRing.strokeColor = [[theme objectForKey:@"outerRingColor"] CGColor];
    
    outerRing.anchorPoint = CGPointMake(outerRadius, outerRadius);
    
    innerFill.path = innerCirclePath.CGPath;
    innerFill.fillColor = [[theme objectForKey:@"innerColor"] CGColor];
    
    innerHandle.path = innerHandlePath.CGPath;
    innerHandle.lineWidth = 2.0;
    innerHandle.strokeColor = [[theme objectForKey:@"innerHandleColor"] CGColor];
    
    innerRing.path = innerRingPath.CGPath;
    innerRing.lineWidth = 1.0;
    innerRing.fillColor = [[UIColor clearColor] CGColor];
    innerRing.strokeColor = [[theme objectForKey:@"innerRingColor"] CGColor];
    
    centerLayer.path = centerCirclePath.CGPath;
    centerLayer.fillColor = [[theme objectForKey:@"centerColor"] CGColor];
}

- (void)drawRect:(CGRect)rect
{
    [self updateLayers];
    return;
}

#pragma mark - cg functions
CGPoint CGPointAddPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake(p1.x+p2.x, p1.y+p2.y);
}
CGPoint CGRectGetCenter(CGRect rect) {
    return CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
}

@end

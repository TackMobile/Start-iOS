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
        [self setNeedsDisplay];
        handleSelected = SelectDurationNoHandle;
        draggingOrientation = SelectDurationDraggingNone;
        changing = NO;
        
        originalFrame = frame;
        
        // default theme
        theme = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                 [UIColor colorWithWhite:1 alpha:.7],@"outerRingColor",
                 [UIColor colorWithWhite:1 alpha:.7],@"innerRingColor",
                 [UIColor colorWithWhite:0 alpha:.7],@"outerColor",
                 [UIColor colorWithWhite:1 alpha:.35],@"innerColor",
                 [UIColor colorWithWhite:0 alpha:.8],@"centerColor",
                 [UIColor whiteColor],@"outerHandleColor",
                 [UIColor whiteColor],@"innerHandleColor",
                 [UIImage imageNamed:@"squares"],@"bgImg",
                 nil];
        
        // set the picker sizes
        outerRadius = 143;
        innerRadius = 101;
        centerRadius = 65;
        
        handleSelected = SelectDurationNoHandle;
        
        center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        
        //TESTING
        [self setBackgroundColor:[UIColor clearColor]];
        
        outerAngle = DEGREES_TO_RADIANS(45);
        innerAngle = DEGREES_TO_RADIANS(90);
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
    touchLoc = CGPointMake(touchLoc.x - center.x, touchLoc.y - center.y); // touch rel to center
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
    
    touchLoc = CGPointMake(touchLoc.x - center.x, touchLoc.y - center.y); // touch rel to center
    float angleToTouch = [self angleFromVector:touchLoc];
    
    // change angle of circles based handle selected
    if (handleSelected == SelectDurationOuterHandle) {
        [self setSnappedOuterAngle:angleToTouch];
        [self setNeedsDisplay];
        
    } else if (handleSelected == SelectDurationInnerHandle) {
        [self setSnappedInnerAngle:angleToTouch];
        [self setNeedsDisplay];
        
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
            [self.superview touchesMoved:touches withEvent:event];
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
    changing = NO;
    
    if ([[touches anyObject] tapCount] > 0)
        if ([delegate respondsToSelector:@selector(durationViewTapped:)])
            [delegate durationViewTapped:self];
    
    if (draggingOrientation == SelectDurationDraggingHoriz || draggingOrientation == SelectDurationDraggingCancel)
        [self.superview touchesEnded:touches withEvent:event];
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

#pragma mark - Properties
- (void) updateTheme:(NSDictionary *)newTheme {
    theme = newTheme;
    [self setNeedsDisplay];
}

-(NSTimeInterval) getTimeInterval {
    float outerValue = (outerAngle / (M_PI*2));
    float innerValue = (innerAngle / (M_PI*2));
    
    // convert ratios to hours. max hours: 23. max minutes: 59
    int hours = (int)(innerValue * 24);
    int minutes = (int)(outerValue * 60);
    
    return hours * 3600 + minutes * 60;
}
-(void) setTimeInterval:(NSTimeInterval)timeInterval {
    if (changing)
        return;
    int totalMin = ((int)timeInterval - (int)timeInterval%60)/60;
    int minutes = totalMin % 60;
    int hours = (totalMin - minutes)/60;
    
    float innerVal = (float)hours / 24.0 ;
    float outerVal = (float)minutes / 60.0f;
    
    // remember the previous angles
    float prevOuter = outerAngle;
    float prevInner = innerAngle;
    
    innerAngle = DEGREES_TO_RADIANS( innerVal * 360);
    outerAngle = DEGREES_TO_RADIANS( outerVal * 360);
    
    if (innerAngle != prevInner || outerAngle != prevOuter) {
        [self setNeedsDisplay];
    }
}
-(void) setDate:(NSDate *)date {
    // select duration
    NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval alarmInterval = [date timeIntervalSince1970];
    NSTimeInterval duration = alarmInterval-nowInterval;
    duration = (duration<0)?duration+86400:duration;
    [self setTimeInterval:duration];
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

-(void) setSnappedOuterAngle:(float)angle {
    outerAngle = roundf(angle/(M_PI * 2 / 60)) * (M_PI * 2 / 60) + (M_PI * 2 / 120);
}
-(void) setSnappedInnerAngle:(float)angle {
    innerAngle = roundf(angle/(M_PI * 2 / 24)) * (M_PI * 2 / 24) + (M_PI * 2 / 48);
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
             NSDictionary *theme = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                 [UIColor colorWithWhite:1 alpha:.7],@"outerRingColor",
                 [UIColor colorWithWhite:1 alpha:.7],@"innerRingColor",
                 [UIColor colorWithWhite:0 alpha:.7],@"outerColor",
                 [UIColor colorWithWhite:1 alpha:.35],@"innerColor",
                 [UIColor colorWithWhite:0 alpha:.8],@"centerColor",
                 [UIColor whiteColor],@"outerHandleColor",
                 [UIColor whiteColor],@"innerHandleColor",
                 [UIImage imageNamed:@"squares"],@"bgFilename"
                 nil];
 */

- (void)drawRect:(CGRect)rect
{   
    CGContextRef aRef = UIGraphicsGetCurrentContext();
    CGContextSaveGState(aRef);
    
    // draw the circles
    float startAngle = DEGREES_TO_RADIANS(-90);
    CGRect centerRect = CGRectMake(center.x-centerRadius, center.y-centerRadius, centerRadius*2, centerRadius*2);
    
    UIBezierPath *outerCircle = [UIBezierPath bezierPath];
    [outerCircle moveToPoint:center];
    [outerCircle addArcWithCenter:center radius:outerRadius startAngle:startAngle endAngle:outerAngle+startAngle clockwise:YES];
    [outerCircle closePath];
    
    UIBezierPath *innerCircle = [UIBezierPath bezierPath];
    [innerCircle moveToPoint:center];
    [innerCircle addArcWithCenter:center radius:innerRadius startAngle:startAngle endAngle:innerAngle+startAngle clockwise:YES];
    [innerCircle closePath];
    
    UIBezierPath *centerCircle = [UIBezierPath bezierPathWithOvalInRect:centerRect];
    
    [[theme objectForKey:@"outerColor"] setFill];  [outerCircle fill];
    [[theme objectForKey:@"innerColor"] setFill];  [innerCircle fill];
    [[theme objectForKey:@"centerColor"] setFill]; [centerCircle fill];
    
    // thicker lines
    UIBezierPath *outerLine = [UIBezierPath bezierPath];
    [outerLine moveToPoint:[self vectorFromAngle:outerAngle distance:innerRadius origin:center]];
    [outerLine addLineToPoint:[self vectorFromAngle:outerAngle distance:outerRadius origin:center]];
    
    UIBezierPath *innerLine = [UIBezierPath bezierPath];
    [innerLine moveToPoint:[self vectorFromAngle:innerAngle distance:centerRadius origin:center]];
    [innerLine addLineToPoint:[self vectorFromAngle:innerAngle distance:innerRadius origin:center]];
    
    [[theme objectForKey:@"innerHandleColor"] setStroke];
    innerLine.lineWidth = 2;    [innerLine stroke];
        
    [[theme objectForKey:@"outerHandleColor"] setStroke];
    outerLine.lineWidth = 2;    [outerLine stroke];
    
    // draw the rings
    CGRect outerRect = CGRectMake(center.x-outerRadius, center.y-outerRadius, outerRadius*2, outerRadius*2);
    CGRect innerRect = CGRectMake(center.x-innerRadius, center.y-innerRadius, innerRadius*2, innerRadius*2);
    
    UIBezierPath *outerOutline = [UIBezierPath bezierPathWithOvalInRect:outerRect];
    UIBezierPath *innerOutline = [UIBezierPath bezierPathWithOvalInRect:innerRect];
    
    [[theme objectForKey:@"outerRingColor"] setStroke];
    outerOutline.lineWidth = 1; [outerOutline stroke];
    
    [[theme objectForKey:@"innerRingColor"] setStroke];
    innerOutline.lineWidth = 1; [innerOutline stroke];
    
    CGContextRestoreGState(aRef);
}

#pragma mark - cg functions
CGPoint CGPointAddPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake(p1.x+p2.x, p1.y+p2.y);
}

@end

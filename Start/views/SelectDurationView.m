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
        isTimerMode = NO;
        _date = [NSDate date];
        prevOuterAngle = 0;
        outerAngle = innerAngle = 0;
        
        originalFrame = frame;
        
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
        outerRadius = 143;
        innerRadius = 101;
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

#pragma mark - Properties
- (void) setTimerMode:(NSNumber *)on {
    isTimerMode = [on boolValue];
    [self setNeedsDisplay];
}
- (void) updateTheme:(NSDictionary *)newTheme {
    theme = newTheme;
    [self setNeedsDisplay];
}

- (void) updateAngles {
    
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


/*-(void) setTimeInterval:(NSTimeInterval)timeInterval {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]];
    
    
    int minute = dateComponents.minute;
    int hour = dateComponents.hour>12?dateComponents.hour-12:dateComponents.hour;
    int second = dateComponents.second;
    
    dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    
    float newInnerAngle = hour * (M_PI*2)/12;
    float newOuterAngle = hour * (M_PI*2)/60;
    
    float saveInnerAngle = innerAngle;
    float saveOuterAngle = outerAngle;
    
    [self setSnappedOuterAngle:newOuterAngle];
    [self setSnappedInnerAngle:newInnerAngle];
    
    // start handles
    float saveOuterStartAngle = outerStartAngle;
    float saveInnerStartAngle = innerStartAngle;
    
    
    hour = [dateComponents hour];
    minute = dateComponents.minute;
    second = dateComponents.second;
    
    NSTimeInterval intervalInDay = (hour*3600) + (minute*60) + second;
    
    while (intervalInDay > 43200.0f)
        intervalInDay = intervalInDay - 43200.0f;
    
    float newInnerStartAngle = roundf(intervalInDay/3600.0f) * (M_PI*60);
    float newOuterStartAngle = ((int)intervalInDay%3600)/(3600) * (M_PI*2)/60;
    
    [self setSnappedOuterStartAngle:newOuterStartAngle];
    [self setSnappedInnerStartAngle:newInnerStartAngle];

    if ((innerAngle != saveInnerAngle) || (outerAngle != saveOuterAngle)
        || (innerStartAngle != saveInnerStartAngle) || (outerStartAngle != saveOuterStartAngle))
        [self setNeedsDisplay];
}*/
- (void) updateTimerTick:(NSTimer *)timer {
    if (handleSelected != SelectDurationNoHandle)
        return;
    [self update];
}

- (void) update {    
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
        [self setNeedsDisplay];
}

- (void) setDate:(NSDate *)date {
    // select duration
    _date = date;
    [self update];
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

- (void)drawRect:(CGRect)rect
{
    CGContextRef aRef = UIGraphicsGetCurrentContext();
    CGContextSaveGState(aRef);
    
    // draw the circles
    float startAngle = DEGREES_TO_RADIANS(-90);
    CGRect centerRect = CGRectMake(center.x-centerRadius, center.y-centerRadius, centerRadius*2, centerRadius*2);
    
    // outer
    UIBezierPath *outerCircle = [UIBezierPath bezierPath];
    if (isTimerMode) {
        [outerCircle addArcWithCenter:center radius:innerRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];
        [outerCircle addArcWithCenter:center radius:outerRadius startAngle:M_PI*2 endAngle:0 clockwise:NO];
    } else {
        [outerCircle addArcWithCenter:center radius:innerRadius startAngle:outerStartAngle+startAngle endAngle:outerAngle+startAngle clockwise:YES];
        [outerCircle addArcWithCenter:center radius:outerRadius startAngle:outerAngle+startAngle endAngle:outerStartAngle+startAngle clockwise:NO];
    }
    //[outerCircle closePath];
    
    UIBezierPath *outerFill = [UIBezierPath bezierPath];
    if (!isTimerMode) {
        [outerFill addArcWithCenter:center radius:innerRadius startAngle:outerAngle+startAngle 
                           endAngle:outerStartAngle+startAngle clockwise:YES];
        [outerFill addArcWithCenter:center radius:outerRadius startAngle:outerStartAngle+startAngle 
                       endAngle:outerAngle+startAngle clockwise:NO];
    }
    //[outerFill closePath];
    
    UIBezierPath *outerLine = [UIBezierPath bezierPath];
    [outerLine moveToPoint:[self vectorFromAngle:outerAngle distance:innerRadius origin:center]];
    [outerLine addLineToPoint:[self vectorFromAngle:outerAngle distance:outerRadius origin:center]];

    // inner
    UIBezierPath *innerCircle = [UIBezierPath bezierPath];
    if (isTimerMode) {
        [innerCircle addArcWithCenter:center radius:centerRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];
        [innerCircle addArcWithCenter:center radius:innerRadius startAngle:M_PI*2 endAngle:0 clockwise:NO];
    } else {
        [innerCircle addArcWithCenter:center radius:centerRadius startAngle:innerStartAngle+startAngle endAngle:innerAngle+startAngle clockwise:YES];
        [innerCircle addArcWithCenter:center radius:innerRadius startAngle:innerAngle+startAngle endAngle:innerStartAngle+startAngle clockwise:NO];
    }
    //[innerCircle closePath];
    
    UIBezierPath *innerFill = [UIBezierPath bezierPath];
    if (!isTimerMode) {
        [innerFill addArcWithCenter:center radius:centerRadius startAngle:innerStartAngle+startAngle endAngle:M_PI*2 clockwise:YES];
        [innerFill addArcWithCenter:center radius:innerRadius startAngle:innerStartAngle+startAngle endAngle:innerAngle+startAngle clockwise:NO];
    }
    //[innerFill closePath];
    
    UIBezierPath *centerCircle = [UIBezierPath bezierPathWithOvalInRect:centerRect];
    
    [[theme objectForKey:@"outerColor"] setFill];       [outerCircle fill];
    [[theme objectForKey:@"outerFillColor"] setFill];   [outerFill fill];
    
    [[theme objectForKey:@"innerColor"] setFill];       [innerCircle fill];
    [[theme objectForKey:@"innerFillColor"] setFill];   [innerFill fill];

    [[theme objectForKey:@"centerColor"] setFill];      [centerCircle fill];
    
    // thicker lines
    
    UIBezierPath *innerLine = [UIBezierPath bezierPath];
    [innerLine moveToPoint:[self vectorFromAngle:innerAngle distance:centerRadius origin:center]];
    [innerLine addLineToPoint:[self vectorFromAngle:innerAngle distance:innerRadius origin:center]];
    
    if (!isTimerMode) {
        [[theme objectForKey:@"innerHandleColor"] setStroke];
        innerLine.lineWidth = 2;    [innerLine stroke];
            
        [[theme objectForKey:@"outerHandleColor"] setStroke];
        outerLine.lineWidth = 2;    [outerLine stroke];
    }
    
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

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
@synthesize handleSelected;
@synthesize innerAngle, outerAngle;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setNeedsDisplay];
        handleSelected = SelectDurationNoHandle;
        draggingOrientation = SelectDurationDraggingNone;
        
        originalFrame = frame;
        
        // set the picker sizes
        outerRadius = 143;
        innerRadius = 101;
        centerRadius = 65;
        
        handleSelected = SelectDurationNoHandle;
        
        center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        
        //TESTING
        [self setBackgroundColor:[UIColor whiteColor]];
        outerAngle = DEGREES_TO_RADIANS(105);
        innerAngle = DEGREES_TO_RADIANS(223);
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame delegate:(id<SelectDurationViewDelegate>)aDelegate {
    delegate = aDelegate;
    return [self initWithFrame:frame];
}

#pragma mark - Touches
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    CGPoint touchLoc = [touch locationInView:self];
    touchLoc = CGPointMake(touchLoc.x - center.x, touchLoc.y - center.y); // touch rel to center
    float distToTouch = sqrtf(powf(touchLoc.x, 2) + powf(touchLoc.y,2));
    float angleToTouch = [self angleFromVector:touchLoc];
    
    // test to see if touch is in range of any handles
    float handlePadding = DEGREES_TO_RADIANS(7);
    if (distToTouch < centerRadius) {
        handleSelected = SelectDurationCenterHandle;
    } else if (distToTouch <= innerRadius && angleToTouch < innerAngle+handlePadding && angleToTouch > innerAngle-handlePadding) {
        handleSelected = SelectDurationInnerHandle;
    } else if (distToTouch > innerRadius && distToTouch <= outerRadius && angleToTouch < outerAngle+handlePadding && angleToTouch > outerAngle-handlePadding) {
        handleSelected = SelectDurationOuterHandle;
    } else {
        handleSelected = SelectDurationNoHandle;
    }
    
    if (handleSelected == SelectDurationOuterHandle || handleSelected == SelectDurationInnerHandle) {
        if ([delegate respondsToSelector:@selector(durationDidBeginChanging:)])
            [delegate durationDidBeginChanging:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UIView *delegateView = (UIView *)delegate;
    
    UITouch *touch = [touches anyObject];
    
    CGPoint touchLoc = [touch locationInView:self];
    CGPoint prevTouchLoc = [touch previousLocationInView:self];
    CGSize touchVel = CGSizeMake(touchLoc.x-prevTouchLoc.x, touchLoc.y-prevTouchLoc.y);
    
    touchLoc = CGPointMake(touchLoc.x - center.x, touchLoc.y - center.y); // touch rel to center
    float angleToTouch = [self angleFromVector:touchLoc];
    
    // change angle of circles based handle selected
    if (handleSelected == SelectDurationOuterHandle) {
        outerAngle = angleToTouch;
        [self setNeedsDisplay];
        
    } else if (handleSelected == SelectDurationInnerHandle) {
        innerAngle = angleToTouch;
        [self setNeedsDisplay];
        
    } else if (handleSelected == SelectDurationCenterHandle || handleSelected == SelectDurationNoHandle) {
        // touchLoc need to be in parent because picker will be moving
        CGPoint parentTouchLoc = [touch locationInView:delegateView];
        CGPoint parentPrevTouchLoc = [touch previousLocationInView:delegateView];
        touchVel = CGSizeMake(parentTouchLoc.x-parentPrevTouchLoc.x, parentTouchLoc.y-parentPrevTouchLoc.y);
        
        CGRect newFrame = self.frame;
        if (draggingOrientation == SelectDurationDraggingNone) {
            if (fabsf(touchVel.width) - 3 > fabsf(touchVel.height))
                draggingOrientation = SelectDurationDraggingHoriz;
            else if (touchVel.height < 0 && fabsf(touchVel.height) - 3 > fabsf(touchVel.width))
                draggingOrientation = SelectDurationDraggingVert;
            else 
                draggingOrientation = SelectDurationDraggingNone;
        }
        if (draggingOrientation == SelectDurationDraggingHoriz) {
            newFrame = CGRectOffset(self.frame, touchVel.width, 0);
            [self setFrame:newFrame];
        } else if (draggingOrientation == SelectDurationDraggingVert) {
            CGRect proposedFrame = CGRectOffset(self.frame, 0, touchVel.height);
            if (proposedFrame.origin.y <= originalFrame.origin.y)
                newFrame = proposedFrame;
            else 
                newFrame = originalFrame;
        }
        
        [self setFrame:newFrame];
        
        if (touchVel.height < -30)
            NSLog(@"swipeUp");
    }
    
    if (handleSelected == SelectDurationOuterHandle || handleSelected == SelectDurationInnerHandle) {
        if ([delegate respondsToSelector:@selector(durationDidChange:)])
            [delegate durationDidChange:self];
    }
        
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    handleSelected = SelectDurationNoHandle;
    draggingOrientation = SelectDurationDraggingNone;
    
    if (!CGRectEqualToRect(self.frame, originalFrame)) {
        [UIView animateWithDuration:.2 animations:^{
            [self setFrame:originalFrame];
        }];
    }
    
    if ([delegate respondsToSelector:@selector(durationDidEndChanging:)])
        [delegate durationDidEndChanging:self];
}

#pragma mark - Properties
-(NSTimeInterval) getTimeInterval {
    float outerValue = (outerAngle / (M_PI*2));
    float innerValue = (innerAngle / (M_PI*2));
    
    // convert ratios to hours. max hours: 23. max minutes: 59
    int hours = (int)(innerValue * 24);
    int minutes = (int)(outerValue * 60);
    
    return hours * 3600 + minutes * 60;
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

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{   
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
    
    [[UIColor colorWithWhite:.8 alpha:1] setFill];  [outerCircle fill];
    [[UIColor colorWithWhite:.4 alpha:.7] setFill]; [innerCircle fill];
    [[UIColor colorWithWhite:.1 alpha:.7] setFill]; [centerCircle fill];
    
    // draw the rings
    CGRect outerRect = CGRectMake(center.x-outerRadius, center.y-outerRadius, outerRadius*2, outerRadius*2);
    CGRect innerRect = CGRectMake(center.x-innerRadius, center.y-innerRadius, innerRadius*2, innerRadius*2);
    
    UIBezierPath *outerOutline = [UIBezierPath bezierPathWithOvalInRect:outerRect];
    UIBezierPath *innerOutline = [UIBezierPath bezierPathWithOvalInRect:innerRect];
    
    [[UIColor grayColor] setStroke];
    outerOutline.lineWidth = 1; [outerOutline stroke];
    innerOutline.lineWidth = 1; [innerOutline stroke];
}

@end

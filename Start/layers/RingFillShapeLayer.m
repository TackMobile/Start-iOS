//
//  RingFillShapeLayer.m
//  Start
//
//  Created by Nick Place on 12/26/12.
//
//

#import "RingFillShapeLayer.h"

@implementation RingFillShapeLayer
@synthesize innerRadius, outerRadius, startAngle, endAngle;
@synthesize fillColor, handleColor;

- (void) displayLayer:(CALayer *)layer {
    float beginAngle = -M_2_PI;

    // OUTER CIRCLE
    UIBezierPath *outerCirclePath = [UIBezierPath bezierPath];
    [outerCirclePath addArcWithCenter:CGPointZero radius:innerRadius startAngle:startAngle+beginAngle endAngle:endAngle+beginAngle clockwise:YES];
    [outerCirclePath addArcWithCenter:CGPointZero radius:outerRadius startAngle:startAngle+beginAngle endAngle:endAngle+beginAngle clockwise:NO];
    
    // OUTER HANDLE
    UIBezierPath *outerHandlePath = [UIBezierPath bezierPath];
    [outerHandlePath moveToPoint:[self vectorFromAngle:endAngle distance:innerRadius origin:CGPointZero]];
    [outerHandlePath addLineToPoint:[self vectorFromAngle:endAngle distance:outerRadius origin:CGPointZero]];
    
    
    // DRAW
    fillLayer.path = outerCirclePath.CGPath;
    fillLayer.fillColor = [fillColor CGColor];
    
    handleLayer.path = outerHandlePath.CGPath;
    handleLayer.lineWidth = 2.0;
    handleLayer.strokeColor = [handleColor CGColor];
    
    [layer addSublayer:fillLayer];
    [layer addSublayer:handleLayer];

}

- (CGPoint) vectorFromAngle:(float)angle distance:(float)distance origin:(CGPoint)origin {
    CGPoint vector;
    angle = angle + -M_2_PI;
    vector.y = roundf( distance * sinf( angle ) );
    vector.x = roundf( distance * cosf( angle ) );
    return CGPointAddPoint(vector, origin);
}

CGPoint CGPointAddPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake(p1.x+p2.x, p1.y+p2.y);
}



@end

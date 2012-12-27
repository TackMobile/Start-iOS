//
//  RingFillShapeLayer.h
//  Start
//
//  Created by Nick Place on 12/26/12.
//
//

#import <QuartzCore/QuartzCore.h>
#define DEGREES_TO_RADIANS(degrees) ((M_PI * degrees)/ 180)

@interface RingFillShapeLayer : CALayer {
    CAShapeLayer *fillLayer;
    CAShapeLayer *handleLayer;
    CAShapeLayer *ringLayer;

}

@property (nonatomic) CGFloat innerRadius;
@property (nonatomic) CGFloat outerRadius;

@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat endAngle;

@property (nonatomic, strong) UIColor *ringFillColor;
@property (nonatomic, strong) UIColor *ringStrokeColor;
@property (nonatomic, strong) UIColor *handleColor;
@property (nonatomic, strong) UIColor *ringColor;



@end

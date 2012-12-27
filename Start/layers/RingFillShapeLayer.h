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

@property (nonatomic) float innerRadius;
@property (nonatomic) float outerRadius;

@property (nonatomic) float startAngle;
@property (nonatomic) float endAngle;

@property (nonatomic, strong) UIColor *ringFillColor;
@property (nonatomic, strong) UIColor *ringStrokeColor;
@property (nonatomic, strong) UIColor *handleColor;
@property (nonatomic, strong) UIColor *ringColor;



@end

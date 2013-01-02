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
}

@property (nonatomic) bool shouldAnimate;

@property (nonatomic) CGFloat innerRadius;
@property (nonatomic) CGFloat outerRadius;

@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat endAngle;

@property (nonatomic, strong) UIColor *ringFillColor;
@property (nonatomic, strong) UIColor *ringStrokeColor;
@property (nonatomic, strong) UIColor *handleColor;
@property (nonatomic, strong) UIColor *ringColor;

@property (nonatomic, strong) CAShapeLayer *ringLayer;
@property (nonatomic, strong) CAShapeLayer *handleLayer;
@property (nonatomic, strong) CAShapeLayer *fillLayer;


- (void) setValue:(id)value forKey:(NSString *)key animated:(bool)animated;


@end

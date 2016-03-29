//
//  RingFillShapeLayer.h
//  Start
//
//  Created by Nick Place on 12/26/12.
//
//

#import <QuartzCore/QuartzCore.h>
#define DEGREES_TO_RADIANS(degrees) ((M_PI * degrees)/ 180)

@interface RingFillShapeLayer : CALayer 
@property (nonatomic, strong) id animDelegate;

@property (atomic, strong) NSString *ringName;

@property (nonatomic) bool shouldAnimate;

@property (nonatomic) CGFloat innerRadius;
@property (nonatomic) CGFloat outerRadius;

@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat endAngle;

@property (atomic, strong) UIColor *ringFillColor;
@property (atomic, strong) UIColor *ringStrokeColor;
@property (atomic, strong) UIColor *handleColor;
@property (atomic, strong) UIColor *ringColor;

@property (atomic, strong) CAShapeLayer *ringLayer;
@property (atomic, strong) CAShapeLayer *handleLayer;
@property (atomic, strong) CAShapeLayer *fillLayer;


- (void) setValue:(id)value forKey:(NSString *)key animated:(bool)animated;

@end

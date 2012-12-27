//
//  RingFillShapeLayer.h
//  Start
//
//  Created by Nick Place on 12/26/12.
//
//

#import <QuartzCore/QuartzCore.h>

@interface RingFillShapeLayer : CAShapeLayer {
    CAShapeLayer *fillLayer;
    CAShapeLayer *handleLayer;
}

@property (nonatomic) float innerRadius;
@property (nonatomic) float outerRadius;

@property (nonatomic) float startAngle;
@property (nonatomic) float endAngle;

@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *handleColor;



@end

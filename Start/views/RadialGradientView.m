//
//  radialGradientView.m
//  Start
//
//  Created by Nick Place on 9/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RadialGradientView.h"

@implementation RadialGradientView
@synthesize innerColor, outerColor;

- (id) init {
  self =[super init];
  if (self) {
    innerColor = [UIColor colorWithWhite:.4 alpha:1];
    outerColor = [UIColor colorWithWhite:.6 alpha:1];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    innerColor = [UIColor colorWithWhite:.4 alpha:1];
    outerColor = [UIColor colorWithWhite:.6 alpha:1];
  }
  return self;
}

- (void)setInnerColor:(UIColor *)iColor outerColor:(UIColor *)oColor {
  innerColor = iColor;
  outerColor = oColor;
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
  CGFloat innerComponents[4];
  CGFloat outerComponents[4];
  
  if ([innerColor respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
    [innerColor getRed:&innerComponents[0] green:&innerComponents[1] blue:&innerComponents[2] alpha:nil];
  } else {
    const CGFloat *components = CGColorGetComponents(innerColor.CGColor);
    innerComponents[0] = components[0];
    innerComponents[1] = components[1];
    innerComponents[2] = components[2];
  }
  innerComponents[3] = 1;
  
  if ([outerColor respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
    [outerColor getRed:&outerComponents[0] green:&outerComponents[1] blue:&outerComponents[2] alpha:nil];
  } else {
    const CGFloat *components = CGColorGetComponents(outerColor.CGColor);
    outerComponents[0] = components[0];
    outerComponents[1] = components[1];
    outerComponents[2] = components[2];
  }
  outerComponents[3] = 1;
  
  CGContextRef currentContext = UIGraphicsGetCurrentContext();
  
  CGGradientRef gradient;
  CGColorSpaceRef rgbColorspace;
  size_t num_locations = 4;
  CGFloat locations[4] = { 0.0, 0.18, 0.82, 1.0 };
  CGFloat components[16] = {
    innerComponents[0], innerComponents[1], innerComponents[2], innerComponents[3],  // Start color
    innerComponents[0], innerComponents[1], innerComponents[2], innerComponents[3],
    outerComponents[0], outerComponents[1], outerComponents[2], outerComponents[3],
    outerComponents[0], outerComponents[1], outerComponents[2], outerComponents[3]}; // End color
  
  rgbColorspace = CGColorSpaceCreateDeviceRGB();
  gradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
  
  CGPoint center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + 23);
  CGContextDrawRadialGradient(currentContext, gradient,
                              center, 0,
                              center, center.x * 1.52, 0);
  CGGradientRelease(gradient);
  CGColorSpaceRelease(rgbColorspace);
}

@end

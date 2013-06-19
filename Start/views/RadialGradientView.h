//
//  radialGradientView.h
//  Start
//
//  Created by Nick Place on 9/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RadialGradientView : UIView

@property (strong) UIColor *innerColor;
@property (strong) UIColor *outerColor;

- (void)setInnerColor:(UIColor *)iColor outerColor:(UIColor *)oColor;

@end

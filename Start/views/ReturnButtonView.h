//
//  ReturnButtonView.h
//  Start
//
//  Created by Nick Place on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReturnButtonView : UIView

@property (strong, nonatomic) UIButton *button;
@property CGRect cellRect;
@property float sectionHeight;

- (id)initWithCellRect:(CGRect)aCellRect sectionHeight:(float)sHeight;

-(void) updateWithContentOffset:(float)cOffset;
@end

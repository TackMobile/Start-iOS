//
//  LeftHeaderView.h
//  Start
//
//  Created by Nick Place on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftHeaderView : UIView

@property (strong, nonatomic) UIImageView *icon;
@property CGRect cellRect;
@property float sectionHeight;

- (id)initWithCellRect:(CGRect)aCellRect sectionHeight:(float)sHeight;

-(void) updateWithContentOffset:(float)cOffset;
- (void)updateCellRect:(CGRect)aCellRect;

@end

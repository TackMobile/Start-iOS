//
//  LeftHeaderView.m
//  Start
//
//  Created by Nick Place on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LeftHeaderView.h"

@implementation LeftHeaderView
@synthesize cellRect, sectionHeight, icon;

- (id)init
{
    self = [super init];
    if (self) {
        CGRect iconRect = CGRectMake(0, 0, 20, 20);
        
        icon = [[UIImageView alloc] initWithFrame:iconRect];
        [self addSubview:icon];
        
        self.frame = CGRectMake(0, cellRect.origin.y, 34, 34);
        [self layoutSubviews];
    }
    return self;
}

- (id)initWithCellRect:(CGRect)aCellRect sectionHeight:(float)sHeight {
    aCellRect = CGRectMake(0, aCellRect.origin.y+10, 0, aCellRect.size.height);
    sHeight -=36;
    
    cellRect = aCellRect;
    sectionHeight = sHeight;
    return [self init];
}

- (void)updateCellRect:(CGRect)aCellRect {
    aCellRect = CGRectMake(0, aCellRect.origin.y+10, 0, aCellRect.size.height);
    cellRect = aCellRect;
}

#pragma mark - positioning
- (void) updateWithContentOffset:(float)cOffset {
    if (cOffset >= cellRect.origin.y && 
        cellRect.origin.y+sectionHeight-self.frame.size.height > cOffset) { // make it sticky
        self.frame = CGRectMake(0, cOffset, self.frame.size.width, self.frame.size.height);
    } else if (cellRect.origin.y+sectionHeight-self.frame.size.height <= cOffset) { // scrolled past it
        self.frame = CGRectMake(0, cellRect.origin.y+sectionHeight-self.frame.size.height, self.frame.size.width, self.frame.size.height);
    } else { // has not scrolled past yet
        self.frame = CGRectMake(0, cellRect.origin.y, self.frame.size.width, self.frame.size.height);
    }
}

- (void) layoutSubviews {
    CGRect iconRect = CGRectMake((self.frame.size.width-icon.frame.size.width)/2, (self.frame.size.height-icon.frame.size.height)/2, icon.frame.size.width, icon.frame.size.height);
    [icon setFrame:iconRect];
}


@end

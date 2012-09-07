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
        
        _topPadding = 0;
        
        self.frame = CGRectMake(0, cellRect.origin.y, 34, 34);
        [self layoutSubviews];
    }
    return self;
}

- (id)initWithCellRect:(CGRect)aCellRect sectionHeight:(float)sHeight {
    aCellRect = CGRectMake(0, aCellRect.origin.y, 0, aCellRect.size.height);
    
    cellRect = aCellRect;
    sectionHeight = sHeight;
    _sectionHeight = sHeight;
    return [self init];
}

- (void)updateCellRect:(CGRect)aCellRect {
    aCellRect = CGRectMake(0, aCellRect.origin.y, 0, aCellRect.size.height);
    cellRect = aCellRect;
}

- (void) setTopPadding:(float)topPadding {
    _topPadding = topPadding;
    _sectionHeight = sectionHeight - (cellRect.size.height-topPadding);
}
- (float) topPadding {
    return _topPadding;
}

#pragma mark - positioning
- (void) updateWithContentOffset:(float)cOffset {
    if (cellRect.origin.y+_sectionHeight  <= cOffset) { // scrolled past it
        self.frame = CGRectMake(0, cellRect.origin.y+_sectionHeight, 
                                self.frame.size.width, 
                                self.frame.size.height);
    } else if (cOffset >= cellRect.origin.y + _topPadding && 
        cellRect.origin.y+_sectionHeight > cOffset) { // make it sticky
        self.frame = CGRectMake(0, cOffset, 
                                self.frame.size.width, 
                                self.frame.size.height);
    } else { // has not scrolled past yet
        self.frame = CGRectMake(0, cellRect.origin.y + _topPadding, self.frame.size.width, self.frame.size.height);
    }
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect iconRect = CGRectMake((self.frame.size.width-icon.frame.size.width)/2, 
                                 _topPadding,
                                 icon.frame.size.width, icon.frame.size.height);
    [icon setFrame:iconRect];
}


@end

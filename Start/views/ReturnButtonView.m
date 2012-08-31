//
//  ReturnButtonView.m
//  Start
//
//  Created by Nick Place on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReturnButtonView.h"

@implementation ReturnButtonView
@synthesize cellRect, sectionHeight, button;

- (id)init
{
    self = [super init];
    if (self) {
        CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;
        
        CGRect buttonRect = CGRectMake(0, 0, screenSize.width-245, screenSize.height);
        
        button = [[UIButton alloc] initWithFrame:buttonRect];
        [self addSubview:button];
                
        self.frame = CGRectMake(245, cellRect.origin.y, buttonRect.size.width, buttonRect.size.height);
        [self layoutSubviews];
    }
    return self;
}

- (id)initWithCellRect:(CGRect)aCellRect sectionHeight:(float)sHeight {    
    cellRect = aCellRect;
    sectionHeight = sHeight;
    return [self init];
}

#pragma mark - positioning
- (void) updateWithContentOffset:(float)cOffset {
    if (cOffset >= cellRect.origin.y && 
        cellRect.origin.y+sectionHeight-self.frame.size.height > cOffset) { // make it sticky
        self.frame = CGRectMake(245, cOffset, self.frame.size.width, self.frame.size.height);
    } else if (cellRect.origin.y+sectionHeight-self.frame.size.height <= cOffset) { // scrolled past it
        self.frame = CGRectMake(245, cellRect.origin.y+sectionHeight-self.frame.size.height, self.frame.size.width, self.frame.size.height);
    } else { // has not scrolled past yet
        self.frame = CGRectMake(245, cellRect.origin.y, self.frame.size.width, self.frame.size.height);
    }
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect buttonRect = CGRectMake(0, 0, button.frame.size.width, button.frame.size.height);
    [button setFrame:buttonRect];
}


@end
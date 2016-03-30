//
//  ActionCell.m
//  Start
//
//  Created by Nick Place on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ActionCell.h"

@implementation ActionCell

static CGFloat const padding = 26;
static CGFloat const ActionFontSize = 30.0f;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _actionTitle = [[UILabel alloc] init];
        _icon = [[UIImageView alloc] init];
        UIFont *actionLabelFont = [UIFont fontWithName:@"Roboto-Thin" size:ActionFontSize];
        
        _actionTitle.font = actionLabelFont;
        _actionTitle.textColor = [UIColor whiteColor];
        _actionTitle.backgroundColor = [UIColor clearColor];
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:_actionTitle];
        [self addSubview:_icon];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    [self.icon sizeToFit];
    
    float height = self.frame.size.height;
    CGSize titleSize = [[self.actionTitle text] sizeWithFont:[self.actionTitle font]];
    CGSize iconSize = self.icon.image.size;
    
    CGRect iconRect = CGRectMake(0, (height-iconSize.height)/2, iconSize.width, iconSize.height);
    CGRect titleRect = CGRectMake(0+iconSize.width+padding, (height-titleSize.height)/2, self.frame.size.width-(0+iconSize.width+padding), titleSize.height);
    
    [self.actionTitle setFrame:titleRect];
    [self.icon setFrame:iconRect];
}

@end

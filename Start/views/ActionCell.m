//
//  ActionCell.m
//  Start
//
//  Created by Nick Place on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ActionCell.h"

@implementation ActionCell
@synthesize actionTitle, icon;

const float padding = 26;
//const float indent = 0;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        actionTitle = [[UILabel alloc] init];
        icon = [[UIImageView alloc] init];
        
        UIFont *actionLabelFont = [UIFont fontWithName:@"Roboto-Thin" size:30];
        
        [actionTitle setFont:actionLabelFont];  [actionTitle setTextColor:[UIColor whiteColor]];
        [actionTitle setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:actionTitle];
        [self addSubview:icon];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    [icon sizeToFit];
    
    float height = self.frame.size.height;
    CGSize titleSize = [[actionTitle text] sizeWithFont:[actionTitle font]];
    CGSize iconSize = icon.image.size;
    
    CGRect iconRect = CGRectMake(0, (height-iconSize.height)/2, iconSize.width, iconSize.height);
    CGRect titleRect = CGRectMake(0+iconSize.width+padding, (height-titleSize.height)/2, self.frame.size.width-(0+iconSize.width+padding), titleSize.height);
    
    [actionTitle setFrame:titleRect];
    [icon setFrame:iconRect];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

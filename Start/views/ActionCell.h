//
//  ActionCell.h
//  Start
//
//  Created by Nick Place on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionCell : UITableViewCell

@property (nonatomic, strong) UILabel *actionTitle;
@property (nonatomic, strong) UIImageView *icon;

@property float labelOpacity;

-(void) hide;
-(void) show;

@end

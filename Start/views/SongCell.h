//
//  SongCell.h
//  Start
//
//  Created by Nick Place on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicPlayer.h"

@interface SongCell : UITableViewCell {
    MusicPlayer *musicPlayer;
}

@property NSNumber *persistentID;

@property (nonatomic, strong) UILabel *songLabel;
@property (nonatomic, strong) UILabel *artistLabel;

-(void) longPress:(UIGestureRecognizer *)gestRecog;

@end

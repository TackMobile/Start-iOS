//
//  SongCell.m
//  Start
//
//  Created by Nick Place on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SongCell.h"

@implementation SongCell
@synthesize artistLabel, songLabel, persistentID;

const float indent = 34;
const float spacer = -2;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        persistentID =[[NSNumber alloc] initWithInt:-1 ];
        musicPlayer = [[MusicPlayer alloc]init];
        
        songLabel = [[UILabel alloc] init];
        artistLabel = [[UILabel alloc] init];
        
        UIFont *songLabelFont = [UIFont fontWithName:@"Roboto-Thin" size:30];
        UIFont *artistLabelFont = [UIFont fontWithName:@"Roboto-Light" size:16];
        
        [songLabel setFont:songLabelFont];      [songLabel setTextColor:[UIColor whiteColor]];
        [songLabel setBackgroundColor:[UIColor clearColor]];
        [artistLabel setFont:artistLabelFont];  [artistLabel setTextColor:[UIColor whiteColor]];
        [artistLabel setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:songLabel];
        [self addSubview:artistLabel];
        
        // gestureRecognizer
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [longPress setMinimumPressDuration:.2];
        [self addGestureRecognizer:longPress];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    float cellHeight = self.frame.size.height;
    float cellWidth = 245;
    CGSize songSize = [[songLabel text] sizeWithFont:[songLabel font]];
    CGSize artistSize = [[artistLabel text] sizeWithFont:[artistLabel font]];
    float topSpacer = (cellHeight - (songSize.height + spacer + artistSize.height))/2;
    
    CGRect songRect = CGRectMake(indent, topSpacer, cellWidth-indent, songSize.height);
    CGRect artistRect = CGRectMake(indent, topSpacer+songSize.height+spacer, cellWidth-indent, artistSize.height);
        
    [songLabel setFrame:songRect];
    [artistLabel setFrame:artistRect];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - gestures
-(void) longPress:(UIGestureRecognizer *)gestRecog {
    if ([persistentID intValue] != -1 && gestRecog.state == UIGestureRecognizerStateBegan)
        [musicPlayer playSongWithID:persistentID];
    
    if (gestRecog.state == UIGestureRecognizerStateEnded)
        [musicPlayer stop];
}

@end

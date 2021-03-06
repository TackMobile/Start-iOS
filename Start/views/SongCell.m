//
//  SongCell.m
//  Start
//
//  Created by Nick Place on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SongCell.h"
#import "Constants.h"

@implementation SongCell
@synthesize artistLabel, songLabel, persistentID;
@synthesize delegate;

const float indent = 34;
const float spacer = -2;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    persistentID =[[NSNumber alloc] initWithInt:-1 ];
    
    songLabel = [[UILabel alloc] init];
    artistLabel = [[UILabel alloc] init];
    
    artistLabel.lineBreakMode = NSLineBreakByCharWrapping;
    artistLabel.numberOfLines = 0;
    
    UIFont *songLabelFont = [UIFont fontWithName:StartFontName.robotoThin size:30];
    UIFont *artistLabelFont = [UIFont fontWithName:StartFontName.robotoLight size:16];
    
    [songLabel setFont:songLabelFont];      [songLabel setTextColor:[UIColor whiteColor]];
    [songLabel setBackgroundColor:[UIColor clearColor]];
    [artistLabel setFont:artistLabelFont];  [artistLabel setTextColor:[UIColor whiteColor]];
    [artistLabel setBackgroundColor:[UIColor clearColor]];
    
    [self addSubview:songLabel];
    [self addSubview:artistLabel];
    self.backgroundColor = [UIColor clearColor];
    [self layoutSubviews];
    
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
  float cellWidth = self.frame.size.width;
  CGSize songSize = [songLabel.text sizeWithAttributes:@{NSFontAttributeName : songLabel.font}];
  CGRect rect = [artistLabel.text boundingRectWithSize:CGSizeMake(245, cellHeight/2) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: artistLabel.font} context:nil];
  CGSize artistSize = rect.size;
  
  float topSpacer = (cellHeight - (songSize.height + spacer + artistSize.height))/2;
  
  CGRect songRect = CGRectMake(indent, topSpacer, cellWidth-indent, songSize.height);
  CGRect artistRect = CGRectMake(indent, topSpacer+songSize.height+spacer, cellWidth-indent, artistSize.height);
  
  [songLabel setFrame:songRect];
  [artistLabel setFrame:artistRect];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  
  // Configure the view for the selected state
}

#pragma mark - Gestures

- (void)longPress:(UIGestureRecognizer *)gestRecog {
  if ([delegate respondsToSelector:@selector(sampleSongWithID:)] && [persistentID intValue] != -1 && gestRecog.state == UIGestureRecognizerStateBegan) {
    [delegate sampleSongWithID:persistentID];
  }
  
  if ((gestRecog.state == UIGestureRecognizerStateEnded || gestRecog.state == UIGestureRecognizerStateCancelled || gestRecog.state == UIGestureRecognizerStateFailed) && [delegate respondsToSelector:@selector(stopSamplingSong)]) {
    [delegate stopSamplingSong];
  }
}

@end

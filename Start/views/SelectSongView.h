//
//  SelectSongView.h
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 TackMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MusicManager.h"
#import "MusicPlayer.h"
#import "SongCell.h"
#import "SearchSongCell.h"

@protocol SelectSongViewDelegate <NSObject>
-(BOOL) expandSelectSongView;
-(void) songSelected:(NSNumber *)persistentMediaItemID withArtwork:(UIImage *)artwork theme:(NSNumber *)themeID;
-(void) compressSelectSong;
-(id) getDelegateMusicPlayer;

@end

@interface SelectSongView : UIView <UITableViewDataSource, UITableViewDelegate, SearchSongCellDelegate, SongCellDelegate, UIAlertViewDelegate>

@property (nonatomic) BOOL isOpen;
@property (nonatomic) BOOL isSearching;
@property (nonatomic) BOOL artworkPresent;

@property (nonatomic, strong) id<SelectSongViewDelegate> delegate;
@property (nonatomic, strong) MusicManager *musicManager;

@property (nonatomic, strong) UITableView *songTableView;
@property (nonatomic, strong) UIView *songDurationIndicator;

@property (nonatomic, strong) SongCell *cell;
@property (nonatomic, strong) SongCell *showCell;
- (void) quickSelectCell;
- (void) selectCellWithID:(NSNumber *)cellNumID ;
- (void)songPlayingTick:(MusicPlayer *)aMusicPlayer;
- (id) initWithFrame:(CGRect)frame delegate:(id<SelectSongViewDelegate>)aDelegate presetSongs:(NSArray *)thePresetSongs;

@end
//
//  SelectSongView.h
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 TackMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicManager.h"
#import "SongCell.h"
#import "SearchSongCell.h"
#import "LeftHeaderView.h"
#import "ReturnButtonView.h"

@protocol SelectSongViewDelegate <NSObject>
-(BOOL) expandSelectSongView;
-(void) songSelected:(NSNumber *)persistentMediaItemID withArtwork:(UIImage *)artwork theme:(NSNumber *)themeID;
-(void) compressSelectSong;
// - (void) song selected with album artwork:

@end


@interface SelectSongView : UIView <UITableViewDataSource, UITableViewDelegate, SearchSongCellDelegate, SongCellDelegate> {
    bool isOpen;
    bool isSearching;
    bool artworkPresent;
    NSIndexPath *selectedIndexPath;
    
    CGRect compressedFrame;
    NSArray *librarySongs;
    NSArray *searchedSongs;
    NSArray *presetSongs;
    
    NSMutableArray *headerViews;
    
    MusicPlayer *musicPlayer;
}
@property (nonatomic, strong) id<SelectSongViewDelegate> delegate;

@property (nonatomic, strong) MusicManager *musicManager;

@property (nonatomic, strong) UITableView *songTableView;
@property (nonatomic, strong) UIView *songDurationIndicator;

- (void) quickSelectCell;
- (void) selectCellWithID:(NSNumber *)cellNumID ;
-(void)songPlayingTick:(MusicPlayer *)aMusicPlayer;
- (id) initWithFrame:(CGRect)frame delegate:(id<SelectSongViewDelegate>)aDelegate presetSongs:(NSArray *)thePresetSongs;
@end
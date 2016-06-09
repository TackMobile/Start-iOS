//
//  SelectSongView.m
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectSongView.h"
#import "LeftHeaderView.h"
#import "ReturnButtonView.h"
#import "LocalizedStrings.h"
#import "Constants.h"

typedef NS_ENUM(NSInteger, NonSearchTableSection) {
  NonSearchSectionSearch,
  NonSearchSectionNoSound,
  NonSearchSectionPresetSongs,
  NonSearchSectionLibrarySongs,
  
  NonSearchSectionCount,
};

typedef NS_ENUM(NSInteger, SearchingTableSection) {
  SearchingSectionSearch,
  SearchingSectionLibrarySongs,
  
  SearchingSectionCount,
};

static CGFloat const ShorterRowHeight = 60.0f;
static CGFloat const TallerRowHeight = 70.0f;

@interface SelectSongView()

@property (nonatomic, strong) NSMutableArray *headerViews;
@property (nonatomic, strong) NSArray *librarySongs;
@property (nonatomic, strong) NSArray *searchedSongs;
@property (nonatomic, strong) NSArray *presetSongs;
@property (nonatomic) CGRect compressedFrame;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation SelectSongView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setClipsToBounds:YES];
    
    _compressedFrame = frame;
    _musicManager = [[MusicManager alloc] init];
    _librarySongs = [_musicManager getLibrarySongs];
    _isSearching = NO;
    _artworkPresent = NO;
    _headerViews = [[NSMutableArray alloc] init];
    _selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    
    // Views
    CGRect screenBounds = [[UIScreen mainScreen] applicationFrame];
    CGRect songTableRect = CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height);
    CGRect songDurIndRect = CGRectMake(0, 0, 0, 2);
    
    _songTableView = [[UITableView alloc] initWithFrame:songTableRect style:UITableViewStylePlain];
    _songDurationIndicator = [[UIView alloc] initWithFrame:songDurIndRect];
    
    [self addSubview:_songTableView];
    [self addSubview:_songDurationIndicator];
    
    _songTableView.userInteractionEnabled = NO;
    _songTableView.delegate = self;
    _songTableView.dataSource = self;
    _songTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _songTableView.rowHeight = TallerRowHeight;
    _songTableView.backgroundColor = [UIColor clearColor];
    
    [_songTableView reloadData];
    
    _songDurationIndicator.backgroundColor = [UIColor whiteColor];
    
    // set up the headers
    NSArray *headerIcons = [NSArray arrayWithObjects:[UIImage imageNamed:@"no-sound-icon"],
                            [UIImage imageNamed:@"tone-icon"], [UIImage imageNamed:@"song-icon"], nil];
    for (int i=1; i<4; i++) {
      if (i == 3 && _librarySongs.count == 0) {
        //Breaks if there are no library songs loaded
        break;
      }
      
      UIImage *icon = [headerIcons objectAtIndex:i-1];
      NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:0 inSection:i];
      NSIndexPath *lastCellPath = [NSIndexPath indexPathForRow:[_songTableView numberOfRowsInSection:i]-1 inSection:i];
      
      
      CGRect cellRect = [_songTableView rectForRowAtIndexPath:cellIndexPath];
      CGRect lastRect = [_songTableView rectForRowAtIndexPath:lastCellPath];
      
      LeftHeaderView *headerView = [[LeftHeaderView alloc] initWithCellRect:cellRect sectionHeight:lastRect.origin.y+lastRect.size.height-cellRect.origin.y];
      
      // Hard coded in because :(
      float topPadding = 0;
      if (cellIndexPath.section == 1) {
        topPadding = 7;
      } else if (cellIndexPath.section == 2) {
        topPadding = 10;
      } else if (cellIndexPath.section == 3) {
        topPadding = 8;
      }
      
      [headerView setTopPadding:topPadding];
      
      [headerView setAlpha:0];
      
      [headerView.icon setImage:icon];
      [_headerViews addObject:headerView];
      [_songTableView addSubview:headerView];
    }
    
    // Add the return button (it is invisible and stays on the right margin)
    ReturnButtonView *returnButton = [[ReturnButtonView alloc] initWithCellRect:[_songTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]
                                                                  sectionHeight:100000];
    [returnButton.button addTarget:self action:@selector(returnButtonTapped:) forControlEvents:UIControlEventTouchDown];
    [_songTableView addSubview:returnButton];
    [_headerViews addObject:returnButton];
    
    // Scroll away from search
    [_songTableView setContentOffset:CGPointMake(0, 67)];
    
    // Add the fade on the right
    float fadeXPos = 0.74f;
    float fadeWidth = .06;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    NSArray *gradientColors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:1 alpha:1] CGColor],
                               (id)[[UIColor colorWithWhite:1 alpha:1] CGColor],
                               (id)[[UIColor colorWithWhite:1 alpha:0] CGColor],
                               (id)[[UIColor colorWithWhite:1 alpha:0] CGColor],nil];
    
    NSArray *gradientLocations = [NSArray arrayWithObjects:
                                  [NSNumber numberWithFloat:0.0f],
                                  [NSNumber numberWithFloat:fadeXPos],
                                  [NSNumber numberWithFloat:fadeXPos+fadeWidth],
                                  [NSNumber numberWithFloat:1.0f], nil];
    
    [gradient setColors:gradientColors];
    [gradient setLocations:gradientLocations];
    [gradient setFrame:CGRectMake(0, 0, screenBounds.size.width, _songTableView.contentSize.height)];
    [gradient setStartPoint:CGPointMake(0, .5)]; // middle left
    [gradient setEndPoint:CGPointMake(1, .5)]; // middle right
    [self.layer setMask:gradient];
    [self.layer setMasksToBounds:YES];
    
    float searchHeight = [_songTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].size.height;
    
    CALayer *solidLayer = [CALayer layer];
    solidLayer.backgroundColor = [[UIColor whiteColor] CGColor];
    [solidLayer setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, searchHeight+1)];
    
    [gradient addSublayer:solidLayer];
    [_songTableView.layer setMask:gradient];
    [_songTableView.layer setMasksToBounds:YES];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<SelectSongViewDelegate>)aDelegate presetSongs:(NSArray *)thePresetSongs {
  _presetSongs = thePresetSongs;
  _delegate = aDelegate;
  return [self initWithFrame:frame];
}

- (void)returnButtonTapped:(id)button {
  [self quickSelectCell];
}

#pragma mark - Positioning

- (void)viewTapped {
  if ([self.delegate respondsToSelector:@selector(expandSelectSongView)])
  if ([self.delegate expandSelectSongView]) {
    [self.songTableView setUserInteractionEnabled:YES];
    
    // Show surrounding cells
    [UIView animateWithDuration:.2 animations:^{
      for (UITableViewCell *visibleCell in [self.songTableView visibleCells])
      [visibleCell setAlpha:1];
      for (UIView *headerView in self.headerViews)
      [headerView setAlpha:1];
    }];
  }
}

- (void)songSelected:(NSIndexPath *)indexPath {
  if (indexPath != self.selectedIndexPath || !self.artworkPresent) {
    
    self.selectedIndexPath = indexPath;
    
    NSNumber *songID = [[NSNumber alloc] init];
    UIImage *artwork = nil;
    
    NSNumber *themeID = [NSNumber numberWithInt:0];
    
    if (indexPath.section == 1) { // none
      songID = [NSNumber numberWithInt:-1];
      int rand = arc4random() % 5;
      themeID = [NSNumber numberWithInt:rand]; // random theme
    } else if (indexPath.section == 2) { // preset
      songID = @(indexPath.row);
      themeID = @(indexPath.row);
    } else if (indexPath.section == 3) {
      songID = [(MPMediaItem *)self.librarySongs[indexPath.row] valueForProperty:MPMediaItemPropertyPersistentID];
      themeID = @6;
    }
    
    if ([self.delegate respondsToSelector:@selector(songSelected:withArtwork:theme:)]) {
      self.artworkPresent = YES;
      // Testing
      [self.delegate songSelected:songID withArtwork:artwork theme:themeID];
    }
  }
}

- (void)quickSelectCell {
  if (self.isSearching) {
    [self endSearch];
  }
  [self tableView:self.songTableView didSelectRowAtIndexPath:self.selectedIndexPath];
}

- (void)selectCellWithID:(NSNumber *)cellNumID {
  [self.songTableView reloadData];
  if ([cellNumID isEqualToNumber:[NSNumber numberWithInt:-1]])
  self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];// No song
  else {
    self.selectedIndexPath = [self songIndexPathFromID:cellNumID];
  }
  [self quickSelectCell];
}

#pragma mark - Touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  if (touch.tapCount >= 1) {
    [self viewTapped];
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (self.isSearching) {
    switch (section) {
      case SearchingSectionSearch:
      return 1;
      break;
      case SearchingSectionLibrarySongs:
      return self.searchedSongs.count;
      break;
    }
  } else {
    switch (section) {
      case NonSearchSectionSearch:
      return 1;
      break;
      case NonSearchSectionNoSound:
      return 1;
      case NonSearchSectionPresetSongs:
      return self.presetSongs.count;
      break;
      case NonSearchSectionLibrarySongs:
      return self.librarySongs.count;
      break;
    }
  }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    SearchSongCell *cells = (SearchSongCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierString.searchCell];
    if (cells == nil) {
      cells = [[SearchSongCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierString.searchCell delegate:self];
      [cells setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return cells;
  }
  
  self.cell = (SongCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierString.normalSongCell];
  if (self.cell == nil) {
    self.cell = [[SongCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierString.normalSongCell];
    [self.cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self.cell setDelegate:self];
  }
  
  NSString *songTitle;
  NSString *songArtist;
  NSNumber *persistentID = [NSNumber numberWithInt:-1];
  MPMediaItem *cellSong;
  
  if (self.isSearching) {
    switch (indexPath.section) {
      case SearchingSectionLibrarySongs:
      cellSong = self.searchedSongs[indexPath.row];
      songTitle = [cellSong valueForProperty:MPMediaItemPropertyTitle];
      songArtist = [cellSong valueForProperty:MPMediaItemPropertyArtist];
      persistentID = [cellSong valueForProperty:MPMediaItemPropertyPersistentID];
      break;
    }
  } else {
    switch (indexPath.section) {
      case NonSearchSectionNoSound:
      songTitle = [LocalizedStrings noSound];
      songArtist = [LocalizedStrings tapToSelectOrPreview];
      break;
      case NonSearchSectionPresetSongs:
      songTitle = [self.presetSongs[indexPath.row] objectForKey:PresetSongsKey.title];
      songArtist = [self.presetSongs[indexPath.row] objectForKey:PresetSongsKey.artist];
      persistentID = @(indexPath.row);
      break;
      case NonSearchSectionLibrarySongs:
      cellSong = self.librarySongs[indexPath.row];
      songTitle = [cellSong valueForProperty:MPMediaItemPropertyTitle];
      songArtist = [cellSong valueForProperty:MPMediaItemPropertyArtist];
      persistentID = [cellSong valueForProperty:MPMediaItemPropertyPersistentID];
      break;
    }
  }
  
  self.cell.songLabel.text = songTitle;
  self.cell.artistLabel.text = songArtist;
  self.cell.persistentID = persistentID;
  [self.cell setAlpha:1];
  return self.cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if (self.isSearching) {
    return SearchingSectionCount;
  }
  if (self.librarySongs.count == 0) {
    return 3;
  } else {
    return NonSearchSectionCount;
  }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (self.isSearching) {
    return TallerRowHeight;
  }
  
  if (indexPath.section == NonSearchSectionNoSound) { // same height as other cells so the icon from left header is centered with the text from this row
    return ShorterRowHeight;
  }
  if (indexPath.section == NonSearchSectionPresetSongs) {
    return ([[self.presetSongs[indexPath.row] objectForKey:PresetSongsKey.artist] isEqualToString:@""])
    ?ShorterRowHeight:TallerRowHeight;
  }
  return TallerRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0 && indexPath.row == 0) {
    return;
  }
  
  if (self.isSearching) {
    SongCell *selectedCell = (SongCell *)[self.songTableView cellForRowAtIndexPath:indexPath];
    indexPath = [self songIndexPathFromID:selectedCell.persistentID];
    
    [self endSearch];
  }
  CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
  CGRect bottomRect = [tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:[tableView numberOfRowsInSection:[tableView numberOfSections]-1]-1 inSection:[tableView numberOfSections]-1]];
  
  // Center the cell
  float centerOffset = (self.compressedFrame.size.height-cellRect.size.height)/2;
  CGRect contentRect = CGRectMake(0, cellRect.origin.y-centerOffset, tableView.frame.size.width, tableView.frame.size.height);
  
  // Extend rect
  float bottom = contentRect.origin.y + contentRect.size.height;
  float maxBottom = bottomRect.origin.y + bottomRect.size.height;
  if (bottom >= maxBottom)
  [tableView setContentSize:CGSizeMake(tableView.frame.size.width, bottom)];
  else
  [tableView setContentSize:CGSizeMake(tableView.contentSize.width, maxBottom)];
  
  [tableView scrollRectToVisible:contentRect animated:YES];
  
  // Animation
  if ([self.delegate respondsToSelector:@selector(compressSelectSong)])
  [self.delegate compressSelectSong];
  
  [self.songTableView setUserInteractionEnabled:NO];
  
  // Hide cells above and below
  self.showCell = (SongCell *)[self.songTableView cellForRowAtIndexPath:indexPath];
  [UIView animateWithDuration:.2 animations:^{
    for (UITableViewCell *visibleCell in [self.songTableView visibleCells])
    [visibleCell setAlpha:(visibleCell == self.showCell)?1:0];
    for (UIView *headerView in self.headerViews)
    [headerView setAlpha:0];
  }];
  
  // Asynch
  [self performSelectorInBackground:@selector(songSelected:) withObject:indexPath];
}

- (NSIndexPath *)songIndexPathFromID:(NSNumber *)pID {
  if ([pID intValue] < 6 && [pID intValue] > -1) {
    // Preset song
    return [NSIndexPath indexPathForRow:[pID intValue] inSection:2];
    
  } else {
    int row = 0;
    for (int i=0; i<self.librarySongs.count; i++) {
      MPMediaItem *mediaItem = self.librarySongs[i];
      if ([pID intValue] == [[mediaItem valueForKey:MPMediaItemPropertyPersistentID] intValue]) {
        row = i;
        break;
      }
    }
    return [NSIndexPath indexPathForRow:row inSection:3];
  }
}

#pragma mark - scrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  SearchSongCell *searchCell = (SearchSongCell *)[self.songTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  [searchCell.textField resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  for (LeftHeaderView *headerView in self.headerViews)
  [headerView updateWithContentOffset:scrollView.contentOffset.y];
  
  // Move the fade out of way of the search divider
  float searchHeight = [self.songTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].size.height;
  CGRect maskFrame = self.layer.mask.frame;
  if (scrollView.contentOffset.y <= searchHeight){
    maskFrame.origin.x = scrollView.contentOffset.y;
  } else {
    maskFrame.origin.x = 0;
  }
  
  self.layer.mask.frame = maskFrame;
}

#pragma mark - searchSongCell delegate

- (void)textChanged:(UITextField *)textField {
  NSString *searchString = textField.text;
  if ([searchString isEqualToString:@""]) {
    self.searchedSongs = self.librarySongs;
  } else {
    NSMutableArray *applicableSongs = [[NSMutableArray alloc] init];
    
    for (MPMediaItem *mediaItem in self.librarySongs) {
      if ([[mediaItem valueForKey:MPMediaItemPropertyTitle] rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound ||
          [[mediaItem valueForKey:MPMediaItemPropertyArtist] rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
        [applicableSongs addObject:mediaItem];
      }
    }
    self.searchedSongs = applicableSongs;
  }
  
  [self.songTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)textCleared:(UITextField *)textField {
  self.searchedSongs = self.librarySongs;
  
  [self.songTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)didBeginSearching {
  self.searchedSongs = self.librarySongs;
  if (!self.isSearching) {
    self.isSearching = YES;
    
    // Hides No Sounds and Present Songs Sections, and only searches user's music
    [self.songTableView beginUpdates];
    [self.songTableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationFade];
    [self.songTableView endUpdates];
  }
  
  // Update the headers
  LeftHeaderView *songHeader = self.headerViews[2];
  CGRect sRect = [self.songTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  CGRect firstRect= CGRectOffset(sRect, 0, sRect.size.height);
  [songHeader updateCellRect:firstRect];
  [songHeader updateWithContentOffset:0];
  for (int i=0; i<2; i++)
  [self.headerViews[i] setAlpha:0];
}

- (void)didEndSearchingWithText:(NSString *)text {
  if ([text isEqualToString:@""] || [text isEqualToString:[LocalizedStrings search]]) {
    [self endSearch];
  }
}

- (bool)shouldBeginSearching {
  if (self.librarySongs.count > 0){
    return YES;
  }
  return NO;
}

- (void)endSearch {
  // Resign keyboard
  self.isSearching = NO;
  SearchSongCell *searchCell = (SearchSongCell *)[self.songTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  [searchCell.textField resignFirstResponder];
  searchCell.textField.text = @"";
  [self.songTableView reloadData];
  
  // Update the headers
  LeftHeaderView *songHeader = self.headerViews[2];
  [songHeader updateCellRect:[self.songTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]]];
  [songHeader updateWithContentOffset:0];
  for (int i=0; i<2; i++)
  [self.headerViews[i] setAlpha:1];
}

#pragma mark - songCellDelegate

- (void)sampleSongWithID:(NSNumber *)songID {
  MusicPlayer *musicPlayer = [self.delegate getDelegateMusicPlayer];
  [musicPlayer playSongWithID:songID vibrate:NO];
}

- (void)stopSamplingSong {
  [[self.delegate getDelegateMusicPlayer] stop];
}

- (void)songPlayingTick:(MusicPlayer *)aMusicPlayer {
  float screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
  float durationWidth = aMusicPlayer.playPercent * screenWidth;
  if (durationWidth == NAN)
  durationWidth = 1.0f;
  CGRect durRect = CGRectMake(0.0f, 0.0f, durationWidth, 2.0f);
  
  [self.songDurationIndicator setFrame:durRect];
}

#pragma mark - functions

CGRect CGRectExpand(CGRect rect, float top, float right, float bottom, float left) {
  return CGRectMake(rect.origin.x - left, rect.origin.y-top, rect.size.width+right+left, rect.size.height+top+bottom);
}

@end
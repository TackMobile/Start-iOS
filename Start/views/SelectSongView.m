//
//  SelectSongView.m
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectSongView.h"

@implementation SelectSongView
@synthesize delegate;
@synthesize musicManager;
@synthesize songTableView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setClipsToBounds:YES];

        compressedFrame = frame;
        musicManager = [[MusicManager alloc] init];
        librarySongs = [musicManager getLibrarySongs];
        isSearching = NO;
        artworkPresent = NO;
        headerViews = [[NSMutableArray alloc] init];
        selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        
        // views
        CGRect screenBounds = [[UIScreen mainScreen] applicationFrame];
        CGRect songTableRect = CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height);
        
        songTableView = [[UITableView alloc] initWithFrame:songTableRect style:UITableViewStylePlain];
        
        [self addSubview:songTableView];
        
        [songTableView setUserInteractionEnabled:NO];
        [songTableView setDelegate:self];
        [songTableView setDataSource:self];
        [songTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [songTableView setRowHeight:70];
        [songTableView setBackgroundColor:[UIColor clearColor]];
                
        [songTableView reloadData];
        
        // set up the headers
        NSArray *headerIcons = [NSArray arrayWithObjects:[UIImage imageNamed:@"no-sound-icon"],
                                [UIImage imageNamed:@"tone-icon"], [UIImage imageNamed:@"song-icon"], nil];
        for (int i=1; i<4; i++) {
            UIImage *icon = [headerIcons objectAtIndex:i-1];
            NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:0 inSection:i];
            NSIndexPath *lastCellPath = [NSIndexPath indexPathForRow:[songTableView numberOfRowsInSection:i]-1 inSection:i];
            CGRect cellRect = [songTableView rectForRowAtIndexPath:cellIndexPath];
            CGRect lastRect = [songTableView rectForRowAtIndexPath:lastCellPath];
            
            LeftHeaderView *headerView = [[LeftHeaderView alloc] initWithCellRect:cellRect sectionHeight:lastRect.origin.y+lastRect.size.height-cellRect.origin.y];
            
            [headerView.icon setImage:icon];
            [headerViews addObject:headerView];
            [songTableView addSubview:headerView];
        }
        // add the return button
        ReturnButtonView *returnButton = [[ReturnButtonView alloc] initWithCellRect:[songTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] sectionHeight:100000];
        [returnButton.button addTarget:self action:@selector(returnButtonTapped:) forControlEvents:UIControlEventTouchDown];
        [songTableView addSubview:returnButton];
        [headerViews addObject:returnButton];
        
        
        // TESTING
        // scroll away from search
        [songTableView setContentOffset:CGPointMake(0, 65)];
        
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame delegate:(id<SelectSongViewDelegate>)aDelegate presetSongs:(NSArray *)thePresetSongs {
    presetSongs = thePresetSongs;
    delegate = aDelegate;
    return [self initWithFrame:frame];
}
-(void) returnButtonTapped:(id)button {
    [self quickSelectCell];
}

#pragma mark - Positioning
- (void) viewTapped {
    if ([delegate respondsToSelector:@selector(expandSelectSongView)])
        if ([delegate expandSelectSongView]) {
            [songTableView setUserInteractionEnabled:YES];
            
            // show surrounding cells
            [UIView animateWithDuration:.2 animations:^{
                for (UITableViewCell *visibleCell in [songTableView visibleCells])
                    [visibleCell setAlpha:1];
                for (UIView *headerView in headerViews)
                    [headerView setAlpha:1];
            }];
            
        }
}

- (void) songSelected:(NSIndexPath *)indexPath {
    if ([delegate respondsToSelector:@selector(compressSelectSong)])
        [delegate compressSelectSong];
    
    [songTableView setUserInteractionEnabled:NO];
    
    if (indexPath != selectedIndexPath 
        || !artworkPresent) {
        
        selectedIndexPath = indexPath;
        
        NSNumber *songID;
        UIImage *artwork = nil;
        //testing
        NSNumber *themeID = [NSNumber numberWithInt:0];
        
        if (indexPath.section == 1) { // none
            songID = [NSNumber numberWithInt:-1];
        } else if (indexPath.section == 2) { // preset
            songID = [NSNumber numberWithInt:indexPath.row];
            
        } else if (indexPath.section == 3) {
            songID = [(MPMediaItem *)[librarySongs objectAtIndex:indexPath.row] valueForProperty:MPMediaItemPropertyPersistentID];
            themeID = [NSNumber numberWithInt:-1];
            artwork = [musicManager getBackgroundImageForSongID:songID];
        }
        
        if ([delegate respondsToSelector:@selector(songSelected:withArtwork:theme:)]) {
            artworkPresent = YES;
            // testing
            [delegate songSelected:songID withArtwork:artwork theme:themeID];
        }
    }
    
    // hide cells above and below
    SongCell *showCell = (SongCell *)[songTableView cellForRowAtIndexPath:selectedIndexPath];
    [UIView animateWithDuration:.2 animations:^{
        for (UITableViewCell *visibleCell in [songTableView visibleCells])
            [visibleCell setAlpha:(visibleCell == showCell)?1:0];
        for (UIView *headerView in headerViews)
            [headerView setAlpha:0];
    }];
}

- (void) quickSelectCell {
    if (isSearching) {
        [self endSearch];
    }
    [self tableView:songTableView didSelectRowAtIndexPath:selectedIndexPath];
}

- (void) selectCellWithID:(NSNumber *)cellNumID {
    [songTableView reloadData];
    NSIndexPath *indexToSelect;
    if ([cellNumID isEqualToNumber:[NSNumber numberWithInt:0]])
        indexToSelect = [NSIndexPath indexPathForRow:0 inSection:1];// No song
    else {
        selectedIndexPath = [self songIndexPathFromID:cellNumID];
        [self quickSelectCell]; // might have to un-animate
    }
}

#pragma mark - Touches
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch.tapCount >= 1) {
        [self viewTapped];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isSearching) {
        switch (section) {
            case 0:
                return 1;
                break;
            case 1:
                return [searchedSongs count];
                break;
        }
    } else {
        switch (section) {
            case 0:
                return 1;
                break;
            case 1:
                return 1;
            case 2:
                return [presetSongs count];
                break;
            case 3:
                return [librarySongs count];
                break;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    static NSString *NormalSongCell = @"NormalSongCell";
    static NSString *SearchCell = @"SearchCell";
    
    if (indexPath.section == 0) {
        SearchSongCell *cell = (SearchSongCell *)[tableView dequeueReusableCellWithIdentifier:SearchCell];
        if (cell == nil) {
            cell = [[SearchSongCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SearchCell delegate:self];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        return cell;
    }
    
    SongCell *cell = (SongCell *)[tableView dequeueReusableCellWithIdentifier:NormalSongCell];
    if (cell == nil) {
        cell = [[SongCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NormalSongCell];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    NSString *songTitle;
    NSString *songArtist;
    NSNumber *persistentID = [NSNumber numberWithInt:-1];
    MPMediaItem *cellSong;
    
    if (isSearching) {
        switch (indexPath.section) {
            case 1:
                cellSong = [searchedSongs objectAtIndex:indexPath.row];
                songTitle = [cellSong valueForProperty:MPMediaItemPropertyTitle];
                songArtist = [cellSong valueForProperty:MPMediaItemPropertyArtist];
                persistentID = [cellSong valueForProperty:MPMediaItemPropertyPersistentID];
                break;
        }
    } else {
        switch (indexPath.section) {
            case 1:
                songTitle = @"No Sound";
                songArtist = @"Tap to select a sound.";
                break;
            case 2:
                songTitle = [[presetSongs objectAtIndex:indexPath.row] objectForKey:@"title"];
                songArtist = [[presetSongs objectAtIndex:indexPath.row] objectForKey:@"artist"];
                break;
            case 3:
                cellSong = [librarySongs objectAtIndex:indexPath.row];
                songTitle = [cellSong valueForProperty:MPMediaItemPropertyTitle];
                songArtist = [cellSong valueForProperty:MPMediaItemPropertyArtist];
                persistentID = [cellSong valueForProperty:MPMediaItemPropertyPersistentID];
                break;
        }
    }
    
    cell.songLabel.text = songTitle;
    cell.artistLabel.text = songArtist;
    cell.persistentID = persistentID;
    [cell setAlpha:1];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (isSearching)
        return 2;
    return 4;
}

/*- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    //NSIndexPath *lastCell = [NSIndexPath indexPathForRow:[tableView numberOfRowsInSection:section] inSection:section];
    //CGRect lastCellRect = [tableView rectForRowAtIndexPath:lastCell];
    CGRect iconRect = CGRectMake(10, -100, 30, 30);
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
    UIView *sectionIcon = [[UIView alloc] initWithFrame:iconRect];
    [sectionIcon setBackgroundColor:[UIColor colorWithWhite:1 alpha:.5]];
    [contentView addSubview:sectionIcon];
    
    return contentView;
    
}
- (float) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}*/

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.rowHeight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0)
        return;
    
    if (isSearching) {        
        SongCell *selectedCell = (SongCell *)[songTableView cellForRowAtIndexPath:indexPath];

        indexPath = [self songIndexPathFromID:selectedCell.persistentID];
        
        [self endSearch];
    }
    
    CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
    CGRect bottomRect = [tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:[tableView numberOfRowsInSection:[tableView numberOfSections]-1]-1 inSection:[tableView numberOfSections]-1]];
    
    /* center the cell*/
    float centerOffset = (compressedFrame.size.height-cellRect.size.height)/2;
    CGRect contentRect = CGRectMake(0, cellRect.origin.y-centerOffset, tableView.frame.size.width, tableView.frame.size.height);
    
    // extend rect
    float bottom = contentRect.origin.y + contentRect.size.height;
    float maxBottom = bottomRect.origin.y + bottomRect.size.height;
    if (bottom >= maxBottom)
        [tableView setContentSize:CGSizeMake(tableView.frame.size.width, bottom)];
    else
        [tableView setContentSize:CGSizeMake(tableView.contentSize.width, maxBottom)];
    
    [self songSelected:indexPath];
    [tableView scrollRectToVisible:contentRect animated:YES];
}

- (NSIndexPath *)songIndexPathFromID:(NSNumber *)pID {
    int row = 0;
    for (int i=0; i<[librarySongs count]; i++) {
        MPMediaItem *mediaItem = [librarySongs objectAtIndex:i];
        if ([[mediaItem valueForKey:MPMediaItemPropertyPersistentID] isEqualToNumber:pID] ) {
            row = i;
            break;
        }
    }
    return [NSIndexPath indexPathForRow:row inSection:3];
}
#pragma mark - scrollViewDelegate
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    SearchSongCell *searchCell = (SearchSongCell *)[songTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [searchCell.textField resignFirstResponder];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    for (LeftHeaderView *headerView in headerViews)
        [headerView updateWithContentOffset:scrollView.contentOffset.y];
}

#pragma mark - searchSongCell delegate
-(void) textChanged:(UITextField *)textField {
    NSString *searchString = textField.text;
    if ([searchString isEqualToString:@""]) {
        searchedSongs = librarySongs;
    } else {
        NSMutableArray *applicableSongs = [[NSMutableArray alloc] init];
        
        for (MPMediaItem *mediaItem in librarySongs) {
            if ([[mediaItem valueForKey:MPMediaItemPropertyTitle] rangeOfString:searchString].location != NSNotFound ||
                [[mediaItem valueForKey:MPMediaItemPropertyArtist] rangeOfString:searchString].location != NSNotFound) {
                [applicableSongs addObject:mediaItem];
            }
        }
        searchedSongs = applicableSongs;
    }
    
    [songTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}
-(void) textCleared:(UITextField *)textField {
    searchedSongs = librarySongs;
    
    [songTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}
-(void) didBeginSearching {
    searchedSongs = librarySongs;
    if (!isSearching) {
        isSearching = YES;
        
        [songTableView beginUpdates];
        [songTableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSRangeFromString(@"{location=1;length=2}")] withRowAnimation:UITableViewRowAnimationFade];
        [songTableView endUpdates];
    }
    
    // update the headers
    LeftHeaderView *songHeader = [headerViews objectAtIndex:2];
    [songHeader updateCellRect:[songTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]];
    [songHeader updateWithContentOffset:0];
    for (int i=0; i<2; i++)
        [[headerViews objectAtIndex:i] setAlpha:0];
}
-(void) didEndSearchingWithText:(NSString *)text {
    if ([text isEqualToString:@""]) {
        [self endSearch];
    }
}

- (void) endSearch {
    // resign keyboard
    isSearching = NO;
    SearchSongCell *searchCell = (SearchSongCell *)[songTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [searchCell.textField resignFirstResponder];
    [searchCell.textField setText:@""];
    [songTableView reloadData];
    
    // update the headers
    NSLog(@"%i", [songTableView numberOfSections]);
    LeftHeaderView *songHeader = [headerViews objectAtIndex:2];
    [songHeader updateCellRect:[songTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]]];
    [songHeader updateWithContentOffset:0];
    for (int i=0; i<2; i++)
        [[headerViews objectAtIndex:i] setAlpha:1];
}

#pragma mark - funcitons
CGRect CGRectExpand(CGRect rect, float top, float right, float bottom, float left) {
    return CGRectMake(rect.origin.x - left, rect.origin.y-top, rect.size.width+right+left, rect.size.height+top+bottom);
}

@end









































//
//  MusicPlayer.m
//  Start
//
//  Created by Nick Place on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MusicPlayer.h"

@implementation MusicPlayer
@synthesize musicPlayer, userMediaItemCollection;

-(id) init {
    self = [super init];
    if (self) {
        musicPlayer = [[MPMusicPlayerController alloc] init];
        

    }
    return self;
}

- (void) playSongWithID:(NSNumber *)songID {  
    if (!library) {
        // get music library 
        MPMediaQuery *songQuery = [[MPMediaQuery alloc] init];
        library = [songQuery items];
    }
    
    MPMediaItemCollection *playCollection;
    for (MPMediaItem *mediaItem in library) {
        if ([[mediaItem valueForKey:MPMediaItemPropertyPersistentID] intValue] == [songID intValue]) {
            playCollection = [[MPMediaItemCollection alloc] initWithItems:[[NSArray alloc] initWithObjects:mediaItem, nil]];
            break;
        }
    }
    
    NSLog(@"%i", [playCollection count]);
    [self updatePlayerQueueWithMediaCollection:playCollection];
}

- (void) stop {
    [musicPlayer stop];
}


-  (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection {
    
	// Configure the music player, but only if the user chose at least one song to play
	if (mediaItemCollection) {
        // apply the new media item collection as a playback queue for the music player
        [self setUserMediaItemCollection: mediaItemCollection];
        [musicPlayer setQueueWithItemCollection: userMediaItemCollection];
	}
    [musicPlayer play];
}
@end

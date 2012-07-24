//
//  MusicPlayer.h
//  Start
//
//  Created by Nick Place on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MusicPlayer : NSObject {
    NSArray *library;
}

@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;
@property (nonatomic, strong) MPMediaItemCollection *userMediaItemCollection;

- (void) playSongWithID:(NSNumber *)songID;
- (void) stop;

@end

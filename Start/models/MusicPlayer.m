//
//  MusicPlayer.m
//  Start
//
//  Created by Nick Place on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MusicPlayer.h"

@implementation MusicPlayer
@synthesize musicPlayer, audioPlayer, userMediaItemCollection;
@synthesize playPercent;

-(id) init {
    self = [super init];
    if (self) {
        playPercent = 0.0f;
        stopped = YES;
        musicPlayer = [[MPMusicPlayerController alloc] init];
        
        // Begin Audio Session (SILENT)
        audioSession = [AVAudioSession sharedInstance];
        
        NSError *setCategoryError = nil;
        BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&setCategoryError];
        if (!success) { NSLog(@"%@", setCategoryError); }
        
        NSError *activationError = nil;
        success = [audioSession setActive:YES error:&activationError];
        if (!success) { NSLog(@"%@", activationError); }
        
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    }
    return self;
}

- (void) playSongWithID:(NSNumber *)songID vibrate:(bool)vibrate {    
    NSLog(@"song ID: %i", [ songID intValue]);
    stopped = NO;
    
    if ([songID intValue] == -1) {
        NSLog(@"n-1");
    //do nothing, play nothing
    }else if ([songID intValue] >= 0 && [songID intValue] < 6) { //default tones
        if (!audioLibrary) {
            pListModel  = [[PListModel alloc] init];
            audioLibrary = [pListModel getPresetSongs];
        }
        NSString *wavName = [[audioLibrary objectAtIndex:[songID intValue]] objectForKey:@"filename"];
        // play audioloop
        NSLog(@"%@ wavName", wavName);
        NSString *playerPath = [[NSBundle mainBundle] pathForResource:wavName ofType:@"wav"];
        [self playAudioWithPath:playerPath volume:.6];
        
    } else {
        //if ([audioPlayer isPlaying])
        //    [audioPlayer stop];
        
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
        [self updatePlayerQueueWithMediaCollection:playCollection];
    }
    shouldVibrate = vibrate;
    [self beginTick];

}

- (void) playAudioWithPath:(NSString *)path volume:(float)volume { 
    NSError *setURLError = nil;
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&setURLError];
    if (setURLError)
        NSLog(@"%@", setURLError);
    
    [self.audioPlayer setVolume:volume];
    [self.audioPlayer setNumberOfLoops:-1];
    [self.audioPlayer play];
    // enable bg playing
    NSError *catError = nil;

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&catError];
    if (catError)
        NSLog(@"%@", catError);
    
    if (![self.audioPlayer play])
        NSLog(@"could not play");
}

- (void) stop {
    if (musicPlayer && musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
        [musicPlayer stop];
    if (audioPlayer && audioPlayer.isPlaying) {
        [audioPlayer stop];
    }
    stopped = YES;
    shouldVibrate = NO;
    
]
}

-  (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection {
    [musicPlayer stop];
	// Configure the music player, but only if the user chose at least one song to play
	if (mediaItemCollection) {
        // apply the new media item collection as a playback queue for the music player
        [self setUserMediaItemCollection: mediaItemCollection];
        [musicPlayer setQueueWithItemCollection: userMediaItemCollection];
	}
    [musicPlayer play];
    [self beginTick];
}

- (void) addTargetForSampling:(id)aTarget selector:(SEL)aSelector {
    samplingSelector = aSelector;
    samplingTarget = aTarget;
}

- (void) beginTick {
    // start the tick
    playingTimer = [NSTimer scheduledTimerWithTimeInterval:.05 target:self selector:@selector(songPlayingTick:) userInfo:nil repeats:YES];
    vibratingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(vibratingTick:) userInfo:nil repeats:YES];
}

- (void) songPlayingTick:(NSTimer *)timer {
    
    if ([audioPlayer isPlaying])
        playPercent = audioPlayer.currentTime / audioPlayer.duration;
    else if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
        playPercent = musicPlayer.currentPlaybackTime / [(NSNumber *)[musicPlayer.nowPlayingItem valueForKey:MPMediaItemPropertyPlaybackDuration] doubleValue];
    
    if (stopped) {
        [timer invalidate];
        playPercent = 0.0f;
    }
    
    if (playPercent >= 0.0f)
        if ([samplingTarget respondsToSelector:samplingSelector])
            [samplingTarget performSelector:samplingSelector withObject:self];
}

- (void) vibratingTick:(NSTimer *)timer {
    if (stopped)
        [timer invalidate];
    if (shouldVibrate)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    else {
        return;
    }
}

@end

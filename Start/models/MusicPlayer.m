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
        BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
        if (!success) { NSLog(@"%@", setCategoryError); }
        
        NSError *activationError = nil;
        success = [audioSession setActive:YES error:&activationError];
        if (!success) { NSLog(@"%@", activationError); }
        
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    }
    return self;
}

- (void) playSongWithID:(NSNumber *)songID vibrate:(bool)vibrate {    
    stopped = NO;
    if ([songID intValue] >= 0 && [songID intValue] < 6) {
        if (!audioLibrary) {
            pListModel  = [[PListModel alloc] init];
            audioLibrary = [pListModel getPresetSongs];
        }
        NSString *wavName = [[audioLibrary objectAtIndex:[songID intValue]] objectForKey:@"filename"];
        // play audioloop
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
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&setURLError];
    if (setURLError)
        NSLog(@"%@", setURLError);
    
    [audioPlayer setVolume:volume];
    [audioPlayer setNumberOfLoops:-1];
    
    if (![audioPlayer play])
        NSLog(@"could not play");
}

- (void) stop {
    [musicPlayer stop];
    stopped = YES;
    shouldVibrate = NO;
    if (audioPlayer && audioPlayer.isPlaying) {
        [audioPlayer stop];
    }
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

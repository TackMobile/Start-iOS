//
//  MusicPlayer.m
//  Start
//
//  Created by Nick Place on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MusicPlayer.h"

@interface MusicPlayer()

@property (nonatomic, strong) NSArray *library;
@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) MPMediaItemCollection *userMediaItemCollection;

@end

@implementation MusicPlayer

- (id)init {
  self = [super init];
  if (self) {
    _playPercent = 0.0f;
    stopped = YES;
    _musicPlayer = [[MPMusicPlayerController alloc] init];
    
    // Begin Audio Session (SILENT)
    audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&setCategoryError];
    
    NSError *activationError = nil;
    success = [audioSession setActive:YES error:&activationError];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
  }
  return self;
}

- (void)playSongWithID:(NSNumber *)songID vibrate:(bool)vibrate {
  stopped = NO;
  
  if (songID.intValue >= 0 && songID.intValue < 6) { //default tones
    
    if (!audioLibrary) {
      pListModel  = [[PListModel alloc] init];
      audioLibrary = [pListModel getPresetSongs];
    }
    NSString *wavName = [audioLibrary[songID.intValue] objectForKey:@"filename"];
    // play audioloop
    NSString *playerPath = [[NSBundle mainBundle] pathForResource:wavName ofType:@"wav"];
    [self playAudioWithPath:playerPath volume:.6];
    
  } else {
    if (!self.library) {
      // get music library
      MPMediaQuery *songQuery = [[MPMediaQuery alloc] init];
      self.library = [songQuery items];
    }
    
    MPMediaItemCollection *playCollection;
    for (MPMediaItem *mediaItem in self.library) {
      if ([[mediaItem valueForKey:MPMediaItemPropertyPersistentID] intValue] == songID.intValue) {
        playCollection = [[MPMediaItemCollection alloc] initWithItems:[[NSArray alloc] initWithObjects:mediaItem, nil]];
        break;
      }
    }
    [self updatePlayerQueueWithMediaCollection:playCollection];
  }
  shouldVibrate = vibrate;
  [self beginTick];
}

- (void)playAudioWithPath:(NSString *)path volume:(float)volume {
  NSError *setURLError = nil;
  
  self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&setURLError];
  
  [self.audioPlayer setVolume:volume];
  [self.audioPlayer setNumberOfLoops:-1];
  [self.audioPlayer play];
  // Enable bg playing
  NSError *catError = nil;
  
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&catError];
}

- (void)stop {
  if (self.musicPlayer && self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
  [self.musicPlayer stop];
  if (self.audioPlayer && self.audioPlayer.isPlaying) {
    [self.audioPlayer stop];
  }
  stopped = YES;
  shouldVibrate = NO;
}

- (void)updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection {
  [self.musicPlayer stop];
  // Configure the music player, but only if the user chose at least one song to play
  if (mediaItemCollection) {
    // Apply the new media item collection as a playback queue for the music player
    [self setUserMediaItemCollection: mediaItemCollection];
    [self.musicPlayer setQueueWithItemCollection: self.userMediaItemCollection];
  }
  [self.musicPlayer play];
  [self beginTick];
}

- (void)addTargetForSampling:(id)aTarget selector:(SEL)aSelector {
  samplingSelector = aSelector;
  samplingTarget = aTarget;
}

- (void)beginTick {
  // Start the tick
  playingTimer = [NSTimer scheduledTimerWithTimeInterval:.05 target:self selector:@selector(songPlayingTick:) userInfo:nil repeats:YES];
  vibratingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(vibratingTick:) userInfo:nil repeats:YES];
}

- (void)songPlayingTick:(NSTimer *)timer {
  
  if ([self.audioPlayer isPlaying])
  self.playPercent = self.audioPlayer.currentTime / self.audioPlayer.duration;
  else if (self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
  self.playPercent = self.musicPlayer.currentPlaybackTime / [(NSNumber *)[self.musicPlayer.nowPlayingItem valueForKey:MPMediaItemPropertyPlaybackDuration] doubleValue];
  
  if (stopped) {
    [timer invalidate];
    self.playPercent = 0.0f;
  }
  
  if (self.playPercent >= 0.0f)
  if ([samplingTarget respondsToSelector:samplingSelector]) {
    [samplingTarget performSelector:samplingSelector withObject:self];
  }
}

- (void)vibratingTick:(NSTimer *)timer {
  if (stopped)
  [timer invalidate];
  if (shouldVibrate)
  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
  else {
    return;
  }
}

@end

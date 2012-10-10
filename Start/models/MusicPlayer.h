//
//  MusicPlayer.h
//  Start
//
//  Created by Nick Place on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVAudioSession.h>
#import "PListModel.h"

@interface MusicPlayer : NSObject <AVAudioPlayerDelegate> {
    NSArray *library;
    
    id samplingTarget;
    SEL samplingSelector;
    
    bool shouldVibrate;
    bool stopped;
    
    PListModel *pListModel;
    NSArray *audioLibrary;
    AVAudioSession *audioSession;
    
    NSTimer *playingTimer;
    NSTimer *vibratingTimer;
}

@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) MPMediaItemCollection *userMediaItemCollection;

- (void) playSongWithID:(NSNumber *)songID vibrate:(bool)vibrate ;
- (void) stop;

@property double playPercent;
- (void) addTargetForSampling:(id)aTarget selector:(SEL)aSelector;

@end

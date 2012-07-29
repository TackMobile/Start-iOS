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
    
    id samplingTarget;
    SEL samplingSelector;
}

@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;
@property (nonatomic, strong) MPMediaItemCollection *userMediaItemCollection;

- (void) playSongWithID:(NSNumber *)songID;
- (void) stop;

@property double playPercent;
- (void) addTargetForSampling:(id)aTarget selector:(SEL)aSelector;

@end

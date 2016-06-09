//
//  MusicLibrary.h
//  Start
//
//  Created by Nick Place on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PListModel.h"

@class PListModel;

@interface MusicManager : NSObject {
  NSArray *librarySongs;
  PListModel *pListModel;
}

- (NSArray *)getLibrarySongs;

- (NSDictionary *)getThemeForSongID:(NSNumber *)songID;
- (NSDictionary *)getThemeWithID:(int)themeID;

- (UIImage *)getBackgroundImageForSongID:(NSNumber *)songID;

@end

@interface UIColor (ColorWithHex)

+ (UIColor*)colorWithHexValue:(uint)hexValue andAlpha:(float)alpha;
+ (UIColor*)colorWithHexString:(NSString *)hexString andAlpha:(float)alpha;

@end
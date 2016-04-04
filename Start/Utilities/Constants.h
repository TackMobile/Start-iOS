//
//  Constants.h
//  Start
//
//  Created by Naomi Himley on 4/4/16.
//
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT const struct CellIdentifierString {
    __unsafe_unretained NSString *normalSongCell;
    __unsafe_unretained NSString *searchCell;
} CellIdentifierString;

FOUNDATION_EXPORT const struct PresetSongsKey {
    __unsafe_unretained NSString *title;
    __unsafe_unretained NSString *artist;
} PresetSongsKey;

FOUNDATION_EXPORT const struct StartFontName {
    __unsafe_unretained NSString *roboto;
    __unsafe_unretained NSString *robotoThin;
    __unsafe_unretained NSString *robotoLight;
} StartFontName;

FOUNDATION_EXPORT const struct StartUserDefaultKey {
    __unsafe_unretained NSString *snoozeTime;
    __unsafe_unretained NSString *seenIntro;
    __unsafe_unretained NSString *currentAlarmIndex;
    __unsafe_unretained NSString *alarms;
} StartUserDefaultKey;

@interface Constants : NSObject

@end

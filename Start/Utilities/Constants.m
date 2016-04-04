//
//  Constants.m
//  Start
//
//  Created by Naomi Himley on 4/4/16.
//
//

#import "Constants.h"

@implementation Constants

const struct CellIdentifierString CellIdentifierString = {
    .normalSongCell = @"NormalSongCell",
    .searchCell = @"SearchCell",
};

const struct PresetSongsKey PresetSongsKey = {
    .title = @"title",
    .artist = @"artist",
};

const struct StartFontName StartFontName = {
    .roboto = @"Roboto",
    .robotoThin = @"Roboto-Thin",
    .robotoLight = @"Roboto-Light",
};

const struct StartUserDefaultKey StartUserDefaultKey = {
    .snoozeTime = @"snoozeTime",
    .seenIntro = @"seenIntro",
    .currentAlarmIndex = @"currAlarmIndex",
    .alarms = @"alarms",
};

@end

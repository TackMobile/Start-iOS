//
//  PListModel.h
//  Start
//
//  Created by Nick Place on 7/5/12.
//  Copyright (c) 2012 TackMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicManager.h"

enum PListFileNames {
    PListAlarmsFile = 0,
    PListPresetSongsFile,
    PListThemesFile,
    PListActionsFile
};

@interface PListModel : NSObject {
    NSArray *alarms;
    NSArray *presetSongs;
    NSArray *themes;
    NSArray *actions;
}

-(NSArray *)getAlarms;
-(NSArray *)saveAlarms:(NSArray *)alarmData;

-(NSArray *)getPresetSongs;

-(NSArray *)getThemes;

-(NSArray *)getActions;

-(NSArray *)getPList:(int)pList;
-(NSArray *)saveData:(NSArray *)data toPList:(int)pList;

-(id)init;

@end

//
//  PListModel.m
//  Start
//
//  Created by Nick Place on 7/5/12.
//  Copyright (c) 2012 TackMobile. All rights reserved.
//

#import "PListModel.h"

@implementation PListModel

- (id) init {
    self = [super init];
    if (self) {
        alarms = [self getAlarms];
        presetSongs = [self getPresetSongs];
        themes = [self getThemes];
        actions = [self getActions];
    }
    return self;
}

-(NSArray *)getAlarms {
    alarms = [[NSUserDefaults standardUserDefaults] objectForKey:@"alarms"];
    return alarms;
}
-(NSArray *)saveAlarms:(NSArray *)alarmData {
    [[NSUserDefaults standardUserDefaults] setObject:alarmData forKey:@"alarms"];
    return [self getAlarms];
}

-(NSArray *)getPresetSongs {
    if (!presetSongs)
        presetSongs = [self getPList:PListPresetSongsFile];
    return presetSongs;
}

-(NSArray *)getThemes {
    if (!themes)
        themes = [self getPList:PListThemesFile];
    return themes;
}

-(NSArray *)getActions {
    if (!actions)
        actions = [self getPList:PListActionsFile];
    return actions;
}

-(NSArray *)getPList:(int)pList {
    NSString *filePath = [self filePathForPList:pList];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSArray* plistArray = [[NSArray alloc] initWithContentsOfFile:filePath];
        return plistArray;
    } else {
        NSLog(@"PLIST NOT FOUND");
    }
    return nil;
}
-(NSArray *)saveData:(NSArray *)data toPList:(int)pList {
    NSLog(@"data: %@", data);
    
    NSString *filePath = [self filePathForPList:pList];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        BOOL result = [data writeToFile:filePath atomically:NO];
        if (!result)
            NSLog(@"ERROR SAVING DATA");
    }
    return [self getPList:pList];
}

-(NSString *)filePathForPList:(int)pList {
    NSString *fileName;

    switch (pList) {
        case PListActionsFile:
            fileName = @"actions";
            break;
        case PListAlarmsFile:
            fileName = @"alarms";
            break;
        case PListPresetSongsFile:
            fileName = @"presetSongs";
            break;
        case PListThemesFile:
            fileName = @"themes";
            break;
    }
    return [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
}

@end


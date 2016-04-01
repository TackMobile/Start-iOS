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
    
    NSMutableArray *newActions = [[NSMutableArray alloc] init];
    UIApplication *app = [UIApplication sharedApplication];
    for (int i=0; i<[actions count]; i++) {
        NSMutableDictionary *action = [[actions objectAtIndex:i] mutableCopy];
        [action setValue:[NSNumber numberWithBool:NO] forKey:@"canOpen"];
        NSURL *url = [NSURL URLWithString:[action objectForKey:@"url"]];
        
        if (i==0 || [app canOpenURL:url])
            [newActions addObject:action];
        
        //[newActions addObject:action];
    }
    actions = newActions;
    
    return actions;
}

-(NSArray *)getPList:(int)pList {
    NSString *filePath = [self filePathForPList:pList];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSArray* plistArray = [[NSArray alloc] initWithContentsOfFile:filePath];
        return plistArray;
    }
    return nil;
}
-(NSArray *)saveData:(NSArray *)data toPList:(int)pList {
    NSString *filePath = [self filePathForPList:pList];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [data writeToFile:filePath atomically:NO];
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


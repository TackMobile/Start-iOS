//
//  LocalizedStrings.m
//  Start
//
//  Created by Naomi Himley on 4/1/16.
//
//

#import "LocalizedStrings.h"

@implementation LocalizedStrings

+ (NSString *)timerFinished
{
    return NSLocalizedString(@"Timer Finished", @"Body Description for Timer Finished Alert");
}
+ (NSString *)alarmTriggered
{
    return NSLocalizedString(@"Alarm Triggered", @"Body Description of alarm triggered alert");
}

+ (NSString *)timerPaused
{
    return NSLocalizedString(@"Paused.\nTap again to reset", @"Text for Pause label on timer");
}

+ (NSString *)pinchToDelete
{
    return NSLocalizedString(@"Pinch to Delete", @"Text for Pinch to Delete instruction label");
}

@end

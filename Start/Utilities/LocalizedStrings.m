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

+ (NSString *)search
{
  return NSLocalizedString(@"Search", @"Title for search section, and placeholder text for Search textfield");
}

+ (NSString *)noSound
{
  return NSLocalizedString(@"No Sound", @"Title for No Sound cell for no alarm sound option");
}

+ (NSString *)tapToSelectOrPreview
{
  return NSLocalizedString(@"Tap to select. Hold to preview.", @"Instruction text for tap to select or hold to preview song titles");
}

+ (NSString *)tapToSnooze
{
  return NSLocalizedString(@"TAP TO SNOOZE", @"Title for Snooze label on alarm");
}

+ (NSString *)alarm
{
  return NSLocalizedString(@"ALARM", @"Title for Alarm option");
}

+ (NSString *)timer
{
  return NSLocalizedString(@"TIMER", @"Title for Timer option");
}

+ (NSString *)createANewSpace
{
  return NSLocalizedString(@"Create a new space", @"Title for Settings row create a new space");
}

+ (NSString *)tapToSwitch
{
  return NSLocalizedString(@"Tap to switch alarm or timer", @"Title for Settings row tap to switch alarm or timer");
}

+ (NSString *)setTimeSoundAction
{
  return NSLocalizedString(@"Set time, sound and action", @"Title for Settings row set time sound and action");
}

+ (NSString *)flickUpToActivate
{
  return NSLocalizedString(@"Flick up to activate", @"Title for Settings row flick up to activate");
}

+ (NSString *)flickDownStopwatch
{
  return NSLocalizedString(@"Flick down for stopwatch", @"Title for Settings row flick down for stopwatch");
}

+ (NSString *)keepOpenForMusic
{
  return NSLocalizedString(@"Keep open for music alarms", @"Title for Settings row keep open for music alarms");
}

+ (NSString *)assembledBy
{
  return NSLocalizedString(@"Assembled by", @"Assembled by text for Tack Mobile credit label");
}

@end

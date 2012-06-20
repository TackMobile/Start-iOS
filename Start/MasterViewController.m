//
//  ViewController.m
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController ()
@end

@implementation MasterViewController
@synthesize selectAlarmView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	alarms = [[NSMutableArray alloc] init];
    
    CGRect frameRect = [[UIScreen mainScreen] applicationFrame];
    CGRect selectAlarmRect = CGRectMake(0, frameRect.size.height-50, frameRect.size.width, 50);

    currAlarmRect = CGRectMake(0, 0, frameRect.size.width, frameRect.size.height);
    newAlarmRect = CGRectOffset(currAlarmRect, -frameRect.size.width, 0);
    nextAlarmRect = CGRectOffset(currAlarmRect, frameRect.size.width, 0);

    selectAlarmView = [[SelectAlarmView alloc] initWithFrame:selectAlarmRect delegate:self];
    
    [self.view addSubview:selectAlarmView];
    
    // TESTING    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - SelectAlarmViewDelegate
- (void) alarmAdded {
    AlarmView *newAlarm = [[AlarmView alloc] initWithFrame:newAlarmRect];
    [alarms insertObject:newAlarm atIndex:0];
    [self.view insertSubview:newAlarm atIndex:0];
    
    [UIView animateWithDuration:.2 animations:^{
        for (int i=1; i<[alarms count]; i++)
            [[alarms objectAtIndex:i] setFrame:newAlarmRect];
        [[alarms objectAtIndex:0] setFrame:currAlarmRect];
    }];
}

@end

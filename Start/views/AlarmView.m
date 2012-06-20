//
//  AlarmView.m
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AlarmView.h"

@implementation AlarmView

@synthesize backgroundImage, toolbarImage;
@synthesize selectSongView, selectActionView, selectDurationView, selectedTimeView;
@synthesize countdownTimer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect bgImageRect = self.frame;
        CGRect toolBarRect = CGRectMake(0, 0, self.frame.size.width, 70);
        CGRect selectSongRect = CGRectMake(0, 0, self.frame.size.width-100, toolBarRect.size.height);
        CGRect selectActionRect = CGRectMake(self.frame.size.width-100, 0, 100, toolBarRect.size.height);
        CGRect selectDurRect = CGRectMake(0, self.frame.size.height-self.frame.size.width-50, self.frame.size.width, self.frame.size.width);
        selectedTimeRect = CGRectExtendFromPoint(CGRectCenter(selectDurRect), 65, 65);
        
        backgroundImage = [[UIImageView alloc] initWithFrame:bgImageRect];
        toolbarImage = [[UIImageView alloc] initWithFrame:toolBarRect];
        selectSongView = [[SelectSongView alloc] initWithFrame:selectSongRect];
        selectActionView = [[SelectActionView alloc] initWithFrame:selectActionRect];
        selectDurationView = [[SelectDurationView alloc] initWithFrame:selectDurRect delegate:self];
        selectedTimeView = [[SelectedTimeView alloc] initWithFrame:selectedTimeRect];
        
        [selectedTimeView updateTimeInterval:[selectDurationView getTimeInterval] part:SelectDurationNoHandle];
        
        [self addSubview:backgroundImage];
        [self addSubview:toolbarImage];
        [self addSubview:selectSongView];
        [self addSubview:selectActionView];
        [self addSubview:selectDurationView];
        [self addSubview:selectedTimeView];
        
        //TESTING
        [backgroundImage setBackgroundColor:[UIColor greenColor]];
        [toolbarImage setBackgroundColor:[UIColor blackColor]];
            [toolbarImage setAlpha:.5];
    }
    return self;
}

#pragma mark - CountdownTimerDelegate
- (void) countdown:(id)countdown tickWithDate:(NSDate *)date {
    
}
- (void) countdownEnded:(id)countdown {
    
}

#pragma mark - SelectDurationViewDelegate
-(void) durationDidChange:(SelectDurationView *)selectDuration {  
    [selectedTimeView updateTimeInterval:[selectDuration getTimeInterval] part:selectDuration.handleSelected];
}

-(void) durationDidBeginChanging:(SelectDurationView *)selectDuration {
    [UIView animateWithDuration:.2 animations:^{
        CGRect newSelectedTimeRect = CGRectMake(selectedTimeView.frame.origin.x, 0, selectedTimeView.frame.size.width, selectedTimeView.frame.size.height);
        [selectedTimeView setFrame:newSelectedTimeRect];
    }];
}

-(void) durationDidEndChanging:(SelectDurationView *)selectDuration {
    [selectedTimeView updateTimeInterval:[selectDuration getTimeInterval] part:selectDuration.handleSelected];
    
    [UIView animateWithDuration:.2 animations:^{
        [selectedTimeView setFrame:selectedTimeRect];
    }];
}

#pragma mark - Utilities

CGRect CGRectExtendFromPoint(CGPoint p1, float dx, float dy) {
    return CGRectMake(p1.x-dx, p1.y-dy, dx*2, dy*2);
}

CGPoint CGRectCenter(CGRect rect) {
    return CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
}
@end
